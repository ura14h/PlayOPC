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

- (void)executeSynchronousBlock:(void (^)())block {
	DEBUG_DETAIL_LOG(@"");

	/// メインスレッド以外で処理ブロックを実行して呼び出したスレッドで実行完了を待ち合わせします。
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)executeAsynchronousBlock:(void (^)())block {
	DEBUG_DETAIL_LOG(@"");

	/// メインスレッド以外で非同期に処理ブロックを実行します。
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)executeAsynchronousBlockOnMainThread:(void (^)())block {
	DEBUG_DETAIL_LOG(@"");
	
	/// メインスレッドで非同期に処理ブロックを実行します。
	dispatch_async(dispatch_get_main_queue(), ^{
		DEBUG_DETAIL_LOG(@"");
		block();
	});
}

- (void)showProgress:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UIWindow *window = delegate.window;
	[MBProgressHUD showHUDAddedTo:window animated:YES];
}

- (void)hideProgress:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UIWindow *window = delegate.window;
	[MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)hideAllProgresses:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UIWindow *window = delegate.window;
	[MBProgressHUD hideAllHUDsForView:window animated:animated];
}

- (void)showProgress:(BOOL)animated whileExecutingBlock:(void (^)(MBProgressHUD *progressView))block {
	DEBUG_DETAIL_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));

	// 進捗表示用のビューを作成します。
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UIWindow *window = delegate.window;
	MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithWindow:window];
	progressHUD.removeFromSuperViewOnHide = YES;

	// ビューを最前面に表示して処理ブロックを実行開始します。
	void (^progressBlock)() = ^{
		if (block) {
			block(progressHUD);
		}
	};
	[window addSubview:progressHUD];
	[progressHUD showAnimated:YES whileExecutingBlock:progressBlock];
}

@end
