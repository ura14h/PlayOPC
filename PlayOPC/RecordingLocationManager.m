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

@property (strong, nonatomic) CLLocationManager *locationManager; ///< 位置情報マネージャ
@property (strong, nonatomic) CLLocation *location; ///< デバイスの現在位置
@property (strong, nonatomic) NSError *locationError; ///< デバイスの現在位置が取得できなかった時のエラー内容
@property (assign, nonatomic) BOOL running; ///< 実行中か否か

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

	_desiredAccuracy = kCLLocationAccuracyBest;
	_distanceFilter = kCLHeadingFilterNone;
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	[_locationManager stopUpdatingLocation];
	_locationManager.delegate = nil;
	_locationManager = nil;
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

	// 現在位置の取得を準備を開始します。
	if (!self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = self.desiredAccuracy;
		self.locationManager.distanceFilter = self.distanceFilter;
		self.location = nil;
		self.locationError = nil;
	}

	// 位置情報が利用不可なら即答します。
	if (self.locationManager.authorizationStatus == kCLAuthorizationStatusDenied) {
		return kCLAuthorizationStatusDenied;
	}

	// 決まっていないならユーザーが許可もしくは禁止を選択するまで待ちます。
	if (self.locationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	while (self.locationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
		[NSThread sleepForTimeInterval:0.05];
	}

	// ユーザーの選択した結果を返します。
	DEBUG_LOG(@"authorization=%ld", (long)self.locationManager.authorizationStatus);
	return self.locationManager.authorizationStatus;
}

- (CLLocation *)currentLocation:(NSTimeInterval)timeout error:(NSError **)error {
	DEBUG_LOG(@"");
	
	// メインスレッドで実行できません。
	if ([NSThread isMainThread]) {
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CouldNotPerformCurrentLocationInMainThread", @"RecordingLocationManager.currentLocation")
		};
		NSError *internalError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:userInfo];
		if (error) {
			*error = internalError;
		}
		return nil;
	}

	// すでに実行中の場合はさらに実行できません。
	if (self.running) {
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CurrentLocationIsRunning", @"RecordingLocationManager.currentLocation")
		};
		NSError *internalError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:userInfo];
		if (error) {
			*error = internalError;
		}
		return nil;
	}
	self.running = YES;
	
	// 現在位置利用の権限があるかを確認します。
	CLAuthorizationStatus authorizationStatus = self.locationManager.authorizationStatus;
	if (authorizationStatus == kCLAuthorizationStatusNotDetermined ||
		authorizationStatus == kCLAuthorizationStatusDenied ||
		authorizationStatus == kCLAuthorizationStatusRestricted) {
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CLLocationManagerAuthorizationStatusIsNotAuthorized", @"RecordingLocationManager.currentLocation")
		};
		NSError *internalError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:userInfo];
		if (error) {
			*error = internalError;
		}
		self.running = NO;
		return nil;
	}

	// 現在位置を取得します。
	NSDate *scanStartTime = [NSDate date];
	while (!self.location && !self.locationError && [[NSDate date] timeIntervalSinceDate:scanStartTime] < timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	[self.locationManager stopUpdatingLocation];
	CLLocation *location = self.location;
	NSError *locationError = self.locationError;
	self.locationManager = nil;
	self.location = nil;
	self.locationError = nil;
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
		self.running = NO;
		return nil;
	}

	// 取得した現在位置を返却します。
	DEBUG_LOG(@"location=%@", location.description);
	self.running = NO;
	return location;
}

/// 現在位置利用の権限が変化した時に呼び出されます。
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
	DEBUG_LOG(@"");

	switch (self.locationManager.authorizationStatus) {
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
