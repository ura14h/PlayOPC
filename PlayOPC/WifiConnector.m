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
#import "Reachability.h"
#import "AppDelegate.h"
#import "AppCamera.h"

NSString *const WifiStatusChangedNotification = @"WifiStatusChangedNotification";

@interface WifiConnector ()

@property (assign, nonatomic) BOOL monitoring; ///< 接続状態の監視中か否かを示します。
@property (strong, nonatomic) dispatch_queue_t reachabilityQueue; ///< 到達確認性を実行するキュー
@property (strong, nonatomic) Reachability *reachability;
@property (assign, nonatomic) NetworkStatus networkStatus; ///< 最新のネットワーク状態
@property (assign, nonatomic) BOOL cameraResponded; ///< カメラの応答があったか否か

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
	_reachabilityQueue = nil;
	_reachability = nil;
	_networkStatus = NotReachable;
	_cameraResponded = NO;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:kReachabilityChangedNotification object:nil];
	
	_reachabilityQueue = nil;
	_reachability = nil;
	_SSID = nil;
	_passphrase = nil;
}

#pragma mark -

- (WifiConnectionStatus)connectionStatus {
	DEBUG_DETAIL_LOG(@"");
	
	switch (self.networkStatus) {
		case ReachableViaWiFi:
			return WifiConnectionStatusConnected;
		case NotReachable:
			return WifiConnectionStatusNotConnected;
		default:
			break;
	}
	return WifiConnectionStatusUnknown;
}

- (WifiCameraStatus)cameraStatus {
	DEBUG_DETAIL_LOG(@"");
	
	switch (self.networkStatus) {
		case ReachableViaWiFi:
			break;
		default:
			return WifiCameraStatusUnreachable;
	}
	if (!self.cameraResponded) {
		return WifiCameraStatusUnreachable;
	}
	return WifiCameraStatusReachable;
}

- (void)startMonitoring {
	DEBUG_LOG(@"");
	
	if (self.monitoring) {
		// 監視はすでに実行中です。
		NSLog(NSLocalizedString(@"$desc:MonitoringIsRunnning", @"WifiConnector.startMonitoring"));
		return;
	}

	if (!self.reachability) {
		AppCamera *camera = GetAppCamera();
		self.reachabilityQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.reachabilityQueue", DISPATCH_QUEUE_SERIAL);
		self.reachability = [Reachability reachabilityWithHostName:camera.host];
	}

	self.networkStatus = NotReachable;
	self.cameraResponded = NO;

	__weak WifiConnector *weakSelf = self;
	dispatch_async(weakSelf.reachabilityQueue, ^{
		[weakSelf updateStatusWithToKnockOnCamera:YES];
		// 監視を開始します。
		// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
		dispatch_async(dispatch_get_main_queue(), ^{
			if (![weakSelf.reachability startNotifier]) {
				// Reachabilityの通知開始に失敗しました。
				NSLog(NSLocalizedString(@"$desc:CouldNotStartMonitoring", @"WifiConnector.startMonitoring"));
				return;
			}
		});
	});
	self.monitoring = YES;
}

- (void)stopMonitoring {
	DEBUG_LOG(@"");

	if (!self.monitoring) {
		// 監視は未実行です。
		NSLog(NSLocalizedString(@"$desc:MonitoringIsNotRunnning", @"WifiConnector.stopMonitoring"));
		return;
	}
	
	__weak WifiConnector *weakSelf = self;
	dispatch_async(weakSelf.reachabilityQueue, ^{
		// 監視を停止します。
		// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.reachability stopNotifier];
		});
	});
	self.monitoring = NO;
}

- (void)pokeMonitoring {
	DEBUG_LOG(@"");
	
	if (!self.monitoring) {
		return;
	}
	
	__weak WifiConnector *weakSelf = self;
	dispatch_async(weakSelf.reachabilityQueue, ^{
		[weakSelf updateStatusWithToKnockOnCamera:YES];
	});
}

- (BOOL)connect:(NSError**)error {
	DEBUG_LOG(@"SSID=%@, passphrase=%@", self.SSID, self.passphrase);
	
	BOOL monitoring = self.monitoring;
	self.monitoring = NO;
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

	self.monitoring = monitoring;
	if (error != nil) {
		*error = applyError;
	}
	return applyResult;
}

- (void)disconnect {
	DEBUG_LOG(@"SSID=%@", self.SSID);
	
	NEHotspotConfigurationManager *manager = NEHotspotConfigurationManager.sharedManager;
	[manager removeConfigurationForSSID:self.SSID];
}

- (BOOL)waitForConnected:(NSTimeInterval)timeout {
	DEBUG_LOG(@"timeout=%ld", (long)timeout);

	// 監視を一時的に停止します。
	if (self.monitoring) {
		__weak WifiConnector *weakSelf = self;
		dispatch_sync(weakSelf.reachabilityQueue, ^{
			// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.reachability stopNotifier];
			});
		});
	}

	// 接続状態の変化をポーリングします。
	BOOL connected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		[self updateStatusWithToKnockOnCamera:YES];
		if (self.networkStatus == ReachableViaWiFi && self.cameraResponded) {
			connected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	
	// 監視を再開します。
	if (self.monitoring) {
		__weak WifiConnector *weakSelf = self;
		dispatch_sync(weakSelf.reachabilityQueue, ^{
			// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.reachability startNotifier];
			});
		});
	}
	
	return connected;
}

- (BOOL)waitForDisconnected:(NSTimeInterval)timeout {
	DEBUG_LOG(@"timeout=%ld", (long)timeout);
	
	// 監視を一時的に停止します。
	if (self.monitoring) {
		__weak WifiConnector *weakSelf = self;
		dispatch_sync(weakSelf.reachabilityQueue, ^{
			// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.reachability stopNotifier];
			});
		});
	}
	
	// 接続状態の変化をポーリングします。
	BOOL disconnected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		// MARK: カメラの電源オフ中にCGIコマンドを送信するとカメラが電源オフにならないようです。
		// ここでは、カメラへCGIコマンドを送らないように電源オフ(Wi-Fi切断)を待つようにしています。
		[self updateStatusWithToKnockOnCamera:NO];
		if (self.networkStatus == NotReachable || !self.cameraResponded) {
			disconnected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	
	// 監視を再開します。
	if (self.monitoring) {
		__weak WifiConnector *weakSelf = self;
		dispatch_sync(weakSelf.reachabilityQueue, ^{
			// MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.reachability startNotifier];
			});
		});
	}
	
	return disconnected;
}

#pragma mark -

/// Wi-Fi接続の状態が変化した時に呼び出されます。
- (void)reachabilityChanged:(NSNotification *)notification {
	DEBUG_LOG(@"");

	__weak WifiConnector *weakSelf = self;
	dispatch_async(weakSelf.reachabilityQueue, ^{
		[weakSelf updateStatusWithToKnockOnCamera:YES];
	});
}

#pragma mark -

/// 接続状態を更新します。
/// 必要ならば、カメラに接続できるか否かも確かめます。
- (void)updateStatusWithToKnockOnCamera:(BOOL)ping {
	DEBUG_DETAIL_LOG(@"");
	
	NetworkStatus previousNetworkStatus = self.networkStatus;
	BOOL previousCameraResponded = self.cameraResponded;
	
	NetworkStatus networkStatus = self.reachability.currentReachabilityStatus;
	if (networkStatus == NotReachable) {
		// Wi-Fi未接続
		self.networkStatus = NotReachable;
		self.cameraResponded = NO;
	} else if (networkStatus == ReachableViaWiFi) {
		// Wi-Fi接続済
		self.networkStatus = ReachableViaWiFi;
		self.cameraResponded = NO;
		if (ping) {
			AppCamera *camera = GetAppCamera();
			if (camera.connected) {
				self.cameraResponded = YES;
			} else {
				self.cameraResponded = [camera canConnect:OLYCameraConnectionTypeWiFi timeout:3.0 error:nil];
			}
		}
	} else {
		// ここにはこないはず...
	}
	
	// 状態に変化があった時にだけ通知します。
	if (self.networkStatus != previousNetworkStatus ||
		self.cameraResponded != previousCameraResponded) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:WifiStatusChangedNotification object:self];
		});
	}
}

@end
