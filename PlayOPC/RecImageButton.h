//
//  RecImageButton.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/07.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// カメラのレックビュー(撮影後確認画像)がサムネイル表示されるボタン。
@interface RecImageButton : UIButton

/// ボタン画像を設定します。
- (void)setImage:(UIImage *)image;

@end
