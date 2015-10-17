//
//  CameraPropertyValueSelectionViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/11.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CameraPropertyValueSelectionViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface CameraPropertyValueSelectionViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate>

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書

@end

#pragma mark -

@implementation CameraPropertyValueSelectionViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	
	// 表示セルの識別子を初期化します。
	self.itemCellIdentifier = @"CameraPropertyValueCell";
	
	// 表示タイトルを設定します。
	AppCamera *camera = GetAppCamera();
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:self.property];
	self.title = propertyTitle;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_cameraPropertyObserver = nil;
	_property = nil;
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

	// カメラプロパティ値のリスト表示を開始します。
	__weak CameraPropertyValueSelectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラプロパティ値のリストを取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSArray *values = [camera cameraPropertyValueList:weakSelf.property error:&error];
		if (!values) {
			// カメラプロパティ値のリストを取得できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotGetCameraPropertyValueList", @"CameraPropertyValueSelectionViewController.didStartActivity")];
			return;
		}
		NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:values.count];
		for (NSString *value in values) {
			NSString *valueTitle = [camera cameraPropertyValueLocalizedTitle:value];
			UIImage *valueImage = [self imageOfCameraPropertyValue:value];
			NSDictionary *item;
			if (valueImage) {
				item = @{
					ItemSelectionViewItemTitleKey: valueTitle,
					ItemSelectionViewItemImageKey: valueImage,
					ItemSelectionViewItemValueKey: value,
				};
			} else {
				item = @{
					ItemSelectionViewItemTitleKey: valueTitle,
					ItemSelectionViewItemValueKey: value,
				};
			}
			[items addObject:item];
		}
		weakSelf.items = items;
		
		// 現在設定されているカメラプロパティ値を取得します。
		NSString *value = [camera cameraPropertyValue:weakSelf.property error:&error];
		if (!value) {
			// 現在設定されているカメラプロパティ値を取得できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotGetCameraPropertyValue", @"CameraPropertyValueSelectionViewController.didStartActivity")];
			return;
		}
		weakSelf.selectedItemIndex = [values indexOfObject:value];
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf.tableView reloadData];

			// カメラプロパティ値のリストが一つもない場合はここで終了します。
			if (weakSelf.items.count == 0) {
				return;
			}
			
			// 選択されているカメラプロパティ値がないようであれば先頭にスクロールしておきます。
			if (weakSelf.selectedItemIndex == NSNotFound) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				[weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
				return;
			}
			
			// 選択されているカメラプロパティ値を表示領域の中央になるようにスクロールします。
			NSUInteger row = weakSelf.selectedItemIndex;
#if 0 // iOS9では正しく動作するようになった気がします。
			if (weakSelf.navigationController.navigationController) {
				// MARK: ナビゲーションコントローラーが入れ子になっているレイアウトでは、UITableViewScrollPositionMiddleでを指定してスクロールすると表示領域の計算に間違うようです。
				// FIXME: 使いにくいので、暫定処置として特殊なレイアウトの時は1つ上の行を指定してスクロールします。
				if (row > 0) {
					row--;
				}
			}
#endif
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
			[weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
			[weakSelf.tableView flashScrollIndicators];
		}];
		
		// カメラプロパティ値のリスト表示が完了しました。
		DEBUG_LOG(@"");
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

	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	// すでにチェックマークが付いているセルを選択した場合は何もしません。
	if (indexPath.row == self.selectedItemIndex) {
		// セルの選択を解除します。
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		DEBUG_LOG(@"The row is already selected.");
		return;
	}

	// 現在、値の変更が許可されているか確認します。
	AppCamera *camera = GetAppCamera();
	if ([camera cameraActionStatus] != AppCameraActionStatusReady) {
		// セルの選択を解除します。
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		// 変更は許されていません。
		[self showAlertMessage:NSLocalizedString(@"$desc:CanNotSetCameraPropertyInTaking", @"CameraPropertyValueSelectionViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CanNotSetCameraPropertyInTaking", @"CameraPropertyValueSelectionViewController.didSelectRowAtIndexPath")];
		return;
	}
	if (![camera canSetCameraProperty:self.property]) {
		// セルの選択を解除します。
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		// 変更は許されていません。
		[self showAlertMessage:NSLocalizedString(@"$desc:CanNotSetCameraProperty", @"CameraPropertyValueSelectionViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CanNotSetCameraProperty", @"CameraPropertyValueSelectionViewController.didSelectRowAtIndexPath")];
		return;
	}
	
	// カメラプロパティ値の変更を開始します。
	__weak CameraPropertyValueSelectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// カメラプロパティ値を変更します。
		NSDictionary *selectedItem = weakSelf.items[indexPath.row ];
		NSString *value = selectedItem[ItemSelectionViewItemValueKey];
		NSError *error = nil;
		if (![camera setCameraPropertyValue:weakSelf.property value:value error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotSetCameraPropertyValue", @"CameraPropertyValueSelectionViewController.didSelectRowAtIndexPath")];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}];
			return;
		}

		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf superView:tableView didSelectRowAtIndexPath:indexPath];
		}];
		
		// カメラプロパティ値の変更が完了しました。
		DEBUG_LOG(@"");
	}];
}

#pragma mark -

/// スーパークラスのメソッドをブロック内から呼び出すためのヘルパーメソッドです。
- (void)superView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

/// カメラプロパティ値に対応する画像を取得します。
- (UIImage *)imageOfCameraPropertyValue:(NSString *)value {
	DEBUG_DETAIL_LOG(@"value=%@", value);
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^<(.+)/(.+)>$" options:0 error:nil];
	NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
	if (matches.numberOfRanges != 3) {
		return nil;
	}
	NSString *propertyName = [value substringWithRange:[matches rangeAtIndex:1]];
	NSString *propertyValue = [value substringWithRange:[matches rangeAtIndex:2]];
	NSString *fileName = [NSString stringWithFormat:@"CameraProperty-%@-%@.png", propertyName, propertyValue];
	UIImage *image = [UIImage imageNamed:fileName];
	
	return image;
}

@end
