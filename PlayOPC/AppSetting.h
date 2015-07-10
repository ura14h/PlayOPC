//
//  AppSetting.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AppSettingChangedNotification; ///< アプリケーションの設定が変化した時の通知名


/// アプリケーションの設定
@interface AppSetting : NSObject

/// アプリ設定に保存されているBluetoothペリフェラルのローカルネーム
@property (strong, nonatomic) NSString *bluetoothLocalName;
/// アプリ設定に保存されているBluetoothペリフェラルのパスコード
@property (strong, nonatomic) NSString *bluetoothPasscode;
/// アプリ設定に保存されているの最後のカメラ設定を記憶するか否か
@property (assign, nonatomic) BOOL keepLastCameraSetting;
/// アプリ設定に保存されているの最後のカメラ設定
@property (strong, nonatomic) NSDictionary *latestSnapshotOfCameraSettings;

@end
