//
//  PlaybackViewCell.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// コンテンツ一覧の表示セル。
@interface PlaybackViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage; ///< コンテンツのサムネイル画像
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel; ///< コンテンツのファイル名
@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel; ///< コンテンツの作成年月日
@property (weak, nonatomic) IBOutlet UILabel *filesizeLabel; ///< コンテンツのファイルサイズ
@property (weak, nonatomic) IBOutlet UILabel *attributesLabel; ///< コンテンツの属性

@end
