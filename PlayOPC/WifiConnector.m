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

NSString *const WifiStatusChangedNotification = @"WifiStatusChangedNotification";

@interface WifiConnector ()

@property (strong, nonatomic) NSString *SSID;
@property (strong, nonatomic) NSString *BSSID;
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
	_BSSID = nil;
	_reachabilityQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.reachabilityQueue", DISPATCH_QUEUE_SERIAL);
	_reachability = [Reachability reachabilityForLocalWiFi];
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
	_BSSID = nil;
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

	__weak WifiConnector *weakSelf = self;
	dispatch_async(weakSelf.reachabilityQueue, ^{
		[weakSelf updateStatusWithToPingCamera:YES];
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
		[self updateStatusWithToPingCamera:YES];
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
		[self updateStatusWithToPingCamera:NO];
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
		[weakSelf updateStatusWithToPingCamera:YES];
	});
}

#pragma mark -

/// 接続状態を更新します。
- (void)updateStatusWithToPingCamera:(BOOL)ping {
	DEBUG_DETAIL_LOG(@"");
	
	NetworkStatus previousNetworkStatus = self.networkStatus;
	BOOL previousCameraResponded = self.cameraResponded;
	
	NetworkStatus networkStatus = self.reachability.currentReachabilityStatus;
	if (networkStatus == NotReachable) {
		// Wi-Fi未接続
		self.networkStatus = NotReachable;
		self.cameraResponded = NO;
		[self retreiveSSID];
	} else if (networkStatus == ReachableViaWiFi) {
		// Wi-Fi接続済
		self.networkStatus = ReachableViaWiFi;
		self.cameraResponded = NO;
		[self retreiveSSID];
		if (ping) {
			self.cameraResponded = [self pingCamera];
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

/// ネットワーク接続情報を更新します。
- (void)retreiveSSID {
	DEBUG_DETAIL_LOG(@"");
	
	// SSIDとBSSIDを取得します。
	// MARK: iOSシミュレータでは正しく動作しません。SSIDもBSSIDもnilに設定されます。
	NSString *currentSSID = nil;
	NSString *currentBSSID = nil;
	if (self.networkStatus == ReachableViaWiFi) {
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
}

/// カメラにアクセスできるか否かを確かめます。
- (BOOL)pingCamera {
	DEBUG_DETAIL_LOG(@"");
	
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
		return false;
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
		return false;
	}
	if (response.statusCode != 200) {
		DEBUG_LOG(@"error");
		return false;
	}
	NSDictionary *fields = response.allHeaderFields;
	NSString *contentType = fields[@"Content-Type"];
	if (![contentType isEqualToString:@"text/xml"]) {
		DEBUG_LOG(@"error");
		return false;
	}
	NSString *resultText = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	if ([resultText rangeOfString:@"<connectmode>OPC</connectmode>"].location == NSNotFound) {
		DEBUG_LOG(@"error");
		return false;
	}
	
	// カメラへHTTPで接続できたようです。
	return YES;
}

@end
