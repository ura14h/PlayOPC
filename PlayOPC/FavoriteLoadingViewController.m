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

	// 不要な行を表示しないようにします。
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
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
	double sinceSec = -[date timeIntervalSinceNow];
	double sinceMin = round(sinceSec / 60.0);
	double sinceHour = round(sinceSec / 60.0 / 60.0);
	double sinceDay = round(sinceSec / 60.0 / 60.0 / 24.0);
	NSString *dateText;
	if (sinceSec < 1.25) {
		dateText = NSLocalizedString(@"$cell:SavingFavoriteSettingIsNow", @"FavoriteLoadingViewController.cellForRowAtIndexPath");
	} else if (sinceMin < 1.25) {
		dateText = [NSString stringWithFormat:NSLocalizedString(@"$cell:SavingFavoriteSettingIsSecondsAgo(%ld)", @"FavoriteLoadingViewController.cellForRowAtIndexPath"), (long)sinceSec];
	} else if (sinceHour < 1.25) {
		dateText = [NSString stringWithFormat:NSLocalizedString(@"$cell:SavingFavoriteSettingIsMinutesAgo(%ld)", @"FavoriteLoadingViewController.cellForRowAtIndexPath"), (long)sinceMin];
	} else if (sinceDay < 1.25) {
		dateText = [NSString stringWithFormat:NSLocalizedString(@"$cell:SavingFavoriteSettingIsHoursAgo(%ld)", @"FavoriteLoadingViewController.cellForRowAtIndexPath"), (long)sinceHour];
	} else {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingFile", @"FavoriteLoadingViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSDictionary *optimizedSnapshot = [camera optimizeSnapshotOfSetting:setting.snapshot error:&error];
		if (!optimizedSnapshot) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		
		// 気に入り設定のスナップショットからカメラの設定を復元します。
		NSArray *exclude = @[
			CameraPropertyWifiCh, // Wi-Fiチャンネルの設定は復元しません。
		];
		[weakSelf reportBlockSettingToProgress:progressView];
		if (![camera restoreSnapshotOfSetting:optimizedSnapshot exclude:exclude fallback:NO error:&error]) {
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
	
	// MARK: セルを左スワイプした時にアクションを表示するためには、このメソッドを空っぽの実装で用意しなければなりません。

}

/// セルを左スワイプした時に表示されるアクション群を返します。
/// 編集モードに入った時にも呼び出されます。
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	// 削除アクションを構築します。
	__weak FavoriteLoadingViewController *weakSelf = self;
	NSString *deleteActionTitle = NSLocalizedString(@"$title:DeleteFavroiteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath");
	UITableViewRowActionStyle deleteActionStyle = UITableViewRowActionStyleDestructive;
	void (^deleteActionHandler)(UITableViewRowAction *action, NSIndexPath *indexPath) = ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		
		// カメラに設定するお気に入り設定ファイルのパスを取得します。
		NSDictionary *favoriteSetting = weakSelf.favoriteSettingList[indexPath.row];
		NSString *filePath = favoriteSetting[AppFavoriteSettingListPathKey];
		
		// お気に入り設定の共有を開始します。
		[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
			DEBUG_LOG(@"weakSelf=%p", weakSelf);

			// お気に入り設定のファイルを削除します。
			if (![AppFavoriteSetting removeFile:filePath]) {
				[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotDeleteFavoriteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotDeleteFavoriteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath")];
				return;
			}
			
			// お気に入り設定一覧から削除します。
			[weakSelf.favoriteSettingList removeObjectAtIndex:indexPath.row];

			// 画面表示を更新します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			}];
		}];
	};
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:deleteActionStyle title:deleteActionTitle handler:deleteActionHandler];

	// 共有アクションを構築します。
	NSString *shareActionTitle = NSLocalizedString(@"$title:ShareFavroiteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath");
	UITableViewRowActionStyle shareActionStyle = UITableViewRowActionStyleNormal;
	void (^shareActionHandler)(UITableViewRowAction *action, NSIndexPath *indexPath) = ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		
		// カメラに設定するお気に入り設定ファイルのパスを取得します。
		NSDictionary *favoriteSetting = self.favoriteSettingList[indexPath.row];
		NSString *filePath = favoriteSetting[AppFavoriteSettingListPathKey];
		
		// お気に入り設定の共有を開始します。
		[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
			DEBUG_LOG(@"weakSelf=%p", weakSelf);

			// 共有ドキュメントフォルダからお気に入り設定を読み込みます。
			AppFavoriteSetting *setting = [AppFavoriteSetting favoriteSettingWithContentsOfFile:filePath];
			if (!setting) {
				[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingFile", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotShareFavoriteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath")];
				return;
			}
			AppCamera *camera = GetAppCamera();
			NSError *error = nil;
			NSDictionary *optimizedSnapshot = [camera optimizeSnapshotOfSetting:setting.snapshot error:&error];
			if (!optimizedSnapshot) {
				[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingFile", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotShareFavoriteSetting", @"FavoriteLoadingViewController.editActionsForRowAtIndexPath")];
				return;
			}
			
			// お気に入り設定を共有できるようにフォーマット変換します。
			NSString *snapshotText = [optimizedSnapshot description];
			DEBUG_LOG(@"snapshotText=%@", snapshotText);
			
			// 共有ダイアログを表示します。
			// 一番最初だけ表示されるまでとても時間がかかるようです。
			NSArray *shareItems = @[ snapshotText ];
			UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
			shareController.popoverPresentationController.sourceView = weakSelf.view;
			CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
			[weakSelf.tableView convertRect:cellRect toView:weakSelf.view];
			shareController.popoverPresentationController.sourceRect = cellRect;
			shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
				DEBUG_LOG(@"sharing completed.");
			};
			
			// 画面表示を更新します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf presentViewController:shareController animated:YES completion:nil];
			}];
		}];
	};
	UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:shareActionStyle title:shareActionTitle handler:shareActionHandler];

	// 左スワイプで使用できるアクションを返します。
	return @[deleteAction, shareAction];
}

#pragma mark -

/// 進捗画面にカメラ設定中を報告します。
- (void)reportBlockSettingToProgress:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	__block UIImageView *progressImageView;
	dispatch_sync(dispatch_get_main_queue(), ^{
		UIImage *image = [UIImage imageNamed:@"Progress-Setting"];
		progressImageView = [[UIImageView alloc] initWithImage:image];
		progressImageView.tintColor = [UIColor whiteColor];
		progressImageView.alpha = 0.75;
	});
	progress.customView = progressImageView;
	progress.mode = MBProgressHUDModeCustomView;
	
	// 回転アニメーションを付け加えます。
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	animation.toValue = @(0.0);
	animation.fromValue = @(M_PI * -2.0);
	animation.duration = 4.0;
	animation.repeatCount = HUGE_VALF;
	dispatch_sync(dispatch_get_main_queue(), ^{
		[progressImageView.layer addAnimation:animation forKey:nil];
	});
}

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
