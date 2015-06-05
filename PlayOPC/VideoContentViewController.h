//
//  VideoContentViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@protocol VideoContentViewControllerDelegate;

/// 動画コンテンツを表示します。
@interface VideoContentViewController : UIViewController

@property (weak, nonatomic) id<VideoContentViewControllerDelegate> delegate; ///< コンテンツ表示中に発生した通知を受け取るためのデリゲート
@property (strong, nonatomic) NSDictionary *content; ///< 表示する動画コンテンツ

@end

/// 動画コンテンツ表示中に発生した通知を受け取るためのデリゲートプロトコル。
@protocol VideoContentViewControllerDelegate <NSObject>
@optional

/// 新しい動画コンテンツをカメラ内に追加しました。
- (void)videoContentViewControllerDidAddNewVideoContent:(VideoContentViewController *)controller;

@end
