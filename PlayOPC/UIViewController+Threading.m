//
//  UIViewController+Threading.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/11.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "UIViewController+Threading.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@implementation UIViewController (Threading)

- (void)executeSynchronousBlock:(void (^)(void))block {
	DEBUG_DETAIL_LOG(@"");

	/// メインスレッド以外で処理ブロックを実行して呼び出したスレッドで実行完了を待ち合わせします。
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)executeAsynchronousBlock:(void (^)(void))block {
	DEBUG_DETAIL_LOG(@"");

	/// メインスレッド以外で非同期に処理ブロックを実行します。
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)executeAsynchronousBlockOnMainThread:(void (^)(void))block {
	DEBUG_DETAIL_LOG(@"");
	
	/// メインスレッドで非同期に処理ブロックを実行します。
	dispatch_async(dispatch_get_main_queue(), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)showProgress:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	UIWindow *window = GetAppDelegate().window;
	[MBProgressHUD showHUDAddedTo:window animated:YES];
}

- (void)hideProgress:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	UIWindow *window = GetAppDelegate().window;
	[MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)showProgress:(BOOL)animated whileExecutingBlock:(void (^)(MBProgressHUD *progressView))block {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));

	// 進捗表示用のビューを作成します。
	UIWindow *window = GetAppDelegate().window;
	MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:window animated:animated];
	progressHUD.removeFromSuperViewOnHide = YES;

	/// メインスレッド以外で非同期に処理ブロックを実行します。
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEBUG_DETAIL_LOG(@"");
		block(progressHUD);
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:window animated:animated];
		});
	});
}

@end
