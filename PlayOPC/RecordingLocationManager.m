//
//  RecordingLocationManager.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RecordingLocationManager.h"

@interface RecordingLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *location; ///< デバイスの現在位置
@property (strong, nonatomic) NSError *locationError; ///< デバイスの現在位置が取得できなかった時のエラー内容

@end

#pragma mark -

@implementation RecordingLocationManager

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");
	
	self = [super init];
	if (!self) {
		return nil;
	}

	_location = nil;
	_locationError = nil;
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	_location = nil;
	_locationError = nil;
}

#pragma mark -

/// 現在位置が更新された時に呼び出されます。
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	DEBUG_LOG(@"locations=%@", locations);
	
	/// 現在位置を更新します。
	self.location = [locations lastObject];
	self.locationError = nil;
}

/// 現在位置の取得に失敗した時に呼び出されます。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DEBUG_LOG(@"error=%@", error.description);
	
	/// 現在位置を無効にします。
	self.location = nil;
	self.locationError = error;
}

#pragma mark -

- (CLAuthorizationStatus)reqeustAuthorization {
	DEBUG_LOG(@"");

	// 位置情報が利用不可なら即答します。
	CLLocationManager *manager = [[CLLocationManager alloc] init];
	if (manager.authorizationStatus == kCLAuthorizationStatusDenied) {
		return kCLAuthorizationStatusDenied;
	}

	// 決まっていないならユーザーが許可もしくは禁止を選択するまで待ちます。
	if (manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
		[manager requestWhenInUseAuthorization];
	}
	while (manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
		[NSThread sleepForTimeInterval:0.05];
	}

	// ユーザーの選択した結果を返します。
	DEBUG_LOG(@"authorization=%ld", (long)manager.authorizationStatus);
	return manager.authorizationStatus;
}

- (CLLocation *)currentLocation:(NSTimeInterval)timeout error:(NSError **)error {
	DEBUG_LOG(@"");

	// 現在位置の取得を準備します。
	// MARK: 位置情報マネージャのセットアップはメインスレッドで実行しないとデリゲートが呼び出されないらしいです。
	self.location = nil;
	self.locationError = nil;
	__block CLLocationManager *manager;
	dispatch_sync(dispatch_get_main_queue(), ^{
		DEBUG_DETAIL_LOG(@"");
		
		manager = [[CLLocationManager alloc] init];
		manager.delegate = self;
		manager.desiredAccuracy = kCLLocationAccuracyBest;
		manager.distanceFilter = kCLHeadingFilterNone;
		
		// 現在位置の取得を開始します。
		[manager startUpdatingLocation];
	});
	
	// 現在位置を取得します。
	NSDate *scanStartTime = [NSDate date];
	while (!self.location && !self.locationError && [[NSDate date] timeIntervalSinceDate:scanStartTime] < timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	CLLocation *location = self.location;
	NSError *locationError = self.locationError;

	// 現在位置の取得を終了します。
	[manager stopUpdatingLocation];
	manager.delegate = nil;
	manager = nil;
	self.location = nil;
	self.locationError = nil;

	// 取得した現在位置を返却します。
	if (!location) {
		// 現在位置が取得できませんでした。
		if (!locationError) {
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CouldNotGetCurrentGeolocation", @"RecordingLocationManager.currentLocation")
			};
			NSError *internalError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:userInfo];
			locationError = internalError;
		}
		if (error) {
			*error = locationError;
		}
		return nil;
	}
	DEBUG_LOG(@"location=%@", location.description);
	return location;
}

/// 現在位置利用の権限が変化した時に呼び出されます。
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
	DEBUG_LOG(@"");

	switch (manager.authorizationStatus) {
		case kCLAuthorizationStatusNotDetermined:
			DEBUG_LOG(@"Using location service isn't determind.");
			break;
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			DEBUG_LOG(@"Using location service is already authorized.");
			break;
		case kCLAuthorizationStatusDenied:
		case kCLAuthorizationStatusRestricted:
			DEBUG_LOG(@"Using location service is restricted.");
			break;
	}
}

@end
