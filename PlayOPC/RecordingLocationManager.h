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

@interface RecordingLocationManager : NSObject

@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy; ///< 位置データの精度
@property(assign, nonatomic) CLLocationDistance distanceFilter; ///< 位置を更新させるために移動しなければならない最小の距離

/// 現在位置を取得します。
/// メインスレッドから呼び出してはいけません。
- (CLLocation *)currentLocation:(NSTimeInterval)timeout error:(NSError **)error;

@end
