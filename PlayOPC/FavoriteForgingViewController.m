//
//  FavoriteForgingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/10/15.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "FavoriteForgingViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "AppFavoriteSetting.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface FavoriteForgingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *favoriteSettingNameText;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か

@end

#pragma mark -

@implementation FavoriteForgingViewController

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
	
	_content = nil;
	_information = nil;
	_metadata = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];

	// タイトルを設定します。
	self.title = self.content[OLYCameraContentListFilenameKey];
	
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
	
	// コンテンツ情報をお気に入り設定として保存します。
	__weak FavoriteForgingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// TODO: カメラ設定のスナップショットを捏造します。
		NSDictionary *snapshot = nil;
		
		// 捏造したカメラプロパティの設定値を共有ドキュメントフォルダのファイルとして保存します。
		AppFavoriteSetting *setting = [[AppFavoriteSetting alloc] initWithSnapshot:snapshot name:name];
		if (![setting writeToFile]) {
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotWriteFavoriteSettingFile", @"FavoriteForgingViewController.didTapSaveButton") title:NSLocalizedString(@"$title:CouldNotSaveFavoriteSetting", @"FavoriteForgingViewController.didTapSaveButton")];
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
