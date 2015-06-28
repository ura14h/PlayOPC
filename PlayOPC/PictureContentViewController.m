//
//  PictureContentViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/14.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "PictureContentViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface PictureContentViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resizeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か

@end

#pragma mark -

@implementation PictureContentViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
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

- (void)viewDidLayoutSubviews {
	DEBUG_DETAIL_LOG(@"");
	[super viewDidLayoutSubviews];

	// 未だ活動していない場合は何もしません。
	if (!self.startingActivity) {
		return;
	}
	
	// スクロールビューの表示を調節します。
	[self adjustScrollViewZoomScale:NO];
	[self adjustScrollViewContentInset:NO];
}

#pragma mark -

// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

	// MARK: 初期表示用の画像をダウンロードします。
	// デバイス用画像のダウンロード(downloadContentScreennail:progressHandler:completionHandler:errorHandler:)で
	// 得た画像にはメタデータに回転情報が入っていないらしく、UIImageViewを使って表示した時に撮影時のカメラ本体の向きが再現されないようです。
	// 通信速度が遅くなりますがここでは表示の正確性を求めたいので、
	// リサイズ画像のダウンロード(downloadContentScreennail:progressHandler:completionHandler:errorHandler:)を使います。
	[self downloadResizedImage:OLYCameraImageResize1024];
	
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

/// スワイプジェスチャーで前の画面に戻ろうとした時に呼び出されます。(iOS7はここに到達しないがiOS8ではここに来てしまうらしい)
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	DEBUG_DETAIL_LOG(@"");
	
	if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
		return NO;
	}
	return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	DEBUG_DETAIL_LOG(@"");
	
	// ズームするビューとして画像表示ビューを返します。
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	DEBUG_DETAIL_LOG(@"");
	
	// スクロールビューの表示を調節します。
	[self adjustScrollViewContentInset:NO];
}

/// スクロールビューがダブルタップされた時に呼び出されます。
- (IBAction)didTapScrollView:(UITapGestureRecognizer *)sender {
	DEBUG_LOG(@"");
	
	// 最小と最大の間の中間の倍率を境にズームインするかズームアウトするかを決めます。
	CGFloat minimumZoomScale = self.scrollView.minimumZoomScale;
	CGFloat maximumZoomScale = self.scrollView.maximumZoomScale;
	CGFloat boundaryScale = (maximumZoomScale - minimumZoomScale) / 2.0 + minimumZoomScale;
	if (self.scrollView.zoomScale < boundaryScale) {
		// スクロールビューをタップした座標を中心に最大倍率までズームインします。
		CGPoint point = [sender locationInView:self.scrollView];
		point.x /= self.scrollView.zoomScale;
		point.y /= self.scrollView.zoomScale;
		CGRect rect;
		rect.size.width  = self.scrollView.bounds.size.width / maximumZoomScale;
		rect.size.height = self.scrollView.bounds.size.height / maximumZoomScale;
		rect.origin.x = point.x - (rect.size.width  / 2.0);
		rect.origin.y = point.y - (rect.size.height / 2.0);
		[self.scrollView zoomToRect:rect animated:YES];
	} else {
		// スクロールビューを最小倍率までズームアウトします。
		[self.scrollView setZoomScale:minimumZoomScale animated:YES];
	}
}

/// リサイズボタンがタップされた時に呼び出されます。
- (IBAction)didTapResizeButton:(id)sender {
	DEBUG_LOG(@"");

	NSString *title = NSLocalizedString(@"Resize the image", nil);
	NSString *message = NSLocalizedString(@"An image with a long side pixel size of specified length is downloaded, the current image will be replaced at it.", nil);
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.resizeButton;
	
	__weak PictureContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"1024 Pixels", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1024];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"1600 Pixels", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1600];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"1920 Pixels", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1920];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"2048 Pixels", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize2048];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"Original Size", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResizeNone];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
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

/// 共有ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShareButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 実行するかを確認します。
	NSString *title = NSLocalizedString(@"Share the picture", nil);
	NSString *message = NSLocalizedString(@"The application downloads this picture of the original size before sharing it. The handling takes a little bit of time.", nil);
	UIAlertControllerStyle style = UIAlertControllerStyleAlert;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.shareButton;
	
	__weak PictureContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"OK", nil);
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			// 写真を共有します。
			[weakSelf sharePicture];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
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

/// 削除ボタンがタップされた時に呼び出されます。
- (IBAction)didTapEraseButton:(id)sender {
	DEBUG_LOG(@"");
	
	__weak PictureContentViewController *weakSelf = self;
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not erase content", nil)];
			return;
		}

		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			if (weakSelf.delegate) {
				[weakSelf.delegate pictureContentViewControllerDidErasePictureContent:weakSelf];
			}

			// 前の画面に戻ります。
			[weakSelf performSegueWithIdentifier:@"DonePictureContent" sender:self];
		}];
	}];
}

#pragma mark -

- (void)adjustScrollViewZoomScale:(BOOL)animated {
	DEBUG_LOG(@"");

	// 画像が設定されていない場合は何もしません。
	if (!self.imageView.image) {
		self.scrollView.minimumZoomScale = 1.0;
		self.scrollView.maximumZoomScale = 1.0;
		self.scrollView.zoomScale = 1.0;
		return;
	}
	
	// スクロールビューの表示領域を求めます。
	CGFloat width = self.scrollView.frame.size.width;
	CGFloat height = self.scrollView.frame.size.height;
	height -= [self.topLayoutGuide length];
	height -= [self.bottomLayoutGuide length];

	// スクロールビューの表示領域に最適な最小倍率を求めます。
	CGFloat minimumZoomScaleX = width / self.imageView.intrinsicContentSize.width;
	CGFloat minimumZoomScaleY = height / self.imageView.intrinsicContentSize.height;
	CGFloat minimumZoomScale = MIN(minimumZoomScaleX, minimumZoomScaleY);
	
	// ズームの倍率範囲を設定します。
	self.scrollView.minimumZoomScale = minimumZoomScale;
	self.scrollView.maximumZoomScale = 1.0;
	
	// ズームの現在倍率が範囲外なら収まるように調整します。
	CGFloat zoomScale = self.scrollView.zoomScale;
	self.scrollView.zoomScale = MIN(MAX(zoomScale, minimumZoomScale), 1.0);
}

/// スクロールビューの中にある画像表示ビューの余白部分を調節します。
- (void)adjustScrollViewContentInset:(BOOL)animated {
	DEBUG_LOG(@"");

	// 画像が設定されていない場合は何もしません。
	if (!self.imageView.image) {
		return;
	}
	
	// スクロールビューの表示領域を求めます。
	CGFloat width = self.scrollView.frame.size.width;
	CGFloat height = self.scrollView.frame.size.height;
	height -= [self.topLayoutGuide length];
	height -= [self.bottomLayoutGuide length];
	
	// スクロールビューに画像表示ビューを表示するときのマージンをもとめます。
	CGFloat insetHorizontal = (width - self.scrollView.contentSize.width) / 2.0f;
	CGFloat insetVertical = (height - self.scrollView.contentSize.height) / 2.0f;
	
	// コンテンツビューが十分にスクロールビューの表示範囲より大きいときはマージンの必要なしにします。
	insetHorizontal = MAX(0.0, insetHorizontal);
	insetVertical = MAX(0.0, insetVertical);
	
	// マージンをスクロールビューに適用します。
	CGFloat insetTop = insetVertical + [self.topLayoutGuide length];
	CGFloat insetBottom = insetVertical + [self.bottomLayoutGuide length];
	UIEdgeInsets insets = UIEdgeInsetsMake(insetTop, insetHorizontal, insetBottom, insetHorizontal);
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			self.scrollView.contentInset = insets;
		}];
	} else {
		self.scrollView.contentInset = insets;
	}
}

/// リサイズ画像をダウンロードします。
- (void)downloadResizedImage:(OLYCameraImageResize)size {
	DEBUG_LOG(@"size=%f", size);
	
	// リサイズ画像のダウンロードを開始します。
	__weak PictureContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		// リサイズ画像をダウンロードします。
		// オリジナルサイズ画像は大きすぎてかつダウンロードに時間がかかりすぎるので初期表示には適さないと思います。
		// MARK: Appleのドキュメントによると、1024*1024より大きいUIImageの表示は推奨できないらしい。
		// MARK: iPhone 4Sで動かしてみた限りでは、オリジナル画像のサイズ(OLYCameraImageResizeNone)でも表示は問題なくできるようです。
		AppCamera *camera = GetAppCamera();
		__block UIImage *image = nil;
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		[camera downloadImage:filepath withResize:size progressHandler:^(float progress, BOOL *stop) {
			// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
			if (!weakSelf.startingActivity) {
				*stop = YES;
				downloadCompleted = YES;
				return;
			}
			// 進捗率表示モードに変更します。
			if (progressView.mode == MBProgressHUDModeIndeterminate) {
				progressView.mode = MBProgressHUDModeAnnularDeterminate;
			}
			// 進捗率の表示を更新します。
			progressView.progress = progress;
		} completionHandler:^(NSData *data) {
			DEBUG_LOG(@"data=%p", data);
			image = [UIImage imageWithData:data];
			downloadCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not download image", nil)];
		}];
		
		// リサイズ画像のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.1];
		}
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			return;
		}
		// この後はすぐに完了するはずで表示のチラツキを抑えるため、進捗率の表示を止めません。
		
		// ダウンロードしたリサイズ画像を表示します。
		__block BOOL renderingComplete = NO;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[UIView animateWithDuration:0.25 delay:0.0 options:0 animations:^{
				weakSelf.imageView.alpha = 0.0; // レイアウトの乱れを隠すため処理が完了するまで透明にしておきます。
			} completion:^(BOOL finished) {
				weakSelf.imageView.image = image;
				// スクロールビューの表示を調節します。
				// MARK: 一つのイベント内で表示しようとするとレイアウト計算の時に画像表示ビューの大きさが正しいサイズになっていないようです。
				[weakSelf executeAsynchronousBlockOnMainThread:^{
					weakSelf.scrollView.zoomScale = 0; // 絶対に全体表示
					[weakSelf.scrollView setNeedsUpdateConstraints];
					renderingComplete = YES;
				}];
			}];
		}];
		
		// リサイズ画像の表示が完了するのを待ちます。
		while (!renderingComplete) {
			[NSThread sleepForTimeInterval:0.1];
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[UIView animateWithDuration:0.25 animations:^{
				weakSelf.imageView.alpha = 1.0;
			}];
		}];
	}];
}

/// 写真を共有します。
- (void)sharePicture {
	DEBUG_LOG(@"");

	__weak PictureContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];
		
		// 写真の保存先URLを作成します。
		NSString *temporaryDirectory = NSTemporaryDirectory();
		NSString *temporaryFilepath = [temporaryDirectory stringByAppendingPathComponent:filename];
		NSURL *imageUrl = [NSURL fileURLWithPath:temporaryFilepath isDirectory:NO];
		DEBUG_LOG(@"imageUrl=%@", imageUrl);
		
		// 画像ファイルを準備します。
		NSFileManager *manager = [[NSFileManager alloc] init];
		if ([manager fileExistsAtPath:imageUrl.path]) {
			NSError *error = nil;
			if (![manager removeItemAtPath:imageUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// 画像をダウンロードします。
		AppCamera *camera = GetAppCamera();
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		[camera downloadContent:filepath progressHandler:^(float progress, BOOL *stop) {
			// ビューコントローラーが活動が停止しているようならダウンロードは必要ないのでキャンセルします。
			if (!weakSelf.startingActivity) {
				*stop = YES;
				downloadCompleted = YES;
				return;
			}
			// 進捗率表示モードに変更します。
			if (progressView.mode == MBProgressHUDModeIndeterminate) {
				progressView.mode = MBProgressHUDModeAnnularDeterminate;
			}
			// 進捗率の表示を更新します。
			progressView.progress = progress;
		} completionHandler:^(NSData *data) {
			DEBUG_LOG(@"data=%p", data);
			// ファイルに保存します。
			[data writeToURL:imageUrl atomically:YES];
			downloadCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not download image", nil)];
		}];
		
		// 画像のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.1];
		}
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			NSError *error = nil;
			if (![manager removeItemAtPath:imageUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			return;
		}
		// 進捗率の表示を止めます。
		progressView.mode = MBProgressHUDModeIndeterminate;
		
		// 共有ダイアログを表示します。
		// 一番最初だけ表示されるまでとても時間がかかるようです。
		NSArray *shareItems = @[ imageUrl ];
		UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
		shareController.popoverPresentationController.sourceView = weakSelf.view;
		shareController.popoverPresentationController.barButtonItem = weakSelf.shareButton;
		shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
			// 完了したので画像ファイルを破棄します。
			NSError *error = nil;
			if (![manager removeItemAtPath:imageUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		};
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf presentViewController:shareController animated:YES completion:nil];
		}];
	}];
}

@end
