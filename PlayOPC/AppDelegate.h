//
//  AppDelegate.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@class AppSetting;
@class AppCamera;
@class AppCameraLog;

/// アプリケーションデリゲート
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

/// アプリケーションインスタンスを取得します。
extern UIApplication *GetApp(void);

/// アプリ内で唯一のアプリケーションデリゲートインスタンスを取得します。
extern AppDelegate *GetAppDelegate(void);

/// アプリ内で唯一のアプリケーション設定インスタンスを取得します。
extern AppSetting *GetAppSetting(void);

/// アプリ内で唯一のカメラインスタンスを取得します。
extern AppCamera *GetAppCamera(void);

/// アプリ内で唯一のカメラログインスタンスを取得します。
extern AppCameraLog *GetAppCameraLog(void);

/// アプリのタッチ操作を無効にします。
extern void AppBeginIgnoringInteractionEvents(void);

/// アプリのタッチ操作を有効にします。
extern void AppEndIgnoringInteractionEvents(void);
