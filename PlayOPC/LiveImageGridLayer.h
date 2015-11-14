//
//  LiveImageGridLayer.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/11/14.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <QuartzCore/QuartzCore.h>
#import <UIKIT/UIKit.h>

/// グリッド分割線を表示するレイヤーです。
@interface LiveImageGridLayer : CALayer

@property (assign, nonatomic) NSUInteger gridBands; ///< グリッドの分割数
@property (assign, nonatomic) CGFloat gridLineWidth; ///< グリッド線の幅
@property (strong, nonatomic) UIColor *gridLineColor; ///< グリッド線の色

@end
