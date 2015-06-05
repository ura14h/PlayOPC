//
//  AppCameraLog.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

/// カメラキットからのログ出力の履歴を管理します。
/// OLYCameraクラスと同様にこのクラスもシングルトンパターンで扱わなければなりません。
@interface AppCameraLog : NSObject

@property (strong, nonatomic, readonly) NSArray *messages;	///< カメラから出力されたログの履歴

/// ログ履歴をクリアします。
- (BOOL)clearMessages;

@end
