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
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"

NSString *const WifiConnectionChangedNotification = @"WifiConnectionChangedNotification";
NSString *const WifiConnectorErrorDomain = @"WifiConnectorErrorDomain";

@interface WifiConnector ()

@property (strong, nonatomic) NSString *SSID;
@property (strong, nonatomic) NSString *BSSID;
@property (assign, nonatomic) BOOL monitoring; ///< 接続状態の監視中か否かを示します。
@property (strong, nonatomic) Reachability *reachability;

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
	_BSSID = nil;
	_reachability = [Reachability reachabilityForLocalWiFi];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:kReachabilityChangedNotification object:nil];
	_reachability = nil;
	_SSID = nil;
	_BSSID = nil;
}

#pragma mark -

- (WifiConnectionStatus)currentConnectionStatus {
	DEBUG_DETAIL_LOG(@"");
	
	NetworkStatus networkStatus = self.reachability.currentReachabilityStatus;
	switch (networkStatus) {
		case ReachableViaWiFi:
			return WifiConnectionStatusConnected;
		case NotReachable:
			return WifiConnectionStatusNotConnected;
		default:
			break;
	}
	return WifiConnectionStatusUnknown;
}

- (BOOL)startMonitoring:(NSError **)error {
	DEBUG_LOG(@"");
	
	if (self.monitoring) {
		// 監視はすでに実行中です。
		NSError *internalError = [self createError:WifiConnectorErrorBusy description:NSLocalizedString(@"$desc:MonitoringIsRunnning", @"WifiConnector.startMonitoring")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	
	[self updateNetworkInfo];
	if (![self.reachability startNotifier]) {
		// Reachabilityの通知開始に失敗しました。
		NSError *internalError = [self createError:WifiConnectorErrorReachabilityFailed description:NSLocalizedString(@"$desc:CouldNotStartMonitoring", @"WifiConnector.startMonitoring")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	self.monitoring = YES;
	
	return YES;
}

- (BOOL)stopMonitoring:(NSError **)error {
	DEBUG_LOG(@"");

	if (!self.monitoring) {
		// 監視は未実行です。
		NSError *internalError = [self createError:WifiConnectorErrorBusy description:NSLocalizedString(@"$desc:MonitoringIsNotRunnning", @"WifiConnector.stopMonitoring")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	
	[self.reachability stopNotifier];
	self.monitoring = NO;
	
	return YES;
}

- (BOOL)isPossibleToAccessCamera {
	DEBUG_LOG(@"");

	// 接続していなかったらカメラにはアクセスできません。
	if ([self currentConnectionStatus] != WifiConnectionStatusConnected) {
		return NO;
	}

	// SSIDが"AIR-A01-?????????"でなければカメラにアクセスできません。
	// FIXME: 現状ではこんな判断の方法しかないようです。
	if (self.SSID) {
		NSString *pattern = @"^AIR-A\\d+-.+$";
		NSError *error = nil;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
		NSTextCheckingResult *match = [regex firstMatchInString:self.SSID options:0 range:NSMakeRange(0, self.SSID.length)];
		if (!match) {
			return NO;
		}
		return YES;
	}
	
	// MARK: iOSシミュレーターとiOS9では、接続先のSSIDが正しく取得できないようです。
	// TODO: カメラのIPアドレスを指定して接続できるかを試みます。
	return YES;
}

- (BOOL)waitForConnectionStatus:(WifiConnectionStatus)status timeout:(NSTimeInterval)timeout {
	DEBUG_LOG(@"timeout=%ld", (long)timeout);

	// 引数を確認します。
	if (status != WifiConnectionStatusConnected &&
		status != WifiConnectionStatusNotConnected) {
		return NO;
	}

	// 監視を一時的に停止します。
	[self.reachability stopNotifier];
	
	// 接続状態の変化をポーリングします。
	NSDate *waitStartTime = [NSDate date];
	while ([[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		if ([self currentConnectionStatus] == status) {
			// 期待した接続状態になったらSSIDを更新します。(Wi-Fi接続状態変化の通知が飛ぶかもしれません)
			[self reachabilityChanged:nil];
			BOOL result;
			if (status == WifiConnectionStatusConnected) {
				// 接続中になったらカメラに接続できるか否かを確認します。
				if ([self isPossibleToAccessCamera]) {
					result = YES;
				} else {
					// Wi-Fi接続済みでカメラにアクセスできない状態は望みがないので異常終了です。
					result = NO;
				}
			} else if (status == WifiConnectionStatusNotConnected) {
				// 切断中になったら正常終了です。
				result = YES;
			}
			// 監視を再開します。
			if (![self.reachability startNotifier]) {
				DEBUG_LOG(@"Could not restart monitoring by failed [Reachability startNotifier].");
			}
			return result;
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	
	// タイムアウトしました。
	return NO;
}

#pragma mark -

/// Wi-Fi接続の状態が変化した時に呼び出されます。
- (void)reachabilityChanged:(NSNotification *)notification {
	DEBUG_LOG(@"");

	[self updateNetworkInfo];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
}

/// ネットワーク接続情報を更新します。
- (BOOL)updateNetworkInfo {
	DEBUG_LOG(@"");
	
	BOOL validNetworkInfo = NO;
	NSString *currentSSID = nil;
	NSString *currentBSSID = nil;
	NetworkStatus networkStatus = self.reachability.currentReachabilityStatus;
	if (networkStatus == ReachableViaWiFi) {
		NSArray* supportedInterfaces = (__bridge_transfer id)CNCopySupportedInterfaces();
		for (NSString *interfaceName in supportedInterfaces) {
			NSDictionary *currentNetworkInfo = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
			if (currentNetworkInfo) {
				currentSSID = currentNetworkInfo[(__bridge NSString *)kCNNetworkInfoKeySSID];
				currentBSSID = currentNetworkInfo[(__bridge NSString *)kCNNetworkInfoKeyBSSID];
				validNetworkInfo = YES;
			}
		}
	}
	self.SSID = currentSSID;
	self.BSSID = currentBSSID;

	return validNetworkInfo;
}

/// エラー情報を作成します。
- (NSError *)createError:(NSInteger)code description:(NSString *)description {
	DEBUG_LOG(@"code=%ld, description=%@", (long)code, description);
	
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
	NSError *error = [[NSError alloc] initWithDomain:WifiConnectorErrorDomain code:code userInfo:userInfo];
	return error;
}

@end
