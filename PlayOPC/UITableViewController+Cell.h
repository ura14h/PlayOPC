//
//  UITableViewController+Cell.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// テーブルビューコントローラーにセル有効無行の機能を拡張します。
@interface UITableViewController (Cell)

/// 指定されたインデックスのテーブルビューセルの有効/無効を設定します。
- (void)tableViewCellAtRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled;

/// 指定されたテーブルビューセルの有効/無効を設定します。
- (void)tableViewCell:(UITableViewCell *)cell enabled:(BOOL)enabled;

@end
