//
//  UITableViewController+Cell.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "UITableViewController+Cell.h"

@implementation UITableViewController (Cell)

- (void)tableViewCellAtRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld, enabled=%@", (long)indexPath.row, (enabled ? @"YES" : @"NO"));

	UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
	[self tableViewCell:cell enabled:enabled];
}

- (void)tableViewCell:(UITableViewCell *)cell enabled:(BOOL)enabled {
	DEBUG_DETAIL_LOG(@"enabled=%@", (enabled ? @"YES" : @"NO"));

	// セルの要素に有効無効を設定します。
	cell.userInteractionEnabled = enabled;
	cell.textLabel.enabled = enabled;
	cell.detailTextLabel.enabled = enabled;
}

@end
