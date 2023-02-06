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
	WifiConnectionStatusConnectedOther, ///< 接続中 (他のアクセスポイント)
	WifiConnectionStatusConnected, ///< 接続中
} WifiConnectionStatus;

/// Wi-Fi接続状態監視のエラーコード
typedef enum : NSInteger {
	WifiConnectorErrorUnknown = 1000, ///< 不明
	WifiConnectorErrorBusy, ///< 処理中につき多忙
	WifiConnectorErrorTimeout, ///< 内部のReachabilityでエラー発生
} WifiConnectorError;

extern NSString *const WifiConnectionChangedNotification; ///< Wi-Fiの接続状態が変化した時の通知名
extern NSString *const WifiConnectorErrorDomain; ///< Wi-Fi接続状態監視のエラードメイン

/// Wi-Fi接続の監視をお手伝いをします。
@interface WifiConnector : NSObject

@property (strong, nonatomic) NSString *SSID; ///< Wi-FiのSSID
@property (strong, nonatomic) NSString *passphrase; ///< Wi-Fiのパスフレーズ
@property (assign, nonatomic) NSTimeInterval timeout; ///< 処理のタイムアウト値

/// Wi-Fiの接続状態を取得します。
- (WifiConnectionStatus)connectionStatus;

/// 接続状態の監視を開始します。
- (void)startMonitoring;

/// 接続状態の監視を終了します。
- (void)stopMonitoring;

/// カメラのアクセスポイントへの接続を試みます。
- (BOOL)connectHotspot:(NSError**)error;

/// カメラのアクセスポイントへの接続を切断します。
- (BOOL)disconnectHotspot:(NSError **)error;

@end
