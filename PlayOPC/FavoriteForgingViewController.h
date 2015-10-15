//
//  FavoriteForgingViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/10/15.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// コンテンツ情報をお気に入りの設定になんとか変換して保存します。
@interface FavoriteForgingViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *content; ///< コンテンツ情報(コンテンツ一覧から得た項目)
@property (strong, nonatomic) NSDictionary *information; ///< コンテンツ情報(コンテンツ情報取得から得た項目)
@property (strong, nonatomic) NSDictionary *metadata; ///< コンテンツのメタデータ

@end
