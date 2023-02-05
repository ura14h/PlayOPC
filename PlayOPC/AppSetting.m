//
//  AppSetting.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppSetting.h"

NSString *const AppSettingChangedNotification = @"AppSettingChangedNotification";

static NSString *const UserDefaultsBluetoothLocalName = @"BluetoothLocalName";
static NSString *const UserDefaultsBluetoothPasscode = @"BluetoothPasscode";
static NSString *const UserDefaultsWifiSSID = @"WifiSSID";
static NSString *const UserDefaultsWifiPassphrase = @"WifiPassphrase";
static NSString *const UserDefaultsWifiHost = @"WifiHost";
static NSString *const UserDefaultsWifiCommandPort = @"WifiCommandPort";
static NSString *const UserDefaultsWifiEventPort = @"WifiEventPort";
static NSString *const UserDefaultsWifiLiveViewStreamingPort = @"WifiLiveViewStreamingPort";
static NSString *const UserDefaultsKeepLastCameraSetting = @"KeepLastCameraSetting";
static NSString *const UserDefaultsLatestSnapshotOfCameraSetting = @"LatestSnapshotOfCameraSetting";
static NSString *const UserDefaultsLiveViewTappingAction = @"LiveViewTappingAction";
static NSString *const UserDefaultsShowLiveImageGrid = @"ShowLiveImageGrid";

@interface AppSetting ()
@end

#pragma mark -

@implementation AppSetting

#pragma mark -

+ (void)initialize {
	DEBUG_LOG(@"");
	
	if ([self class] != [AppSetting class]) {
		return;
	}
	
	// ユーザー設定の工場出荷設定値を読み込んで初期化します。
	NSString *userDefaultsPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *userDefaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:userDefaultsPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDictionary];
}

- (instancetype)init
{
	DEBUG_LOG(@"");

	self = [super init];
	if (!self) {
		return nil;
	}
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize];
}

#pragma mark -

- (NSString *)bluetoothLocalName {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsBluetoothLocalName];
}

- (void)setBluetoothLocalName:(NSString *)name {
	DEBUG_DETAIL_LOG(@"name=%@", name);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (name) {
		[userDefaults setObject:name forKey:UserDefaultsBluetoothLocalName];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsBluetoothLocalName];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (NSString *)bluetoothPasscode {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsBluetoothPasscode];
}

- (void)setBluetoothPasscode:(NSString *)passcode {
	DEBUG_DETAIL_LOG(@"passcode=%@", passcode);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (passcode) {
		[userDefaults setObject:passcode forKey:UserDefaultsBluetoothPasscode];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsBluetoothPasscode];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (NSString *)wifiSSID {
	DEBUG_DETAIL_LOG(@"");

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsWifiSSID];
}

- (void)setWifiSSID:(NSString *)ssid {
	DEBUG_DETAIL_LOG(@"ssid=%@", ssid);

	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (ssid) {
		[userDefaults setObject:ssid forKey:UserDefaultsWifiSSID];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsWifiSSID];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (NSString *)wifiPassphrase {
	DEBUG_DETAIL_LOG(@"");

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsWifiPassphrase];
}

- (void)setWifiPassphrase:(NSString *)passphrase {
	DEBUG_DETAIL_LOG(@"passphrase=%@", passphrase);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (passphrase) {
		[userDefaults setObject:passphrase forKey:UserDefaultsWifiPassphrase];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsWifiPassphrase];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (BOOL)keepLastCameraSetting {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:UserDefaultsKeepLastCameraSetting];
}

- (void)setKeepLastCameraSetting:(BOOL)enable {
	DEBUG_DETAIL_LOG(@"enable=%@", enable);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:enable forKey:UserDefaultsKeepLastCameraSetting];
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (NSDictionary *)latestSnapshotOfCameraSetting {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsLatestSnapshotOfCameraSetting];
}

- (void)setLatestSnapshotOfCameraSetting:(NSDictionary *)setting {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (setting) {
		[userDefaults setObject:setting forKey:UserDefaultsLatestSnapshotOfCameraSetting];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsLatestSnapshotOfCameraSetting];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (AppSettingLiveViewTappingAction)liveViewTappingAction {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults integerForKey:UserDefaultsLiveViewTappingAction];
}

- (void)setLiveViewTappingAction:(AppSettingLiveViewTappingAction)action {
	DEBUG_DETAIL_LOG(@"action=%ld", (long)action);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:action forKey:UserDefaultsLiveViewTappingAction];
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (BOOL)showLiveImageGrid {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:UserDefaultsShowLiveImageGrid];
}

- (void)setShowLiveImageGrid:(BOOL)show {
	DEBUG_DETAIL_LOG(@"show=%ld", (long)show);
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:show forKey:UserDefaultsShowLiveImageGrid];
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

@end
