//
//  UIViewController+Threading.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/11.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

/// ビューコントローラーに処理ブロックの並列実行と進捗表示の機能を拡張します。
@interface UIViewController (Threading)

/// 処理ブロックをメインスレッド以外で実行して呼び出したスレッドで実行完了を待ち合わせします。
/// dispatch_sync(dispatch_get_global_queue(), block)のシュガーシンタックスです。
- (void)executeSynchronousBlock:(void (^)(void))block;

/// 処理ブロックをメインスレッド以外で非同期に実行します。
/// dispatch_async(dispatch_get_global_queue(), block)のシュガーシンタックスです。
- (void)executeAsynchronousBlock:(void (^)(void))block;

/// 処理ブロックをメインスレッドで非同期に実行します。
/// dispatch_async(dispatch_get_main_queue(), block)のシュガーシンタックスです。
- (void)executeAsynchronousBlockOnMainThread:(void (^)(void))block;

// 進捗表示用のビューを表示します。
- (void)showProgress:(BOOL)animated;

// 進捗表示用のビューを消去します。
- (void)hideProgress:(BOOL)animated;

/// 進捗表示ビューを表示しながら、指定された処理ブロックを実行します。
- (void)showProgress:(BOOL)animated whileExecutingBlock:(void (^)(MBProgressHUD *progressView))block;

@end
