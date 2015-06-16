//
//  RecordingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/11.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RecordingViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "RecordingLocationManager.h"
#import "LiveImageView.h"
#import "RecImageButton.h"
#import "RecImageViewController.h"
#import "SPanelViewController.h"
#import "EPanelViewController.h"
#import "CPanelViewController.h"
#import "APanelViewController.h"
#import "ZPanelViewController.h"
#import "VPanelViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "ALAssetsLibrary+CustomAlbum.h"

/// コントロールパネルの表示状態
typedef enum : NSInteger {
	ControlPanelVisibleStatusUnknown, ///< コントロールパネルの表示はどうなっているのか不明
	ControlPanelVisibleStatusHidden, ///< パネルは非表示
	ControlPanelVisibleStatusSPanel, ///< Sパネルを表示中
	ControlPanelVisibleStatusEPanel, ///< Eパネルを表示中
	ControlPanelVisibleStatusCPanel, ///< Cパネルを表示中
	ControlPanelVisibleStatusAPanel, ///< Aパネルを表示中
	ControlPanelVisibleStatusZPanel, ///< Zパネルを表示中
	ControlPanelVisibleStatusVPanel, ///< Vパネルを表示中
} ControlPanelVisibleStatus;

static NSString *const PhotosAlbumGroupName = @"OLYMPUS"; ///< 写真アルバムのグループ名(OAシリーズに合わせてあります)

@interface RecordingViewController () <OLYCameraLiveViewDelegate, OLYCameraPropertyDelegate, OLYCameraRecordingDelegate, OLYCameraRecordingSupportsDelegate>

// ビューコントローラーの構成に関する設計メモ:
//
// 一つのビューコントローラーに撮影に関するすべてのパラメータの表示と操作を組み込んでしまうと、とんでもなく太った実装になってしまうので、
// パラメータの性質が似通っているものを集めて、それぞれをコンテナビューの先のビューコントローラーへと配置しました。
// 親のビューコントローラーと子のビューコントローラーの間の情報のやり取りは、原則としてアプリが保持しているカメラインスタンスを経由させます。
// 弊害として、ライブビュー上に撮影パラメータを操作する部品を直接配置するようなクールなUIデザインがやりにくくなってしまいました。
//
// ビュー階層
//   view
//    |-- finderPanelView
//    |    |-- cameraPanelView
//    |    |    |-- liveImageView ... ライブビュー表示
//    |    |    |-- recImageView ... レックビュー(撮影後確認画像)表示
//    |    |-- controlPanelView
//    |         |-- SPanelView ... ステータス全般と設定全体の保存と呼び出し
//    |         |-- EPanelView ... 露出と撮影モード
//    |         |-- CPanelView ... 色味と画像エフェクト
//    |         |-- APanelView ... オートフォーカスと自動露出
//    |         |-- ZPanelView ... 光学ズームとデジタルズーム
//    |         |-- VPanelView ... 画面表示と音量と画像保存
//    |-- toolPanelView
//         |-- showSPanelButton
//         |-- showEPanelButton
//         |-- showCPanelButton
//         |-- takeButton ... 撮影/録画ボタン
//         |-- showAPanelButton
//         |-- showZPanelButton
//         |-- showVPanelButton
//

@property (weak, nonatomic) IBOutlet UIView *finderPanelView;
@property (weak, nonatomic) IBOutlet UIView *cameraPanelView;
@property (weak, nonatomic) IBOutlet LiveImageView *liveImageView;
@property (weak, nonatomic) IBOutlet RecImageButton *recImageButton;
@property (weak, nonatomic) IBOutlet UIView *controlPanelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlPanelViewHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlPanelViewWidthConstraints;
@property (weak, nonatomic) IBOutlet UIView *SPanelView;
@property (weak, nonatomic) IBOutlet UIView *EPanelView;
@property (weak, nonatomic) IBOutlet UIView *CPanelView;
@property (weak, nonatomic) IBOutlet UIView *APanelView;
@property (weak, nonatomic) IBOutlet UIView *ZPanelView;
@property (weak, nonatomic) IBOutlet UIView *VPanelView;
@property (weak, nonatomic) IBOutlet UIView *toolPanelView;
@property (weak, nonatomic) IBOutlet UIButton *showSPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *showEPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *showCPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
@property (weak, nonatomic) IBOutlet UIButton *showAPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *showZPanelButton;
@property (weak, nonatomic) IBOutlet UIButton *showVPanelButton;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (assign, nonatomic) OLYCameraRunMode previousRunMode; ///< この画面に遷移してくる前のカメラ実行モード
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書
@property (strong, nonatomic) UIImage *latestRecImage; ///< 最新の撮影後確認画像
@property (assign, nonatomic) ControlPanelVisibleStatus controlPanelVisibleStatus; ///< コントロールの表示状態
@property (strong, nonatomic) SPanelViewController *embeddedSPanelViewController; ///< Sパネルのビューコントローラ
@property (strong, nonatomic) EPanelViewController *embeddedEPanelViewController; ///< Eパネルのビューコントローラ
@property (strong, nonatomic) CPanelViewController *embeddedCPanelViewController; ///< Cパネルのビューコントローラ
@property (strong, nonatomic) APanelViewController *embeddedAPanelViewController; ///< Aパネルのビューコントローラ
@property (strong, nonatomic) ZPanelViewController *embeddedZPanelViewController; ///< Zパネルのビューコントローラ
@property (strong, nonatomic) VPanelViewController *embeddedVPanelViewController; ///< Vパネルのビューコントローラ

@end

#pragma mark -

@implementation RecordingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
    [super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	self.previousRunMode = OLYCameraRunModeUnknown;

	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAfLockState)) forKey:CameraPropertyAfLockState];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAeLockState)) forKey:CameraPropertyAeLockState];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyDetectedHumanFaces options:0 context:@selector(didChangeDetectedHumanFaces:)];
	
	// 画面表示を初期設定します。
	self.controlPanelVisibleStatus = ControlPanelVisibleStatusUnknown;
	self.toolPanelView.layer.borderWidth = 0.5;
	self.toolPanelView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] CGColor];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	[camera removeObserver:self forKeyPath:CameraPropertyDetectedHumanFaces];
	[camera removeCameraPropertyDelegate:self];
	_cameraPropertyObserver = nil;
	_latestRecImage = nil;
	_embeddedSPanelViewController = nil;
	_embeddedEPanelViewController = nil;
	_embeddedCPanelViewController = nil;
	_embeddedAPanelViewController = nil;
	_embeddedZPanelViewController = nil;
	_embeddedVPanelViewController = nil;
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

- (void)viewDidLayoutSubviews {
	DEBUG_LOG(@"");
	[super viewDidLayoutSubviews];
	
	// コントロールのレイアウトがStroyboardで設定した初期状態になっている場合は非表示にします。
	// それ以外は、デバイスの縦置きや横置きに合うようにパネルの表示サイズを再配置します。
	if (self.controlPanelVisibleStatus == ControlPanelVisibleStatusUnknown) {
		[self showPanel:ControlPanelVisibleStatusHidden animated:NO];
	} else {
		[self showPanel:self.controlPanelVisibleStatus animated:NO];
	}
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)collection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	DEBUG_LOG(@"collection=%@", collection);
	[super willTransitionToTraitCollection:collection withTransitionCoordinator:coordinator];

	// !!!: プログラムで変更したレイアウト制約をここで一度外しておかないとこのメソッドの後にAuto Layoutから警告を受けてしまいます。
	// デバイスが回転してレイアウトが変わる前の制約が何か邪魔しているっぽいです。
	// 以下はアドホックな対策ですが、他に良い方法が見つかりませんでした。
	// !!!: 他のビューコントローラーのビューが表示されている時に実施されないようにします。
	// これを考慮しないと制約が外れたままになってしまいこのビューコントローラーの表示が復帰した時に画面レイアウトが崩れてしまいます。
	if (self.view.window) {
		self.controlPanelViewWidthConstraints.active = NO;
		self.controlPanelViewHeightConstraints.active = NO;
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
	
	// 撮影モードを開始します。
	__weak RecordingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// カメラを撮影モードに入れる前の準備をします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		camera.autoStartLiveView = NO;	// ライブビュー自動開始を無効にします。

		// カメラを撮影モードに移行します。
		weakSelf.previousRunMode = camera.runMode;
		if (![camera changeRunMode:OLYCameraRunModeRecording error:&error]) {
			// モードを移行できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not start Recording", nil)];
			return;
		}
		if (!camera.autoStartLiveView && camera.liveViewEnabled) {
			DEBUG_LOG(@"Why the live view is already started?");
		}
		
		// 最新スナップショットからカメラ設定を復元します。
		NSDictionary *snapshot = GetApp().latestSnapshotOfCameraSettings;
		if (snapshot) {
			if (![camera restoreSnapshotOfSettings:snapshot error:&error]) {
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not restore lastest camera setting", nil)];
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// 現在位置を取得します。
		RecordingLocationManager *locationManager = [[RecordingLocationManager alloc] init];
		CLLocation *location = [locationManager currentLocation:10.0 error:&error];
		if (location) {
			// カメラに位置情報を設定します。
			if (![camera setGeolocationWithCoreLocation:location error:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		} else {
			// カメラに設定されている位置情報をクリアします。
			if (![camera clearGeolocation:&error]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// ライブビューの表示を開始にします。
		// !!!: ライブビュー自動開始が有効でないなら、明示的にライブビューの表示開始を呼び出さなければなりません。
		[camera addLiveViewDelegate:weakSelf];
		[camera addRecordingDelegate:weakSelf];
		[camera addRecordingSupportsDelegate:weakSelf];
		if (![camera startLiveView:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not start Recording", nil)];
			return;
		}

		// デバイスのスリープを禁止します。
		// ???: Xcodeでケーブル接続してデバッグ実行しているとスリープは発動しないようです。
		[UIApplication sharedApplication].idleTimerDisabled = YES;
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
	
	// パネル表示を終了します。
	[self.embeddedSPanelViewController didFinishActivity];
	[self.embeddedEPanelViewController didFinishActivity];
	[self.embeddedCPanelViewController didFinishActivity];
	[self.embeddedAPanelViewController didFinishActivity];
	[self.embeddedZPanelViewController didFinishActivity];
	[self.embeddedVPanelViewController didFinishActivity];
	
	// 撮影モードを終了します。
	// !!!: weakなselfを使うとshowProgress:whileExecutingBlock:のブロックに到達する前に解放されてしまいます。
	__block RecordingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		AppCamera *camera = GetAppCamera();
		if (!camera.autoStartLiveView && !camera.liveViewEnabled) {
			DEBUG_LOG(@"Why the live view is already stopped?");
		}
		
		// ライブビューの表示を終了します。
		// !!!: ライブビュー自動開始が有効でないなら、明示的にライブビューの表示停止を呼び出さなければなりません。
		[camera removeLiveViewDelegate:weakSelf];
		[camera removeRecordingDelegate:weakSelf];
		[camera removeRecordingSupportsDelegate:weakSelf];
		NSError *error = nil;
		if (![camera stopLiveView:&error]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// カメラ設定のスナップショットを取ります。
		// ???: 撮影中にここに突入してきた場合にここで取ったカメラ設定のスナップショットが復元可能なのか分かりません...
		NSDictionary *snapshot = [camera createSnapshotOfSettings:&error];
		if (snapshot) {
			GetApp().latestSnapshotOfCameraSettings = snapshot;
		} else {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// カメラを以前のモードに移行します。
		if (![camera changeRunMode:weakSelf.previousRunMode error:&error]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}

		// デバイスのスリープを許可します。
		[UIApplication sharedApplication].idleTimerDisabled = NO;

		// 画面操作の後始末が完了しました。
		weakSelf = nil;
		DEBUG_LOG(@"");
	}];

	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier hasPrefix:@"Embedded"] && [segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
		// セグエは埋め込み用セグエでかつ埋め込んであるのはナビゲーションコントローラーしか許しません。
		UINavigationController *navigationController = segue.destinationViewController;
		// ついでにコントロールパネルのナビゲーションバーのタイトルも装飾を変更します。
		UIFont *titleFont = [UIFont systemFontOfSize:17.0]; // ???:ナビゲーションバータイトルの省略時のフォントサイズがわからなかったのでハードコーディングしました。
		UIColor *titleColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		NSDictionary *titleAttributes = @{
			NSFontAttributeName: titleFont,
			NSForegroundColorAttributeName: titleColor,
		};
		navigationController.navigationBar.titleTextAttributes = titleAttributes;
		navigationController.navigationBar.tintColor = self.view.tintColor;
		// 各パネルのビューコントローラーを保持します。
		// それぞれのパネルの入り口はナビゲーションコントローラーのルートビューコントローラになっている必要があります。
		if ([segueIdentifier isEqualToString:@"EmbeddedSPanelViewController"]) {
			self.embeddedSPanelViewController = navigationController.viewControllers[0];
		} else if ([segueIdentifier isEqualToString:@"EmbeddedEPanelViewController"]) {
			self.embeddedEPanelViewController = navigationController.viewControllers[0];
		} else if ([segueIdentifier isEqualToString:@"EmbeddedCPanelViewController"]) {
			self.embeddedCPanelViewController = navigationController.viewControllers[0];
		} else if ([segueIdentifier isEqualToString:@"EmbeddedAPanelViewController"]) {
			self.embeddedAPanelViewController = navigationController.viewControllers[0];
		} else if ([segueIdentifier isEqualToString:@"EmbeddedZPanelViewController"]) {
			self.embeddedZPanelViewController = navigationController.viewControllers[0];
		} else if ([segueIdentifier isEqualToString:@"EmbeddedVPanelViewController"]) {
			self.embeddedVPanelViewController = navigationController.viewControllers[0];
		} else {
			// 何もしません。
		}
	} else {
		if ([segueIdentifier isEqualToString:@"ShowRecImageViewController"]) {
			RecImageViewController *viewController = segue.destinationViewController;
			viewController.image = self.latestRecImage;
		} else {
			// 何もしません。
		}
	}
}

/// キー値監視機構によって呼び出されます。
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	DEBUG_DETAIL_LOG(@"keyPath=%@", keyPath);
	
	// すでに活動停止している場合や何かの誤りでセレクタが取得できない場合は何もしません。
	if (!self.startingActivity) {
		return;
	}
	SEL selector = (SEL)context;
	if (!selector || ![self respondsToSelector:selector]) {
		return;
	}
	
	// メインスレッドでイベントハンドラを呼び出します。
	if ([NSThread isMainThread]) {
		[self performSelector:selector withObject:change afterDelay:0];
	} else {
		__weak RecordingViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:change afterDelay:0];
		}];
	}
}

/// カメラプロパティの値に変更があった時に呼び出されます。
- (void)camera:(OLYCamera *)camera didChangeCameraProperty:(NSString *)name {
	// !!!: 特定のカメラプロパティ値がカメラプロパティの撮影モードに依存してnilとなりプロパティ値変更通知のデリゲートがライブビュー画像の更新と同じ間隔で呼び出され続けます。
	// !!!: ログの出力が煩わしいのであえてDEBUG_LOGをDEBUG_DETAIL_LOGに変更しています。
	DEBUG_DETAIL_LOG(@"name=%@", name);
	
	// すでに活動停止している場合や何かの誤りでセレクタが取得できない場合は何もしません。
	if (!self.startingActivity) {
		return;
	}
	SEL selector = NSSelectorFromString(self.cameraPropertyObserver[name]);
	if (!selector || ![self respondsToSelector:selector]) {
		return;
	}
	
	// メインスレッドでイベントハンドラを呼び出します。
	if ([NSThread isMainThread]) {
		[self performSelector:selector withObject:nil afterDelay:0];
	} else {
		__weak RecordingViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

- (void)camera:(OLYCamera *)camera didUpdateLiveView:(NSData *)data metadata:(NSDictionary *)metadata {
	DEBUG_DETAIL_LOG(@"");
	
	// ライブビューの表示を最新の画像で更新します。
	UIImage *image = OLYCameraConvertDataToImage(data, metadata);
	self.liveImageView.image = image;
}

- (void)cameraDidStartRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");
	
	// 表示を撮影中にします。
	self.takeButton.selected = YES;
}

- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// 表示を待機中にします。
	self.takeButton.selected = NO;
}

- (void)camera:(OLYCamera *)camera didChangeAutoFocusResult:(NSDictionary *)result {
	DEBUG_LOG(@"result=%@", result);
}

- (void)cameraWillReceiveCapturedImagePreview:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// レックビューの表示を一旦消去します。
	self.latestRecImage = nil;
	[self.recImageButton setImage:nil];
}

- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata {
	DEBUG_LOG(@"data.length=%ld", (long)data.length);
	
	// レックビューの表示を最新の画像で更新します。
	UIImage *image = OLYCameraConvertDataToImage(data, metadata);
	self.latestRecImage = image;
	[self.recImageButton setImage:image];
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImagePreviewWithError:(NSError *)error {
	DEBUG_LOG(@"error=%@", error);

	// レックビューの取得に失敗しました。
	self.latestRecImage = nil;
	[self.recImageButton setImage:nil];
	[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not show captured image", nil)];
}

- (void)cameraWillReceiveCapturedImage:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// 進捗表示用のビューを表示します。
	[self showProgress:YES];
}

- (void)camera:(OLYCamera *)camera didReceiveCapturedImage:(NSData *)data {
	DEBUG_LOG(@"data.length=%ld", (long)data.length);

	// ダウンロードした画像を保存します。
	__weak RecordingViewController *weakSelf = self;
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeImageDataToSavedPhotosAlbum:data metadata:nil groupName:PhotosAlbumGroupName completionBlock:^(NSURL *assetURL, NSError *error) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 進捗表示用のビューを消去します。
		[weakSelf hideProgress:YES];

		// 撮影画像の保存に失敗しました。
		if (error) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not save captured image", nil)];
		}
	}];
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImageWithError:(NSError *)error {
	DEBUG_LOG(@"error=%@", error);

	// 進捗表示用のビューを消去します。
	[self hideProgress:YES];

	// 撮影画像の取得に失敗しました。
	[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not download captured image", nil)];
}

- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera {
	DEBUG_LOG(@"");
}

#pragma mark -

/// フォーカス固定(AFロック)の値が変わった時に呼び出されます。
- (void)didChangeAfLockState {
	DEBUG_LOG(@"");

	// 今のところこの呼び出しがあるのはフォーカスロックが解除された時のみ、かつカメラプロパティ値を取得して参照するのは処理コストが高いので、
	// 闇雲にオートフォーカス枠を非表示にします。
	[self.liveImageView hideFocusFrame:YES];
}

/// 露出固定(AEロック)の値が変わった時に呼び出されます。
- (void)didChangeAeLockState {
	DEBUG_LOG(@"");

	// 今のところこの呼び出しがあるのは自動露出ロックが解除された時のみ、かつカメラプロパティ値を取得して参照するのは処理コストが高いので、
	// 闇雲に自動露出枠を非表示にします。
	[self.liveImageView hideExposureFrame:YES];
}

/// 顔認識情報の状態が変わった時に呼び出されます。
- (void)didChangeDetectedHumanFaces:(NSDictionary *)change {
	DEBUG_LOG(@"");

	// 顔の数が少ない時は期待通りにそのオブジェクトを追跡しますが、顔の数が多い場合の挙動を観察して見る限り、
	// 一度認識した顔を追跡する(インデックスが変化しない)わけではなく、ライブビュー画像ごとに認識しなおしている
	// (同じオブジェクトでも違うインデックスが割当られている)ように思えます。
	
	// !!!: カメラの顔認識情報の内容をライブビューの顔認識情報にコピーします。
	// カメラプロパティのdetectedHumanFacesを取得してからその中を参照するようにしないと、顔認識結果に変化が
	// あるたびにメインスレッド以外のところでdetectedHumanFacesのオブジェクトツリーが丸ごと入れ替わらしく、
	// camra.detectedHumanFacesの要素を直に参照したらメモリ違反で異常終了したりする場合があります。
	AppCamera *camera = GetAppCamera();
	NSDictionary *detectedHumanFaces = camera.detectedHumanFaces;
	[self.liveImageView showFaceFrames:detectedHumanFaces animated:YES];
}

/// ライブビューがタップされた時に呼び出されます。
- (IBAction)didTapLiveImageView:(UITapGestureRecognizer *)sender {
	DEBUG_LOG(@"");
	
	// タップされた座標にオートフォーカスロックします。
	CGPoint point = [self.liveImageView pointWithGestureRecognizer:sender];
	[self lockAutoFocusPoint:point];
}

/// ライブビューがロングタップされた時に呼び出されます。
- (IBAction)didLongPressLiveImageView:(UILongPressGestureRecognizer *)sender {
	DEBUG_LOG(@"sender.state=%ld", (long)sender.state);
	
	// ロングタップの開始以外は無視します。
	if (sender.state != UIGestureRecognizerStateBegan) {
		return;
	}

	// タップされた座標に自動露出ロックします。
	CGPoint point = [self.liveImageView pointWithGestureRecognizer:sender];
	[self lockAutoExposurePoint:point];
}

/// 'TAKE'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapTakeButton:(UITapGestureRecognizer *)sender {
	DEBUG_LOG(@"");

	// 単写モードと連写モードの場合は静止画撮影、動画モードの場合は動画撮影開始もしくは動画撮影終了します。
	AppCamera *camera = GetAppCamera();
	OLYCameraActionType actionType = [camera actionType];
	if (actionType == OLYCameraActionTypeSingle ||
		actionType == OLYCameraActionTypeSequential) {
		[self takePicture];
	} else if (actionType == OLYCameraActionTypeMovie) {
		if (!camera.recordingVideo) {
			[self startRecordingVideo];
		} else {
			[self stopRecordingVideo];
		}
	}
}

/// 'TAKE'ボタンがロングタップされた時に呼び出されます。
- (IBAction)didLongPressTakeButton:(UILongPressGestureRecognizer *)sender {
	DEBUG_LOG(@"sender.state=%ld", (long)sender.state);

	AppCamera *camera = GetAppCamera();
	OLYCameraActionType actionType = [camera actionType];
	if (sender.state == UIGestureRecognizerStateBegan) {
		// ロングタップの押し始めにて、
		// 単写モードの場合は静止画撮影、連写モードの場合は静止画撮影開始、動画モードの場合は動画撮影開始します。
		if (actionType == OLYCameraActionTypeSingle) {
			[self takePicture];
		} else if (actionType == OLYCameraActionTypeSequential) {
			[self startTakingPicture];
		} else if (actionType == OLYCameraActionTypeMovie) {
			[self startRecordingVideo];
		}
	} else if (sender.state == UIGestureRecognizerStateEnded ||
			   sender.state == UIGestureRecognizerStateCancelled) {
		// ロングタップの押し終わりにて、
		// 連写モードの場合は静止画撮影開始します。
		if (actionType == OLYCameraActionTypeSequential) {
			[self stopTakingPicture];
		}
	}
}

/// 撮影後確認画像ボタンがタップされた時に呼び出されます。
- (IBAction)didTapRecImageButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 撮影後確認画像がない場合は何もしません。
	if (!self.latestRecImage) {
		DEBUG_LOG(@"no image.");
		return;
	}
	
	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}
	
	// 撮影後確認画像を表示します。
	[self performSegueWithIdentifier:@"ShowRecImageViewController" sender:self];
}

/// 'S'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowSPanelButton:(id)sender {
	DEBUG_LOG(@"");

	/// Sパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusSPanel animated:YES];
}

/// 'E'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowEPanelButton:(id)sender {
	DEBUG_LOG(@"");

	/// Eパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusEPanel animated:YES];
}

/// 'C'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowCPanelButton:(id)sender {
	DEBUG_LOG(@"");

	/// Cパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusCPanel animated:YES];
}

/// 'A'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowAPanelButton:(id)sender {
	DEBUG_LOG(@"");

	/// Aパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusAPanel animated:YES];
}

/// 'Z'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowZPanelButton:(id)sender {
	DEBUG_LOG(@"");
	
	/// Zパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusZPanel animated:YES];
}

/// 'V'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShowVPanelButton:(id)sender {
	DEBUG_LOG(@"");
	
	/// Vパネルを表示します。
	[self togglePanel:ControlPanelVisibleStatusVPanel animated:YES];
}

#pragma mark -

/// オートフォーカスしてフォーカスロックします。
- (void)lockAutoFocusPoint:(CGPoint)point {
	DEBUG_LOG(@"point=%@", NSStringFromCGPoint(point));

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}

	// ライブビューが表示されていない場合はエラーとします。
	if (!self.liveImageView || !self.liveImageView.image) {
		[self showAlertMessage:NSLocalizedString(@"The camera is not sending application any image of the live view. Could not calculate a focus point in the live view.", nil) title:NSLocalizedString(@"Could not get touch point", nil)];
		return;
	}
	
	// タッチした座標が明らかに領域外の時はエラーとします。
	if (![self.liveImageView containsPoint:point]) {
		DEBUG_LOG(@"ignore the point: point=%@", NSStringFromCGPoint(point));
		// AF有効枠を表示します。
		CGRect effectiveArea = [camera autoFocusEffectiveArea:nil];
		[self.liveImageView showAutoFocusEffectiveArea:effectiveArea duration:0.5 animated:YES];
#if 0 // 範囲外タッチでロック解除したい場合はこのブロックを有効にします。
		// 指定した座標は無効です。
		[camera clearAutoFocusPoint:nil];
		[camera unlockAutoFocus:nil];
		[self.liveImageView hideFocusFrame];
#endif
		return;
	}

	// オートフォーカスする座標を設定します。
	NSError *error = nil;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	if (![camera setAutoFocusPoint:point error:&error]) {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 座標の設定に失敗しました。
		DEBUG_LOG(@"error=%@", error);
		// AF有効枠を表示します。
		CGRect effectiveArea = [camera autoFocusEffectiveArea:nil];
		[self.liveImageView showAutoFocusEffectiveArea:effectiveArea duration:0.5 animated:YES];
#if 0 // 範囲外タッチでロック解除したい場合はこのブロックを有効にします。
		// 指定した座標は無効です。
		[camera clearAutoFocusPoint:nil];
		[camera unlockAutoFocus:nil];
		[self.liveImageView hideFocusFrame];
#endif
		return;
	}

	// タッチした座標に暫定的なフォーカス枠を表示します。
	CGFloat focusWidth = 0.15;		// この値は大雑把なものです。
	CGFloat focusHeight = 0.15;		// この値は大雑把なものです。
	CGFloat imageWidth = self.liveImageView.intrinsicContentSize.width;
	CGFloat imageHeight = self.liveImageView.intrinsicContentSize.height;
	focusHeight *= ((imageWidth > imageHeight) ? (imageWidth / imageHeight) : (imageHeight / imageWidth));
	CGRect preFocusFrameRect = CGRectMake(point.x - focusWidth / 2, point.y - focusHeight / 2, focusWidth, focusHeight);
	[self.liveImageView showFocusFrame:preFocusFrameRect status:RecordingCameraLiveImageViewStatusRunning animated:YES];
	
	// オートフォーカスおよびフォーカスロックします。
	__weak RecordingViewController *weakSelf = self;
	[camera lockAutoFocus:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// オートフォーカスの結果を取得します。
		NSString *focusResult = info[OLYCameraTakingPictureProgressInfoFocusResultKey];
		NSValue *focusRectValue = info[OLYCameraTakingPictureProgressInfoFocusRectKey];
		DEBUG_LOG(@"focusResult=%@, focusRectValue=%@", focusResult, focusRectValue);
		if ([focusResult isEqualToString:@"ok"] && focusRectValue) {
			// オートフォーカスとフォーカスロックに成功しました。結果のフォーカス枠を表示します。
			CGRect postFocusFrameRect = [focusRectValue CGRectValue];
			[weakSelf.liveImageView showFocusFrame:postFocusFrameRect status:RecordingCameraLiveImageViewStatusLocked animated:YES];
		} else if ([focusResult isEqualToString:@"none"]) {
			// オートフォーカスできませんでした。(オートフォーカス機構が搭載されていません)
			[camera clearAutoFocusPoint:nil];
			[camera unlockAutoFocus:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		} else {
			// オートフォーカスできませんでした。
			[camera clearAutoFocusPoint:nil];
			[camera unlockAutoFocus:nil];
			[weakSelf.liveImageView showFocusFrame:preFocusFrameRect status:RecordingCameraLiveImageViewStatusFailed duration:1.0 animated:YES];
		}
		// フォーカスロックを自発的に他のビューコントローラへ通知します。
		[camera camera:camera notifyDidChangeCameraProperty:CameraPropertyAfLockState sender:weakSelf];
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// オートフォーカスまたはフォーカスロックに失敗しました。
		DEBUG_LOG(@"error=%@", error);
		[camera clearAutoFocusPoint:nil];
		[camera unlockAutoFocus:nil];
		[weakSelf.liveImageView hideFocusFrame:YES];
	}];
}

/// 測光座標と自動露出をロックします。
- (void)lockAutoExposurePoint:(CGPoint)point {
	DEBUG_LOG(@"point=%@", NSStringFromCGPoint(point));

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}
	
	// ライブビューが表示されていない場合はエラーとします。
	if (!self.liveImageView || !self.liveImageView.image) {
		[self showAlertMessage:NSLocalizedString(@"The camera is not sending application any image of the live view. Could not calculate a metering exposure point in the live view.", nil) title:NSLocalizedString(@"Could not get touch point", nil)];
		return;
	}
	
	// タッチした座標が明らかに領域外の時はエラーとします。
	if (![self.liveImageView containsPoint:point]) {
		DEBUG_LOG(@"ignore the point: point=%@", NSStringFromCGPoint(point));
		// AE有効枠を表示します。
		CGRect effectiveArea = [camera autoExposureEffectiveArea:nil];
		[self.liveImageView showAutoExposureEffectiveArea:effectiveArea duration:0.5 animated:YES];
#if 0 // 範囲外タッチでロック解除したい場合はこのブロックを有効にします。
		// 指定した座標は無効です。
		[camera clearAutoExposurePoint:nil];
		[camera unlockAutoExposure:nil];
		[self.liveImageView hideExposureFrame];
#endif
		return;
	}
	
	// 自動露出する座標を設定します。
	NSError *error = nil;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	if (![camera setAutoExposurePoint:point error:&error]) {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 座標の設定に失敗しました。
		DEBUG_LOG(@"error=%@", error);
		// AE有効枠を表示します。
		CGRect effectiveArea = [camera autoExposureEffectiveArea:nil];
		[self.liveImageView showAutoExposureEffectiveArea:effectiveArea duration:0.5 animated:YES];
#if 0 // 範囲外タッチでロック解除したい場合はこのブロックを有効にします。
		// 指定した座標は無効です。
		[camera clearAutoExposurePoint:nil];
		[camera unlockAutoExposure:nil];
		[self.liveImageView hideExposureFrame];
#endif
		return;
	}
	
	// タッチした座標に暫定的な自動露出枠を表示します。
	CGFloat exposureWidth = 0.15;		// この値は大雑把なものです。
	CGFloat exposureHeight = 0.15;		// この値は大雑把なものです。
	CGFloat imageWidth = self.liveImageView.intrinsicContentSize.width;
	CGFloat imageHeight = self.liveImageView.intrinsicContentSize.height;
	exposureHeight *= ((imageWidth > imageHeight) ? (imageWidth / imageHeight) : (imageHeight / imageWidth));
	CGRect preExposureFrameRect = CGRectMake(point.x - exposureWidth / 2, point.y - exposureHeight / 2, exposureWidth, exposureHeight);
	[self.liveImageView showExposureFrame:preExposureFrameRect status:RecordingCameraLiveImageViewStatusRunning animated:YES];
	
	// 自動露出および露出ロックします。
	__weak RecordingViewController *weakSelf = self;
	[camera lockAutoExposure:^{
		DEBUG_LOG(@"");
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 自動露出および露出ロックに成功しました。結果の自動露出枠を表示します。
		CGFloat exposureWidth = 0.1;		// この値は大雑把なものです。
		CGFloat exposureHeight = 0.1;		// この値は大雑把なものです。
		CGFloat imageWidth = self.liveImageView.intrinsicContentSize.width;
		CGFloat imageHeight = self.liveImageView.intrinsicContentSize.height;
		exposureHeight *= ((imageWidth > imageHeight) ? (imageWidth / imageHeight) : (imageHeight / imageWidth));
		CGRect postExposureFrameRect = CGRectMake(point.x - exposureWidth / 2, point.y - exposureHeight / 2, exposureWidth, exposureHeight);
		[weakSelf.liveImageView showExposureFrame:postExposureFrameRect status:RecordingCameraLiveImageViewStatusLocked animated:YES];
		// 露出ロックを自発的に他のビューコントローラへ通知します。
		[camera camera:camera notifyDidChangeCameraProperty:CameraPropertyAeLockState sender:self];
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 自動露出できませんでした。
		DEBUG_LOG(@"error=%@", error);
		[camera clearAutoFocusPoint:nil];
		[camera unlockAutoFocus:nil];
		[weakSelf.liveImageView showExposureFrame:preExposureFrameRect status:RecordingCameraLiveImageViewStatusFailed duration:1.0 animated:YES];
	}];
}

/// 静止画を単写撮影します。
- (void)takePicture {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}

	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not take", nil)];
		return;
	}
	
	// 単写撮影します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera takePicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		if (progress == OLYCameraTakingProgressEndFocusing) {
			// この撮影中にフォーカスロックした場合はオートフォーカス枠を表示します。
			if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
				// オートフォーカスの結果を取得します。
				NSString *focusResult = info[OLYCameraTakingPictureProgressInfoFocusResultKey];
				NSValue *focusRectValue = info[OLYCameraTakingPictureProgressInfoFocusRectKey];
				DEBUG_LOG(@"focusResult=%@, focusRectValue=%@", focusResult, focusRectValue);
				if ([focusResult isEqualToString:@"ok"] && focusRectValue) {
					// オートフォーカスとフォーカスロックに成功しました。結果のフォーカス枠を表示します。
					CGRect postFocusFrameRect = [focusRectValue CGRectValue];
					[weakSelf.liveImageView showFocusFrame:postFocusFrameRect status:RecordingCameraLiveImageViewStatusLocked animated:YES];
				} else if ([focusResult isEqualToString:@"none"]) {
					// オートフォーカスできませんでした。(オートフォーカス機構が搭載されていません)
					[weakSelf.liveImageView hideFocusFrame:YES];
				} else {
					// オートフォーカスできませんでした。
					[weakSelf.liveImageView hideFocusFrame:YES];
				}
			}
		} else if (progress == OLYCameraTakingProgressReadyCapturing) {
			// 撮影を開始する時にフラッシュ表現を開始します。
			[weakSelf.liveImageView showFlashing:YES];
		} else if (progress == OLYCameraTakingProgressFinished) {
			// 撮影を完了した時にフラッシュ表現を終了します。
			[weakSelf.liveImageView hideFlashing:YES];
		}
	} completionHandler:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not take", nil)];
	}];
}

/// 静止画の連写撮影を開始します。
- (void)startTakingPicture {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}
	
	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not take", nil)];
		return;
	}

	// 連写撮影を開始します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera startTakingPicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		if (progress == OLYCameraTakingProgressEndFocusing) {
			// この撮影中にフォーカスロックした場合はオートフォーカス枠を表示します。
			if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
				// オートフォーカスの結果を取得します。
				NSString *focusResult = info[OLYCameraTakingPictureProgressInfoFocusResultKey];
				NSValue *focusRectValue = info[OLYCameraTakingPictureProgressInfoFocusRectKey];
				DEBUG_LOG(@"focusResult=%@, focusRectValue=%@", focusResult, focusRectValue);
				if ([focusResult isEqualToString:@"ok"] && focusRectValue) {
					// オートフォーカスとフォーカスロックに成功しました。結果のフォーカス枠を表示します。
					CGRect postFocusFrameRect = [focusRectValue CGRectValue];
					[weakSelf.liveImageView showFocusFrame:postFocusFrameRect status:RecordingCameraLiveImageViewStatusLocked animated:YES];
				} else if ([focusResult isEqualToString:@"none"]) {
					// オートフォーカスできませんでした。(オートフォーカス機構が搭載されていません)
					[weakSelf.liveImageView hideFocusFrame:YES];
				} else {
					// オートフォーカスできませんでした。
					[weakSelf.liveImageView hideFocusFrame:YES];
				}
			}
		}
	} completionHandler:^{
		DEBUG_LOG(@"");
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 連写撮影を継続します。
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not take", nil)];
	}];
}

/// 静止画の連写撮影を終了します。
- (void)stopTakingPicture {
	DEBUG_LOG(@"");

	// 撮影していない時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (!camera.takingPicture) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}

	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		// エラーを無視して続行します。
		DEBUG_LOG(@"An error occurred, but ignores it.");
	}
	
	// 連写撮影を終了します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera stopTakingPicture:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		// 特に何もしません。
	} completionHandler:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 撮影に失敗しました。
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not take", nil)];
	}];
}

/// 動画の撮影を開始します。
- (void)startRecordingVideo {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (camera.takingPicture || camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}

	// 動画撮影を開始します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera startRecordingVideo:nil completionHandler:^{
		DEBUG_LOG(@"");
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		self.takeButton.selected = YES;
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not record", nil)];
	}];
}

/// 動画の撮影を終了します。
- (void)stopRecordingVideo {
	DEBUG_LOG(@"");

	// 撮影していない時は何もできません。
	AppCamera *camera = GetAppCamera();
	if (!camera.recordingVideo) {
		DEBUG_LOG(@"camera.takingPicture=%ld, camera.recordingVideo=%ld", (long)camera.takingPicture, (long)camera.recordingVideo);
		return;
	}

	// 動画撮影を終了します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera stopRecordingVideo:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		self.takeButton.selected = NO;
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not record", nil)];
	}];
}

#pragma mark -

/// コントロールパネルの中に指定されたパネルをトグル表示します。
/// (すでに該当のパネルが表示されている場合はコントロールパネル全体を非表示にします)
- (void)togglePanel:(ControlPanelVisibleStatus)status animated:(BOOL)animated {
	DEBUG_LOG(@"status=%ld, animated=%@", (long)status, (animated ? @"YES" : @"NO"));
	
	if (status == self.controlPanelVisibleStatus) {
		// トグル動作させるため、変更前と変更後のステータスが同じ場合はコントロールパネルを非表示にします。
		// すべてのパネルのビューコントローラの活動を停止させます。
		[self.embeddedSPanelViewController didFinishActivity];
		[self.embeddedEPanelViewController didFinishActivity];
		[self.embeddedCPanelViewController didFinishActivity];
		[self.embeddedAPanelViewController didFinishActivity];
		[self.embeddedZPanelViewController didFinishActivity];
		[self.embeddedVPanelViewController didFinishActivity];
		// コントロールパネルを非表示にします。
		[self showPanel:ControlPanelVisibleStatusHidden animated:animated];
	} else {
		// 指定されたパネルが始めて表示されるならそのビューコントローラの活動を開始させます。
		// 非表示にされるならそのビューコントローラの活動を停止させます。
		switch (status) {
			case ControlPanelVisibleStatusSPanel:
				[self.embeddedSPanelViewController didStartActivity];
				[self.embeddedEPanelViewController didFinishActivity];
				[self.embeddedCPanelViewController didFinishActivity];
				[self.embeddedAPanelViewController didFinishActivity];
				[self.embeddedZPanelViewController didFinishActivity];
				[self.embeddedVPanelViewController didFinishActivity];
				break;
			case ControlPanelVisibleStatusEPanel:
				[self.embeddedSPanelViewController didFinishActivity];
				[self.embeddedEPanelViewController didStartActivity];
				[self.embeddedCPanelViewController didFinishActivity];
				[self.embeddedAPanelViewController didFinishActivity];
				[self.embeddedZPanelViewController didFinishActivity];
				[self.embeddedVPanelViewController didFinishActivity];
				break;
			case ControlPanelVisibleStatusCPanel:
				[self.embeddedSPanelViewController didFinishActivity];
				[self.embeddedEPanelViewController didFinishActivity];
				[self.embeddedCPanelViewController didStartActivity];
				[self.embeddedAPanelViewController didFinishActivity];
				[self.embeddedZPanelViewController didFinishActivity];
				[self.embeddedVPanelViewController didFinishActivity];
				break;
			case ControlPanelVisibleStatusAPanel:
				[self.embeddedSPanelViewController didFinishActivity];
				[self.embeddedEPanelViewController didFinishActivity];
				[self.embeddedCPanelViewController didFinishActivity];
				[self.embeddedAPanelViewController didStartActivity];
				[self.embeddedZPanelViewController didFinishActivity];
				[self.embeddedVPanelViewController didFinishActivity];
				break;
			case ControlPanelVisibleStatusZPanel:
				[self.embeddedSPanelViewController didFinishActivity];
				[self.embeddedEPanelViewController didFinishActivity];
				[self.embeddedCPanelViewController didFinishActivity];
				[self.embeddedAPanelViewController didFinishActivity];
				[self.embeddedZPanelViewController didStartActivity];
				[self.embeddedVPanelViewController didFinishActivity];
				break;
			case ControlPanelVisibleStatusVPanel:
				[self.embeddedSPanelViewController didFinishActivity];
				[self.embeddedEPanelViewController didFinishActivity];
				[self.embeddedCPanelViewController didFinishActivity];
				[self.embeddedAPanelViewController didFinishActivity];
				[self.embeddedZPanelViewController didFinishActivity];
				[self.embeddedVPanelViewController didStartActivity];
				break;
			default:
				// ありえません。
				break;
		}
		// コントロールパネルを表示します。
		[self showPanel:status animated:YES];
	}
}

/// コントロールパネルの中に指定されたパネルのみを表示します。
- (void)showPanel:(ControlPanelVisibleStatus)status animated:(BOOL)animated {
	DEBUG_LOG(@"status=%ld, animated=%@", (long)status, (animated ? @"YES" : @"NO"));

	// 最初にこのステータスを変更しておかないと、
	// layoutIfNeededから誘発されたviewDidLayoutSubviewsでこのメソッドが再帰呼び出しされてしまい
	// 結果的にアプリがハングアップしてしまいます。
	self.controlPanelVisibleStatus = status;

	// 指定されたパネルのボタンだけを選択状態にして残りのパネルのボタンは選択解除にします。
	self.showSPanelButton.selected = (status == ControlPanelVisibleStatusSPanel);
	self.showEPanelButton.selected = (status == ControlPanelVisibleStatusEPanel);
	self.showCPanelButton.selected = (status == ControlPanelVisibleStatusCPanel);
	self.showAPanelButton.selected = (status == ControlPanelVisibleStatusAPanel);
	self.showZPanelButton.selected = (status == ControlPanelVisibleStatusZPanel);
	self.showVPanelButton.selected = (status == ControlPanelVisibleStatusVPanel);
	
	// 指定されたパネルだけを表示にして残りのパネルは非表示にします。
	if (status != ControlPanelVisibleStatusHidden) {
		self.SPanelView.hidden = (status != ControlPanelVisibleStatusSPanel);
		self.EPanelView.hidden = (status != ControlPanelVisibleStatusEPanel);
		self.CPanelView.hidden = (status != ControlPanelVisibleStatusCPanel);
		self.APanelView.hidden = (status != ControlPanelVisibleStatusAPanel);
		self.ZPanelView.hidden = (status != ControlPanelVisibleStatusZPanel);
		self.VPanelView.hidden = (status != ControlPanelVisibleStatusVPanel);
	}

	// コントロールパネルの開閉を設定します。
	CGFloat controlPanelViewAlpha;
	if (status == ControlPanelVisibleStatusHidden) {
		// 閉じます。
		self.controlPanelViewWidthConstraints.constant = 0;
		self.controlPanelViewHeightConstraints.constant = 0;
		controlPanelViewAlpha = 0.0;
	} else {
		// 開きます。
		CGFloat width = self.finderPanelView.bounds.size.width * 0.5; // 倍率は適当な値です。
		CGFloat height = self.finderPanelView.bounds.size.height * 0.5;	// 倍率は適当な値です。
		self.controlPanelViewWidthConstraints.constant = width;
		self.controlPanelViewHeightConstraints.constant = height;
		controlPanelViewAlpha = 1.0;
	}
	[self.controlPanelView setNeedsUpdateConstraints];
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			[self.view layoutIfNeeded];
			self.controlPanelView.alpha = controlPanelViewAlpha;
		}];
	} else {
		[self.view layoutIfNeeded];
		self.controlPanelView.alpha = controlPanelViewAlpha;
	}
}

@end
