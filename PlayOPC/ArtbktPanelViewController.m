//
//  ArtbktPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/05.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ArtbktPanelViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface ArtbktPanelViewController ()

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSArray *properties; ///< カメラプロパティのリスト
@property (strong, nonatomic) NSMutableDictionary *propertyValues; ///< カメラプロパティ値のリスト

@end

#pragma mark -

@implementation ArtbktPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// プロパティリストを初期表示します。
	NSMutableArray *properties = [[NSMutableArray alloc] init];
	[properties addObject:CameraPropertyBracketPictPopart];
	[properties addObject:CameraPropertyBracketPictFantasicFocus];
	[properties addObject:CameraPropertyBracketPictDaydream];
	[properties addObject:CameraPropertyBracketPictLightTone];
	[properties addObject:CameraPropertyBracketPictRoughMonochrome];
	[properties addObject:CameraPropertyBracketPictToyPhoto];
	[properties addObject:CameraPropertyBracketPictMiniature];
	[properties addObject:CameraPropertyBracketPictCrossProcess];
	[properties addObject:CameraPropertyBracketPictGentleSepia];
	[properties addObject:CameraPropertyBracketPictDramaticTone];
	[properties addObject:CameraPropertyBracketPictLigneClair];
	[properties addObject:CameraPropertyBracketPictPastel];
	[properties addObject:CameraPropertyBracketPictVintage];
	[properties addObject:CameraPropertyBracketPictPartcolor];
	self.properties = properties;
	self.propertyValues = nil;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_properties = nil;
	_propertyValues = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];
	
	if (self.isMovingToParentViewController) {
		[self didStartActivity];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidDisappear:animated];
	
	if (self.isMovingFromParentViewController) {
		[self didFinishActivity];
	}
}

#pragma mark -

/// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

	// カメラプロパティ値リストの構築を開始します。
	__weak ArtbktPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// カメラプロパティ値のリストを取得します。
		AppCamera *camera = GetAppCamera();
		NSMutableSet *properties = [[NSMutableSet alloc] init];
		for (NSString *property in weakSelf.properties) {
			[properties addObject:property];
		}
		NSError *error = nil;
		NSDictionary *propertyValues = [camera cameraPropertyValues:properties error:&error];
		if (!propertyValues) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not get camera properties", nil)];
			return;
		}
		weakSelf.propertyValues = [propertyValues mutableCopy];
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 表示を更新します。
			[weakSelf.tableView reloadData];
		}];
	}];
	
	// ビューコントローラーが活動を開始しました。
	self.startingActivity = YES;
}

/// ビューコントローラーが画面を破棄して活動を完了する時に呼び出されます。
- (void)didFinishActivity {
	DEBUG_LOG(@"");
	
	// すでに活動停止している場合は何もしません。
	if (!self.startingActivity) {
		return;
	}

	// カメラプロパティ値のリストを破棄します。
	self.propertyValues = nil;
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_LOG(@"");
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_LOG(@"");
	
	return self.properties.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	// 表示セルを取得します。
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
	
	// 表示用の文言を取得します。
	AppCamera *camera = GetAppCamera();
	NSString *property = self.properties[indexPath.row];
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];

	// チェックマークのオンオフを判定します。
	BOOL checked = NO;
	NSString *value = self.propertyValues[property];
	if (value) {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^<(.+)/(.+)>$" options:0 error:nil];
		NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
		if (matches.numberOfRanges == 3) {
			NSString *propertyName = [value substringWithRange:[matches rangeAtIndex:1]];
			NSString *propertyValue = [value substringWithRange:[matches rangeAtIndex:2]];
			if ([propertyName isEqualToString:property] && [propertyValue isEqualToString:@"ON"]) {
				checked = YES;
			}
		}
	}
	
	// 表示を更新します。
	cell.textLabel.text = propertyTitle;
	cell.accessoryType = (checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	// 行選択されたカメラプロパティを取得します。
	NSString *property = self.properties[indexPath.row];
	
	// 現在、値の変更が許可されているか確認します。
	AppCamera *camera = GetAppCamera();
	if (![camera canSetCameraProperty:property]) {
		// セルの選択を解除します。
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		// 変更は許されていません。
		[self showAlertMessage:NSLocalizedString(@"The property is prohibited from changing other values.", nil) title:NSLocalizedString(@"Could not set camera property", nil)];
		return;
	}

	// 現在のカメラプロパティ値を取得します。
	NSString *value = self.propertyValues[property];
	BOOL checked = NO;
	if (value) {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^<(.+)/(.+)>$" options:0 error:nil];
		NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
		if (matches.numberOfRanges == 3) {
			NSString *propertyName = [value substringWithRange:[matches rangeAtIndex:1]];
			NSString *propertyValue = [value substringWithRange:[matches rangeAtIndex:2]];
			if ([propertyName isEqualToString:property] && [propertyValue isEqualToString:@"ON"]) {
				checked = YES;
			}
		}
	}
	// 新しいカメラプロパティ値を作成します。(現在値の反転)
	if (checked) {
		value = [NSString stringWithFormat:@"<%@/OFF>", property];
	} else {
		value = [NSString stringWithFormat:@"<%@/ON>", property];
	}
	
	// カメラプロパティ値の変更を開始します。
	__weak ArtbktPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラプロパティ値を変更します。
		NSError *error = nil;
		if (![camera setCameraPropertyValue:property value:value error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not set camera property", nil)];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}];
			return;
		}
		weakSelf.propertyValues[property] = value;
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}];
		
		// カメラプロパティ値の変更が完了しました。
		DEBUG_LOG(@"");
	}];
}

@end
