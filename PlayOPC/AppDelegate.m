//
//  AppDelegate.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"
#import <OLYCameraKit/OACentralConfiguration.h>
#import "AppCamera.h"
#import "AppCameraLog.h"

NSString *const AppUrlSchemeGetFromOacentral = @"net.homeunix.hio.ipa.PlayOPC.GetFromOacentral";
NSString *const AppOACentralConfigurationDidGetNotification = @"AppOACentralConfigurationDidGetNotification";
NSString *const AppOACentralConfigurationDidGetNotificationUserInfo = @"AppOACentralConfigurationDidGetNotificationUserInfo";
NSString *const UserDefaultsBluetoothLocalName = @"BluetoothLocalName";
NSString *const UserDefaultsBluetoothPasscode = @"BluetoothPasscode";

@interface AppDelegate ()

@property (strong, nonatomic) AppCamera *camera; ///< カメラ
@property (strong, nonatomic) AppCameraLog *cameraLog; ///< カメラキットのログ履歴

@end

#pragma mark -

@implementation AppDelegate

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	DEBUG_LOG(@"launchOptions=%@", launchOptions);

	// Storyboardで設定しても有効にならないので、ここで規定の色合いをハードコーディングして変更します。
	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
	[UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.6 alpha:1.0];
	
	// カメラログインスタンスをカメラインスタンスより先に生成しておかないと、カメラの初期化に関わるログが記録されません。
	self.cameraLog = [[AppCameraLog alloc] init];
	self.camera = [[AppCamera alloc] init];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	DEBUG_LOG(@"");
	// やらなければならないことは全てConnectionViewControllerで行います。
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	DEBUG_LOG(@"");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	DEBUG_LOG(@"");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	DEBUG_LOG(@"");
	// やらなければならないことは全てConnectionViewControllerで行います。
}

- (void)applicationWillTerminate:(UIApplication *)application {
	DEBUG_LOG(@"");
	
	// カメラログインスタンスをカメラインスタンスより後に解放しないと、カメラの終了に関わるログが記録されません。
	self.camera = nil;
	self.cameraLog = nil;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	DEBUG_LOG(@"url=%@, sourceApplication=%@, annotation=%@", url, sourceApplication, annotation);
	
	if ([[url scheme] isEqualToString:AppUrlSchemeGetFromOacentral]) {
		// OA.Centralから呼び出されました。
		// OA.Centralが保持している設定情報を送り返してきています。
		OACentralConfiguration *configuration = [[OACentralConfiguration alloc] initWithConfigurationURL:url];
		DEBUG_LOG(@"configuration.bleName=%@", configuration.bleName);
		DEBUG_LOG(@"configuration.bleCode=%@", configuration.bleCode);

		// OA.Centralから接続設定を取得したことをお知らせします。
		// この設定情報を欲しがっているビューコントローラーは、このインスタンスから遠いところにいるので、通知を使って届けます。
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		NSDictionary *userInfo = @{
			AppOACentralConfigurationDidGetNotificationUserInfo:configuration
		};
		[notificationCenter postNotificationName:AppOACentralConfigurationDidGetNotification object:self userInfo:userInfo];
	}
	return YES;
}

@end

#pragma mark -

AppCamera *GetAppCamera() {
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!delegate) {
		return nil;
	}
	return delegate.camera;
}

AppCameraLog *GetAppCameraLog() {
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (!delegate) {
		return nil;
	}
	return delegate.cameraLog;
}
