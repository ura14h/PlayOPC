//
//  ZPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ZPanelViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "ItemSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface ZPanelViewController () <OLYCameraRecordingSupportsDelegate, ItemSelectionViewControllerDelegate>

// MARK: スライダーの右側マージンの制約は、横置き画面でパラメータパネルを右側に収納する時にAuto Layoutから警告を受けないようにするため、他の制約より優先度を下げてあります。
@property (weak, nonatomic) IBOutlet UITableViewCell *opticalZoomingMinimumFocalLengthCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *opticalZoomingMaximumFocalLengthCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *opticalZoomingCurrentFocalLengthCell;
@property (weak, nonatomic) IBOutlet UISlider *opticalZoomingSlider;
@property (weak, nonatomic) IBOutlet UITableViewCell *zoomTowardWideEndCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *zoomTowardTeleEndCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showZoomingSpeedCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *digitalZoomingMinimumScaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *digitalZoomingMaximumScaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *digitalZoomingCurrentScaleCell;
@property (weak, nonatomic) IBOutlet UISlider *digitalZoomingSlider;
@property (weak, nonatomic) IBOutlet UITableViewCell *startMagnifyingLiveViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *stopMagnifyingLiveViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showMagnifyingLiveViewScaleCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSArray *opticalZoomingSpeeds; ///< 光学ズームの駆動速度の選択肢
@property (assign, nonatomic) NSInteger opticalZoomingSpeed; ///< 光学ズームを駆動させる速度
@property (assign, nonatomic) BOOL opticalZoomingBySlider; ///< 光学ズームの焦点距離をスライダーで指定したか否か
@property (strong, nonatomic) NSArray *magnifyingLiveViewScales; ///< ライブビュー拡大の選択肢

@end

#pragma mark -

@implementation ZPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// 光学ズーム駆動速度の選択肢を構築します。
	NSMutableArray *opticalZoomingSpeeds = [[NSMutableArray alloc] init];
	NSDictionary *speedSlow = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:OpticalZoomingSpeedSlow", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedSlow)
	};
	NSDictionary *speedNormal = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:OpticalZoomingSpeedNormal", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedNormal)
	};
	NSDictionary *speedFast = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:OpticalZoomingSpeedFast", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedFast)
	};
	NSDictionary *speedBurst = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:OpticalZoomingSpeedBusrt", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedBurst)
	};
	[opticalZoomingSpeeds addObject:speedSlow];
	[opticalZoomingSpeeds addObject:speedNormal];
	[opticalZoomingSpeeds addObject:speedFast];
	[opticalZoomingSpeeds addObject:speedBurst];
	self.opticalZoomingSpeeds = opticalZoomingSpeeds;
	self.opticalZoomingSpeed = 1;

	// ライブビュー拡大の選択肢を構築します。
	NSMutableArray *magnifyingLiveViewScales = [[NSMutableArray alloc] init];
	NSDictionary *scaleX5 = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:MagnifyingLiveViewScale5", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraMagnifyingLiveViewScaleX5)
	};
	NSDictionary *scaleX7 = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:MagnifyingLiveViewScale7", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraMagnifyingLiveViewScaleX7)
	};
	NSDictionary *scaleX10 = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:MagnifyingLiveViewScale10", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraMagnifyingLiveViewScaleX10)
	};
	NSDictionary *scaleX14 = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:MagnifyingLiveViewScale14", @"ZPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:@(OLYCameraMagnifyingLiveViewScaleX14)
	};
	[magnifyingLiveViewScales addObject:scaleX5];
	[magnifyingLiveViewScales addObject:scaleX7];
	[magnifyingLiveViewScales addObject:scaleX10];
	[magnifyingLiveViewScales addObject:scaleX14];
	self.magnifyingLiveViewScales = magnifyingLiveViewScales;
	
	// カメラの光学ズームの駆動、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addRecordingSupportsDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyMinimumFocalLength options:0 context:@selector(didChangeMinimumFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyMaximumFocalLength options:0 context:@selector(didChangeMaximumFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyCurrentFocalLength options:0 context:@selector(didChangeCurrentFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyMinimumDigitalZoomScale options:0 context:@selector(didChangeMinimumDigitalZoomScale:)];
	[camera addObserver:self forKeyPath:CameraPropertyMaximumDigitalZoomScale options:0 context:@selector(didChangeMaximumDigitalZoomScale:)];
	[camera addObserver:self forKeyPath:CameraPropertyCurrentDigitalZoomScale options:0 context:@selector(didChangeCurrentDigitalZoomScale:)];
	[camera addObserver:self forKeyPath:CameraPropertyMagnifyingLiveView options:0 context:@selector(didChangeMagnifyingLiveView:)];
	
	// 画面表示を初期表示します。
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.opticalZoomingMinimumFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.opticalZoomingMaximumFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.opticalZoomingCurrentFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showZoomingSpeedCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingMinimumScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingMaximumScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingCurrentScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showMagnifyingLiveViewScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.opticalZoomingSlider.enabled = NO;
	self.digitalZoomingSlider.enabled = NO;
	[self tableViewCell:self.zoomTowardWideEndCell enabled:NO];
	[self tableViewCell:self.zoomTowardTeleEndCell enabled:NO];
	[self tableViewCell:self.showZoomingSpeedCell enabled:NO];
	[self tableViewCell:self.startMagnifyingLiveViewCell enabled:NO];
	[self tableViewCell:self.stopMagnifyingLiveViewCell enabled:NO];
	[self tableViewCell:self.showMagnifyingLiveViewScaleCell enabled:NO];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	// カメラの光学ズームの駆動、カメラのプロパティを監視終了します。
	AppCamera *camera = GetAppCamera();
	[camera removeObserver:self forKeyPath:CameraPropertyMinimumFocalLength];
	[camera removeObserver:self forKeyPath:CameraPropertyMaximumFocalLength];
	[camera removeObserver:self forKeyPath:CameraPropertyCurrentFocalLength];
	[camera removeObserver:self forKeyPath:CameraPropertyMinimumDigitalZoomScale];
	[camera removeObserver:self forKeyPath:CameraPropertyMaximumDigitalZoomScale];
	[camera removeObserver:self forKeyPath:CameraPropertyCurrentDigitalZoomScale];
	[camera removeObserver:self forKeyPath:CameraPropertyMagnifyingLiveView];
	[camera removeRecordingSupportsDelegate:self];
	_opticalZoomingSpeeds = nil;
	_magnifyingLiveViewScales = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// MARK: セグエで遷移して戻ってくるとたまに自動で行選択が解除されないようです。
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];

	// didStartActivityメソッドは、パネルを表示する直前にRecordingViewControllerによって呼び出されます。
	// RecordingViewController, PlaybackViewController, SystemViewControllerの手順とは異なります。
}

- (void)viewDidDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidDisappear:animated];
	
	// didFinishActivityメソッドは、パネルを消去する直前にRecordingViewControllerによって呼び出されます。
	// RecordingViewController, PlaybackViewController, SystemViewControllerの手順とは異なります。
}

#pragma mark -

/// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

	// 表示を更新します。
	[self updateOpticalZoomingMinimumFocalLengthCell];
	[self updateOpticalZoomingMaximumFocalLengthCell];
	[self updateOpticalZoomingCurrentFocalLengthCell];
	[self updateShowZoomingSpeedCell];
	[self updateDigitalZoomingMinimumScaleCell];
	[self updateDigitalZoomingMaximumScaleCell];
	[self updateDigitalZoomingCurrentScaleCell];
	[self updateShowMagnifyingLiveViewScaleCell];
	
	// 光学ズーム操作の有効無効をズームの駆動状態に従って設定します。
	AppCamera *camera = GetAppCamera();
	self.opticalZoomingBySlider = NO;
	BOOL enableOpticalZooming = !camera.drivingZoomLens;
	[self updateOpticalZoomingSliderEnabled:enableOpticalZooming];
	[self tableViewCell:self.zoomTowardWideEndCell enabled:enableOpticalZooming];
	[self tableViewCell:self.zoomTowardTeleEndCell enabled:enableOpticalZooming];
	[self tableViewCell:self.showZoomingSpeedCell enabled:YES];
	
	// デジタルズーム操作の有効無効を設定します。
	[self updateDigitalZoomingSliderEnabled:YES];

	// ライブビュー拡大の有効無効に従って設定します。
	BOOL enableMagnifying = camera.magnifyingLiveView;
	[self tableViewCell:self.startMagnifyingLiveViewCell enabled:!enableMagnifying];
	[self tableViewCell:self.stopMagnifyingLiveViewCell enabled:enableMagnifying];
	[self tableViewCell:self.showMagnifyingLiveViewScaleCell enabled:YES];
	
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

	// 表示を更新します。
	self.opticalZoomingSlider.enabled = NO;
	self.digitalZoomingSlider.enabled = NO;
	[self tableViewCell:self.zoomTowardWideEndCell enabled:NO];
	[self tableViewCell:self.zoomTowardTeleEndCell enabled:NO];
	[self tableViewCell:self.showZoomingSpeedCell enabled:NO];
	[self tableViewCell:self.startMagnifyingLiveViewCell enabled:NO];
	[self tableViewCell:self.stopMagnifyingLiveViewCell enabled:NO];
	[self tableViewCell:self.showMagnifyingLiveViewScaleCell enabled:NO];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);

	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowZoomingSpeed"]) {
		ItemSelectionViewController *viewController = segue.destinationViewController;
		viewController.tag = [CameraPropertyOpticalZoomingSpeed hash];
		viewController.items = self.opticalZoomingSpeeds;
		viewController.selectedItemIndex = self.opticalZoomingSpeed;
		viewController.itemCellIdentifier = @"ItemCell";
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowMagnifyingLiveViewScale"]) {
		ItemSelectionViewController *viewController = segue.destinationViewController;
		viewController.tag = [CameraPropertyMagnifyingLiveViewScale hash];
		viewController.items = self.magnifyingLiveViewScales;
		viewController.selectedItemIndex = NSNotFound;
		AppCamera *camera = GetAppCamera();
		[self.magnifyingLiveViewScales enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger index, BOOL *stop) {
			NSInteger scaleValue = [item[ItemSelectionViewItemValueKey] integerValue];
			OLYCameraMagnifyingLiveViewScale scale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
			if (camera.magnifyingLiveViewScale == scale) {
				viewController.selectedItemIndex = index;
				*stop = YES;
			}
		}];
		viewController.itemCellIdentifier = @"ItemCell";
		viewController.itemSelectionDeleage = self;
	} else {
		// 何もしません。
	}
}

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);
	
	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;
	
	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"ZoomTowardWideEnd"]) {
		[self didSelectRowAtZoomTowardWideEnd];
	} else if ([cellReuseIdentifier isEqualToString:@"ZoomTowardTeleEnd"]) {
		[self didSelectRowAtZoomTowardTeleEnd];
	} else if ([cellReuseIdentifier isEqualToString:@"StartMagnifyingLiveView"]) {
		[self didSelectRowAtStartMagnifyingLiveView];
	} else if ([cellReuseIdentifier isEqualToString:@"StopMagnifyingLiveView"]) {
		[self didSelectRowAtStopMagnifyingLiveView];
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	NSUInteger hash = controller.tag;
	if (hash == [CameraPropertyOpticalZoomingSpeed hash]) {
		[self didSelectZoomingSpeedItem:index];
	} else if (hash == [CameraPropertyMagnifyingLiveViewScale hash]) {
		[self didSelectMagnifyingLiveViewScaleItem:index];
	} else {
		DEBUG_LOG(@"Unknown hash: %lu", (unsigned long)hash);
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
		__weak ZPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:change afterDelay:0];
		}];
	}
}

/// 光学ズームの駆動が終了した時に呼び出されます。
- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// すでに活動停止している場合は何もしません。
	if (!self.startingActivity) {
		return;
	}

	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ZPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf cameraDidStopDrivingZoomLens:camera];
		}];
		return;
	}
	
	self.opticalZoomingBySlider = NO;
	[self updateOpticalZoomingSliderEnabled:YES];
	[self tableViewCell:self.zoomTowardWideEndCell enabled:YES];
	[self tableViewCell:self.zoomTowardTeleEndCell enabled:YES];
}

#pragma mark -

/// カメラに装着されたズームレンズのワイド端での焦点距離の状態が変わった時に呼び出されます。
- (void)didChangeMinimumFocalLength:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateOpticalZoomingMinimumFocalLengthCell];
}

/// カメラに装着されたズームレンズのテレ端での焦点距離の状態が変わった時に呼び出されます。
- (void)didChangeMaximumFocalLength:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateOpticalZoomingMaximumFocalLengthCell];
}

/// カメラに装着されたレンズの現在の焦点距離の状態が変わった時に呼び出されます。
- (void)didChangeCurrentFocalLength:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateOpticalZoomingCurrentFocalLengthCell];
}

/// 光学ズームの倍率スライダーの値を変更した時に呼び出されます。
- (IBAction)didChangeOpticalZoomingSliderValue:(id)sender {
	DEBUG_LOG(@"value=%f", self.opticalZoomingSlider.value);
	
	// 光学ズームの新しい焦点距離を取得します。
	float length = self.opticalZoomingSlider.value;
	
	// 光学ズームの指定位置へのズーミングを開始します。
	__weak ZPanelViewController *weakSelf = self;
	weakSelf.opticalZoomingBySlider = YES;
	[weakSelf updateOpticalZoomingSliderEnabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:NO];
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// ズーミングを開始します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera startDrivingZoomLensToFocalLength:length error:&error]) {
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.opticalZoomingBySlider = NO;
				[weakSelf updateOpticalZoomingSliderEnabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:YES];
			}];
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartDrivingZoomLens", @"ZPanelViewController.didChangeOpticalZoomingSliderValue")];
			return;
		}
		
		// ズーミングの開始が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// 'Toward Wide End'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtZoomTowardWideEnd {
	DEBUG_LOG(@"");
	
	// ズームスピードを取得します。
	NSDictionary *item = self.opticalZoomingSpeeds[self.opticalZoomingSpeed];
	OLYCameraDrivingZoomLensSpeed speed = (OLYCameraDrivingZoomLensSpeed)[item[ItemSelectionViewItemValueKey] integerValue];
	
	// 光学ズームのワイド端へのズーミングを開始します。
	__weak ZPanelViewController *weakSelf = self;
	weakSelf.opticalZoomingBySlider = NO;
	[weakSelf updateOpticalZoomingSliderEnabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:NO];
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// ズーミングを開始します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera startDrivingZoomLensForDirection:OLYCameraDrivingZoomLensWide speed:speed error:&error]) {
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf updateOpticalZoomingSliderEnabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:YES];
			}];
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartDrivingZoomLens", @"ZPanelViewController.didSelectRowAtZoomTowardWideEnd")];
			return;
		}
		
		// ズーミングの開始が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// 'Toward Tele End'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtZoomTowardTeleEnd {
	DEBUG_LOG(@"");

	// ズームスピードを取得します。
	NSDictionary *item = self.opticalZoomingSpeeds[self.opticalZoomingSpeed];
	OLYCameraDrivingZoomLensSpeed speed = (OLYCameraDrivingZoomLensSpeed)[item[ItemSelectionViewItemValueKey] integerValue];
	
	// 光学ズームのテレ端へのズーミングを開始します。
	__weak ZPanelViewController *weakSelf = self;
	weakSelf.opticalZoomingBySlider = NO;
	[weakSelf updateOpticalZoomingSliderEnabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:NO];
	[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:NO];
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// ズーミングを開始します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera startDrivingZoomLensForDirection:OLYCameraDrivingZoomLensTele speed:speed error:&error]) {
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf updateOpticalZoomingSliderEnabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardWideEndCell enabled:YES];
				[weakSelf tableViewCell:weakSelf.zoomTowardTeleEndCell enabled:YES];
			}];
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartDrivingZoomLens", @"ZPanelViewController.didSelectRowAtZoomTowardTeleEnd")];
			return;
		}
		
		// ズーミングの開始が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// 光学ズームの駆動速度の選択肢が選択された時に呼び出されます。
- (void)didSelectZoomingSpeedItem:(NSUInteger)itemIndex {
	DEBUG_LOG(@"itemIndex=%ld", (long)itemIndex);

	// 光学ズームの駆動速度を変更します。
	self.opticalZoomingSpeed = itemIndex;

	// 画面表示を更新します。
	[self updateShowZoomingSpeedCell];
}

/// デジタルズームの最小倍率の状態が変わった時に呼び出されます。
- (void)didChangeMinimumDigitalZoomScale:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateDigitalZoomingMinimumScaleCell];
}

/// デジタルズームの最大倍率の状態が変わった時に呼び出されます。
- (void)didChangeMaximumDigitalZoomScale:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateDigitalZoomingMaximumScaleCell];
}

/// デジタルズームの現在の倍率の状態が変わった時に呼び出されます。
- (void)didChangeCurrentDigitalZoomScale:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateDigitalZoomingCurrentScaleCell];
}

/// デジタルズームの倍率スライダーの値を変更した時に呼び出されます。
- (IBAction)didChangeDigitalZoomingSliderValue:(id)sender {
	DEBUG_LOG(@"value=%f", self.digitalZoomingSlider.value);

	// デジタルズームの新しい倍率を取得します。
	float scale = self.digitalZoomingSlider.value;
	
	// デジタルズームの倍率変更を開始します。
	__weak ZPanelViewController *weakSelf = self;
	[weakSelf updateDigitalZoomingSliderEnabled:NO];
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// デジタルズームの倍率を変更します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera changeDigitalZoomScale:scale error:&error]) {
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf updateDigitalZoomingSliderEnabled:YES];
			}];
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotChangeDigitalZoomScale", @"ZPanelViewController.didChangeDigitalZoomingSliderValue")];
			return;
		}
		
		// デジタルズームの倍率変更が完了しました。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateDigitalZoomingSliderEnabled:YES];
		}];
		DEBUG_LOG(@"");
	}];
}

/// ライブビュー拡大の状態が変わった時に呼び出されます。
- (void)didChangeMagnifyingLiveView:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	AppCamera *camera = GetAppCamera();
	BOOL enableMagnifying = camera.magnifyingLiveView;
	[self tableViewCell:self.startMagnifyingLiveViewCell enabled:!enableMagnifying];
	[self tableViewCell:self.stopMagnifyingLiveViewCell enabled:enableMagnifying];
	
	// MARK: ライブビュー拡大を開始するとデジタルズームの倍率変更に影響するようなので表示を更新します。
	[self updateDigitalZoomingSliderEnabled:YES];
}

/// 'Start Magnifying'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtStartMagnifyingLiveView {
	DEBUG_LOG(@"");

	// ライブビュー拡大開始を開始します。
	__weak ZPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progress) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// ライブビュー拡大を開始します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera startMagnifyingLiveView:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStartMagnifying", @"ZPanelViewController.didChangeMagnifyingLiveView")];
			return;
		}
		
		// ライブビュー拡大開始が完了しました。
		// MARK: 表示の更新はKVO監視している先で行われます。
		DEBUG_LOG(@"");
	}];
}

/// 'Stop Magnifying'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtStopMagnifyingLiveView {
	DEBUG_LOG(@"");
	
	// ライブビュー拡大終了を開始します。
	__weak ZPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progress) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// ライブビュー拡大を終了します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera stopMagnifyingLiveView:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotStopMagnifying", @"ZPanelViewController.didSelectRowAtStopMagnifyingLiveView")];
			return;
		}
		
		// ライブビュー拡大終了が完了しました。
		// MARK: 表示の更新はKVO監視している先で行われます。
		DEBUG_LOG(@"");
	}];
}

/// ライブビュー拡大の倍率の選択肢が選択された時に呼び出されます。
- (void)didSelectMagnifyingLiveViewScaleItem:(NSInteger)itemIndex {
	DEBUG_LOG(@"itemIndex=%ld", (long)itemIndex);

	// ライブビュー拡大倍率の変更を開始します。
	__weak ZPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progress) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// 選択された倍率を取得します。
		NSDictionary *item = weakSelf.magnifyingLiveViewScales[itemIndex];
		NSInteger scaleValue = [item[ItemSelectionViewItemValueKey] integerValue];
		OLYCameraMagnifyingLiveViewScale scale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
		
		// ライブビュー拡大倍率を変更します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera changeMagnifyingLiveViewScale:scale error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotChangeMagnifyingScale", @"ZPanelViewController.didSelectMagnifyingLiveViewScaleItem")];
			return;
		}

		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowMagnifyingLiveViewScaleCell];
		}];
	}];
}

#pragma mark -

/// カメラに装着されたズームレンズのワイド端での焦点距離の状態を表示します。
- (void)updateOpticalZoomingMinimumFocalLengthCell {
	DEBUG_LOG(@"");

	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *opticalZoomingMinimumFocalLength;
	if (!isnan(camera.minimumFocalLength)) {
		opticalZoomingMinimumFocalLength =  [NSString stringWithFormat:NSLocalizedString(@"$cell:OpticalZoomingMinimumFocalLength(%1.1f mm)", @"ZPanelViewController.updateOpticalZoomingMinimumFocalLengthCell"), camera.minimumFocalLength];
	} else {
		opticalZoomingMinimumFocalLength = NSLocalizedString(@"$cell:OpticalZoomingMinimumFocalLengthNotAvailable", @"ZPanelViewController.updateOpticalZoomingMinimumFocalLengthCell");
	}
	// 表示を更新します。
	self.opticalZoomingMinimumFocalLengthCell.detailTextLabel.text = opticalZoomingMinimumFocalLength;
	[self updateOpticalZoomingSliderValue];
	[self updateOpticalZoomingSliderEnabled:YES];
}

/// カメラに装着されたズームレンズのテレ端での焦点距離の状態を表示します。
- (void)updateOpticalZoomingMaximumFocalLengthCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *opticalZoomingMaximumFocalLength;
	if (!isnan(camera.maximumFocalLength)) {
		opticalZoomingMaximumFocalLength =  [NSString stringWithFormat:NSLocalizedString(@"$cell:OpticalZoomingMaximumFocalLength(%1.1f mm)", @"ZPanelViewController.updateOpticalZoomingMaximumFocalLengthCell"), camera.maximumFocalLength];
	} else {
		opticalZoomingMaximumFocalLength = NSLocalizedString(@"$cell:OpticalZoomingMaximumFocalLengthNotAvailable", @"ZPanelViewController.updateOpticalZoomingMaximumFocalLengthCell");
	}
	// 表示を更新します。
	self.opticalZoomingMaximumFocalLengthCell.detailTextLabel.text = opticalZoomingMaximumFocalLength;
	[self updateOpticalZoomingSliderValue];
	[self updateOpticalZoomingSliderEnabled:YES];
}

/// カメラに装着されたレンズの現在の焦点距離の状態を表示します。
- (void)updateOpticalZoomingCurrentFocalLengthCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *opticalZoomingCurrentFocalLength;
	if (!isnan(camera.actualFocalLength) && camera.actualFocalLength > 0.0) {
		opticalZoomingCurrentFocalLength =  [NSString stringWithFormat:NSLocalizedString(@"$cell:OpticalZoomingCurrentFocalLength(%1.1f mm)", @"ZPanelViewController.updateOpticalZoomingCurrentFocalLengthCell"), camera.actualFocalLength];
	} else {
		opticalZoomingCurrentFocalLength = NSLocalizedString(@"$cell:OpticalZoomingCurrentFocalLengthNotAvailable", @"ZPanelViewController.updateOpticalZoomingCurrentFocalLengthCell");
	}
	// 表示を更新します。
	self.opticalZoomingCurrentFocalLengthCell.detailTextLabel.text = opticalZoomingCurrentFocalLength;
	[self updateOpticalZoomingSliderValue];
}

/// 光学ズームの倍率スライダーの値を設定します。
- (void)updateOpticalZoomingSliderValue {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	if (!isnan(camera.minimumFocalLength) &&
		!isnan(camera.maximumFocalLength) &&
		!isnan(camera.actualFocalLength)) {
		self.opticalZoomingSlider.minimumValue = camera.minimumFocalLength;
		self.opticalZoomingSlider.maximumValue = camera.maximumFocalLength;
		// ユーザーがスライダーを操作していない時だけ値を変更します。(操作している時に値を変えるとツマミがピクピク動いてしまう)
		// 付け加えて、最後のユーザー操作によってズーム駆動が完了するまでの間も変更を無視します。
		if (!self.opticalZoomingSlider.tracking && !self.opticalZoomingBySlider) {
			self.opticalZoomingSlider.value = camera.actualFocalLength;
		}
	} else {
		self.opticalZoomingSlider.minimumValue = 0.0;
		self.opticalZoomingSlider.maximumValue = 1.0;
		self.opticalZoomingSlider.value = 0.5;
	}
}

/// 光学ズームの倍率スライダーの有効無効を設定します。
- (void)updateOpticalZoomingSliderEnabled:(BOOL)enabled {
	DEBUG_LOG(@"enabled=%@", (enabled ? @"YES" : @"NO"));
	
	AppCamera *camera = GetAppCamera();
	if (!isnan(camera.minimumFocalLength) &&
		!isnan(camera.maximumFocalLength) &&
		!isnan(camera.actualFocalLength)) {
		// 電動ズーム付きレンズが装着されている場合のみ有効です。
		NSString *lensMountStatus = camera.lensMountStatus;
		if ([lensMountStatus hasPrefix:@"normal"]) {
			if ([lensMountStatus rangeOfString:@"+electriczoom"].location != NSNotFound) {
				self.opticalZoomingSlider.enabled = enabled;
			} else {
				self.opticalZoomingSlider.enabled = NO;
			}
		} else {
			self.opticalZoomingSlider.enabled = NO;
		}
	} else {
		self.opticalZoomingSlider.enabled = NO;
	}
}

/// 光学ズームの駆動速度の状態を表示します。
- (void)updateShowZoomingSpeedCell {
	DEBUG_LOG(@"");
	
	NSDictionary *item = self.opticalZoomingSpeeds[self.opticalZoomingSpeed];
	NSString *zoomingSpeed = item[ItemSelectionViewItemTitleKey];
	self.showZoomingSpeedCell.detailTextLabel.text = zoomingSpeed;
}

/// デジタルズームの最小倍率の状態を表示します。
- (void)updateDigitalZoomingMinimumScaleCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *minimumDigitalZoomScale;
	if (!isnan(camera.minimumDigitalZoomScale)) {
		minimumDigitalZoomScale =  [NSString stringWithFormat:NSLocalizedString(@"$cell:MinimumDigitalZoomScale(%1.1f times)", @"ZPanelViewController.updateDigitalZoomingMinimumScaleCell"), camera.minimumDigitalZoomScale];
	} else {
		minimumDigitalZoomScale = NSLocalizedString(@"$cell:MinimumDigitalZoomScaleNotAvailable", @"ZPanelViewController.updateDigitalZoomingMinimumScaleCell");
	}
	// 表示を更新します。
	self.digitalZoomingMinimumScaleCell.detailTextLabel.text = minimumDigitalZoomScale;
	[self updateDigitalZoomingSliderValue];
}

/// デジタルズームの最大倍率の状態を表示します。
- (void)updateDigitalZoomingMaximumScaleCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *maximumDigitalZoomScale;
	if (!isnan(camera.maximumDigitalZoomScale)) {
		maximumDigitalZoomScale =  [NSString stringWithFormat:NSLocalizedString(@"$cell:MaximumDigitalZoomScale(%1.1f times)", @"ZPanelViewController.updateDigitalZoomingMaximumScaleCell"), camera.maximumDigitalZoomScale];
	} else {
		maximumDigitalZoomScale = NSLocalizedString(@"$cell:MaximumDigitalZoomScaleNotAvailable", @"ZPanelViewController.updateDigitalZoomingMaximumScaleCell");
	}
	// 表示を更新します。
	self.digitalZoomingMaximumScaleCell.detailTextLabel.text = maximumDigitalZoomScale;
	[self updateDigitalZoomingSliderValue];
}

/// 現在のデジタルズームの倍率の状態を表示します。
- (void)updateDigitalZoomingCurrentScaleCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *currentDigitalZoomScale;
	if (!isnan(camera.currentDigitalZoomScale)) {
		currentDigitalZoomScale =  [NSString stringWithFormat:NSLocalizedString(@"$cell:CurrentDigitalZoomScale(%1.1f times)", @"ZPanelViewController.updateDigitalZoomingCurrentScaleCell"), camera.currentDigitalZoomScale];
	} else {
		currentDigitalZoomScale = NSLocalizedString(@"$cell:CurrentDigitalZoomScaleNotAvailable", @"ZPanelViewController.updateDigitalZoomingCurrentScaleCell");
	}
	// 表示を更新します。
	self.digitalZoomingCurrentScaleCell.detailTextLabel.text = currentDigitalZoomScale;
	[self updateDigitalZoomingSliderValue];
}

/// デジタルズームの倍率スライダーの値を設定します。
- (void)updateDigitalZoomingSliderValue {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	if (!isnan(camera.minimumDigitalZoomScale) &&
		!isnan(camera.maximumDigitalZoomScale) &&
		!isnan(camera.currentDigitalZoomScale)) {
		self.digitalZoomingSlider.minimumValue = camera.minimumDigitalZoomScale;
		self.digitalZoomingSlider.maximumValue = camera.maximumDigitalZoomScale;
		// ユーザーがスライダーを操作していない時だけ値を変更します。(操作している時に値を変えるとツマミがピクピク動いてしまう)
		if (!self.digitalZoomingSlider.tracking) {
			self.digitalZoomingSlider.value = camera.currentDigitalZoomScale;
		}
	} else {
		self.digitalZoomingSlider.minimumValue = 0.0;
		self.digitalZoomingSlider.maximumValue = 1.0;
		self.digitalZoomingSlider.value = 0.5;
	}
}

/// デジタルズームの倍率スライダーの有効無効を設定します。
- (void)updateDigitalZoomingSliderEnabled:(BOOL)enabled {
	DEBUG_LOG(@"enabled=%@", (enabled ? @"YES" : @"NO"));
	
	AppCamera *camera = GetAppCamera();
	if (!isnan(camera.minimumDigitalZoomScale) &&
		!isnan(camera.maximumDigitalZoomScale) &&
		!isnan(camera.currentDigitalZoomScale)) {
		if (!camera.magnifyingLiveView) {
			self.digitalZoomingSlider.enabled = enabled;
		} else {
			// MARK: ライブビュー拡大しているとデジタルズームの倍率変更は禁止になるようです。
			self.digitalZoomingSlider.enabled = NO;
		}
	} else {
		self.digitalZoomingSlider.enabled = NO;
	}
}

/// ライブビュー拡大の倍率を表示します。
- (void)updateShowMagnifyingLiveViewScaleCell {
	DEBUG_LOG(@"");

	// 倍率の値を表示用の文言に変換します。
	__block NSString *magnifyingLiveViewScale = NSLocalizedString(@"$cell:MagnifyingLiveViewScaleUnknown", @"ZPanelViewController.updateShowMagnifyingLiveViewScaleCell");
	AppCamera *camera = GetAppCamera();
	[self.magnifyingLiveViewScales enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger index, BOOL *stop) {
		NSInteger scaleValue = [item[ItemSelectionViewItemValueKey] integerValue];
		OLYCameraMagnifyingLiveViewScale scale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
		if (camera.magnifyingLiveViewScale == scale) {
			magnifyingLiveViewScale = item[ItemSelectionViewItemTitleKey];
			*stop = YES;
		}
	}];
	// 表示を更新します。
	self.showMagnifyingLiveViewScaleCell.detailTextLabel.text = magnifyingLiveViewScale;
}

@end
