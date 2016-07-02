//
//  RecImageViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/07.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RecImageViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

@interface RecImageViewController () <UIScrollViewDelegate, OLYCameraRecordingSupportsDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) UIImage *image; ///< 表示している画像('撮影後確認画像'もしくは'最後に撮影された画像')
@property (strong, nonatomic) UIImage *lastCapturedImage; ///< '最後に撮影された画像'
@property (assign, nonatomic) BOOL imageIsLastCapturedImage; ///< '最後に撮影された画像'を表示しているか
@property (strong, nonatomic) NSArray *latestRecImageToolbarItems; ///< '撮影後確認画像'を表示するときのツールバーボタンセット
@property (strong, nonatomic) NSArray *lastCapturedImageToolbarItems; ///< '最後に撮影された画像'を表示するときのツールバーボタンセット

@end

#pragma mark -

@implementation RecImageViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
    [super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// ツールバーボタンセットを初期設定します。
	NSArray *designedToolbarItems = self.toolbarItems;
	self.latestRecImageToolbarItems = @[
		designedToolbarItems[0], // リサイズボタン(小さい方の絵がアクティブ)
		designedToolbarItems[2], // スペーサー
		designedToolbarItems[3], // 削除ボタン
	];
	self.lastCapturedImageToolbarItems = @[
		designedToolbarItems[1], // リサイズボタン(大きい方の絵がアクティブ)
		designedToolbarItems[2], // スペーサー
		designedToolbarItems[3], // 削除ボタン
	];
	self.toolbarItems = @[];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	_image = nil;
	_latestRecImage = nil;
	_lastCapturedImage = nil;
	_latestRecImageToolbarItems = nil;
	_lastCapturedImageToolbarItems = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
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

	// 撮影後確認画像の取得通知を受け取れるようにします。
	AppCamera *camera = GetAppCamera();
	[camera addRecordingSupportsDelegate:self];
	
	// 撮影後確認画像を表示します。
	self.image = self.latestRecImage;
	self.lastCapturedImage = nil;
	self.imageIsLastCapturedImage = NO;
	[self updateImageView];
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

	// 撮影後確認画像の取得通知を受け取りを止めます。
	AppCamera *camera = GetAppCamera();
	[camera removeRecordingSupportsDelegate:self];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}


#pragma mark -

- (void)cameraWillReceiveCapturedImagePreview:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// 進捗表示用のビューを表示します。
	[self showProgress:YES];
}

- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata {
	DEBUG_LOG(@"data.length=%ld", (long)data.length);
	
	// レックビューの表示を最新の画像で更新します。
	UIImage *image = OLYCameraConvertDataToImage(data, metadata);
	self.latestRecImage = image;
	
	// 撮影後確認画像を表示します。
	self.image = self.latestRecImage;
	self.lastCapturedImage = nil;
	self.imageIsLastCapturedImage = NO;
	[self updateImageView];
	[self updateToolbarItems:YES];
	
	// 進捗表示用のビューを消去します。
	[self hideProgress:YES];
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImagePreviewWithError:(NSError *)error {
	DEBUG_LOG(@"error=%@", error);

	// 進捗表示用のビューを消去します。
	[self hideProgress:YES];
	
	// レックビューの取得に失敗しました。
	[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:ReceiveCapturedImagePreviewFailed", @"RecImageViewController.didFailToReceiveCapturedImagePreviewWithError")];
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

	// 現在は'撮影後確認画像'が表示されているはずなので、
	// '最後に撮影された画像'を表示します。
	if (self.lastCapturedImage) {
		self.imageIsLastCapturedImage = YES;
		self.image = self.lastCapturedImage;
		[self updateImageView];
		[self updateToolbarItems:YES];
		return;
	}
	
	// 初めて'最後に撮影された画像'を表示するときはカメラからダウンロードしてこなければなりません。
	// '最後に撮影された画像'のダウンロードを開始します。
	__weak RecImageViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// '最後に撮影された画像'をダウンロードします。
		AppCamera *camera = GetAppCamera();
		__block BOOL downloadCompleted = NO;
		__block BOOL downloadFailed = NO;
		__block NSData *downloadData = nil;
		[camera downloadLastCapturedImage:^(float progress, BOOL *stop) {
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
			downloadData = data;
			downloadCompleted = YES;
		} errorHandler:^(NSError *error) {
			DEBUG_LOG(@"error=%p", error);
			downloadFailed = YES; // 下の方で待っている人がいるので、すぐにダウンロードが終わったことにします。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotResizePicture", @"RecImageViewController.didTapResizeButton")];
		}];

		// '最後に撮影された画像'のダウンロードが完了するのを待ちます。
		while (!downloadCompleted && !downloadFailed) {
			[NSThread sleepForTimeInterval:0.05];
		}
		if (downloadFailed) {
			// ダウンロードに失敗したようです。
			return;
		}
		
		// バイナリデータから画像データを抽出します。
		weakSelf.imageIsLastCapturedImage = YES;
		weakSelf.lastCapturedImage = [UIImage imageWithData:downloadData];
		
		// この後はすぐに完了するはずで表示のチラツキを抑えるため、進捗率の表示を止めません。
		
		// '最後に撮影された画像'を表示します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakSelf.image = weakSelf.lastCapturedImage;
			[weakSelf updateImageView];
			[weakSelf updateToolbarItems:YES];
		}];
	}];
}

/// リサイズボタンがタップされた時に呼び出されます。
- (IBAction)didTapInvertedResizeButton:(id)sender {
	DEBUG_LOG(@"");

	// 現在は'最後に撮影された画像'が表示されているはずなので、
	// '撮影後確認画像'を表示します。
	self.imageIsLastCapturedImage = NO;
	self.image = self.latestRecImage;
	[self updateImageView];
	[self updateToolbarItems:YES];
}

/// 削除ボタンがタップされた時に呼び出されます。
- (IBAction)didTapEraseButton:(id)sender {
	DEBUG_LOG(@"");

	if (self.delegate) {
		[self.delegate recImageViewControllerDidEraseImage:self];
	}
	
	// 前の画面に戻ります。
	[self performSegueWithIdentifier:@"DoneRecImageView" sender:self];
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

/// 現在表示している画像を撮影後確認画像プロパティに設定されているものに更新します。
- (void)updateImageView {
	DEBUG_LOG(@"");

	__weak RecImageViewController *weakSelf = self;
	if (weakSelf.imageView.image) {
		// これは2回目以降の表示です。
		[UIView animateWithDuration:0.25 animations:^{
			weakSelf.imageView.alpha = 0.0; // レイアウトの乱れを隠すため処理が完了するまで透明にしておきます。
		} completion:^(BOOL finished) {
			weakSelf.imageView.image = self.image;
			// スクロールビューの表示を調節します。
			// MARK: 一つのイベント内で表示しようとするとレイアウト計算の時に画像表示ビューの大きさが正しいサイズになっていないようです。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.scrollView.zoomScale = 0; // 絶対に全体表示
				[weakSelf.scrollView setNeedsUpdateConstraints];
				[UIView animateWithDuration:0.25 animations:^{
					weakSelf.imageView.alpha = 1.0;
				}];
			}];
		}];
	} else {
		// これは初回の表示です。
		weakSelf.imageView.image = self.image;
		
		// スクロールビューの表示を調節します。
		// MARK: 一つのイベント内で表示しようとするとレイアウト計算の時に画像表示ビューの大きさが正しいサイズになっていないようです。
		weakSelf.imageView.alpha = 0.0; // レイアウトの乱れを隠すため処理が完了するまで透明にしておきます。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakSelf.scrollView.zoomScale = 0; // 絶対に全体表示
			[weakSelf.scrollView setNeedsUpdateConstraints];
			[UIView animateWithDuration:0.25 animations:^{
				weakSelf.imageView.alpha = 1.0;
			}];
		}];
	}
}

// ツールバーの表示を更新します。
- (void)updateToolbarItems:(BOOL)animated {
	DEBUG_LOG(@"");
	
	if (self.imageIsLastCapturedImage) {
		[self setToolbarItems:self.lastCapturedImageToolbarItems animated:animated];
	} else {
		[self setToolbarItems:self.latestRecImageToolbarItems animated:animated];
	}
}

@end
