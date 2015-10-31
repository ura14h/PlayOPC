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
#import "AppSetting.h"
#import "AppCamera.h"
#import "RecordingLocationManager.h"
#import "LiveImageView.h"
#import "LiveImageOverallView.h"
#import "RecImageButton.h"
#import "MarginedLabel.h"
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

@interface RecordingViewController () <OLYCameraLiveViewDelegate, OLYCameraPropertyDelegate, OLYCameraRecordingDelegate, OLYCameraRecordingSupportsDelegate, AppCameraTakingPictureDelegate, RecImageViewControllerControllerDelegate>

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
//    |    |    |-- liveImageOverallView ... ライブビュー拡大表示の全体図
//    |    |    |-- moveToUpButton ... ライブビュー拡大表示の上移動
//    |    |    |-- moveToLeftButton ... ライブビュー拡大表示の左移動
//    |    |    |-- moveToRightButton ... ライブビュー拡大表示の右移動
//    |    |    |-- moveToDownButton ... ライブビュー拡大表示の下移動
//    |    |    |-- recImageButton ... レックビュー(撮影後確認画像)表示
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
@property (weak, nonatomic) IBOutlet LiveImageOverallView *liveImageOverallView;
@property (weak, nonatomic) IBOutlet UIButton *moveToUpButton;
@property (weak, nonatomic) IBOutlet UIButton *moveToLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *moveToRightButton;
@property (weak, nonatomic) IBOutlet UIButton *moveToDownButton;
@property (weak, nonatomic) IBOutlet RecImageButton *recImageButton;
@property (weak, nonatomic) IBOutlet MarginedLabel *progressLabel;
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
@property (assign, nonatomic) ControlPanelVisibleStatus controlPanelVisibleStatus; ///< コントロールパネルの表示状態
@property (assign, nonatomic) CGFloat controlPanelWidthRatio; // 画面に対するコントロールパネル横幅の割合
@property (assign, nonatomic) CGFloat controlPanelHeightRatio; // 画面に対するコントロールパネル高さの割合
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
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAspectRatio)) forKey:CameraPropertyAspectRatio];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyDetectedHumanFaces options:0 context:@selector(didChangeDetectedHumanFaces:)];
	[camera addObserver:self forKeyPath:CameraPropertyRecordingElapsedTime options:0 context:@selector(didChangeRecordingElapsedTime:)];
	[camera addObserver:self forKeyPath:CameraPropertyMagnifyingLiveView options:0 context:@selector(didChangeMagnifyingLiveView:)];
	[camera addObserver:self forKeyPath:CameraPropertyMagnifyingLiveViewScale options:0 context:@selector(didChangeMagnifyingLiveViewScale:)];
	
	// 画面表示を初期設定します。
	BOOL magnifyingLiveViewAlpha = camera.magnifyingLiveView ? 1.0 : 0.0;
	self.liveImageOverallView.alpha = magnifyingLiveViewAlpha;
	self.moveToUpButton.alpha = magnifyingLiveViewAlpha;
	self.moveToLeftButton.alpha = magnifyingLiveViewAlpha;
	self.moveToRightButton.alpha = magnifyingLiveViewAlpha;
	self.moveToDownButton.alpha = magnifyingLiveViewAlpha;
	self.progressLabel.layer.cornerRadius = 5.0;
	self.progressLabel.clipsToBounds = true;
	self.progressLabel.alpha = 0.0;
	self.progressLabel.text = @" ";
	self.controlPanelVisibleStatus = ControlPanelVisibleStatusUnknown;
	self.controlPanelWidthRatio = 0.5;
	self.controlPanelHeightRatio = 0.5;
	self.toolPanelView.layer.borderWidth = 0.5;
	self.toolPanelView.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] CGColor];
	self.takeButton.selected = NO;
	self.takeButton.enabled = YES;
	self.showSPanelButton.selected = NO;
	self.showEPanelButton.selected = NO;
	self.showCPanelButton.selected = NO;
	self.showAPanelButton.selected = NO;
	self.showZPanelButton.selected = NO;
	self.showVPanelButton.selected = NO;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	[camera removeObserver:self forKeyPath:CameraPropertyDetectedHumanFaces];
	[camera removeObserver:self forKeyPath:CameraPropertyRecordingElapsedTime];
	[camera removeObserver:self forKeyPath:CameraPropertyMagnifyingLiveView];
	[camera removeObserver:self forKeyPath:CameraPropertyMagnifyingLiveViewScale];
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

	// MARK: プログラムで変更したレイアウト制約をここで一度外しておかないとこのメソッドの後にAuto Layoutから警告を受けてしまいます。
	// デバイスが回転してレイアウトが変わる前の制約が何か邪魔しているっぽいです。
	// 以下はアドホックな対策ですが、他に良い方法が見つかりませんでした。
	// MARK: 他のビューコントローラーのビューが表示されている時に実施されないようにします。
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartRecordingMode", @"RecordingViewController.didStartActivity")];
			return;
		}
		if (!camera.autoStartLiveView && camera.liveViewEnabled) {
			DEBUG_LOG(@"Why the live view is already started?");
		}
		
		// 最新スナップショットからカメラ設定を復元します。
		AppSetting *setting = GetAppSetting();
		if (setting.keepLastCameraSetting) {
			NSDictionary *snapshot = setting.latestSnapshotOfCameraSetting;
			if (snapshot) {
				NSDictionary *optimizedSnapshot = [camera optimizeSnapshotOfSetting:snapshot error:&error];
				if (optimizedSnapshot) {
					NSArray *exclude = @[
						CameraPropertyWifiCh, // Wi-Fiチャンネルの設定は復元しません。
					];
					[weakSelf reportBlockSettingToProgress:progressView];
					if (![camera restoreSnapshotOfSetting:optimizedSnapshot exclude:exclude fallback:YES error:&error]) {
						[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotRestoreLastestCameraSetting", @"RecordingViewController.didStartActivity")];
						// エラーを無視して続行します。
						DEBUG_LOG(@"An error occurred, but ignores it.");
					}
					progressView.mode = MBProgressHUDModeIndeterminate;
				} else {
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotRestoreLastestCameraSetting", @"RecordingViewController.didStartActivity")];
					// エラーを無視して続行します。
					DEBUG_LOG(@"An error occurred, but ignores it.");
				}
			} else {
				DEBUG_LOG(@"No snapshots.");
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
		// MARK: ライブビュー自動開始が有効でないなら、明示的にライブビューの表示開始を呼び出さなければなりません。
		[camera addLiveViewDelegate:weakSelf];
		[camera addRecordingDelegate:weakSelf];
		[camera addRecordingSupportsDelegate:weakSelf];
		[camera addTakingPictureDelegate:weakSelf];
		if (![camera startLiveView:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartRecordingMode", @"RecordingViewController.didStartActivity")];
			return;
		}

		// デバイスのスリープを禁止します。
		// MARK: Xcodeでケーブル接続してデバッグ実行しているとスリープは発動しないようです。
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
	// MARK: weakなselfを使うとshowProgress:whileExecutingBlock:のブロックに到達する前に解放されてしまいます。
	__block RecordingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		AppCamera *camera = GetAppCamera();
		if (!camera.autoStartLiveView && !camera.liveViewEnabled) {
			DEBUG_LOG(@"Why the live view is already stopped?");
		}
		
		// ライブビューの表示を終了します。
		// MARK: ライブビュー自動開始が有効でないなら、明示的にライブビューの表示停止を呼び出さなければなりません。
		[camera removeLiveViewDelegate:weakSelf];
		[camera removeRecordingDelegate:weakSelf];
		[camera removeRecordingSupportsDelegate:weakSelf];
		[camera removeTakingPictureDelegate:weakSelf];
		NSError *error = nil;
		if (![camera stopLiveView:&error]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// カメラ設定のスナップショットを取ります。
		// FIXME: 撮影中にここに突入してきた場合にここで取ったカメラ設定のスナップショットが復元可能なのか分かりません...
		AppSetting *setting = GetAppSetting();
		if (setting.keepLastCameraSetting) {
			[weakSelf reportBlockSettingToProgress:progressView];
			NSDictionary *snapshot = [camera createSnapshotOfSetting:&error];
			if (snapshot) {
				NSDictionary *optimizedSnapshot = [camera optimizeSnapshotOfSetting:snapshot error:&error];
				if (optimizedSnapshot) {
					// ユーザー設定の更新はメインスレッドで実行しないと接続画面で監視している人が困るようです。
					// (接続画面側の画面更新がとても遅れる)
					[weakSelf executeAsynchronousBlockOnMainThread:^{
						setting.latestSnapshotOfCameraSetting = optimizedSnapshot;
					}];
				} else {
					// エラーを無視して続行します。
					DEBUG_LOG(@"An error occurred, but ignores it.");
				}
			} else {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			progressView.mode = MBProgressHUDModeIndeterminate;
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

/// このビューコントローラーの画面に戻る時に呼び出されます。
- (IBAction)exitToRecordingViewController:(UIStoryboardSegue *)segue {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"DoneRecImageView"]) {
	} else {
		// 何もしません。
	}
}

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier hasPrefix:@"Embedded"] && [segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
		// セグエは埋め込み用セグエでかつ埋め込んであるのはナビゲーションコントローラーしか許しません。
		UINavigationController *navigationController = segue.destinationViewController;
		// コントロールパネルのナビゲーションバーのドラッグを検知します。
		UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanNavigationBarInControlPanel:)];
		[navigationController.navigationBar addGestureRecognizer:gestureRecognizer];
		// コントロールパネルのナビゲーションバーのタイトルも装飾を変更します。
		UIFont *titleFont = [UIFont systemFontOfSize:17.0]; // FIXME: ナビゲーションバータイトルの省略時のフォントサイズがわからなかったのでハードコーディングしました。
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
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingSPanel" bundle:nil];
			SPanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedSPanelViewController = viewController;
		} else if ([segueIdentifier isEqualToString:@"EmbeddedEPanelViewController"]) {
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingEPanel" bundle:nil];
			EPanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedEPanelViewController = viewController;
		} else if ([segueIdentifier isEqualToString:@"EmbeddedCPanelViewController"]) {
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingCPanel" bundle:nil];
			CPanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedCPanelViewController = viewController;
		} else if ([segueIdentifier isEqualToString:@"EmbeddedAPanelViewController"]) {
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingAPanel" bundle:nil];
			APanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedAPanelViewController = viewController;
		} else if ([segueIdentifier isEqualToString:@"EmbeddedZPanelViewController"]) {
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingZPanel" bundle:nil];
			ZPanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedZPanelViewController = viewController;
		} else if ([segueIdentifier isEqualToString:@"EmbeddedVPanelViewController"]) {
			// 分割されたストーリーボードから読み込んで小画面にします。
			UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"RecordingVPanel" bundle:nil];
			VPanelViewController *viewController = [storybard instantiateInitialViewController];
			navigationController.viewControllers = @[viewController];
			self.embeddedVPanelViewController = viewController;
		} else {
			// 何もしません。
		}
	} else {
		if ([segueIdentifier isEqualToString:@"ShowRecImageViewController"]) {
			RecImageViewController *viewController = segue.destinationViewController;
			viewController.delegate = self;
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
	DEBUG_LOG(@"name=%@", name);
	
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

	// ライブビューの回転方向をライブビュー拡大表示の全体図に反映します。
	self.liveImageOverallView.orientation = self.liveImageView.image.imageOrientation;
}

- (void)cameraDidStartRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");
	
	// シャッターボタンの状態を撮影中にします。
	self.takeButton.selected = YES;
	self.takeButton.enabled = YES;

	// 撮影進捗ラベルを表示開始します。
	NSString *text = NSLocalizedString(@"$title:RecordingVideoStart", @"RecordingViewController.cameraDidStartRecordingVideo");
	self.progressLabel.text = text;
	[UIView animateWithDuration:0.25 animations:^{
		self.progressLabel.alpha = 1.0;
	}];
}

- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// シャッターボタンの状態を待機中にします。
	self.takeButton.selected = NO;
	self.takeButton.enabled = YES;

	// 撮影進捗ラベルを消去します。
	[UIView animateWithDuration:0.25 animations:^{
		self.progressLabel.alpha = 0.0;
	}];
}

- (void)camera:(OLYCamera *)camera didChangeAutoFocusResult:(NSDictionary *)result {
	DEBUG_LOG(@"result=%@", result);
	
	AppCamera *appCamera = GetAppCamera();
	if ([appCamera focusMode:nil] == AppCameraFocusModeCAF) {
		// オートフォーカスの結果を取得します。
		NSString *focusResult = result[OLYCameraTakingPictureProgressInfoFocusResultKey];
		NSValue *focusRectValue = result[OLYCameraTakingPictureProgressInfoFocusRectKey];
		DEBUG_LOG(@"focusResult=%@, focusRectValue=%@", focusResult, focusRectValue);
		if ([focusResult isEqualToString:@"ok"] && focusRectValue) {
			// オートフォーカスとフォーカスロックに成功しました。結果のフォーカス枠を表示します。
			CGRect postFocusFrameRect = [focusRectValue CGRectValue];
			[self.liveImageView showFocusFrame:postFocusFrameRect status:RecordingCameraLiveImageViewStatusLocked animated:YES];
		} else if ([focusResult isEqualToString:@"none"]) {
			// オートフォーカスできませんでした。
			// コンティニュアスオートフォーカスなので、結果のフォーカス枠の表示は合焦失敗ではなくフォーカスロック試行中に戻します。
			[self.liveImageView changeFocusFrameStatus:RecordingCameraLiveImageViewStatusRunning animated:YES];
		} else {
			// オートフォーカスできませんでした。
			// この状況は起きて欲しくないが、念のためフォーカス枠の表示は合焦失敗にしておきます。
			[self.liveImageView changeFocusFrameStatus:RecordingCameraLiveImageViewStatusFailed animated:YES];
		}
	} else {
		// 他のフォーカスモードはフォーカスロック時に必要な処理を行っているのでここでは無視します。
	}
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
	[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:ReceiveCapturedImagePreviewFailed", @"RecordingViewController.didFailToReceiveCapturedImagePreviewWithError")];
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotSaveCapturedImage", @"RecordingViewController.didReceiveCapturedImage")];
		}
	}];
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImageWithError:(NSError *)error {
	DEBUG_LOG(@"error=%@", error);

	// 進捗表示用のビューを消去します。
	[self hideProgress:YES];

	// 撮影画像の取得に失敗しました。
	[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:ReceiveCapturedImageFailed", @"RecordingViewController.didFailToReceiveCapturedImageWithError")];
}

- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera {
	DEBUG_LOG(@"");
}

- (void)cameraDidStartTakingPluralPictures:(AppCamera *)camera {
	DEBUG_LOG(@"");

	// シャッターボタンの状態を撮影中にします。
	self.takeButton.selected = YES;
	self.takeButton.enabled = YES;
	
	// 撮影進捗ラベルを表示開始します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureAutoBracketing:
			text = NSLocalizedString(@"$title:AutoBracketingStart", @"RecordingViewController.cameraDidStartTakingPluralPictures");
			break;
		case AppCameraActionTypeTakingPictureIntervalTimer:
			text = NSLocalizedString(@"$title:IntervalTimerStart", @"RecordingViewController.cameraDidStartTakingPluralPictures");
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = NSLocalizedString(@"$title:TakingPluralPicturesStart", @"RecordingViewController.cameraDidStartTakingPluralPictures");
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
	[UIView animateWithDuration:0.25 animations:^{
		self.progressLabel.alpha = 1.0;
	}];
}

- (void)cameraWillTakePictureByAutoBracketing:(AppCamera *)camera currentCount:(NSInteger)count totalCount:(NSInteger)total {
	DEBUG_LOG(@"count=%ld", (long)count);

	// 撮影進捗ラベルを表示更新します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureAutoBracketing:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:AutoBracketingProgres(%ld,%ld)", @"RecordingViewController.cameraWillTakePictureByAutoBracketing"), (long)count, (long)total];
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:TakingPluralPicturesProgres(%ld,%ld)", @"RecordingViewController.cameraWillTakePictureByAutoBracketing"), (long)count, (long)total];
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
	
	// 撮影を開始する時にフラッシュ表現を開始します。
	[self.liveImageView showFlashing:YES];
}

- (void)cameraDidTakePictureByAutoBracketing:(AppCamera *)camera currentCount:(NSInteger)count totalCount:(NSInteger)total {
	DEBUG_LOG(@"count=%ld", (long)count);

	// 撮影進捗ラベルを表示更新します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureAutoBracketing:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:AutoBracketingProgres(%ld,%ld)", @"RecordingViewController.cameraDidTakePictureByAutoBracketing"), (long)count, (long)total];
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:TakingPluralPicturesProgres(%ld,%ld)", @"RecordingViewController.cameraDidTakePictureByAutoBracketing"), (long)count, (long)total];
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
	
	// 撮影を完了した時にフラッシュ表現を終了します。
	[self.liveImageView hideFlashing:YES];
}

- (void)cameraWillTakePictureByIntervalTimer:(AppCamera *)camera currentCount:(NSInteger)count totalCount:(NSInteger)total {
	DEBUG_LOG(@"count=%ld", (long)count);
	
	// 撮影進捗ラベルを表示更新します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureIntervalTimer:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:IntervalTimerProgres(%ld,%ld)", @"RecordingViewController.cameraWillTakePictureByIntervalTimer"), (long)count, (long)total];
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:TakingPluralPicturesProgres(%ld,%ld)", @"RecordingViewController.cameraWillTakePictureByIntervalTimer"), (long)count, (long)total];
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
	
	// 撮影を開始する時にフラッシュ表現を開始します。
	[self.liveImageView showFlashing:YES];
}

- (void)cameraDidTakePictureByIntervalTimer:(AppCamera *)camera currentCount:(NSInteger)count totalCount:(NSInteger)total {
	DEBUG_LOG(@"count=%ld", (long)count);

	// 撮影進捗ラベルを表示更新します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureIntervalTimer:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:IntervalTimerProgres(%ld,%ld)", @"RecordingViewController.cameraDidTakePictureByIntervalTimer"), (long)count, (long)total];
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:TakingPluralPicturesProgres(%ld,%ld)", @"RecordingViewController.cameraDidTakePictureByIntervalTimer"), (long)count, (long)total];
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
	
	// 撮影を完了した時にフラッシュ表現を終了します。
	[self.liveImageView hideFlashing:YES];
}

- (void)cameraDidPauseTakingPictureForIntervalTimer:(AppCamera *)camera remainTime:(NSTimeInterval)remain currentCount:(NSInteger)current totalCount:(NSInteger)total {
	DEBUG_DETAIL_LOG(@"remain=%f, count=%ld, total=%ld", remain, (long)count, (long)total);

	// 撮影進捗ラベルを表示更新します。
	NSString *text = nil;
	switch ([camera cameraActionType]) {
		case AppCameraActionTypeTakingPictureIntervalTimer:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:IntervalTimerProgres(%f,%ld,%ld)", @"RecordingViewController.cameraDidPauseTakingPictureForIntervalTimer"), remain, (long)current, (long)total];
			break;
		case AppCameraActionTypeTakingPictureCombination:
			text = [NSString stringWithFormat:NSLocalizedString(@"$title:TakingPluralPicturesProgres(%f,%ld,%ld)", @"RecordingViewController.cameraDidPauseTakingPictureForIntervalTimer"), remain, (long)current, (long)total];
			break;
		default:
			DEBUG_LOG(@"Program Error !");
	}
	self.progressLabel.text = text;
}

- (void)cameraDidStopTakingPluralPictures:(AppCamera *)camera error:(NSError *)error {
	DEBUG_LOG(@"error=%@", error);
	
	// シャッターボタンの状態を待機中にします。
	self.takeButton.selected = NO;
	self.takeButton.enabled = YES;
	
	// 撮影進捗ラベルを消去します。
	[UIView animateWithDuration:0.25 animations:^{
		self.progressLabel.alpha = 0.0;
	}];

	if (error) {
		// エラー終了して中途半端になっているかもしれない、フラッシュ表現を終了します。
		[self.liveImageView hideFlashing:NO];

		// オートブラケット撮影に失敗しました。
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:TakingPluralPicturesFailed", @"RecordingViewController.cameraDidStopTakingPluralPictures")];
	}
}

/// 撮影後確認画像表示で画像が削除された時に呼び出されます。
- (void)recImageViewControllerDidEraseImage:(RecImageViewController *)controller {
	DEBUG_LOG(@"");
	
	// レックビューの表示を消去します。
	self.latestRecImage = nil;
	[self.recImageButton setImage:nil];
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

/// アスペクト比の値が変わった時に呼び出されます。
- (void)didChangeAspectRatio {
	DEBUG_LOG(@"");

	__weak RecordingViewController *weakSelf = self;
	[self executeAsynchronousBlock:^{
		AppCamera *camera = GetAppCamera();
		if (camera.magnifyingLiveView) {
			// 拡大率変更後の表示位置を取得します。
			NSError *error = nil;
			NSDictionary *area = [camera magnifyingLiveViewArea:&error];
			if (!area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]) {
				// FIXME: エラーを無視します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
				return;
			}
			CGSize overallViewSize = [area[OLYCameraMagnifyingOverallViewSizeKey] CGSizeValue];
			CGRect displayAreaRect = [area[OLYCameraMagnifyingDisplayAreaRectKey] CGRectValue];
			DEBUG_LOG(@"overallViewSize=%@", NSStringFromCGSize(overallViewSize));
			DEBUG_LOG(@"displayAreaRect=%@", NSStringFromCGRect(displayAreaRect));

			// ライブビュー拡大表示コントローラを更新します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.liveImageOverallView.overallViewSize = overallViewSize;
				[weakSelf.liveImageOverallView setDisplayAreaRect:displayAreaRect animated:YES];
				weakSelf.liveImageOverallView.orientation = weakSelf.liveImageView.image.imageOrientation;
			}];
		}
	}];
}

/// 顔認識情報の状態が変わった時に呼び出されます。
- (void)didChangeDetectedHumanFaces:(NSDictionary *)change {
	DEBUG_LOG(@"");

	// 顔の数が少ない時は期待通りにそのオブジェクトを追跡しますが、顔の数が多い場合の挙動を観察して見る限り、
	// 一度認識した顔を追跡する(インデックスが変化しない)わけではなく、ライブビュー画像ごとに認識しなおしている
	// (同じオブジェクトでも違うインデックスが割当られている)ように思えます。
	
	// MARK: カメラの顔認識情報の内容をライブビューの顔認識情報にコピーします。
	// カメラプロパティのdetectedHumanFacesを取得してからその中を参照するようにしないと、顔認識結果に変化が
	// あるたびにメインスレッド以外のところでdetectedHumanFacesのオブジェクトツリーが丸ごと入れ替わらしく、
	// camra.detectedHumanFacesの要素を直に参照したらメモリ違反で異常終了したりする場合があります。
	AppCamera *camera = GetAppCamera();
	NSDictionary *detectedHumanFaces = camera.detectedHumanFaces;
	[self.liveImageView showFaceFrames:detectedHumanFaces animated:YES];
}

/// 動画撮影経過時間が変わった時に呼び出されます。
- (void)didChangeRecordingElapsedTime:(NSDictionary *)change {
	DEBUG_DETAIL_LOG(@"");

	// 動画撮影経過時間を取得します。
	AppCamera *camera = GetAppCamera();
	NSInteger time = (NSInteger)camera.recordingElapsedTime;
	NSInteger minutes = time / 60;
	NSInteger seconds = time % 60;

	// 撮影進捗ラベルを表示更新します。
	NSString *text = [NSString stringWithFormat:NSLocalizedString(@"$title:RecordingVideo(%ld,%ld)", @"RecordingViewController.didChangeRecordingElapsedTime"), (long)minutes, (long)seconds];
	self.progressLabel.text = text;
}

/// ライブビュー拡大の状態が変わった時に呼び出されます。
- (void)didChangeMagnifyingLiveView:(NSDictionary *)change {
	DEBUG_LOG(@"");

	__weak RecordingViewController *weakSelf = self;
	[self executeAsynchronousBlock:^{
		AppCamera *camera = GetAppCamera();
		if (camera.magnifyingLiveView) {
			// 最初の表示位置を取得します。
			NSError *error = nil;
			NSDictionary *area = [camera magnifyingLiveViewArea:&error];
			if (!area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]) {
				// FIXME: エラーを無視します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
				return;
			}
			CGSize overallViewSize = [area[OLYCameraMagnifyingOverallViewSizeKey] CGSizeValue];
			CGRect displayAreaRect = [area[OLYCameraMagnifyingDisplayAreaRectKey] CGRectValue];
			DEBUG_LOG(@"overallViewSize=%@", NSStringFromCGSize(overallViewSize));
			DEBUG_LOG(@"displayAreaRect=%@", NSStringFromCGRect(displayAreaRect));
			
			// ライブビュー拡大表示コントローラを表示します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.liveImageOverallView.overallViewSize = overallViewSize;
				weakSelf.liveImageOverallView.displayAreaRect = displayAreaRect;
				weakSelf.liveImageOverallView.orientation = weakSelf.liveImageView.image.imageOrientation;
				[UIView animateWithDuration:0.25 animations:^{
					weakSelf.liveImageOverallView.alpha = 1.0;
					weakSelf.moveToUpButton.alpha = 1.0;
					weakSelf.moveToLeftButton.alpha = 1.0;
					weakSelf.moveToRightButton.alpha = 1.0;
					weakSelf.moveToDownButton.alpha = 1.0;
				}];
			}];
		} else {
			// ライブビュー拡大表示コントローラを消去します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[UIView animateWithDuration:0.25 animations:^{
					weakSelf.liveImageOverallView.alpha = 0.0;
					weakSelf.moveToUpButton.alpha = 0.0;
					weakSelf.moveToLeftButton.alpha = 0.0;
					weakSelf.moveToRightButton.alpha = 0.0;
					weakSelf.moveToDownButton.alpha = 0.0;
				}];
			}];
		}
	}];
}

/// ライブビュー拡大の拡大率が変わった時に呼び出されます。
- (void)didChangeMagnifyingLiveViewScale:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	__weak RecordingViewController *weakSelf = self;
	[self executeAsynchronousBlock:^{
		AppCamera *camera = GetAppCamera();
		if (camera.magnifyingLiveView) {
			// 拡大率変更後の表示位置を取得します。
			NSError *error = nil;
			NSDictionary *area = [camera magnifyingLiveViewArea:&error];
			if (!area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]) {
				// FIXME: エラーを無視します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
				return;
			}
			CGSize overallViewSize = [area[OLYCameraMagnifyingOverallViewSizeKey] CGSizeValue];
			CGRect displayAreaRect = [area[OLYCameraMagnifyingDisplayAreaRectKey] CGRectValue];
			DEBUG_LOG(@"overallViewSize=%@", NSStringFromCGSize(overallViewSize));
			DEBUG_LOG(@"displayAreaRect=%@", NSStringFromCGRect(displayAreaRect));
			
			// ライブビュー拡大表示コントローラを更新します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.liveImageOverallView.overallViewSize = overallViewSize;
				[weakSelf.liveImageOverallView setDisplayAreaRect:displayAreaRect animated:YES];
				weakSelf.liveImageOverallView.orientation = weakSelf.liveImageView.image.imageOrientation;
			}];
		}
	}];
}

/// ライブビューがタップされた時に呼び出されます。
- (IBAction)didTapLiveImageView:(UITapGestureRecognizer *)sender {
	DEBUG_LOG(@"");

	// ライブビューパネルでタップした時の動作を取得します。
	AppSetting *setting = GetAppSetting();
	AppSettingLiveViewTappingAction action = setting.liveViewTappingAction;

	if (action == AppSettingLiveViewTappingActionUnknown) {
		// 何もしません。
	} else if (action == AppSettingLiveViewTappingActionAF) {
		// タップされた座標にオートフォーカスロックします。
		CGPoint point = [self.liveImageView pointWithGestureRecognizer:sender];
		[self lockAutoFocusPoint:point];
	} else if (action == AppSettingLiveViewTappingActionAE) {
		// タップされた座標に自動露出ロックします。
		CGPoint point = [self.liveImageView pointWithGestureRecognizer:sender];
		[self lockAutoExposurePoint:point];
	} else {
		// 何もしません。
	}
}

/// ライブビューがロングタップされた時に呼び出されます。
- (IBAction)didLongPressLiveImageView:(UILongPressGestureRecognizer *)sender {
	DEBUG_LOG(@"sender.state=%ld", (long)sender.state);
	
	// ロングタップの開始以外は無視します。
	if (sender.state != UIGestureRecognizerStateBegan) {
		return;
	}

	// ライブビュー拡大を開始または終了します。
	AppCamera *camera = GetAppCamera();
	if (camera.magnifyingLiveView) {
		[self stopMagnifyingLiveView];
	} else {
		// MARK: ライブビュー拡大開始の座標はオートフォーカスロックや自動露出ロックのような制限範囲がないようです。
		CGPoint point = [self.liveImageView pointWithGestureRecognizer:sender];
		[self startMagnifyingLiveView:point];
	}
}

/// 'TAKE'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapTakeButton:(UITapGestureRecognizer *)sender {
	DEBUG_LOG(@"");

	// 現在設定されている撮影モードと現在実行されている撮影状態から何をすべきかを決めます。
	AppCamera *camera = GetAppCamera();
	AppCameraActionType actionType = [camera cameraActionType];
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];

	if (actionType == AppCameraActionTypeTakingPictureSingle) {
		if (actionStatus == AppCameraActionStatusReady) {
			[self takePicture];
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	} else if (actionType == AppCameraActionTypeTakingPictureSequential) {
		if (actionStatus == AppCameraActionStatusReady) {
			[self takePicture];
		} else if (actionStatus == AppCameraActionStatusTakingPictureSequential) {
			[self stopTakingPicture];
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	} else if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
			   actionType == AppCameraActionTypeTakingPictureIntervalTimer ||
			   actionType == AppCameraActionTypeTakingPictureCombination) {
		if (actionStatus == AppCameraActionStatusReady) {
			[self startTakingPluralPictures];
		} else if (actionStatus == AppCameraActionStatusTakingPictureAutoBracketing ||
				   actionStatus == AppCameraActionStatusTakingPictureIntervalTimer ||
				   actionStatus == AppCameraActionStatusTakingPictureCombination) {
			[self stopTakingPluralPictures];
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	} else if (actionType == AppCameraActionTypeRecordingVideo) {
		if (actionStatus == AppCameraActionStatusReady) {
			[self startRecordingVideo];
		} else if (actionStatus == AppCameraActionStatusRecordingVideo) {
			[self stopRecordingVideo];
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	} else {
		DEBUG_LOG(@"ignore user action.");
	}
}

/// 'TAKE'ボタンがロングタップされた時に呼び出されます。
- (IBAction)didLongPressTakeButton:(UILongPressGestureRecognizer *)sender {
	DEBUG_LOG(@"sender.state=%ld", (long)sender.state);

	// 現在設定されている撮影モードと現在実行されている撮影状態から何をすべきかを決めます。
	AppCamera *camera = GetAppCamera();
	AppCameraActionType actionType = [camera cameraActionType];
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];

	if (sender.state == UIGestureRecognizerStateBegan) {
		// ロングタップの押し始め
		if (actionType == AppCameraActionStatusTakingPictureSingle) {
			if (actionStatus == AppCameraActionStatusReady) {
				[self takePicture];
			} else {
				DEBUG_LOG(@"ignore user action.");
			}
		} else if (actionType == AppCameraActionStatusTakingPictureSequential) {
			if (actionStatus == AppCameraActionStatusReady) {
				[self startTakingPicture];
			} else if (actionStatus == AppCameraActionStatusTakingPictureSequential) {
				[self stopTakingPicture];
			} else {
				DEBUG_LOG(@"ignore user action.");
			}
		} else if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
				   actionType == AppCameraActionTypeTakingPictureIntervalTimer ||
				   actionType == AppCameraActionTypeTakingPictureCombination) {
			if (actionStatus == AppCameraActionStatusReady) {
				[self startTakingPluralPictures];
			} else if (actionStatus == AppCameraActionStatusTakingPictureAutoBracketing ||
					   actionStatus == AppCameraActionStatusTakingPictureIntervalTimer ||
					   actionStatus == AppCameraActionStatusTakingPictureCombination) {
				[self stopTakingPluralPictures];
			} else {
				DEBUG_LOG(@"ignore user action.");
			}
		} else if (actionType == AppCameraActionStatusRecordingVideo) {
			if (actionStatus == AppCameraActionStatusReady) {
				[self startRecordingVideo];
			} else if (actionStatus == AppCameraActionStatusRecordingVideo) {
				[self stopRecordingVideo];
			} else {
				DEBUG_LOG(@"ignore user action.");
			}
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	} else if (sender.state == UIGestureRecognizerStateEnded ||
			   sender.state == UIGestureRecognizerStateCancelled) {
		// ロングタップの押し終わり
		if (actionType == AppCameraActionStatusTakingPictureSequential) {
			if (actionStatus == AppCameraActionStatusTakingPictureSequential) {
				[self stopTakingPicture];
			} else {
				DEBUG_LOG(@"ignore user action.");
			}
		} else {
			DEBUG_LOG(@"ignore user action.");
		}
	}
}

/// 'U'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapMoveToUpButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 拡大表示中のライブビューを表示範囲を移動します。
	__weak RecordingViewController *weakSelf = self;
	weakSelf.moveToUpButton.selected = YES;
	[self changeMagnifyingLiveViewArea:OLYCameraMagnifyingLiveViewScrollDirectionUp completion:^{
		weakSelf.moveToUpButton.selected = NO;
	}];
}

/// 'L'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapMoveToLeftButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 拡大表示中のライブビューを表示範囲を移動します。
	__weak RecordingViewController *weakSelf = self;
	weakSelf.moveToLeftButton.selected = YES;
	[self changeMagnifyingLiveViewArea:OLYCameraMagnifyingLiveViewScrollDirectionLeft completion:^{
		weakSelf.moveToLeftButton.selected = NO;
	}];
}

/// 'R'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapMoveToRightButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 拡大表示中のライブビューを表示範囲を移動します。
	__weak RecordingViewController *weakSelf = self;
	weakSelf.moveToRightButton.selected = YES;
	[self changeMagnifyingLiveViewArea:OLYCameraMagnifyingLiveViewScrollDirectionRight completion:^{
		weakSelf.moveToRightButton.selected = NO;
	}];
}

/// 'D'ボタンがタップされた時に呼び出されます。
- (IBAction)didTapMoveToDownButton:(id)sender {
	DEBUG_LOG(@"");
	
	// 拡大表示中のライブビューを表示範囲を移動します。
	__weak RecordingViewController *weakSelf = self;
	weakSelf.moveToDownButton.selected = YES;
	[self changeMagnifyingLiveViewArea:OLYCameraMagnifyingLiveViewScrollDirectionDown completion:^{
		weakSelf.moveToDownButton.selected = NO;
	}];
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
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
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

/// コントロールパネルのナビゲーションバーがドラッグされた時に呼び出されます。
- (IBAction)didPanNavigationBarInControlPanel:(UIPanGestureRecognizer *)sender {
	DEBUG_DETAIL_LOG(@"sender=%@", sender);

	AppCamera *camera = GetAppCamera();
	if (sender.state == UIGestureRecognizerStateBegan) {
		// ドラッグを開始しました。

		// 一時的にライブビューを止めて表示のチラツキを食い止めます。
		NSError *error = nil;
		if (![camera stopLiveView:&error]) {
			// エラーは無視して続行します。
		}
		[UIView animateWithDuration:0.25 animations:^{
			self.cameraPanelView.alpha = 0.5;
		}];
		
		// ドラッグで移動した距離をリセットします。
		[sender setTranslation:CGPointZero inView:self.view];
		
	} else if (sender.state == UIGestureRecognizerStateChanged) {
		// ドラッグを継続しています。
		
		// ドラッグで変化したコントロールパネルのサイズを求めます。
		CGPoint delta = [sender translationInView:self.view];
		CGFloat draggedWidth = self.finderPanelView.bounds.size.width * self.controlPanelWidthRatio - delta.x;
		CGFloat draggedHeight = self.finderPanelView.bounds.size.height * self.controlPanelHeightRatio - delta.y;
		
		// コントロールパネルが操作できなくなるほどサイズを変更できないように制限を加えるため、サイズ変更の上限と下限を求めます。
		// 制限値のマージンはそれぞれ適当な値です。
		CGFloat minimumWidth = 160.0;
		CGFloat minimumHeight = self.navigationController.navigationBar.frame.size.height;
		CGFloat margin = (64.0 + 8.0 * 2); // 撮影後確認画像ボタン分は余白を残しておきます。
		CGFloat maximumWidth = self.finderPanelView.bounds.size.width - margin;
		CGFloat maximumHeight = self.finderPanelView.bounds.size.height - margin;
		
		// 画面に対するコントロールパネルのサイズ割合を更新します。
		CGFloat width = MIN(MAX(draggedWidth, minimumWidth), maximumWidth);
		CGFloat height = MIN(MAX(draggedHeight, minimumHeight), maximumHeight);
		if (self.controlPanelViewWidthConstraints.active) {
			self.controlPanelWidthRatio = width / self.finderPanelView.bounds.size.width;
		}
		if (self.controlPanelViewHeightConstraints.active) {
			self.controlPanelHeightRatio = height / self.finderPanelView.bounds.size.height;
		}
		
		// コントロールパネルのサイズを更新します。
		[self executeAsynchronousBlockOnMainThread:^{
			if (self.controlPanelViewWidthConstraints.active) {
				self.controlPanelViewWidthConstraints.constant = width;
			}
			if (self.controlPanelViewHeightConstraints.active) {
				self.controlPanelViewHeightConstraints.constant = height;
			}
		}];

		// ドラッグで移動した距離をリセットします。
		[sender setTranslation:CGPointZero inView:self.view];
		
	} else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
		// ドラッグを終了しました。
		
		// ライブビューを再開します。
		NSError *error = nil;
		if (![camera startLiveView:&error]) {
			// エラーは無視して続行します。
		}
		[UIView animateWithDuration:0.25 animations:^{
			self.cameraPanelView.alpha = 1.0;
		}];
	}
}

#pragma mark -

/// オートフォーカスしてフォーカスロックします。
- (void)lockAutoFocusPoint:(CGPoint)point {
	DEBUG_LOG(@"point=%@", NSStringFromCGPoint(point));

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// ライブビューが表示されていない場合はエラーとします。
	if (!self.liveImageView || !self.liveImageView.image) {
		[self showAlertMessage:NSLocalizedString(@"$desc:LiveViewImageIsEmpty", @"RecordingViewController.lockAutoFocusPoint") title:NSLocalizedString(@"$title:LiveViewImageIsEmpty", @"RecordingViewController.lockAutoFocusPoint")];
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
			if ([camera focusMode:nil] == AppCameraFocusModeCAF) {
				// MARK: コンティニュアスオートフォーカスはこのタイミングで合焦結果を返さないようです。
				// この後にいつか発生する合焦のデリゲートで残りの表示を行います。
			} else {
				[camera clearAutoFocusPoint:nil];
				[camera unlockAutoFocus:nil];
				[weakSelf.liveImageView showFocusFrame:preFocusFrameRect status:RecordingCameraLiveImageViewStatusFailed duration:1.0 animated:YES];
			}
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
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}
	
	// ライブビューが表示されていない場合はエラーとします。
	if (!self.liveImageView || !self.liveImageView.image) {
		[self showAlertMessage:NSLocalizedString(@"$desc:LiveViewImageIsEmpty", @"RecordingViewController.lockAutoExposurePoint") title:NSLocalizedString(@"$title:LiveViewImageIsEmpty", @"RecordingViewController.lockAutoExposurePoint")];
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

/// ライブビュー拡大を開始します。
- (void)startMagnifyingLiveView:(CGPoint)point {
	DEBUG_LOG(@"point=%@", NSStringFromCGPoint(point));
	
	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}
	
	// ライブビューが表示されていない場合はエラーとします。
	if (!self.liveImageView || !self.liveImageView.image) {
		[self showAlertMessage:NSLocalizedString(@"$desc:LiveViewImageIsEmpty", @"RecordingViewController.startMagnifyingLiveView") title:NSLocalizedString(@"$title:LiveViewImageIsEmpty", @"RecordingViewController.startMagnifyingLiveView")];
		return;
	}
	
	// タッチした座標が明らかに領域外の時はエラーとします。
	if (![self.liveImageView containsPoint:point]) {
		DEBUG_LOG(@"ignore the point: point=%@", NSStringFromCGPoint(point));
		return;
	}
	
	// ライブビュー拡大開始を開始します。
	__weak RecordingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progress) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// ライブビュー拡大を開始します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera startMagnifyingLiveViewAtPoint:point error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartMagnifying", @"RecordingViewController.startMagnifyingLiveView")];
			return;
		}
		
		// ライブビュー拡大開始が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// ライブビュー拡大を終了します。
- (void)stopMagnifyingLiveView {
	DEBUG_LOG(@"");
	
	// ライブビュー拡大終了を開始します。
	__weak RecordingViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progress) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// ライブビュー拡大を終了します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera stopMagnifyingLiveView:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStopMagnifying", @"RecordingViewController.stopMagnifyingLiveView")];
			return;
		}
		
		// ライブビュー拡大終了が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// 静止画を単写撮影します。
- (void)takePicture {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotTakePicture", @"RecordingViewController.takePicture")];
		return;
	}
	
	// 単写撮影します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	// シャッターボタンの状態を準備中にします。
	weakSelf.takeButton.selected = NO;
	weakSelf.takeButton.enabled = NO;
	[camera takePicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		if (progress == OLYCameraTakingProgressEndFocusing) {
			// この撮影中にフォーカスロックした場合はオートフォーカス枠を表示します。
			if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
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
			// シャッターボタンの状態を撮影中にします。
			weakSelf.takeButton.selected = YES;
			weakSelf.takeButton.enabled = YES;
			// 撮影を開始する時にフラッシュ表現を開始します。
			[weakSelf.liveImageView showFlashing:YES];
		} else if (progress == OLYCameraTakingProgressFinished) {
			// 撮影を完了した時にフラッシュ表現を終了します。
			[weakSelf.liveImageView hideFlashing:YES];
		}
	} completionHandler:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を待機中にします。
		weakSelf.takeButton.selected = NO;
		weakSelf.takeButton.enabled = YES;
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を待機中にします。
		weakSelf.takeButton.selected = NO;
		weakSelf.takeButton.enabled = YES;
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotTakePicture", @"RecordingViewController.takePicture")];
	}];
}

/// 静止画の連写撮影を開始します。
- (void)startTakingPicture {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}
	
	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartTakingPicture", @"RecordingViewController.startTakingPicture")];
		return;
	}

	// 連写撮影を開始します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[camera startTakingPicture:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		if (progress == OLYCameraTakingProgressEndFocusing) {
			// この撮影中にフォーカスロックした場合はオートフォーカス枠を表示します。
			if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
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
		// シャッターボタンの状態を撮影中にします。
		weakSelf.takeButton.selected = YES;
		// 連写撮影を継続します。
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartTakingPicture", @"RecordingViewController.startTakingPicture")];
	}];
}

/// 静止画の連写撮影を終了します。
- (void)stopTakingPicture {
	DEBUG_LOG(@"");

	// 撮影中の時以外は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusTakingPictureSequential) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
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
		// シャッターボタンの状態を待機中にします。
		weakSelf.takeButton.selected = NO;
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// 撮影に失敗しました。
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStopTakingPicture", @"RecordingViewController.stopTakingPicture")];
	}];
}

/// 静止画のオートブラケット＋インターバルタイマー撮影を開始します。
- (void)startTakingPluralPictures {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// フォーカスロックしてから撮影をしようとしているのか、この撮影中にフォーカスロックするのかを確認します。
	NSError *error = nil;
	NSString *afLockState = [camera cameraPropertyValue:CameraPropertyAfLockState error:&error];
	DEBUG_LOG(@"afLockState=%@", afLockState);
	if (!afLockState) {
		[self showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartTakingPluralPictures", @"RecordingViewController.startTakingPluralPictures")];
		return;
	}
	
	// オートブラケット＋インターバルタイマー撮影を開始します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	// シャッターボタンの状態を準備中にします。
	weakSelf.takeButton.selected = NO;
	weakSelf.takeButton.enabled = NO;
	[camera startTakingPluralPictures:nil progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
		DEBUG_LOG(@"progress=%ld, info=%p", (long)progress, info);
		if (progress == OLYCameraTakingProgressEndFocusing) {
			// この撮影中にフォーカスロックした場合はオートフォーカス枠を表示します。
			if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
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
		// シャッターボタンの状態を撮影中にします。
		weakSelf.takeButton.selected = YES;
		weakSelf.takeButton.enabled = YES;
		// オートブラケット＋インターバルタイマー撮影を継続します。
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を待機中にします。
		weakSelf.takeButton.selected = NO;
		weakSelf.takeButton.enabled = YES;
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartTakingPluralPictures", @"RecordingViewController.startTakingPluralPictures")];
	}];
}

/// 静止画のオートブラケット＋インターバルタイマー撮影を終了します。
- (void)stopTakingPluralPictures {
	DEBUG_LOG(@"");

	// 撮影中の時以外は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusTakingPictureAutoBracketing &&
		actionStatus != AppCameraActionStatusTakingPictureIntervalTimer &&
		actionStatus != AppCameraActionStatusTakingPictureCombination) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
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
	
	// オートブラケット＋インターバルタイマー撮影を終了します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	// シャッターボタンの状態を準備中にします。
	weakSelf.takeButton.selected = NO;
	weakSelf.takeButton.enabled = NO;
	[camera stopTakingPluralPictures:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// MARK: シャッターボタンの状態変更はオートブラケット＋インターバルタイマー撮影の完了通知にお任せします。
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を撮影中にします。
		weakSelf.takeButton.selected = YES;
		weakSelf.takeButton.enabled = YES;
		// 撮影に失敗しました。
		// この撮影中にフォーカスロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			[camera clearAutoFocusPoint:nil];
			[weakSelf.liveImageView hideFocusFrame:YES];
		}
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStopTakingPluralPictures", @"RecordingViewController.stopTakingPicturePluralPictures")];
	}];
}

/// 動画の撮影を開始します。
- (void)startRecordingVideo {
	DEBUG_LOG(@"");

	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// 動画撮影を開始します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	// シャッターボタンの状態を準備中にします。
	weakSelf.takeButton.selected = NO;
	weakSelf.takeButton.enabled = NO;
	[camera startRecordingVideo:nil completionHandler:^{
		DEBUG_LOG(@"");
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// MARK: 動画撮影を開始しても動画撮影開始通知は呼び出されないようなので自力で呼び出します。
		[weakSelf cameraDidStartRecordingVideo:camera];
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を待機中にします。
		weakSelf.takeButton.selected = NO;
		weakSelf.takeButton.enabled = YES;
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartRecordingVideo", @"RecordingViewController.startRecordingVideo")];
	}];
}

/// 動画の撮影を終了します。
- (void)stopRecordingVideo {
	DEBUG_LOG(@"");

	// 撮影中の時以外は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusRecordingVideo) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// 動画撮影を終了します。
	__weak RecordingViewController *weakSelf = self;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	// シャッターボタンの状態を準備中にします。
	weakSelf.takeButton.selected = NO;
	weakSelf.takeButton.enabled = NO;
	[camera stopRecordingVideo:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// MARK: カメラ側の録画終了の合図が遅れるようなので、アプリの録画終了も少し遅延させます。
		dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC));
		dispatch_after(delay, dispatch_get_main_queue(), ^{
			// MARK: 動画撮影を終了しても動画撮影終了通知は呼び出されないようなので自力で呼び出します。
			[weakSelf cameraDidStopRecordingVideo:camera];
		});
	} errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		// シャッターボタンの状態を撮影中にします。
		weakSelf.takeButton.selected = YES;
		weakSelf.takeButton.enabled = YES;
		// 撮影に失敗しました。
		[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStopRecordingVideo", @"RecordingViewController.stopRecordingVideo")];
	}];
}

/// 拡大表示中のライブビューを表示範囲を移動します。
- (void)changeMagnifyingLiveViewArea:(OLYCameraMagnifyingLiveViewScrollDirection)direction completion:(void (^)())completionHandler {
	DEBUG_LOG(@"direction=%ld", (long)direction);
	
	// 撮影中の時は何もできません。
	AppCamera *camera = GetAppCamera();
	AppCameraActionStatus actionStatus = [camera cameraActionStatus];
	if (actionStatus != AppCameraActionStatusReady) {
		DEBUG_LOG(@"actionStatus=%ld", (long)actionStatus);
		return;
	}

	// ライブビューを拡大していな時は何もできません。
	if (!camera.magnifyingLiveView) {
		DEBUG_LOG(@"camera.magnifyingLiveView=%ld", (long)camera.magnifyingLiveView);
		return;
	}
	
	// MARK: ライブビューが回転している方向に合わせて、表示範囲の移動方向も補正する必要があるようです。
	if (self.liveImageView.image) {
		UIImageOrientation orientation = self.liveImageView.image.imageOrientation;
		switch (orientation) {
			case UIImageOrientationUp:
				// 移動方向はそのままです。
				break;
			case UIImageOrientationDown:
				// 画像が180度回転しているので、移動方向も180度捻ります。
				switch (direction) {
					case OLYCameraMagnifyingLiveViewScrollDirectionUp:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionDown;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionDown:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionUp;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionLeft:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionRight;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionRight:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionLeft;
						break;
				}
				break;
			case UIImageOrientationLeft:
				// 画像が時計回りに90度回転しているので、移動方向も90度捻ります。
				switch (direction) {
					case OLYCameraMagnifyingLiveViewScrollDirectionUp:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionRight;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionDown:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionLeft;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionLeft:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionUp;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionRight:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionDown;
						break;
				}
				break;
			case UIImageOrientationRight:
				// 画像が半時計回りに90度回転しているので、移動方向も90度捻ります。
				switch (direction) {
					case OLYCameraMagnifyingLiveViewScrollDirectionUp:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionLeft;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionDown:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionRight;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionLeft:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionDown;
						break;
					case OLYCameraMagnifyingLiveViewScrollDirectionRight:
						direction = OLYCameraMagnifyingLiveViewScrollDirectionUp;
						break;
				}
				break;
			default:
				// ありえません。
				break;
		}
	}
	
	// 表示範囲を移動します。
	__weak RecordingViewController *weakSelf = self;
	[self executeAsynchronousBlock:^{
		NSError *error = nil;
		if (![camera changeMagnifyingLiveViewArea:direction error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotChangeMagnifyingViewArea", @"RecordingViewController.changeMagnifyingLiveViewArea")];
		}
		
		// 移動後の表示位置を取得します。
		NSDictionary *area = [camera magnifyingLiveViewArea:&error];
		if (!area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]) {
			// FIXME: エラーを無視します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
			return;
		}
		CGSize overallViewSize = [area[OLYCameraMagnifyingOverallViewSizeKey] CGSizeValue];
		CGRect displayAreaRect = [area[OLYCameraMagnifyingDisplayAreaRectKey] CGRectValue];
		DEBUG_LOG(@"overallViewSize=%@", NSStringFromCGSize(overallViewSize));
		DEBUG_LOG(@"displayAreaRect=%@", NSStringFromCGRect(displayAreaRect));
		
		// ライブビュー拡大表示コントローラを更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakSelf.liveImageOverallView.overallViewSize = overallViewSize;
			[weakSelf.liveImageOverallView setDisplayAreaRect:displayAreaRect animated:YES];
			weakSelf.liveImageOverallView.orientation = weakSelf.liveImageView.image.imageOrientation;
			
			// 移動完了です。
			if (completionHandler) {
				completionHandler();
			}
		}];
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
		if (self.controlPanelVisibleStatus == ControlPanelVisibleStatusHidden) {
			// コントロールパネルを開いた時のサイズ比率を初期化します。
			CGFloat widthRatio = 0.5;
			CGFloat heightRatio = 0.5;
			
			// iPadだと広がりすぎるのでiPhoneの縦置きと同じ幅に制限します。(高さは適当な値です)
			CGFloat width = self.finderPanelView.bounds.size.width * widthRatio;
			CGFloat height = self.finderPanelView.bounds.size.height * heightRatio;
			widthRatio = MIN(width, 320.0) / self.finderPanelView.bounds.size.width;
			heightRatio = MIN(height, (240.0 + 64.0)) / self.finderPanelView.bounds.size.height;

			// コントロールパネルのサイズ比率を更新します。
			self.controlPanelWidthRatio = widthRatio;
			self.controlPanelHeightRatio = heightRatio;
			
			// コントロールパネルを表示します。
			[self showPanel:status animated:YES];
		} else {
			// この処理ブロックの実装はshowPanelメソッドと似ていてリファクタリングの余地あり
			
			// コントロールパネルは表示されているので、その中のパネルを切り替えます。
			NSDictionary *panels = @{
				@(ControlPanelVisibleStatusSPanel): self.SPanelView,
				@(ControlPanelVisibleStatusEPanel): self.EPanelView,
				@(ControlPanelVisibleStatusCPanel): self.CPanelView,
				@(ControlPanelVisibleStatusAPanel): self.APanelView,
				@(ControlPanelVisibleStatusZPanel): self.ZPanelView,
				@(ControlPanelVisibleStatusVPanel): self.VPanelView,
			};
			UIView *currentPanel = panels[@(self.controlPanelVisibleStatus)]; // 現在表示されているパネル
			UIView *nextPanel = panels[@(status)]; // 次に表示するパネル
			if (animated) {
				// パネルの切り替えはフェードアニメーションします。
				[self.controlPanelView bringSubviewToFront:nextPanel];
				nextPanel.hidden = NO;
				nextPanel.alpha = 1.0;
				[self.controlPanelView bringSubviewToFront:currentPanel];
				// バシバシ切り替えられると困るのでアニメーションが完了するまでタッチ禁止にしておきます。
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[UIView animateWithDuration:0.25 animations:^{
					currentPanel.alpha = 0.0;
				} completion:^(BOOL finished) {
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					currentPanel.hidden = YES;
					currentPanel.alpha = 1.0;
				}];
			} else {
				// パネルを即時切り替えます。
				currentPanel.hidden = YES;
				nextPanel.hidden = NO;
			}

			// 指定されたパネルのボタンだけを選択状態にして残りのパネルのボタンは選択解除にします。
			self.showSPanelButton.selected = (status == ControlPanelVisibleStatusSPanel);
			self.showEPanelButton.selected = (status == ControlPanelVisibleStatusEPanel);
			self.showCPanelButton.selected = (status == ControlPanelVisibleStatusCPanel);
			self.showAPanelButton.selected = (status == ControlPanelVisibleStatusAPanel);
			self.showZPanelButton.selected = (status == ControlPanelVisibleStatusZPanel);
			self.showVPanelButton.selected = (status == ControlPanelVisibleStatusVPanel);
			
			// パネル切り替えは完了です。
			self.controlPanelVisibleStatus = status;
		}
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
		CGFloat width = self.finderPanelView.bounds.size.width * self.controlPanelWidthRatio;
		CGFloat height = self.finderPanelView.bounds.size.height * self.controlPanelHeightRatio;
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

@end
