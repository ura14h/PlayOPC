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
//#import "Reachability.h"
#import <Network/Network.h>
#import "AppDelegate.h"
#import "AppCamera.h"

NSString *const WifiStatusChangedNotification = @"WifiStatusChangedNotification";

@interface WifiConnector ()

@property (assign, nonatomic) BOOL monitoring; ///< 接続状態の監視中か否かを示します。
@property (strong, nonatomic) dispatch_queue_t pathMonitorQueue; ///< 接続状態を確認するキュー
@property (strong, nonatomic) nw_path_monitor_t pathMonitor; ///< 接続状態を監視するモニター
@property (strong, nonatomic) nw_path_t path; ///< 接続情報
@property (assign, nonatomic) nw_path_status_t pathStatus; ///< 接続状態
@property (assign, nonatomic) BOOL cameraResponded; ///< カメラの応答があったか否か
@property (assign, nonatomic) BOOL cameraDisconnecting; ///< カメラとの接続を解除中か否か

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
	_pathMonitorQueue = nil;
	_pathMonitor = nil;
	_path = nil;
	_pathStatus = nw_path_status_invalid;
	_cameraResponded = NO;
	_cameraDisconnecting = NO;

	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_SSID = nil;
	_passphrase = nil;
	_pathMonitorQueue = nil;
	_pathMonitor = nil;
	_path = nil;
}

#pragma mark -

- (WifiConnectionStatus)connectionStatus {
	DEBUG_DETAIL_LOG(@"");
	
	switch (self.pathStatus) {
		case nw_path_status_satisfied:
			return WifiConnectionStatusConnected;
		case nw_path_status_satisfiable:
		case nw_path_status_unsatisfied:
			return WifiConnectionStatusNotConnected;
		case nw_path_status_invalid:
		default:
			break;
	}
	return WifiConnectionStatusUnknown;
}

- (WifiCameraStatus)cameraStatus {
	DEBUG_DETAIL_LOG(@"");
	
	switch (self.pathStatus) {
		case nw_path_status_satisfied:
			break;
		case nw_path_status_satisfiable:
		case nw_path_status_unsatisfied:
		case nw_path_status_invalid:
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

	self.pathMonitorQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.monitorQueue", DISPATCH_QUEUE_SERIAL);
	self.pathMonitor = nw_path_monitor_create_with_type(nw_interface_type_wifi);
	nw_path_monitor_set_queue(self.pathMonitor, self.pathMonitorQueue);
	self.path = nil;
	self.pathStatus = nw_path_status_invalid;
	self.cameraResponded = NO;

	__weak WifiConnector *weakSelf = self;
	nw_path_monitor_set_cancel_handler(self.pathMonitor, ^{
		weakSelf.monitoring = NO;
		weakSelf.pathMonitorQueue = nil;
		weakSelf.pathMonitor = nil;
		weakSelf.path = nil;
		weakSelf.pathStatus = nw_path_status_invalid;
		weakSelf.cameraResponded = NO;
		weakSelf.cameraDisconnecting = NO;
	});
	nw_path_monitor_set_update_handler(self.pathMonitor, ^(nw_path_t path) {
		[weakSelf updatePath:path];
	});
	nw_path_monitor_start(self.pathMonitor);
	self.monitoring = YES;
}

- (void)stopMonitoring {
	DEBUG_LOG(@"");

	if (!self.monitoring) {
		// 監視は未実行です。
		NSLog(NSLocalizedString(@"$desc:MonitoringIsNotRunnning", @"WifiConnector.stopMonitoring"));
		return;
	}
	
	nw_path_monitor_cancel(self.pathMonitor);
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

	// 接続状態の変化をポーリングします。
	BOOL connected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		BOOL isWiFi = nw_path_uses_interface_type(self.path, nw_interface_type_wifi);
		if (isWiFi && self.cameraResponded) {
			connected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}

	return connected;
}

- (BOOL)waitForDisconnected:(NSTimeInterval)timeout {
	DEBUG_LOG(@"timeout=%ld", (long)timeout);
	
	// 接続状態の変化をポーリングします。
	self.cameraDisconnecting = YES;
	BOOL disconnected = NO;
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		if (self.pathStatus != nw_path_status_satisfied || !self.cameraResponded) {
			disconnected = YES;
			break;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	self.cameraDisconnecting = NO;

	return disconnected;
}

#pragma mark -

/// 接続状態を更新します。
/// カメラのアクセスポイントに接続している場合はカメラと通信できるか否かも確かめます。
- (void)updatePath:(nw_path_t)path {
	DEBUG_DETAIL_LOG(@"");

	nw_path_t currentPath = path;
	nw_path_status_t currentStatus = nw_path_get_status(path);
	BOOL currentCameraResponded = NO;
	
	if (currentStatus == nw_path_status_satisfied) {
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block NEHotspotNetwork *network;
		[NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork *current) {
			network = current;
			dispatch_semaphore_signal(semaphore);
		}];
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
		
		if (network && [network.SSID isEqualToString:self.SSID]) {
			// WiFiの接続解除中はカメラにコマンドを送信しないようにします。
			// MARK: カメラのWiFiを接続解除中にCGIコマンドを送信すると接続解除が遅延したり電源がオフにならなかったりするようです。
			if (!self.cameraDisconnecting) {
				AppCamera *camera = GetAppCamera();
				if (camera.connected) {
					currentCameraResponded = YES;
				} else {
					currentCameraResponded = [camera canConnect:OLYCameraConnectionTypeWiFi timeout:1.0 error:nil];
				}
			}
		}
	}
	
	BOOL changed = (self.pathStatus != currentStatus) || (self.cameraResponded != currentCameraResponded);
	self.path = currentPath;
	self.pathStatus = currentStatus;
	self.cameraResponded = currentCameraResponded;
	
	if (changed) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:WifiStatusChangedNotification object:self];
		});
	}
}

@end
