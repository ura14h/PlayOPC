//
//  AppSetting.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

/// ライブビューパネルでタップした時の動作
typedef enum : NSInteger {
	AppSettingLiveViewTappingActionUnknown = 0, ///< 不明
	AppSettingLiveViewTappingActionAF, ///< AFを実行
	AppSettingLiveViewTappingActionAE, ///< AEを実行
} AppSettingLiveViewTappingAction;

extern NSString *const AppSettingChangedNotification; ///< アプリケーションの設定が変化した時の通知名

/// アプリケーションの設定
@interface AppSetting : NSObject

/// アプリ設定に保存されているBluetoothペリフェラルのローカルネーム
@property (strong, nonatomic) NSString *bluetoothLocalName;

/// アプリ設定に保存されているBluetoothペリフェラルのパスコード
@property (strong, nonatomic) NSString *bluetoothPasscode;

///  アプリ設定に保存されているWi-FiアクセスポイントのSSID
@property (strong, nonatomic) NSString *wifiSSID;

///  アプリ設定に保存されているWi-Fiアクセスポイントのパスフレーズ
@property (strong, nonatomic) NSString *wifiPassphrase;

/// アプリ設定に保存されているの最後のカメラ設定を記憶するか否か
@property (assign, nonatomic) BOOL keepLastCameraSetting;

/// アプリ設定に保存されているの最後のカメラ設定
@property (strong, nonatomic) NSDictionary *latestSnapshotOfCameraSetting;

/// ライブビューパネルでタップした時の動作
@property (assign, nonatomic) AppSettingLiveViewTappingAction liveViewTappingAction;

/// ライブビューパネルにグリッドを表示するか否か
@property (assign, nonatomic) BOOL showLiveImageGrid;

@end
