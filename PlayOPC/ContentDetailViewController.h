//
//  ContentDetailViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// コンテンツの詳細情報を表示します。
@interface ContentDetailViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *content; ///< 詳細情報を表示するコンテンツ
@property (strong, nonatomic) NSData *contentData; ///< コンテンツのバイナリデータ

@end
