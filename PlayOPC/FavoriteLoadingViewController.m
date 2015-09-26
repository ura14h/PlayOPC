//
//  FavoriteLoadingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "FavoriteLoadingViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "AppFavoriteSetting.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface FavoriteLoadingViewController ()

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableArray *favoriteSettingList; ///< お気に入り設定一覧

@end

#pragma mark -

@implementation FavoriteLoadingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
    [super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// お気に入り設定一覧をクリアします。
	self.favoriteSettingList = [[NSMutableArray alloc] init];
	
	// 画面表示を初期表示します。
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	self.editing = NO;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_favoriteSettingList = nil;
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

	/// お気に入り設定一覧の表示を開始します。
	__weak FavoriteLoadingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		/// お気に入り設定一覧を読込みます。
		NSArray *favoriteSettingList = [AppFavoriteSetting listOfSettings];
		weakSelf.favoriteSettingList = [favoriteSettingList mutableCopy];
		
		// 一覧を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
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
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_DETAIL_LOG(@"");
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);

	return self.favoriteSettingList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteSettingCell" forIndexPath:indexPath];
	NSDictionary *favoriteSetting = self.favoriteSettingList[indexPath.row];
	
	// お気に入り設定の名前を表示します。
	cell.textLabel.text = favoriteSetting[AppFavoriteSettingListNameKey];

	// お気に入り設定の更新日時を表示します。
	NSDate *date = favoriteSetting[AppFavoriteSettingListDateKey];
	NSString *dateText;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSTimeInterval past = [date timeIntervalSinceDate:[NSDate date]];
	if (past < 24 * 60 * 60) {
		[dateFormatter setDateFormat:@"HH:mm:ss"];
		dateText = [dateFormatter stringFromDate:date];
	} else {
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		dateText = [dateFormatter stringFromDate:date];
	}
	cell.detailTextLabel.text = dateText;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	// セル選択を解除します。
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// カメラに設定するお気に入り設定ファイルのパスを取得します。
	NSDictionary *favoriteSetting = self.favoriteSettingList[indexPath.row];
	NSString *filePath = favoriteSetting[AppFavoriteSettingListPathKey];

	// カメラ設定のロードを開始します。
	__weak FavoriteLoadingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 共有ドキュメントフォルダからお気に入り設定を読み込みます。
		AppFavoriteSetting *setting = [AppFavoriteSetting favoriteSettingWithContentsOfFile:filePath];
		if (!setting) {
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingSnapshot", @"FavoriteLoadingViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		
		// スナップショットからカメラの設定を復元します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSArray *exclude = @[
			CameraPropertyWifiCh, // Wi-Fiチャンネルの設定は復元しません。
		];
		if (![camera restoreSnapshotOfSetting:setting.snapshot exclude:exclude error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		
		// カメラ設定のロードが完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 削除操作以外は無視します。
	if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}

	// カメラに設定するお気に入り設定ファイルのパスを取得します。
	NSDictionary *favoriteSetting = self.favoriteSettingList[indexPath.row];
	NSString *filePath = favoriteSetting[AppFavoriteSettingListPathKey];
	
	// お気に入り設定のファイルを削除します。
	if (![AppFavoriteSetting removeFile:filePath]) {
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotDeleteFavoriteSetting", @"FavoriteLoadingViewController.commitEditingStyle") title:NSLocalizedString(@"$title:CouldNotDeleteFavoriteSetting", @"FavoriteLoadingViewController.commitEditingStyle")];
		return;
	}
	
	// お気に入り設定一覧から削除します。
	[self.favoriteSettingList removeObjectAtIndex:indexPath.row];
	
	// 画面表示を更新します。
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -

/// 進捗画面に処理完了を報告します。
- (void)reportBlockFinishedToProgress:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	__block UIImageView *progressImageView;
	dispatch_sync(dispatch_get_main_queue(), ^{
		UIImage *image = [UIImage imageNamed:@"Progress-Checkmark"];
		progressImageView = [[UIImageView alloc] initWithImage:image];
		progressImageView.tintColor = [UIColor whiteColor];
	});
	progress.customView = progressImageView;
	progress.mode = MBProgressHUDModeCustomView;
	[NSThread sleepForTimeInterval:0.5];
}

@end
