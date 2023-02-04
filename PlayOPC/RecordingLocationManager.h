//
//  RecordingLocationManager.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/// 現在位置を管理します。
@interface RecordingLocationManager : NSObject

/// 位置情報の使用許可を要求します。
- (CLAuthorizationStatus)reqeustAuthorization;

/// 現在位置を取得します。
/// メインスレッドから呼び出してはいけません。
- (CLLocation *)currentLocation:(NSTimeInterval)timeout error:(NSError **)error;

@end
