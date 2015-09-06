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
@property (strong, nonatomic) dispatch_queue_t reachabilityQueue; ///< 到達確認性を実行するキュー
@property (assign, nonatomic) BOOL cameraIsReachable; ///< カメラに到達できるか否かを示します。

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
	_reachabilityQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.reachabilityQueue", DISPATCH_QUEUE_SERIAL);
	
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

	dispatch_sync(self.reachabilityQueue, ^{
		[self updateNetworkInfo];
	});
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

	if ([self currentConnectionStatus] != WifiConnectionStatusConnected) {
		// 接続していなかったらカメラにはアクセスできません。
		return NO;
	}

	return self.cameraIsReachable;
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
			__block BOOL result;
			if (status == WifiConnectionStatusConnected) {
				// 接続中になったらカメラに接続できるか否かを確認します。
				dispatch_sync(self.reachabilityQueue, ^{
					result = self.cameraIsReachable;
				});
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

	dispatch_async(self.reachabilityQueue, ^{
		[self updateNetworkInfo];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:WifiConnectionChangedNotification object:self];
		});
	});
}

/// ネットワーク接続情報を更新します。
- (void)updateNetworkInfo {
	DEBUG_LOG(@"");
	
	// SSIDとBSSIDを取得します。
	// MARK: iOS 9とそれ以降のバージョンのiOSでは正しく動作しません。SSIDもBSSIDもnilに設定されます。
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
			}
		}
	}
	self.SSID = currentSSID;
	self.BSSID = currentBSSID;

	// カメラのIPアドレスを指定して接続できるかを試みます。
	self.cameraIsReachable = NO;

	// 通信仕様書に従って、
	// 単発かつその後の動作に影響の少ないと思われるCGIコマンドをカメラへ送信してそのレスポンスを確認します。
	// 通信仕様書に沿った期待したレスポンスが返って来れば、このWi-Fiはカメラに接続していると判定します。

	NSString *cameraIPAddress = @"192.168.0.10"; // カメラのIPアドレス
	NSTimeInterval timeout = 3.0; // このタイムアウト秒数は暫定の値です。(値が短すぎると誤判断する)
	
	// カメラのIPアドレスへのルーティングがあるかを確認します。
	Reachability *reachability = [Reachability reachabilityWithHostName:cameraIPAddress];
	NSDate *waitStartTime = [NSDate date];
	while ([reachability currentReachabilityStatus] == NotReachable &&
		   [[NSDate date] timeIntervalSinceDate:waitStartTime] < timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	if ([reachability currentReachabilityStatus] != ReachableViaWiFi) {
		DEBUG_LOG(@"timed out");
		return;
	}
	
	// HTTP接続のリクエストを作成します。
	// 送信するCGIコマンドは、接続モード取得(get_connectmode.cgi)を使います。
	NSMutableString *url = [[NSMutableString alloc] init];
	[url appendString:@"http://"];
	[url appendString:cameraIPAddress];
	[url appendString:@"/get_connectmode.cgi"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	request.allowsCellularAccess = NO; // LTE/3G側には送信しないようにします。
	request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
	request.timeoutInterval = timeout;
	[request setValue:cameraIPAddress forHTTPHeaderField:@"Host"];
	[request setValue:@"OlympusCameraKit" forHTTPHeaderField:@"User-Agent"];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	configuration.allowsCellularAccess = request.allowsCellularAccess;
	configuration.timeoutIntervalForRequest = request.timeoutInterval;
	configuration.timeoutIntervalForResource = request.timeoutInterval;
	
	// HTTP接続を試みます。
	__block NSData *result = nil;
	__block NSHTTPURLResponse *response = nil;
	dispatch_semaphore_t completion = dispatch_semaphore_create(0);
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskResult, NSURLResponse *taskResponse, NSError *taskError) {
		result = taskResult;
		response = (NSHTTPURLResponse *)taskResponse;
		dispatch_semaphore_signal(completion);
	}];
	[task resume];
	dispatch_semaphore_wait(completion, DISPATCH_TIME_FOREVER);
	[session invalidateAndCancel];
	
	// HTTP接続のレスポンスを確認します。
	// 期待するCGIコマンドの応答は、XML形式でconnectmode要素のテキストがOPCになっていることです。
	if (!result || !response) {
		DEBUG_LOG(@"timed out");
		return;
	}
	if (response.statusCode != 200) {
		DEBUG_LOG(@"error");
		return;
	}
	NSDictionary *fields = response.allHeaderFields;
	NSString *contentType = fields[@"Content-Type"];
	if (![contentType isEqualToString:@"text/xml"]) {
		DEBUG_LOG(@"error");
		return;
	}
	NSString *resultText = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	if ([resultText rangeOfString:@"<connectmode>OPC</connectmode>"].location == NSNotFound) {
		DEBUG_LOG(@"error");
		return;
	}
	
	// カメラへHTTPで接続できたようです。
	self.cameraIsReachable = YES;
	
	return;
}

/// エラー情報を作成します。
- (NSError *)createError:(NSInteger)code description:(NSString *)description {
	DEBUG_LOG(@"code=%ld, description=%@", (long)code, description);
	
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
	NSError *error = [[NSError alloc] initWithDomain:WifiConnectorErrorDomain code:code userInfo:userInfo];
	return error;
}

@end
