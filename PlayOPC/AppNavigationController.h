//
//  AppNavigationController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/06.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

extern NSString *const AppDidChangeStatusBarOrientationNotification; ///< アプリの画面が回転した時の通知名

/// アプリの中核となるナビゲーションコントローラー。
/// 合わせて、Auto Layoutでの画面サイズの扱いがiPhoneとiPadで異なるのを吸収します。
@interface AppNavigationController : UINavigationController

@end
