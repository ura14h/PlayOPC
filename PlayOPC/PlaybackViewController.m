//
//  PlaybackViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "PlaybackViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "PlaybackViewCell.h"
#import "PictureContentViewController.h"
#import "VideoContentViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

static NSString *const ContentThumbnailImageKey = @"image";	///< コンテンツキャッシュ要素のサムネイル画像データ
static NSString *const ContentThumbnailMetadataKey = @"metadata"; ///< コンテンツキャッシュ要素のサムネイルメタデータ

@interface PlaybackViewController () <PictureContentViewControllerDelegate, VideoContentViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tableviewFooterLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *latestButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unprotectButton;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (assign, nonatomic) OLYCameraRunMode previousRunMode; ///< この画面に遷移してくる前のカメラ実行モード
@property (assign, nonatomic) BOOL needsDownloadContentList; ///< コンテンツ一覧をダウンロードする必要があるか否か
@property (strong, nonatomic) NSMutableArray *contentList; ///< コンテンツ一覧
@property (strong, nonatomic) NSCache *contentThumbnailCache; ///< コンテンツキャッシュ

@end

#pragma mark -

@implementation PlaybackViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	self.previousRunMode = OLYCameraRunModeUnknown;
	
	// コンテンツ一覧とキャッシュをクリアします。
	self.needsDownloadContentList = YES;
	self.contentList = [[NSMutableArray alloc] init];
	self.contentThumbnailCache = [[NSCache alloc] init];
	
	// 画面表示を初期表示します。
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	self.editing = NO;
	self.tableviewFooterLabel.text = @"";
	self.latestButton.enabled = false;
	self.unprotectButton.enabled = false;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_contentList = nil;
	_contentThumbnailCache = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを表示します。
	[self.navigationController setToolbarHidden:NO animated:animated];
	
	// MARK: セグエで遷移して戻ってくるとたまに自動で行選択が解除されないようです。
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];

	if (self.isMovingToParentViewController) {
		[self didStartActivity];
	} else {
		if (self.needsDownloadContentList) {
			[self reloadContentList];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillDisappear:animated];
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

	// 画像キャッシュを準備します。
	[self.contentThumbnailCache removeAllObjects];
	self.contentThumbnailCache.countLimit = 200; // 上限数は適当な値です。
	
	// 再生モードを開始します。
	__weak PlaybackViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラを再生モードに移行します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		weakSelf.previousRunMode = camera.runMode;
		if (![camera changeRunMode:OLYCameraRunModePlayback error:&error]) {
			// モードを移行できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not start Playback", nil)];
			return;
		}

		// コンテンツ一覧をダウンロードします。
		[weakSelf downloadContentList:^{
			// 最下端にスクロールします。
			if (weakSelf.contentList.count > 0) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.contentList.count - 1 inSection:0];
				[weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
			}
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

	// 画像キャッシュをクリアします。
	[self.contentThumbnailCache removeAllObjects];
	
	// 再生モードを終了します。
	// MARK: weakなselfを使うとshowProgress:whileExecutingBlock:のブロックに到達する前に解放されてしまいます。
	__block PlaybackViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラを以前のモードに移行します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera changeRunMode:weakSelf.previousRunMode error:&error]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}

		// 画面操作の後始末が完了しました。
		weakSelf = nil;
		DEBUG_LOG(@"");
	}];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// このビューコントローラーの画面に戻る時に呼び出されます。
- (IBAction)exitToPlaybackViewController:(UIStoryboardSegue *)segue {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"DonePictureContent"]) {
	} else if ([segueIdentifier isEqualToString:@"DoneVideoContent"]) {
	} else {
		// 何もしません。
	}
}

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowPictureContent"]) {
		// 写真コンテンツ
		PictureContentViewController *viewController = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSDictionary *content = self.contentList[indexPath.row];
		viewController.content = content;
		viewController.delegate = self;
	} else if ([segueIdentifier isEqualToString:@"ShowVideoContent"]) {
		// 動画コンテンツ
		VideoContentViewController *viewController = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSDictionary *content = self.contentList[indexPath.row];
		viewController.content = content;
		viewController.delegate = self;
	} else {
		// 何もしません。
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_DETAIL_LOG(@"");
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);
	
	return self.contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	PlaybackViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlaybackViewCell" forIndexPath:indexPath];
	NSDictionary *content = self.contentList[indexPath.row];
	
	// コンテンツの絶対パスを作成し表示します。
	NSString *dirname = content[OLYCameraContentListDirectoryKey];
	NSString *filename = content[OLYCameraContentListFilenameKey];
	NSString *filepath = [dirname stringByAppendingPathComponent:filename];
	cell.filenameLabel.text = filepath;
	
	// コンテンツの作成日付を表示します。
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	NSString *datetime = [dateFormatter stringFromDate:content[OLYCameraContentListDatetimeKey]];
	cell.datetimeLabel.text = datetime;
	
	// コンテンツのファイルサイズを表示します。
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	NSString *filesize = [numberFormatter stringFromNumber:content[OLYCameraContentListFilesizeKey]];
	cell.filesizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ bytes", nil), filesize];
	
	// コンテンツの属性を表示します。
	NSString *attributes = @" ";
	if ([content[OLYCameraContentListAttributesKey] containsObject:@"hidden"]) {
		attributes = NSLocalizedString(@"Hidden", nil);
	} else if ([content[OLYCameraContentListAttributesKey] containsObject:@"protected"]) {
		attributes = NSLocalizedString(@"Protected", nil);
	}
	cell.attributesLabel.text = attributes;
	
	// コンテンツが写真と動画の場合のみ、詳細画面があります。
	NSString *extention = [[filename pathExtension] lowercaseString];
	if ([extention isEqualToString:@"jpg"] ||
		[extention isEqualToString:@"mov"]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	// コンテンツのサムネイル画像がキャッシュにあれば表示します。
	NSDictionary *contentThumbnail = [self.contentThumbnailCache objectForKey:filepath];
	if (contentThumbnail) {
		if (!cell.thumbnailImage.image) {
			// セルに初めて画像を設定する時はフェードアニメーションを追加します。
			CATransition *transision = [CATransition animation];
			transision.duration = 0.25;
			transision.type = kCATransitionFade;
			[cell.thumbnailImage.layer addAnimation:transision forKey:nil];
		} else {
			// セルがリサイクルされた場合、つまり2回目以降の画像設定では、フェードアニメーションはしません。
			[cell.thumbnailImage.layer removeAllAnimations];
		}
		// サムネイル画像を表示します。
		cell.thumbnailImage.image = contentThumbnail[ContentThumbnailImageKey];
		return cell;
	}

	// コンテンツのサムネイル画像がキャッシュになければ、
	// セルにコンテンツを設定するタイミングとは非同期に、サムネイル画像をダウンロードします。
	
	// ダウンロード前の表示画像は空にします。
	// すなわち、表示先のセルではダウンロードした画像を設定する時にフェードアニメーションが発動します。
	[cell.thumbnailImage.layer removeAllAnimations];
	cell.thumbnailImage.image = nil;
	
	// サムネイル画像のダウンロードを開始します。
	__weak PlaybackViewController *weakSelf = self;
	AppCamera *camera = GetAppCamera();
	[camera downloadContentThumbnail:filepath progressHandler:^(float progress, BOOL *stop) {
		// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
		if (!weakSelf.startingActivity) {
			*stop = YES;
		}
	} completionHandler:^(NSData *data, NSMutableDictionary *metadata) {
		DEBUG_LOG(@"data=%p, metadata=%p", data, metadata);
		// ダウンロードしたサムネイル画像をキャッシュに登録します。
		UIImage *image = OLYCameraConvertDataToImage(data, metadata);
		NSDictionary *contentThumbnail = @{
			ContentThumbnailImageKey: image,
			ContentThumbnailMetadataKey: metadata,
		};
		[weakSelf.contentThumbnailCache setObject:contentThumbnail forKey:filepath];
		// サムネイル画像をダウンロードし終わったので再表示します。
		[weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		// エラーを無視して続行します。
		DEBUG_LOG(@"An error occurred, but ignores it.");
	}];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	NSDictionary *content = self.contentList[indexPath.row];
	NSString *filename = content[OLYCameraContentListFilenameKey];
	NSString *extention = [[filename pathExtension] lowercaseString];

	// コンテンツが写真と動画の場合のみ、タップに反応できます。
	if ([extention isEqualToString:@"jpg"] ||
		[extention isEqualToString:@"mov"]) {
		return YES;
	}
	return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	NSDictionary *content = self.contentList[indexPath.row];
	NSString *filename = content[OLYCameraContentListFilenameKey];
	NSString *extention = [[filename pathExtension] lowercaseString];
	
	// コンテンツが写真と動画の場合のみ、セルを選択できます。
	if ([extention isEqualToString:@"jpg"] ||
		[extention isEqualToString:@"mov"]) {
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);

	NSDictionary *content = self.contentList[indexPath.row];
	NSString *filename = content[OLYCameraContentListFilenameKey];
	NSString *extention = [[filename pathExtension] lowercaseString];
	
	// コンテンツが写真と動画の場合のみ、それぞれの詳細画面へ遷移します。
	if ([extention isEqualToString:@"jpg"]) {
		[self performSegueWithIdentifier:@"ShowPictureContent" sender:self];
	} else if([extention isEqualToString:@"mov"]) {
		[self performSegueWithIdentifier:@"ShowVideoContent" sender:self];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 読み取り専用は編集禁止です。
	NSDictionary *content = self.contentList[indexPath.row];
	NSArray *attributes = content[OLYCameraContentListAttributesKey];
	if ([attributes containsObject:@"protected"]) {
		return NO;
	}
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 削除操作以外は無視します。
	if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	
	// コンテンツ一覧から指定されたコンテンツを削除します。
	__weak PlaybackViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// コンテンツの絶対パスを作成します。
		NSDictionary *content = self.contentList[indexPath.row];
		NSString *dirname = content[OLYCameraContentListDirectoryKey];
		NSString *filename = content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];

		// MARK: コンテンツ削除は再生モードで実行できません。カメラを再生保守モードに移行します。
		AppCamera *camera = GetAppCamera();
		if (![camera changeRunMode:OLYCameraRunModePlaymaintenance error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 指定されたコンテンツを削除します。
		NSError *error = nil;
		BOOL erased = [camera eraseContent:filepath error:&error];
		if (erased) {
			[weakSelf.contentList removeObjectAtIndex:indexPath.row];
		}

		// カメラを再生モードに戻します。
		if (![camera changeRunMode:OLYCameraRunModePlayback error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}

		// 正しく削除できたかを確認します。
		if (!erased) {
			// 削除に失敗しました。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not erase content", nil)];
			return;
		}

		// コンテンツ一覧の概要も更新します。
		NSInteger numberOfContents = [camera countNumberOfContents:&error];
		NSInteger numberOfFiles = weakSelf.contentList.count;
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// フッターを更新します。
			NSString *footerLabelTextFormat = NSLocalizedString(@"%ld contents (%ld files)", nil);
			NSString *footerLabelText = [NSString stringWithFormat:footerLabelTextFormat, (long)numberOfContents, (long)numberOfFiles];
			weakSelf.tableviewFooterLabel.text = footerLabelText;
			
			// 表示行を削除します。
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}];
	}];
}

- (void)pictureContentViewControllerDidUpdatedPictureContent:(PictureContentViewController *)controller {
	DEBUG_LOG(@"");
	
	// 次の画面表示開始の時にコンテンツ一覧の読み込み直しが行われます。
	// FIXME: 削除された行のみ表示更新した方が良いが、一覧画面と詳細画面の間のインターフェース設計が不出来なため、一覧表示を全てやり直す方法でお茶を濁しています。
	self.needsDownloadContentList = YES;
}

- (void)pictureContentViewControllerDidErasePictureContent:(PictureContentViewController *)controller {
	DEBUG_LOG(@"");
	
	// 次の画面表示開始の時にコンテンツ一覧の読み込み直しが行われます。
	// FIXME: 削除された行のみ表示更新した方が良いが、一覧画面と詳細画面の間のインターフェース設計が不出来なため、一覧表示を全てやり直す方法でお茶を濁しています。
	self.needsDownloadContentList = YES;
}

- (void)videoContentViewControllerDidAddNewVideoContent:(VideoContentViewController *)controller {
	DEBUG_LOG(@"");

	// 次の画面表示開始の時にコンテンツ一覧の読み込み直しが行われます。
	// FIXME: 追加された行のみ表示更新した方が良いが、一覧画面と詳細画面の間のインターフェース設計が不出来なため、一覧表示を全てやり直す方法でお茶を濁しています。
	self.needsDownloadContentList = YES;
}

- (void)videoContentViewControllerDidUpdatedVideoContent:(VideoContentViewController *)controller {
	DEBUG_LOG(@"");
	
	// 次の画面表示開始の時にコンテンツ一覧の読み込み直しが行われます。
	// FIXME: 追加された行のみ表示更新した方が良いが、一覧画面と詳細画面の間のインターフェース設計が不出来なため、一覧表示を全てやり直す方法でお茶を濁しています。
	self.needsDownloadContentList = YES;
}

- (void)videoContentViewControllerDidEraseVideoContent:(VideoContentViewController *)controller {
	DEBUG_LOG(@"");
	
	// 次の画面表示開始の時にコンテンツ一覧の読み込み直しが行われます。
	// FIXME: 削除された行のみ表示更新した方が良いが、一覧画面と詳細画面の間のインターフェース設計が不出来なため、一覧表示を全てやり直す方法でお茶を濁しています。
	self.needsDownloadContentList = YES;
}

/// 最新ボタンがタップされた時に呼び出されます。
- (IBAction)didTapLatestButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 最下端にスクロールします。
	if (self.contentList.count > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.contentList.count - 1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

/// 解除ボタンがタップされた時に呼び出されます。
- (IBAction)didTapUnprotectButton:(id)sender {
	DEBUG_LOG(@"");
	
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.unprotectButton;
	
	__weak PlaybackViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"Unprotect all contents", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf unprotectAllContents];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"Cancel", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -

/// コンテンツ一覧を読み直します。
- (void)reloadContentList {
	DEBUG_LOG(@"");

	__weak PlaybackViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// コンテンツ一覧をダウンロードします。
		[weakSelf downloadContentList:nil];
	}];
}

/// コンテンツ一覧をダウンロードします。
- (void)downloadContentList:(void (^)())completion {
	DEBUG_LOG(@"%@", [NSThread isMainThread] ? @"App will get hang up!" : @"");

	// コンテンツ一覧をダウンロードます。
	AppCamera *camera = GetAppCamera();
	__block NSMutableArray *downloadedList = nil;
	__block BOOL downloadCompleted = NO;
	__block BOOL downloadFailed = NO;
	__weak PlaybackViewController *weakSelf = self;
	[camera downloadContentList:^(NSMutableArray *list, NSError *error) {
		if (error) {
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not download content list", nil)];
			return;
		}
		downloadedList = list;
		downloadCompleted = YES;
	}];
	
	// コンテンツ一覧のダウンロードが完了するのを待ちます。
	while (!downloadCompleted && !downloadFailed) {
		[NSThread sleepForTimeInterval:0.1];
	}
	if (downloadFailed) {
		// ダウンロードに失敗したようです。
		return;
	}
	
	// コンテンツ一覧を作成日時の昇順でソートします。
	[downloadedList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSDictionary *item1 = (NSDictionary *)obj1;
		NSDictionary *item2 = (NSDictionary *)obj2;
		NSDate *date1 = item1[OLYCameraContentListDatetimeKey];
		NSDate *date2 = item2[OLYCameraContentListDatetimeKey];
		if (date1 && date2) {
			return [date1 compare:date2];
		}
		NSString *path1 = [item1[OLYCameraContentListDirectoryKey] stringByAppendingPathComponent:item1[OLYCameraContentListFilenameKey]];
		NSString *path2 = [item2[OLYCameraContentListDirectoryKey] stringByAppendingPathComponent:item2[OLYCameraContentListFilenameKey]];
		return [path1 localizedCaseInsensitiveCompare:path2];
	}];
	
	// コンテンツ一覧を更新します。
	BOOL unprotectEnabled = NO;
	NSMutableArray *contentList = [[NSMutableArray alloc] init];
	for (NSDictionary *content in downloadedList) {
		if ([content[OLYCameraContentListAttributesKey] containsObject:@"hidden"]) {
			// コンテンツは非表示です。
			// MARK: ここには到達しないようです。(非表示コンテンツはカメラが一覧に乗せてこない)
		}
		if ([content[OLYCameraContentListAttributesKey] containsObject:@"protected"]) {
			// コンテンツはプロテクトされています。
			unprotectEnabled = YES;
		}
		[contentList addObject:content];
	}
	self.contentList = contentList;
	
	// コンテンツ一覧の概要も更新します。
	NSError *error = nil;
	NSInteger numberOfContents = [camera countNumberOfContents:&error];
	NSInteger numberOfFiles = contentList.count;
	
	// 画面表示を更新します。
	[weakSelf executeAsynchronousBlockOnMainThread:^{
		// ボタンを更新します。
		weakSelf.latestButton.enabled = (numberOfContents > 0);
		weakSelf.unprotectButton.enabled = unprotectEnabled;
		
		// フッターを更新します。
		NSString *footerLabelTextFormat = NSLocalizedString(@"%ld contents (%ld files)", nil);
		NSString *footerLabelText = [NSString stringWithFormat:footerLabelTextFormat, (long)numberOfContents, (long)numberOfFiles];
		weakSelf.tableviewFooterLabel.text = footerLabelText;

		// 一覧を更新します。
		[weakSelf.tableView reloadData];
		
		// 完了ハンドラを呼び出します。
		if (completion) {
			completion();
		}
	}];
	
	// ダウンロードが完了しました。
	weakSelf.needsDownloadContentList = NO;
}

/// 全コンテンツをプロテクト解除します。
- (void)unprotectAllContents {
	DEBUG_LOG(@"");

	__weak PlaybackViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// MARK: コンテンツのプロテクト解除は再生モードで実行できません。カメラを再生保守モードに移行します。
		AppCamera *camera = GetAppCamera();
		if (![camera changeRunMode:OLYCameraRunModePlaymaintenance error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 全てのコンテンツのプロテクト解除します。
		__block BOOL unprotectCompleted = NO;
		__block BOOL unprotectFailed = NO;
		[camera unprotectAllContents:^(float progress) {
			// 進捗率表示モードに変更します。
			if (progressView.mode == MBProgressHUDModeIndeterminate) {
				progressView.mode = MBProgressHUDModeAnnularDeterminate;
			}
			// 進捗率の表示を更新します。
			progressView.progress = progress;
		} completionHandler:^{
			unprotectCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			unprotectFailed = YES; // 下の方で待っている人がいるので、すぐにプロテクト解除が終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not unprotect contents", nil)];
		}];
		
		// コンテンツのプロテクト解除が完了するのを待ちます。
		while (!unprotectCompleted && !unprotectFailed) {
			[NSThread sleepForTimeInterval:0.1];
		}
		progressView.mode = MBProgressHUDModeIndeterminate;
		
		// カメラを再生モードに戻します。
		if (![camera changeRunMode:OLYCameraRunModePlayback error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		if (unprotectFailed) {
			// プロテクト解除に失敗したようです。
			return;
		}
		
		// コンテンツ一覧をダウンロードします。
		[weakSelf downloadContentList:nil];
	}];
}

@end
