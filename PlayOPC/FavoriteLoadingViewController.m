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
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

static NSString *const FavoriteSettingListNameKey = @"FavoriteSettingListNameKey";
static NSString *const FavoriteSettingListPathKey = @"FavoriteSettingListPathKey";
static NSString *const FavoriteSettingListDateKey = @"FavoriteSettingListDateKey";
static NSString *const FavoriteSettingNameKey = @"FavoriteSettingName";
static NSString *const FavoriteSettingSnapshotKey = @"FavoriteSettingSnapshot";


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

	/// お気に入り設定一覧を読込みます。
	__weak FavoriteLoadingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
		NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *directoryPath = directoryPaths[0];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error = nil;
		NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
		if (!contents) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didStartActivity")];
			return;
		}

		// お気に入り設定のファイルを一覧に加えます。
		NSMutableArray *favoriteSettingList = [[NSMutableArray alloc] init];
		[contents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger index, BOOL *stop) {
			// お気に入り設定のファイル名は"Favorite-YYYYMMDDHHMMSS.plist"です。
			NSString *filename = [[path lastPathComponent] lowercaseString];
			if (![filename hasPrefix:@"favorite-"] ||
				![filename hasSuffix:@".plist"]) {
				return;
			}
			
			// 一覧で使用する要素を取得します。
			NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
			NSError *error = nil;
			NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
			NSDate *fileDate = fileAttributes[NSFileModificationDate];
			NSDictionary *favoriteSetting = [NSDictionary dictionaryWithContentsOfFile:filePath];
			if (!favoriteSetting[FavoriteSettingNameKey] ||
				!favoriteSetting[FavoriteSettingSnapshotKey]) {
				return;
			}
			NSString *favoriteName = favoriteSetting[FavoriteSettingNameKey];
			if (favoriteName.length == 0) {
				return;
			}
			
			// 取得した要素を持つ辞書を一覧に加えます。
			NSDictionary *favoriteListItem = @{
				FavoriteSettingListNameKey: favoriteName,
				FavoriteSettingListPathKey: filePath,
				FavoriteSettingListDateKey: fileDate,
			};
			[favoriteSettingList addObject:favoriteListItem];
		}];
		DEBUG_LOG(@"favoriteSettingList=%@", favoriteSettingList);
		weakSelf.favoriteSettingList = favoriteSettingList;
		
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
	cell.textLabel.text = favoriteSetting[FavoriteSettingListNameKey];

	// お気に入り設定の更新日時を表示します。
	NSDate *date = favoriteSetting[FavoriteSettingListDateKey];
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
	NSString *filePath = favoriteSetting[FavoriteSettingListPathKey];

	// カメラ設定のロードを開始します。
	__weak FavoriteLoadingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 共有ドキュメントフォルダから設定のスナップショットファイルを読み込みます。
		NSDictionary *favoriteSetting = [NSDictionary dictionaryWithContentsOfFile:filePath];
		if (!favoriteSetting[FavoriteSettingNameKey] ||
			!favoriteSetting[FavoriteSettingSnapshotKey]) {
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingFile", @"FavoriteLoadingViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		NSString *favoriteName = favoriteSetting[FavoriteSettingNameKey];
		if (favoriteName.length == 0) {
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingName", @"FavoriteLoadingViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		NSDictionary *snapshot = favoriteSetting[FavoriteSettingSnapshotKey];
		if (!snapshot) {
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotReadFavoriteSettingSnapshot", @"FavoriteLoadingViewController.didSelectRowAtIndexPath") title:NSLocalizedString(@"$title:CouldNotLoadFavoriteSetting", @"FavoriteLoadingViewController.didSelectRowAtIndexPath")];
			return;
		}
		
		// スナップショットからカメラの設定を復元します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSArray *exclude = @[
			CameraPropertyWifiCh, // Wi-Fiチャンネルの設定は復元しません。
		];
		if (![camera restoreSnapshotOfSetting:snapshot exclude:exclude error:&error]) {
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
	NSString *filePath = favoriteSetting[FavoriteSettingListPathKey];
	
	// お気に入り設定のファイルを削除します。
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	if (![fileManager removeItemAtPath:filePath error:&error]) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotDeleteFavoriteSetting", @"FavoriteLoadingViewController.commitEditingStyle")];
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
