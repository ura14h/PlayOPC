//
//  RecImageViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/07.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@protocol RecImageViewControllerControllerDelegate;

/// 撮影後確認画像を表示します。
@interface RecImageViewController : UIViewController

@property (weak, nonatomic) id<RecImageViewControllerControllerDelegate> delegate; ///< 撮影後確認画像表示中に発生した通知を受け取るためのデリゲート
@property (strong, nonatomic) UIImage *latestRecImage; ///< 表示する'撮影後確認画像'

@end

/// 撮影後確認画像表示中に発生した通知を受け取るためのデリゲートプロトコル。
@protocol RecImageViewControllerControllerDelegate <NSObject>
@optional

/// 撮影後確認画像を削除しました。
- (void)recImageViewControllerDidEraseImage:(RecImageViewController *)controller;

@end
