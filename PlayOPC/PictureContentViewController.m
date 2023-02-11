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
#import "ContentDetailViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface PictureContentViewController () <UIScrollViewDelegate>

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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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
@property (strong, nonatomic) NSData *contentData; ///< コンテンツのバイナリデータ
@property (strong, nonatomic) UIImage *contentImage; ///< コンテンツの表示用画像データ
@property (assign, nonatomic) OLYCameraImageResize contentImageSize; ///< コンテンツの画像サイズ
@property (assign, nonatomic) BOOL isOrf; ///< コンテンツはORF形式か

@end

#pragma mark -

@implementation PictureContentViewController

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
	_contentData = nil;
	_contentImage = nil;
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

	// 現在のプロテクト状態をコンテンツ情報を元に初期化します。
	NSArray *attributes = self.content[OLYCameraContentListAttributesKey];
	self.protected = [attributes containsObject:@"protected"];

	// 扱うコンテンツの画像形式がJPEGかRAWか判定します。
	NSString *filename = self.content[OLYCameraContentListFilenameKey];
	NSString *extention = [[filename pathExtension] lowercaseString];
	self.isOrf = [extention isEqualToString:@"orf"];

	// 初期表示用の画像をダウンロードします。
	// デバイス用画像のダウンロード(downloadContentScreennail:progressHandler:completionHandler:errorHandler:)で
	// 得た画像にはメタデータに回転情報が入っていないらしく、UIImageViewを使って表示した時に撮影時のカメラ本体の向きが再現されないようです。
	// 通信速度が遅くなりますがここでは表示の正確性を求めたいので、
	// リサイズ画像のダウンロード(downloadContentScreennail:progressHandler:completionHandler:errorHandler:)を使います。
	[self downloadResizedImage:OLYCameraImageResize1024];
	
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

	// コンテンツの情報を破棄します。
	self.contentData = nil;
	self.contentImage = nil;
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowPictureContentDetail"]) {
		ContentDetailViewController *viewController = segue.destinationViewController;
		viewController.content = self.content;
		viewController.contentData = self.contentData;
	} else {
		// 何もしません。
	}
}

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

/// 共有ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShareButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 実行するかを確認します。
	NSString *message = NSLocalizedString(@"$desc:SharePicture", @"PictureContentViewController.didTapShareButton");
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.shareButton;
	
	__weak PictureContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"$title:executeSharePicture", @"PictureContentViewController.didTapShareButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			// 写真を共有します。
			[weakSelf sharePicture];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelSharePicture", @"PictureContentViewController.didTapShareButton");
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

	NSString *title = NSLocalizedString(@"$title:ResizePicture", @"PictureContentViewController.didTapResizeButton");
	NSString *message = NSLocalizedString(@"$desc:ResizePicture", @"PictureContentViewController.didTapResizeButton");
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.resizeButton;
	
	__weak PictureContentViewController *weakSelf = self;
	UIAlertActionStyle actionStyle = UIAlertActionStyleDefault;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizePicture1024", @"PictureContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1024];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		if (self.contentImageSize == OLYCameraImageResize1024) {
			action.enabled = NO;
		}
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizePicture1600", @"PictureContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1600];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		if (self.contentImageSize == OLYCameraImageResize1600) {
			action.enabled = NO;
		}
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizePicture1920", @"PictureContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize1920];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		if (self.contentImageSize == OLYCameraImageResize1920) {
			action.enabled = NO;
		}
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteResizePicture2048", @"PictureContentViewController.didTapResizeButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResize2048];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		if (self.contentImageSize == OLYCameraImageResize2048) {
			action.enabled = NO;
		}
		[alertController addAction:action];
	}
	{
		NSString *title;
		if (self.isOrf) {
			title = NSLocalizedString(@"$title:ExecuteResizePictureOriginalRaw", @"PictureContentViewController.didTapResizeButton");
		} else {
			title = NSLocalizedString(@"$title:ExecuteResizePictureOriginalJpeg", @"PictureContentViewController.didTapResizeButton");
		}
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf downloadResizedImage:OLYCameraImageResizeNone];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:actionStyle handler:handler];
		if (self.contentImageSize == OLYCameraImageResizeNone) {
			action.enabled = NO;
		}
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelResizePicture", @"PictureContentViewController.didTapResizeButton");
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
	
	NSString *message;
	if (self.isOrf) {
		message = NSLocalizedString(@"$desc:ProtectRawPicture", @"PictureContentViewController.didTapProtectButton");
	} else {
		message = NSLocalizedString(@"$desc:ProtectJpegPicture", @"PictureContentViewController.didTapProtectButton");
	}
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.protectButton;
	
	__weak PictureContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteProtectPicture", @"PictureContentViewController.didTapProtectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf protectPicture];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelProtectPicture", @"PictureContentViewController.didTapProtectButton");
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
	
	NSString *message;
	if (self.isOrf) {
		message = NSLocalizedString(@"$desc:UnprotectRawPicture", @"PictureContentViewController.didTapUnprotectButton");
	} else {
		message = NSLocalizedString(@"$desc:UnprotectJpegPicture", @"PictureContentViewController.didTapUnprotectButton");
	}
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.unprotectButton;
	
	__weak PictureContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteUnprotectPicture", @"PictureContentViewController.didTapUnprotectButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf unprotectPicture];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelUnprotectPicture", @"PictureContentViewController.didTapUnprotectButton");
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
	
	NSString *message;
	if (self.isOrf) {
		message = NSLocalizedString(@"$desc:EraseRawPicture", @"PictureContentViewController.didTapEraseButton");
	} else {
		message = NSLocalizedString(@"$desc:EraseJpegPicture", @"PictureContentViewController.didTapEraseButton");
	}
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.eraseButton;
	
	__weak PictureContentViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteErasePicture", @"PictureContentViewController.didTapEraseButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf erasePicture];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelErasePicture", @"PictureContentViewController.didTapEraseButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
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
	height -= self.view.safeAreaInsets.top;
	height -= self.view.safeAreaInsets.bottom;

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
	height -= self.view.safeAreaInsets.top;
	height -= self.view.safeAreaInsets.bottom;
	
	// スクロールビューに画像表示ビューを表示するときのマージンをもとめます。
	CGFloat insetHorizontal = (width - self.scrollView.contentSize.width) / 2.0f;
	CGFloat insetVertical = (height - self.scrollView.contentSize.height) / 2.0f;
	
	// コンテンツビューが十分にスクロールビューの表示範囲より大きいときはマージンの必要なしにします。
	insetHorizontal = MAX(0.0, insetHorizontal);
	insetVertical = MAX(0.0, insetVertical);
	
	// マージンをスクロールビューに適用します。
	CGFloat insetTop = insetVertical + self.view.safeAreaInsets.top;
	CGFloat insetBottom = insetVertical + self.view.safeAreaInsets.bottom;
	UIEdgeInsets insets = UIEdgeInsetsMake(insetTop, insetHorizontal, insetBottom, insetHorizontal);
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			self.scrollView.contentInset = insets;
		}];
	} else {
		self.scrollView.contentInset = insets;
	}
}

/// 写真を共有します。
- (void)sharePicture {
	DEBUG_LOG(@"");

	__weak PictureContentViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 写真の保存先URLを作成します。
		NSString *filename = weakSelf.content[OLYCameraContentListFilenameKey];
		NSString *temporaryDirectory = NSTemporaryDirectory();
		NSString *temporaryFilepath = [temporaryDirectory stringByAppendingPathComponent:filename];
		NSURL *imageUrl = [NSURL fileURLWithPath:temporaryFilepath isDirectory:NO];
		DEBUG_LOG(@"imageUrl=%@", imageUrl);
		
		// 画像データをファイルに保存します。
		NSFileManager *manager = [[NSFileManager alloc] init];
		if ([manager fileExistsAtPath:imageUrl.path]) {
			NSError *error = nil;
			if (![manager removeItemAtPath:imageUrl.path error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		[weakSelf.contentData writeToURL:imageUrl atomically:YES];
		
		// 共有ダイアログを表示します。
		// 出現位置を設定するためには、メインスレッドで実行する必要があります。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
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
		
			[weakSelf presentViewController:shareController animated:YES completion:nil];
		}];
	}];
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
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		if (size == OLYCameraImageResizeNone) {
			// リサイズ画像をといいつつも、
			// オリジナルサイズが指定された場合は、リサイズせずにオリジナルデータそのものをダウンロードします。
			[camera downloadContent:filepath progressHandler:^(float progress, BOOL *stop) {
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
				weakSelf.contentData = data;
				downloadCompleted = YES;
			} errorHandler:^(NSError *error) {
				DEBUG_LOG(@"error=%p", error);
				downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotResizePicture", @"PictureContentViewController.downloadResizedImage")];
			}];
		} else {
			[camera downloadImage:filepath withResize:size progressHandler:^(float progress, BOOL *stop) {
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
				weakSelf.contentData = data;
				downloadCompleted = YES;
			} errorHandler:^(NSError *error) {
				DEBUG_LOG(@"error=%p", error);
				downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotResizePicture", @"PictureContentViewController.downloadResizedImage")];
			}];
		}
		
		// リサイズ画像のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.05];
		}
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			return;
		}

		// ダウンロードした画像を保持します。
		if (size == OLYCameraImageResizeNone && self.isOrf) {
			// ORF形式のバイナリデータは現像しないと表示できません。
			weakSelf.contentImage = [self developRawImage:weakSelf.contentData];
		} else {
			// バイナリデータから画像データを抽出します。
			weakSelf.contentImage = [UIImage imageWithData:weakSelf.contentData];
		}
		self.contentImageSize = size;
		
		// この後はすぐに完了するはずで表示のチラツキを抑えるため、進捗率の表示を止めません。
		
		// ダウンロードしたリサイズ画像を表示します。
		__block BOOL renderingComplete = NO;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[UIView animateWithDuration:0.25 delay:0.0 options:0 animations:^{
				weakSelf.imageView.alpha = 0.0; // レイアウトの乱れを隠すため処理が完了するまで透明にしておきます。
			} completion:^(BOOL finished) {
				weakSelf.imageView.image = weakSelf.contentImage;
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
			[NSThread sleepForTimeInterval:0.05];
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[UIView animateWithDuration:0.25 animations:^{
				weakSelf.imageView.alpha = 1.0;
			}];
		}];
	}];
}

/// 写真をプロテクトします。
- (void)protectPicture {
	DEBUG_LOG(@"");
	
	__weak PictureContentViewController *weakSelf = self;
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotProtectPicture", @"PictureContentViewController.protectPicture")];
			return;
		}
		weakSelf.protected = YES;
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateToolbarItems:YES];
			
			if (weakSelf.delegate) {
				[weakSelf.delegate pictureContentViewControllerDidUpdatedPictureContent:weakSelf];
			}
		}];
	}];
}

/// 写真をプロテクト解除します。
- (void)unprotectPicture {
	DEBUG_LOG(@"");
	
	__weak PictureContentViewController *weakSelf = self;
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotUnprotectPicture", @"PictureContentViewController.unprotectPicture")];
			return;
		}
		weakSelf.protected = NO;
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateToolbarItems:YES];
			
			if (weakSelf.delegate) {
				[weakSelf.delegate pictureContentViewControllerDidUpdatedPictureContent:weakSelf];
			}
		}];
	}];
}

/// 写真を削除します。
- (void)erasePicture {
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotErasePicture", @"PictureContentViewController.erasePicture")];
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

/// RAW画像を現像してUIImageにします。
- (UIImage *)developRawImage:(NSData *)data {
	DEBUG_LOG(@"");

	// Apple標準の現像システムでは Olympus AIR A01 はサポートしていないので、
	// メタデータのカメラタイプを同系列の似たようなサポートしている製品に置き換えます。
	// TODO: もう少し真面目に解析して狙った場所を書き換えないとデータを破壊する可能性がある。
	//
	//   $ exiv2 -pa download.orf
	//   Exif.Image.Model          Ascii 17 AIR-A01
	//   Exif.OlympusEq.CameraType Ascii  6 K0055
	//   $ exiv2 -M "set Exif.OlympusEq.CameraType S0046" download.orf
	//
	unsigned char search[] = { 'K', '0', '0', '5', '5'};
	unsigned char replace[] = { 'S', '0', '0', '4', '6'}; // E-PL7
	unsigned char *reader = (unsigned char *)data.bytes;
	for (int count = 0; count < data.length - sizeof(search); count++) {
		if (memcmp(reader, search, sizeof(search)) == 0) {
			memcpy(reader, replace, sizeof(replace));
			break;
		}
		reader++;
	}
	
	// 現像します。
	NSString *hint = @"com.olympus.raw-image";
	CIRAWFilter *filter = [CIRAWFilter filterWithImageData:data identifierHint:hint];
	UIImage *image = [[UIImage alloc] initWithCIImage:filter.outputImage];
	
	return image;
}

@end
