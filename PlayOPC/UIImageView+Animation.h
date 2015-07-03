//
//  UIImageView+Animation.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/03.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface UIImageView (Animation)

/// 描画モードをテンプレート画像にしたアニメーションを設定します。
- (void)setAnimationTemplateImages:(NSArray *)images;

@end
