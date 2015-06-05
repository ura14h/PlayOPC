//
//  WifiConnector.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

/// Wi-Fiの接続状態
typedef enum : NSInteger {
	WifiConnectionStatusUnknown = 0, ///< 不明
	WifiConnectionStatusNotConnected, ///< 未接続
	WifiConnectionStatusConnected ///< 接続中
} WifiConnectionStatus;

/// Wi-Fi接続状態監視のエラーコード
typedef enum : NSInteger {
	WifiConnectorErrorUnknown = 1000, ///< 不明
	WifiConnectorErrorBusy, ///< 処理中につき多忙
	WifiConnectorErrorReachabilityFailed, ///< 内部のReachabilityでエラー発生
} WifiConnectorError;

extern NSString *const WifiConnectionChangedNotification; ///< Wi-Fiの接続状態が変化した時の通知名
extern NSString *const WifiConnectorErrorDomain; ///< Wi-Fi接続状態監視のエラードメイン


/// Wi-Fi接続の監視をお手伝いをします。
/// この内部ではReachabilityが動作しています。
@interface WifiConnector : NSObject

@property (strong, nonatomic, readonly) NSString *SSID; ///< Wi-FiのSSID
@property (strong, nonatomic, readonly) NSString *BSSID; ///< Wi-FiのBSSID

/// 現在の接続状態を取得します。
- (WifiConnectionStatus)currentConnectionStatus;

/// 接続状態の監視を開始します。
- (BOOL)startMonitoring:(NSError **)error;

/// 接続状態の監視を終了します。
- (BOOL)stopMonitoring:(NSError **)error;

/// カメラにアクセスできるWi-Fi接続か否かを示します。
- (BOOL)isPossibleToAccessCamera;

/// Wi-Fi接続が指定した状態になるまで待ちます。
/// startMonitoring:とstopMonitoring:およびWifiConnectionChangedNotificationの通知による監視では、
/// OSの都合か何かにより変化した接続状態を検出するまでに時間がかかるので(特に切断時)、
/// 応答速度を高める必要があるならこのメソッドで状態変化を監視してください。
/// (このメソッドは内部でWi-Fi接続の状態監視を一時停止して状態変化をポーリングします)
- (BOOL)waitForConnectionStatus:(WifiConnectionStatus)status timeout:(NSTimeInterval)timeout;

@end
