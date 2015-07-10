//
//  AppSetting.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//

#import "AppSetting.h"

NSString *const AppSettingChangedNotification = @"AppSettingChangedNotification";

static NSString *const UserDefaultsBluetoothLocalName = @"BluetoothLocalName";
static NSString *const UserDefaultsBluetoothPasscode = @"BluetoothPasscode";
static NSString *const UserDefaultsKeepLastCameraSetting = @"KeepLastCameraSetting";
static NSString *const UserDefaultsLatestSnapshotOfCameraSettings = @"LatestSnapshotOfCameraSettings";


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
	if (enable) {
		[userDefaults setBool:enable forKey:UserDefaultsKeepLastCameraSetting];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsKeepLastCameraSetting];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

- (NSDictionary *)latestSnapshotOfCameraSettings {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定から読み出します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey:UserDefaultsLatestSnapshotOfCameraSettings];
}

- (void)setLatestSnapshotOfCameraSettings:(NSDictionary *)settings {
	DEBUG_DETAIL_LOG(@"");
	
	// ユーザー設定に保存します。
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (settings) {
		[userDefaults setObject:settings forKey:UserDefaultsLatestSnapshotOfCameraSettings];
	} else {
		[userDefaults removeObjectForKey:UserDefaultsLatestSnapshotOfCameraSettings];
	}
	
	// アプリケーションの設定が変更されたことを通知します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:AppSettingChangedNotification object:self];
}

@end
