//
//  LiveImageOverallView.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/10/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// ライブビュー拡大している表示領域がファインダー全体に対してどこなのかを表示します。
@interface LiveImageOverallView : UIView

@property (assign, nonatomic) CGSize overallViewSize; ///< 全体のサイズ(アスペクト比として参照します)
@property (assign, nonatomic) CGRect displayAreaRect; ///< ライブビュー拡大している表示領域
@property (assign, nonatomic) UIImageOrientation orientation; ///< カメラが傾いている方向

/// ライブビュー拡大している表示領域を設定します。
- (void)setDisplayAreaRect:(CGRect)rect animated:(BOOL)animated;

@end
