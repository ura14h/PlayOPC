//
//  FavoriteSavingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "FavoriteSavingViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

static NSString *const FavoriteSettingNameKey = @"FavoriteSettingName";
static NSString *const FavoriteSettingSnapshotKey = @"FavoriteSettingSnapshot";


@interface FavoriteSavingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *favoriteSettingNameText;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か

@end

#pragma mark -

@implementation FavoriteSavingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// 画面表示を初期表示します。
	self.favoriteSettingNameText.text = @"";
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];
	
	if (self.isMovingToParentViewController) {
		[self didStartActivity];
	}

	// キーボードは常に開いておきます。
	[self.favoriteSettingNameText becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidDisappear:animated];
	
	if (self.isMovingFromParentViewController) {
		[self didFinishActivity];
	}
}

#pragma mark -

// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

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

/// キーボードでリターンキーをタップした時に呼び出されます。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DEBUG_LOG(@"textField=%@", textField);
	
	// 保存ボタンと同じ動作をします。
	[self didTapSaveButton:nil];

	return YES;
}

#pragma mark -

/// 保存ボタンがタップされた時に呼び出されます。
- (IBAction)didTapSaveButton:(UIBarButtonItem *)sender {
	DEBUG_LOG(@"");
	
	// 名前が未入力の場合は無視します。
	NSString *nameText = self.favoriteSettingNameText.text;
	NSString *name = [nameText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (name.length == 0) {
		return;
	}

	// キーボードを閉じます。
	[self.favoriteSettingNameText resignFirstResponder];
	
	// 現在のカメラ設定をお気に入りとして保存します。
	__weak FavoriteSavingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 現在のカメラ設定のスナップショットを作成します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSDictionary *snapshot = [camera createSnapshotOfSetting:&error];
		if (!snapshot) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not save favorite setting", nil)];
			return;
		}
		
		// 取得したカメラプロパティの設定値を共有ドキュメントフォルダのファイルとして保存します。
		NSDictionary *favoriteSetting = @{
			FavoriteSettingNameKey: name,
			FavoriteSettingSnapshotKey: snapshot,
		};
		NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *directoryPath = directoryPaths[0];
		NSString *fileName;
		{
			// お気に入り設定のファイル名は"Favorite-YYYYMMDDHHMMSS.plist"です。
			NSDate *timestamp = [NSDate date];
			NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
			[timestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
			[timestampFormatter setDateFormat:@"yyyyMMddHHmmss"];
			fileName = [NSString stringWithFormat:@"Favorite-%@.plist", [timestampFormatter stringFromDate:timestamp]];
		}
		NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
		DEBUG_LOG(@"filePath=%@", filePath);
		DEBUG_LOG(@"fileContent=%@", snapshot);
		if (![favoriteSetting writeToFile:filePath atomically:YES]) {
			[weakSelf showAlertMessage:NSLocalizedString(@"Could not write camera setting to file. The content of file might be lost.", nil) title:NSLocalizedString(@"Could not save favorite setting", nil)];
			return;
		}

		// 前の画面に戻ります。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[self.navigationController popViewControllerAnimated:YES];
		}];
		
		// カメラ設定をセーブが完了しました。
		DEBUG_LOG(@"");
	}];
}

@end
