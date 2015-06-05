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

// !!!: スライダーの右側マージンの制約は、横置き画面でパラメータパネルを右側に収納する時にAuto Layoutから警告を受けないようにするため、他の制約より優先度を下げてあります。
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

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSArray *opticalZoomingSpeeds; ///< 光学ズームの駆動速度の選択肢
@property (assign, nonatomic) NSInteger opticalZoomingSpeed; ///< 光学ズームを駆動させる速度
@property (assign, nonatomic) BOOL opticalZoomingBySlider; ///< 光学ズームの焦点距離をスライダーで指定したか否か

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
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"Slow", nil),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedSlow)
	};
	NSDictionary *speedNormal = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"Normal", nil),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedNormal)
	};
	NSDictionary *speedFast = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"Fast", nil),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedFast)
	};
	NSDictionary *speedBurst = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"Busrt", nil),
		ItemSelectionViewItemValueKey:@(OLYCameraDrivingZoomLensSpeedBurst)
	};
	[opticalZoomingSpeeds addObject:speedSlow];
	[opticalZoomingSpeeds addObject:speedNormal];
	[opticalZoomingSpeeds addObject:speedFast];
	[opticalZoomingSpeeds addObject:speedBurst];
	self.opticalZoomingSpeeds = opticalZoomingSpeeds;
	self.opticalZoomingSpeed = 1;

	// カメラの光学ズームの駆動、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addRecordingSupportsDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyMinimumFocalLength options:0 context:@selector(didChangeMinimumFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyMaximumFocalLength options:0 context:@selector(didChangeMaximumFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyCurrentFocalLength options:0 context:@selector(didChangeCurrentFocalLength:)];
	[camera addObserver:self forKeyPath:CameraPropertyMinimumDigitalZoomScale options:0 context:@selector(didChangeMinimumDigitalZoomScale:)];
	[camera addObserver:self forKeyPath:CameraPropertyMaximumDigitalZoomScale options:0 context:@selector(didChangeMaximumDigitalZoomScale:)];
	[camera addObserver:self forKeyPath:CameraPropertyCurrentDigitalZoomScale options:0 context:@selector(didChangeCurrentDigitalZoomScale:)];
	
	// 画面表示を初期表示します。
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.opticalZoomingMinimumFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.opticalZoomingMaximumFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.opticalZoomingCurrentFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showZoomingSpeedCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingMinimumScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingMaximumScaleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.digitalZoomingCurrentScaleCell.detailTextLabel.text = emptyDetailTextLabel;
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
	[camera removeRecordingSupportsDelegate:self];
	_opticalZoomingSpeeds = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ???: セグエで遷移して戻ってくるとたまに自動で行選択が解除されないようです。
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
	
	// 光学ズーム操作の有効無効をズームの駆動状態に従って設定します。
	AppCamera *camera = GetAppCamera();
	self.opticalZoomingBySlider = NO;
	BOOL enable = !camera.drivingZoomLens;
	[self updateOpticalZoomingSliderEnabled:enable];
	[self tableViewCell:self.zoomTowardWideEndCell enabled:enable];
	[self tableViewCell:self.zoomTowardTeleEndCell enabled:enable];
	
	// デジタルズーム操作の有効無効を設定します。
	[self updateDigitalZoomingSliderEnabled:YES];
	
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
	if ([segueIdentifier isEqualToString:@"ShowZoomingSpeed"]) {
		ItemSelectionViewController *viewController = segue.destinationViewController;
		viewController.tag = [CameraPropertyOpticalZoomingSpeed hash];
		viewController.items = self.opticalZoomingSpeeds;
		viewController.selectedItemIndex = self.opticalZoomingSpeed;
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
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	if ([controller isMemberOfClass:[ItemSelectionViewController class]]) {
		NSUInteger hash = controller.tag;
		if (hash == [CameraPropertyOpticalZoomingSpeed hash]) {
			[self didSelectZoomingSpeedItem:index];
		} else {
			DEBUG_LOG(@"Unknown hash: %lu", (unsigned long)hash);
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not zoom", nil)];
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not zoom", nil)];
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not zoom", nil)];
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not zoom", nil)];
			return;
		}
		
		// デジタルズームの倍率変更が完了しました。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateDigitalZoomingSliderEnabled:YES];
		}];
		DEBUG_LOG(@"");
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
		opticalZoomingMinimumFocalLength =  [NSString stringWithFormat:@"%1.1f", camera.minimumFocalLength];
	} else {
		opticalZoomingMinimumFocalLength = NSLocalizedString(@"Unknown", nil);
	}
	// 表示を更新します。
	self.opticalZoomingMinimumFocalLengthCell.detailTextLabel.text = opticalZoomingMinimumFocalLength;
	[self updateOpticalZoomingSliderValue];
}

/// カメラに装着されたズームレンズのテレ端での焦点距離の状態を表示します。
- (void)updateOpticalZoomingMaximumFocalLengthCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *opticalZoomingMaximumFocalLength;
	if (!isnan(camera.maximumFocalLength)) {
		opticalZoomingMaximumFocalLength =  [NSString stringWithFormat:@"%1.1f", camera.maximumFocalLength];
	} else {
		opticalZoomingMaximumFocalLength = NSLocalizedString(@"Unknown", nil);
	}
	// 表示を更新します。
	self.opticalZoomingMaximumFocalLengthCell.detailTextLabel.text = opticalZoomingMaximumFocalLength;
	[self updateOpticalZoomingSliderValue];
}

/// カメラに装着されたレンズの現在の焦点距離の状態を表示します。
- (void)updateOpticalZoomingCurrentFocalLengthCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *opticalZoomingCurrentFocalLength;
	if (!isnan(camera.actualFocalLength)) {
		opticalZoomingCurrentFocalLength =  [NSString stringWithFormat:@"%1.1f", camera.actualFocalLength];
	} else {
		opticalZoomingCurrentFocalLength = NSLocalizedString(@"Unknown", nil);
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

/// デジタルズームの倍率スライダーの有効無効を設定します。
- (void)updateOpticalZoomingSliderEnabled:(BOOL)enabled {
	DEBUG_LOG(@"enabled=%@", (enabled ? @"YES" : @"NO"));
	
	AppCamera *camera = GetAppCamera();
	if (!isnan(camera.minimumFocalLength) &&
		!isnan(camera.maximumFocalLength) &&
		!isnan(camera.actualFocalLength)) {
		self.opticalZoomingSlider.enabled = enabled;
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
		minimumDigitalZoomScale =  [NSString stringWithFormat:@"%1.1f", camera.minimumDigitalZoomScale];
	} else {
		minimumDigitalZoomScale = NSLocalizedString(@"Unknown", nil);
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
		maximumDigitalZoomScale =  [NSString stringWithFormat:@"%1.1f", camera.maximumDigitalZoomScale];
	} else {
		maximumDigitalZoomScale = NSLocalizedString(@"Unknown", nil);
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
		currentDigitalZoomScale =  [NSString stringWithFormat:@"%1.1f", camera.currentDigitalZoomScale];
	} else {
		currentDigitalZoomScale = NSLocalizedString(@"Unknown", nil);
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
		self.digitalZoomingSlider.enabled = enabled;
	} else {
		self.digitalZoomingSlider.enabled = NO;
	}
}

@end
