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
	WifiConnectionStatusConnected, ///< 接続中
} WifiConnectionStatus;

/// カメラにアクセスできるか否か
typedef enum : NSInteger {
	WifiCameraStatusUnknown = 0, ///< 不明
	WifiCameraStatusUnreachable, ///< 到達不能
	WifiCameraStatusReachable, ///< 到達可能
} WifiCameraStatus;

/// Wi-Fi接続状態監視のエラーコード
typedef enum : NSInteger {
	WifiConnectorErrorUnknown = 1000, ///< 不明
	WifiConnectorErrorBusy, ///< 処理中につき多忙
	WifiConnectorErrorReachabilityFailed, ///< 内部のReachabilityでエラー発生
} WifiConnectorError;

extern NSString *const WifiStatusChangedNotification; ///< Wi-Fiの接続状態かカメラへアクセスできるかが変化した時の通知名

/// Wi-Fi接続の監視をお手伝いをします。
/// この内部ではReachabilityが動作しています。
@interface WifiConnector : NSObject

@property (strong, nonatomic, readonly) NSString *SSID; ///< Wi-FiのSSID
@property (strong, nonatomic, readonly) NSString *BSSID; ///< Wi-FiのBSSID

/// Wi-Fiの接続状態を取得します。
- (WifiConnectionStatus)connectionStatus;

/// カメラにアクセスできるか否かを取得します。
- (WifiCameraStatus)cameraStatus;

/// 接続状態の監視を開始します。
- (void)startMonitoring;

/// 接続状態の監視を終了します。
- (void)stopMonitoring;

/// カメラへのアクセスが可能になるまで待ちます。
- (BOOL)waitForConnected:(NSTimeInterval)timeout;

/// カメラへのアクセスが不能になるまで待ちます。
- (BOOL)waitForDisconnected:(NSTimeInterval)timeout;

@end
