//
//  ItemSelectionViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ItemSelectionViewController.h"

NSString *const ItemSelectionViewItemTitleKey = @"ItemSelectionViewItemTitleKey";
NSString *const ItemSelectionViewItemImageKey = @"ItemSelectionViewItemImageKey";
NSString *const ItemSelectionViewItemValueKey = @"ItemSelectionViewItemValueKey";

@interface ItemSelectionViewController ()

@end

#pragma mark -

@implementation ItemSelectionViewController

#pragma mark -

- (instancetype)initWithCoder:(NSCoder *)decoder {
	DEBUG_LOG(@"");
	
	self = [super initWithCoder:decoder];
	if (!self) {
		return nil;
	}

	_items = nil;
	_itemCellIdentifier = nil;
	_selectedItemIndex = NSNotFound;
	
	return self;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	_items = nil;
	_itemCellIdentifier = nil;
	_itemSelectionDeleage = nil;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_DETAIL_LOG(@"");
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);
	
	if (!self.itemCellIdentifier) {
		DEBUG_LOG(@"itemCellIdentifier is not configured.");
		return 0;
	}
	if (self.items) {
		DEBUG_LOG(@"items.count=%ld", (long)self.items.count);
		return self.items.count;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 表示セルを取得します。
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.itemCellIdentifier forIndexPath:indexPath];
	id item = self.items[indexPath.row];
	
	// 表示用の文言を取得します。
	NSString *title = nil;
	if ([item isKindOfClass:[NSDictionary class]]) {
		title = item[ItemSelectionViewItemTitleKey];
	} else if ([item isKindOfClass:[NSString class]]) {
		title = item;
	}
	
	// 表示用の画像を取得します。
	UIImage *image = nil;
	if ([item isKindOfClass:[NSDictionary class]]) {
		image = item[ItemSelectionViewItemImageKey];
	}
	
	// 表示を更新します。
	cell.textLabel.text = NSLocalizedString(title, nil);
	cell.imageView.image = image;
	if (indexPath.row == self.selectedItemIndex) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// すでにチェックマークが付いているセルを選択した場合は何もしません。
	if (indexPath.row == self.selectedItemIndex) {
		// セルの選択を解除します。
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		DEBUG_LOG(@"The row is already selected.");
		return;
	}
	
	// チェックマークを新しく選択した値に付け直します。
	NSUInteger oldIndex = self.selectedItemIndex;
	NSArray *indexPaths;
	if (oldIndex == NSNotFound) {
		indexPaths = @[indexPath];
	} else {
		NSIndexPath *newIndexPath = indexPath;
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
		indexPaths = @[newIndexPath, oldIndexPath];
	}
	self.selectedItemIndex = indexPath.row;
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	
	// 選択の変更を通知します。
	if (self.itemSelectionDeleage) {
		if ([self.itemSelectionDeleage respondsToSelector:@selector(itemSelectionViewController:didSelectedItemIndex:)]) {
			[self.itemSelectionDeleage itemSelectionViewController:self didSelectedItemIndex:self.selectedItemIndex];
		}
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
