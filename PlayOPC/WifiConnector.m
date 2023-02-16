//
//  WifiConnector.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "WifiConnector.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Network/Network.h>

NSString *const WifiConnectionChangedNotification = @"WifiConnectionChangedNotification";
NSString *const WifiConnectorErrorDomain = @"WifiConnectorErrorDomain";

@interface WifiConnector ()

@property (assign, nonatomic) BOOL monitoring; ///< 接続経路の監視中か否かを示します。
@property (assign, nonatomic) BOOL running; ///< 実行中か否か
@property (strong, nonatomic) dispatch_queue_t pathMonitorQueue; ///< 接続経路を確認するキュー
@property (strong, nonatomic) nw_path_monitor_t pathMonitor; ///< 接続経路を監視するモニター
@property (strong, nonatomic) nw_path_t path; ///< 接続経路
@property (assign, nonatomic) nw_path_status_t pathStatus; ///< 接続経路の状態
@property (strong, nonatomic) NEHotspotNetwork *network; ///< ネットワーク情報
#if (TARGET_OS_SIMULATOR)
@property (assign, nonatomic) BOOL connecting; ///< 接続中か否か
#endif

@end

#pragma mark -

@implementation WifiConnector

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");
	
	self = [super init];
	if (!self) {
		return nil;
	}
	
	_SSID = nil;
	_passphrase = nil;
	_timeout = 30.0;
	_pathMonitorQueue = nil;
	_pathMonitor = nil;
	_path = nil;
	_pathStatus = nw_path_status_invalid;
	_network = nil;
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_SSID = nil;
	_passphrase = nil;
	_pathMonitorQueue = nil;
	_pathMonitor = nil;
	_path = nil;
	_network = nil;
}

#pragma mark -

- (WifiConnectionStatus)connectionStatus {
	DEBUG_DETAIL_LOG(@"");
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではWiFi制御は利用できません。
	if (self.connecting) {
		return WifiConnectionStatusConnected;
	} else {
		return WifiConnectionStatusNotConnected;
	}
#else
	switch (self.pathStatus) {
		case nw_path_status_satisfied:
			if (self.network && [self.network.SSID isEqualToString:self.SSID]) {
				return WifiConnectionStatusConnected;
			} else {
				return WifiConnectionStatusConnectedOther;
			}
		case nw_path_status_satisfiable:
		case nw_path_status_unsatisfied:
			return WifiConnectionStatusNotConnected;
		case nw_path_status_invalid:
		default:
			break;
	}
	return WifiConnectionStatusUnknown;
#endif
}

- (void)startMonitoring {
	DEBUG_LOG(@"");

	if (self.monitoring) {
		// 監視はすでに実行中です。
		return;
	}
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではWiFi制御は利用できません。
	// 監視開始をフェイクします。
	self.monitoring = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
	});
#else
	NSString *dispatchQueueName = [NSString stringWithFormat:@"%@.WifiConnector.queue", [[NSBundle mainBundle] bundleIdentifier]];
	self.pathMonitorQueue = dispatch_queue_create([dispatchQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
	self.pathMonitor = nw_path_monitor_create_with_type(nw_interface_type_wifi);
	nw_path_monitor_set_queue(self.pathMonitor, self.pathMonitorQueue);
	self.path = nil;
	self.pathStatus = nw_path_status_invalid;
	self.network = nil;
	
	__weak WifiConnector *weakSelf = self;
	nw_path_monitor_set_cancel_handler(self.pathMonitor, ^{
		weakSelf.monitoring = NO;
		weakSelf.pathMonitorQueue = nil;
		weakSelf.pathMonitor = nil;
		weakSelf.path = nil;
		weakSelf.pathStatus = nw_path_status_invalid;
		weakSelf.network = nil;
	});
	nw_path_monitor_set_update_handler(self.pathMonitor, ^(nw_path_t path) {
		[weakSelf updatePath:path];
	});
	nw_path_monitor_start(self.pathMonitor);
	self.monitoring = YES;
#endif
}

- (void)stopMonitoring {
	DEBUG_LOG(@"");
	
	if (!self.monitoring) {
		// 監視は未実行です。
		return;
	}
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではWiFi制御は利用できません。
	// 監視停止をフェイクします。
	self.monitoring = NO;
#else
	// 監視が停止するまで待ちます。
	nw_path_monitor_cancel(self.pathMonitor);
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < self.timeout) {
		if (!self.monitoring) {
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
#endif
}

- (BOOL)connectHotspot:(NSError**)error {
	DEBUG_LOG(@"SSID=%@, passphrase=%@", self.SSID, self.passphrase);
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではWiFi制御は利用できません。
	// 接続完了をフェイクします。
	self.connecting = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
	});
	return YES;
#else
	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:WifiConnectorErrorBusy description:NSLocalizedString(@"$desc:ConnectHotspotIsRunnning", @"WifiConnector.connectHotspot")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	
	// アクセスポイントに接続します。
	self.running = YES;
	__block BOOL applyResult = NO;
	__block NSError *applyError = nil;
	NSString* ssid = self.SSID;
	NEHotspotConfigurationManager *manager = NEHotspotConfigurationManager.sharedManager;
	NEHotspotConfiguration *config = [[NEHotspotConfiguration alloc] initWithSSIDPrefix:ssid passphrase:self.passphrase isWEP:NO];
	config.joinOnce = NO; // YESにするとiOS15ではエラーになってしまう...
	config.lifeTimeInDays = [[NSNumber alloc] initWithInt:1];
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[manager applyConfiguration:config completionHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%@", error);
		if (error == nil ||
			(NEHotspotConfigurationError)error.code == NEHotspotConfigurationErrorAlreadyAssociated) {
			applyResult = YES;
			applyError = nil;
		} else if ((NEHotspotConfigurationError)error.code == NEHotspotConfigurationErrorUserDenied) {
			applyResult = NO;
			applyError = nil;
		} else {
			applyResult = NO;
			applyError = error;
		}
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	// アクセスポイントに接続できませんでした。
	if (!applyResult) {
		if (error) {
			*error = applyError;
		}
		self.running = NO;
		return NO;
	}
	
	// 接続経路の変化をポーリングします。
	BOOL connected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < self.timeout) {
		if (self.connectionStatus == WifiConnectionStatusConnected) {
			connected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	if (!connected && error) {
		NSError *internalError = [self createError:WifiConnectorErrorTimeout description:NSLocalizedString(@"$desc:ConnectingHotspotTimedOut", @"WifiConnector.disconnectHotspot")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
	}
	
	self.running = NO;
	return connected;
#endif
}

- (BOOL)disconnectHotspot:(NSError **)error {
	DEBUG_LOG(@"SSID=%@", self.SSID);
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではWiFi制御は利用できません。
	// 切断完了をフェイクします。
	self.connecting = NO;
	dispatch_async(dispatch_get_main_queue(), ^{
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
	});
	return YES;
#else
	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:WifiConnectorErrorBusy description:NSLocalizedString(@"$desc:ConnectHotspotIsRunnning", @"WifiConnector.disconnectHotspot")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	
	// アクセスポイントの接続を解除します。
	self.running = YES;
	NEHotspotConfigurationManager *manager = NEHotspotConfigurationManager.sharedManager;
	[manager removeConfigurationForSSID:self.SSID];
	
	// 接続経路の変化をポーリングします。
	BOOL disconnected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < self.timeout) {
		if (self.connectionStatus != WifiConnectionStatusConnected) {
			disconnected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	if (!disconnected && error) {
		NSError *internalError = [self createError:WifiConnectorErrorTimeout description:NSLocalizedString(@"$desc:ConnectingHotspotTimedOut", @"WifiConnector.disconnectHotspot")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
	}

	self.running = NO;
	return disconnected;
#endif
}

#pragma mark -

/// 接続状態を更新します。
/// カメラのアクセスポイントに接続している場合はカメラと通信できるか否かも確かめます。
- (void)updatePath:(nw_path_t)path {
	DEBUG_DETAIL_LOG(@"");

	// 接続経路を取得します。
	nw_path_t currentPath = path;
	nw_path_status_t currentStatus = nw_path_get_status(path);
	DEBUG_LOG(@"currentStatus=%ld", (long)currentStatus);
	
	// ネットワーク情報を取得します。
	__block NEHotspotNetwork *currentNetwork = nil;
	if (currentStatus == nw_path_status_satisfied) {
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		[NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork *current) {
			currentNetwork = current;
			dispatch_semaphore_signal(semaphore);
		}];
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	}
	
	// 取得した情報を保持します。
	BOOL changed = NO;
	if (self.pathStatus != currentStatus) {
		changed = YES;
	}
	if ((!self.network && currentNetwork) ||
		(self.network && !currentNetwork)) {
		changed = YES;
	}
	if ((self.network && currentNetwork) &&
		![self.network.SSID isEqualToString:currentNetwork.SSID]) {
		changed = YES;
	}
	self.path = currentPath;
	self.pathStatus = currentStatus;
	self.network = currentNetwork;
	
	// 状態に変化があれば通知します。
	if (changed) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
		});
	}
}

/// エラー情報を作成します。
- (NSError *)createError:(NSInteger)code description:(NSString *)description {
	DEBUG_LOG(@"code=%ld, description=%@", (long)code, description);
	
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: description
	};
	NSError *error = [[NSError alloc] initWithDomain:WifiConnectorErrorDomain code:code userInfo:userInfo];
	return error;
}

@end
