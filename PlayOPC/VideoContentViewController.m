//
//  VideoContentViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "VideoContentViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "ContentDetailViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface VideoContentViewController ()

// ツールバーの構成に関する設計メモ:
//
// ツールバーは初期状態、プロテクト解除状態(コンテンツが削除できる状態)、プロテクト状態(コンテンツが削除できない状態)でそれぞれ異なるボタンを表示します。
// 初期状態:
//     何もなし
// プロテクト解除状態:
//     [シェアボタン][-][リサイズボタン][-][プロテクトボタン][-][削除ボタン(有効)]
// プロテクト状態:
//     [シェアボタン][-][リサイズボタン][-][プロテクト解除ボタン][-][削除ボタン(無効)]
// Storyboard上のデザインではこれらを一つにまとめて配置してあります。
//     [シェアボタン][-][リサイズボタン][-][プロテクトボタン][プロテクト解除ボタン][-][削除ボタン(無効)]
// ビューがロードされたときにそれぞれの状態用のツールバーボタンセットを構築します。

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resizeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *protectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unprotectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *eraseButton;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (assign, nonatomic) BOOL protected; ///< コンテンツはプロテクトされているか否か
@property (strong, nonatomic) NSArray *unprotectedContentToolbarItems; ///< プロテクト解除状態のコンテンツを表示するときのツールバーボタンセット
@property (strong, nonatomic) NSArray *protectedContentToolbarItems; ///< プロテクト状態のコンテンツを表示するときのツールバーボタンセット
@property (assign, nonatomic) NSTimeInterval estimatedPlaybackTime; ///< コンテンツの再生時間(リサイズ処理の見積り時間表示に使用します)

@end

#pragma mark -

@implementation VideoContentViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// ツールバーボタンセットを初期設定します。
	NSArray *designedToolbarItems = self.toolbarItems;
	self.unprotectedContentToolbarItems = @[
		designedToolbarItems[0], // シェアボタン
		designedToolbarItems[1], // スペーサー
		designedToolbarItems[2], // リサイズボタン
		designedToolbarItems[3], // スペーサー
		designedToolbarItems[4], // プロテクトボタン
		designedToolbarItems[6], // スペーサー
		designedToolbarItems[7], // 削除ボタン
	];
	self.protectedContentToolbarItems = @[
		designedToolbarItems[0], // シェアボタン
		designedToolbarItems[1], // スペーサー
		designedToolbarItems[2], // リサイズボタン
		designedToolbarItems[3], // スペーサー
		designedToolbarItems[5], // プロテクト解除ボタン
		designedToolbarItems[6], // スペーサー
		designedToolbarItems[7], // 削除ボタン
	];
	self.toolbarItems = @[];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_delegate = nil;
	_content = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// タイトルを設定します。
	self.title = self.content[OLYCameraContentListFilenameKey];

	// ツールバーを表示します。
	[self.navigationController setToolbarHidden:NO animated:animated];
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
	
	// 現在のプロテクト状態をコンテンツ情報を元に初期化します。
	NSArray *attributes = self.content[OLYCameraContentListAttributesKey];
	self.protected = [attributes containsObject:@"protected"];
	
	// 初期表示用の画像をダウンロードします。
	[self downloadScreennail];
	
	// ツールバーの表示を初期化します。
	[self updateToolbarItems:YES];
	
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

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowVideoContentDetail"]) {
		ContentDetailViewController *viewController = segue.destinationViewController;
		viewController.content = self.content;
		viewController.contentData = nil;
	} else {
		// 何もしません。
	}
}

/// 共有ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShareButton:(id)sender {
	DEBUG_LOG(@"");

	// 動画がダウンロードにとても時間がかかりそうかを判定します。
	BOOL isLargeContent = NO;
	long long filesize = [self.content[OLYCameraContentListFilesizeKey] longLongValue];
	long long maximumFilesize = 32 * 1024 * 1024; // FIXME: これはメインメモリに収まるだろうと選んだ根拠のない値です。
	if (filesize > maximumFilesize) {
		isLargeContent = YES;
	}
	
	// 実行するかを確認します。
	NSString *message;
	if (isLargeContent) {
		// サイズの大きすぎる動画はダウンロードにとても時間がかかるのでその旨を警告します。
		message = NSLocalizedString(@"$desc:ShareLargeVideo", @"VideoContentViewController.didTapShareButton");
	} else {
		message = NSLocalizedString(@"$desc:ShareVideo", @"VideoContentViewController.didTapShareButton");
	}
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = (UIBarButtonItem *)sender;
	
	__weak VideoContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteShareVideo", @"VideoContentViewController.didTapShareButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			// 動画を共有します。
			[weakSelf shareVideo];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelShareVideo", @"VideoContentViewController.didTapShareButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	[self presentViewController:alertController animated:YES completion:nil];
}

/// リサイズボタンがタップされた時に呼び出されます。
- (IBAction)didTapResizeButton:(id)sender {
	DEBUG_LOG(@"");

	// メッセージにはリサイズ処理の見積り時間も表示します。
	NSString *title = NSLocalizedString(@"$title:ResizeVideo", @"VideoContentViewController.didTapResizeButton");
	NSString *messageFormat = NSLocalizedString(@"$desc:ResizeVideo(wait %1.0f sec)", @"VideoContentViewController.didTapResizeButton");
	NSString *message = [NSString stringWithFormat:messageFormat, self.estimatedPlaybackTime];
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = (UIBarButtonItem *)sender;
	
	__weak VideoContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizeVideo1920Fine", @"VideoContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf resizeVideo:1920 quality:OLYCameraResizeVideoQualityFine];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizeVideo1920Normal", @"VideoContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf resizeVideo:1920 quality:OLYCameraResizeVideoQualityNormal];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizeVideo1280Fine", @"VideoContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf resizeVideo:1280 quality:OLYCameraResizeVideoQualityFine];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizeVideo1280Normal", @"VideoContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf resizeVideo:1280 quality:OLYCameraResizeVideoQualityNormal];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelResizeVideo", @"VideoContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

/// プロテクトボタンがタップされた時に呼び出されます。
- (IBAction)didTapProtectButton:(id)sender {
	DEBUG_LOG(@"");
	
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.protectButton;
	
	__weak VideoContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteProtectVideo", @"VideoContentViewController.didTapProtectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf protectVideo];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelProtectVideo", @"VideoContentViewController.didTapProtectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

/// 解除ボタンがタップされた時に呼び出されます。
- (IBAction)didTapUnprotectButton:(id)sender {
	DEBUG_LOG(@"");
	
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.unprotectButton;
	
	__weak VideoContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteUnprotectVideo", @"VideoContentViewController.didTapUnprotectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf unprotectVideo];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelUnprotectVideo", @"VideoContentViewController.didTapUnprotectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

/// 削除ボタンがタップされた時に呼び出されます。
- (IBAction)didTapEraseButton:(id)sender {
	DEBUG_LOG(@"");
	
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.eraseButton;
	
	__weak VideoContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteEraseVideo", @"VideoContentViewController.didTapEraseButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf eraseVideo];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelEraseVideo", @"VideoContentViewController.didTapEraseButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -

///
- (void)downloadScreennail {
	DEBUG_LOG(@"");
	
	// コンテンツの再生時間を初期化します。
	self.estimatedPlaybackTime = 0.0;
	
	// デバイス用画像のダウンロードを開始します。
	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;

		// コンテンツの再生時間を取得します。
		NSDictionary *information = [camera inquireContentInformation:filepath error:&error];
		if (!information) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotGetScreennail", @"VideoContentViewController.downloadScreennail")];
			return;
		}
		NSTimeInterval playbackTime = [information[@"playtime"] doubleValue];
		
		// デバイス用画像をダウンロードします。
		__block UIImage *image = nil;
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		[camera downloadContentScreennail:filepath progressHandler:^(float progress, BOOL *stop) {
			// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
			if (!weakSelf.startingActivity) {
				*stop = YES;
				downloadCompleted = YES;
				return;
			}
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				// 進捗率表示モードに変更します。
				if (progressView.mode == MBProgressHUDModeIndeterminate) {
					progressView.mode = MBProgressHUDModeAnnularDeterminate;
				}
				// 進捗率の表示を更新します。
				progressView.progress = progress;
			}];
		} completionHandler:^(NSData *data) {
			DEBUG_LOG(@"data=%p", data);
			image = [UIImage imageWithData:data];
			downloadCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotGetScreennail", @"VideoContentViewController.downloadScreennail")];
		}];
		
		// リサイズ画像のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.05];
		}
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			return;
		}
		// この後はすぐに完了するはずで表示のチラツキを抑えるため、進捗率の表示を止めません。
		
		// ダウンロードしたデバイス用画像を表示します。
		__block BOOL renderingComplete = NO;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakSelf.imageView.alpha = 0.0; // 演出のため処理が完了するまで透明にしておきます。
			weakSelf.imageView.image = image;
			weakSelf.estimatedPlaybackTime = playbackTime;
			renderingComplete = YES;
		}];
		
		// リサイズ画像の表示が完了するのを待ちます。
		while (!renderingComplete) {
			[NSThread sleepForTimeInterval:0.05];
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[UIView animateWithDuration:0.25 animations:^{
				weakSelf.imageView.alpha = 1.0;
			}];
		}];
	}];
}

/// 動画を共有します。
- (void)shareVideo {
	DEBUG_LOG(@"");
	
	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];

		// 動画の保存先URLを作成します。
		NSString *temporaryDirectory = NSTemporaryDirectory();
		NSString *temporaryFilepath = [temporaryDirectory stringByAppendingPathComponent:filename];
		NSURL *videoUrl = [NSURL fileURLWithPath:temporaryFilepath isDirectory:NO];
		DEBUG_LOG(@"videoUrl=%@", videoUrl);
		
		// 動画ファイルを準備します。
		NSError *error = nil;
		NSFileManager *manager = [[NSFileManager alloc] init];
		if ([manager fileExistsAtPath:videoUrl.path]) {
			NSError *error = nil;
			if (![manager removeItemAtPath:videoUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		if (![manager createFileAtPath:videoUrl.path contents:nil attributes:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		__block NSFileHandle *videoFileHandle = [NSFileHandle fileHandleForWritingToURL:videoUrl error:&error];
		if (!videoFileHandle) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotShareVideo", @"VideoContentViewController.shareVideo")];
			return;
		}

		// 動画をダウンロードします。
		AppCamera *camera = GetAppCamera();
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		[camera downloadLargeContent:filepath progressHandler:^(NSData *data, float progress, BOOL *stop) {
			// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
			if (!weakSelf.startingActivity) {
				*stop = YES;
				downloadCompleted = YES;
				return;
			}
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				// 進捗率表示モードに変更します。
				if (progressView.mode == MBProgressHUDModeIndeterminate) {
					progressView.mode = MBProgressHUDModeAnnularDeterminate;
				}
				// 進捗率の表示を更新します。
				progressView.progress = progress;
			}];
			// ファイルに保存します。
			@try {
				[videoFileHandle writeData:data];
			}
			@catch (NSException *exception) {
				// FIXME: 書き込みエラーの原因を握りつぶしてしまっている...
				*stop = YES;
				downloadFailed = YES;
			}
			@finally {
			}
		} completionHandler:^{
			DEBUG_LOG(@"");
			downloadCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotShareVideo", @"VideoContentViewController.shareVideo")];
		}];
		
		// 動画のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.05];
		}
		
		// ファイルへの保存を終了します。
		[videoFileHandle closeFile];
		videoFileHandle = nil;
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			NSError *error = nil;
			if (![manager removeItemAtPath:videoUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			return;
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 進捗率の表示を止めます。
			progressView.mode = MBProgressHUDModeIndeterminate;
		}];
		
		// 共有ダイアログを表示します。
		// 出現位置を設定するためには、メインスレッドで実行する必要があります。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			NSArray *shareItems = @[ videoUrl ];
			UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
			shareController.popoverPresentationController.sourceView = weakSelf.view;
			shareController.popoverPresentationController.barButtonItem = weakSelf.shareButton;
			shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
				// 完了したので動画ファイルを破棄します。
				NSError *error = nil;
				if (![manager removeItemAtPath:videoUrl.path error:&error]) {
					// エラーを無視して続行します。
					DEBUG_LOG(@"An error occurred, but ignores it.");
				}
			};
		
			[weakSelf presentViewController:shareController animated:YES completion:nil];
		}];
	}];
}

/// 動画をリサイズします。
- (void)resizeVideo:(CGFloat)size quality:(OLYCameraResizeVideoQuality)quality {
	DEBUG_LOG(@"size=%f, quality=%ld", size, (long)quality);
	
	// 動画のリサイズを開始します。
	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		// 動画をリサイズします。
		// MARK: resizeパラメータは1920もしくは1280しか受け付けないようです。その他の値を指定するとエラーになるようです。
		AppCamera *camera = GetAppCamera();
		__block BOOL resizeCompleted = NO;
		__block BOOL resizeFailed = NO;
		[camera resizeVideoFrame:filepath size:size quality:quality progressHandler:^(float progress, BOOL *stop) {
			// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
			if (!weakSelf.startingActivity) {
				*stop = YES;
				resizeCompleted = YES;
				return;
			}
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				// 進捗率表示モードに変更します。
				if (progressView.mode == MBProgressHUDModeIndeterminate) {
					progressView.mode = MBProgressHUDModeAnnularDeterminate;
				}
				// 進捗率の表示を更新します。
				progressView.progress = progress;
			}];
		} completionHandler:^{
			DEBUG_LOG(@"");
			resizeCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			resizeFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotResizeVideo", @"VideoContentViewController.resizeVideo")];
		}];
		
		// 動画のリサイズが完了するのを待ちます。
		while (!resizeCompleted && !resizeFailed) {
			[NSThread sleepForTimeInterval:0.05];
		}
		if (resizeFailed) {
			// リサイズに失敗したようです。
			return;
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 進捗率の表示を止めます。
			progressView.mode = MBProgressHUDModeIndeterminate;
		}];
		
		// 通知先にお知らせします。
		if (weakSelf.delegate) {
			if ([weakSelf.delegate respondsToSelector:@selector(videoContentViewControllerDidAddNewVideoContent:)]) {
				[weakSelf.delegate videoContentViewControllerDidAddNewVideoContent:weakSelf];
			}
		}
		
		// リサイズが完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

/// 動画をプロテクトします。
- (void)protectVideo {
	DEBUG_LOG(@"");
	
	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = weakSelf.content[OLYCameraContentListDirectoryKey];
		NSString *filename = weakSelf.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		// MARK: コンテンツのプロテクトは再生モードで実行できません。カメラを再生保守モードに移行します。
		AppCamera *camera = GetAppCamera();
		if (![camera changeRunMode:OLYCameraRunModePlaymaintenance error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 指定されたコンテンツをプロテクトします。
		NSError *error = nil;
		BOOL protected = [camera protectContent:filepath error:&error];
		
		// カメラを再生モードに戻します。
		if (![camera changeRunMode:OLYCameraRunModePlayback error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 正しくプロテクトできたかを確認します。
		if (!protected) {
			// プロテクトに失敗しました。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotProtectVideo", @"VideoContentViewController.protectVideo")];
			return;
		}
		weakSelf.protected = YES;
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateToolbarItems:YES];
			
			if (weakSelf.delegate) {
				[weakSelf.delegate videoContentViewControllerDidUpdatedVideoContent:weakSelf];
			}
		}];
	}];
}

/// 動画をプロテクト解除します。
- (void)unprotectVideo {
	DEBUG_LOG(@"");
	
	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = weakSelf.content[OLYCameraContentListDirectoryKey];
		NSString *filename = weakSelf.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		// MARK: コンテンツのプロテクト解除は再生モードで実行できません。カメラを再生保守モードに移行します。
		AppCamera *camera = GetAppCamera();
		if (![camera changeRunMode:OLYCameraRunModePlaymaintenance error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 指定されたコンテンツをプロテクト解除します。
		NSError *error = nil;
		BOOL unprotected = [camera unprotectContent:filepath error:&error];
		
		// カメラを再生モードに戻します。
		if (![camera changeRunMode:OLYCameraRunModePlayback error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 正しくプロテクト解除できたかを確認します。
		if (!unprotected) {
			// プロテクト解除に失敗しました。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotUnprotectVideo", @"VideoContentViewController.unprotectVideo")];
			return;
		}
		weakSelf.protected = NO;
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateToolbarItems:YES];
			
			if (weakSelf.delegate) {
				[weakSelf.delegate videoContentViewControllerDidUpdatedVideoContent:weakSelf];
			}
		}];
	}];
}

/// 動画を削除します。
- (void)eraseVideo {
	DEBUG_LOG(@"");

	__weak VideoContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = weakSelf.content[OLYCameraContentListDirectoryKey];
		NSString *filename = weakSelf.content[OLYCameraContentListFilenameKey];
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
		
		// カメラを再生モードに戻します。
		if (![camera changeRunMode:OLYCameraRunModePlayback error:nil]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 正しく削除できたかを確認します。
		if (!erased) {
			// 削除に失敗しました。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotEraseVideo", @"VideoContentViewController.eraseVideo")];
			return;
		}
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			if (weakSelf.delegate) {
				[weakSelf.delegate videoContentViewControllerDidEraseVideoContent:weakSelf];
			}
			
			// 前の画面に戻ります。
			[weakSelf performSegueWithIdentifier:@"DoneVideoContent" sender:self];
		}];
	}];
}

/// 進捗画面に処理完了を報告します。
- (void)reportBlockFinishedToProgress:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	__block UIImageView *progressImageView;
	dispatch_sync(dispatch_get_main_queue(), ^{
		UIImage *image = [UIImage imageNamed:@"Progress-Checkmark"];
		progressImageView = [[UIImageView alloc] initWithImage:image];
		progressImageView.tintColor = [UIColor whiteColor];
		progress.customView = progressImageView;
		progress.mode = MBProgressHUDModeCustomView;
	});
	[NSThread sleepForTimeInterval:0.5];
}

// ツールバーの表示を更新します。
- (void)updateToolbarItems:(BOOL)animated {
	DEBUG_LOG(@"");
	
	if (self.protected) {
		// プロテクト状態のツールバーを表示します。(削除できません)
		self.eraseButton.enabled = NO;
		[self setToolbarItems:self.protectedContentToolbarItems animated:animated];
	} else {
		// プロテクト解除状態のツールバーを表示します。(削除できます)
		self.eraseButton.enabled = YES;
		[self setToolbarItems:self.unprotectedContentToolbarItems animated:animated];
	}
}

@end
