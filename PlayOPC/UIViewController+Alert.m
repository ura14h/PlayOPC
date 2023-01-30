//
//  UIViewController+Alert.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/05.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

- (void)showAlertMessage:(NSString *)message title:(NSString *)title {
	[self showAlertMessage:message title:title okHandler:nil cancelHandler:nil];
}

- (void)showAlertMessage:(NSString *)message title:(NSString *)title handler:(void (^)(UIAlertAction *action))handler {
	[self showAlertMessage:message title:title okHandler:handler cancelHandler:nil];
}

- (void)showAlertMessage:(NSString *)message title:(NSString *)title okHandler:(void (^)(UIAlertAction *action))okHandler cancelHandler:(void (^)(UIAlertAction *action))cancelHandler {
	DEBUG_DETAIL_LOG(@"message=%@, title=%@", message, title);
	
	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak UIViewController *weakSelf = self;
		dispatch_async(dispatch_get_main_queue(), ^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf showAlertMessage:message title:title okHandler:okHandler cancelHandler:cancelHandler];
		});
		return;
	}
	
	// 警告メッセージを表示します。
	NSString *okActionTitle = NSLocalizedString(@"$title:OK", @"UIViewController.showAlertMessage");
	NSString *cancelActionTitle = NSLocalizedString(@"$title:Cancel", @"UIViewController.showAlertMessage");
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.sourceRect = self.view.bounds;
	alertController.popoverPresentationController.permittedArrowDirections = 0;
	if (okHandler || (okHandler == nil && cancelHandler == nil)) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:okActionTitle style:UIAlertActionStyleDefault handler:okHandler];
		[alertController addAction:action];
	}
	if (cancelHandler) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:cancelHandler];
		[alertController addAction:action];
	}
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
