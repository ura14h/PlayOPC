//
//  BluetoothConnector.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/29.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/// Bluetoothの接続状態
typedef enum : NSInteger {
	BluetoothConnectionStatusUnknown = 0, ///< 不明
	BluetoothConnectionStatusNotNotAuthorized, ///< 許可されていない
	BluetoothConnectionStatusNotFound, ///< ペリフェラルが見つからない
	BluetoothConnectionStatusNotConnected, ///< 未接続
	BluetoothConnectionStatusConnected, ///< 接続中
} BluetoothConnectionStatus;

/// Bluetooth接続状態監視のエラーコード
typedef enum : NSInteger {
	BluetoothConnectorErrorUnknown = 1000, ///< 不明
	BluetoothConnectorErrorBusy, ///< 処理中につき多忙
	BluetoothConnectorErrorNotAvailable, ///< 利用できない
	BluetoothConnectorErrorNoPeripheral, ///< ペリフェラルがない
	BluetoothConnectorErrorDisconnected, ///< すでに接続が解除されている
	BluetoothConnectorErrorConnected, ///< すでに接続している
	BluetoothConnectorErrorTimeout, ///< 処理待ちがタイムアウトした
} BluetoothConnectorError;

extern NSString *const BluetoothConnectionChangedNotification; ///< Bluetoothの接続状態が変化した時の通知名
extern NSString *const BluetoothConnectorErrorDomain; ///< Bluetooth接続状態監視のエラードメイン

/// Bluetoothペリフェラルへの接続をお手伝いをします。
@interface BluetoothConnector : NSObject

@property (strong, nonatomic) NSArray *services; ///< ペリフェラルを検索するためのBluetoothサービスUUDのリスト
@property (strong, nonatomic) NSString *localName; ///< ペリフェラルのローカルネーム
@property (assign, nonatomic) NSTimeInterval timeout; ///< 処理のタイムアウト値
@property (strong, nonatomic, readonly) CBPeripheral *peripheral; ///< ペリフェラル
@property (assign, nonatomic, readonly) BOOL running; ///< 処理実行中か否かを示します。

/// 現在の接続状態を取得します。
- (BluetoothConnectionStatus)connectionStatus;

/// Bluetoothの使用許可を要求します。
- (CBManagerAuthorization)reqeustAuthorization;

/// ペリフェラルのキャッシュをクリアします。
- (void)clearPeripheralCache;

/// ペリフェラルを探します。
- (BOOL)discoverPeripheral:(NSError **)error;

/// ペリフェラルに接続します。
- (BOOL)connectPeripheral:(NSError **)error;

/// ペリフェラルとの接続を解除します。
- (BOOL)disconnectPeripheral:(NSError **)error;

@end
