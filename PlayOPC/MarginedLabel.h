//
//  MarginedLabel.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/08/02.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// 表示文言の周りに余白を持つラベル。
@interface MarginedLabel : UILabel

@property (nonatomic) UIEdgeInsets textMargins; ///< 余白の大きさ

@end
