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

/// 撮影後確認画像を表示します。
@interface RecImageViewController : UIViewController

@property (strong, nonatomic) UIImage *image; ///< 表示する撮影後確認画像

@end
