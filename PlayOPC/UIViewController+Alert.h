//
//  UIViewController+Alert.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/05.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// ビューコントローラーに警告メッセージ表示の機能を拡張します。
@interface UIViewController (Alert)

/// 警告メッセージを表示します。
- (void)showAlertMessage:(NSString *)message title:(NSString *)title;

@end
