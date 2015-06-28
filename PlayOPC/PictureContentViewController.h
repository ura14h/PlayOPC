//
//  PictureContentViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/14.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@protocol PictureContentViewControllerDelegate;

/// 写真コンテンツを表示します。
@interface PictureContentViewController : UIViewController

@property (weak, nonatomic) id<PictureContentViewControllerDelegate> delegate; ///< コンテンツ表示中に発生した通知を受け取るためのデリゲート
@property (strong, nonatomic) NSDictionary *content; ///< 表示する写真コンテンツ

@end

/// 写真コンテンツ表示中に発生した通知を受け取るためのデリゲートプロトコル。
@protocol PictureContentViewControllerDelegate <NSObject>
@optional

/// 写真コンテンツをカメラ内から削除しました。
- (void)pictureContentViewControllerDidErasePictureContent:(PictureContentViewController *)controller;

@end
