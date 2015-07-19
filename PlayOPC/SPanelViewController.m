//
//  SPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SPanelViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

static NSString *const CameraSettingFilePath = @"CameraSetting.plist"; ///< 一括取得したカメラプロパティ値を保存するファイル名

@interface SPanelViewController () <OLYCameraPropertyDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *batteryLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *highTemperatureWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *isoSensitivityWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *exposureWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *exposureMeteringWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mediaBusyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mediaErrorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *remainingMediaCapacityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *remainingImageCapacityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *remainingVideoCapacityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *levelGaugeOrientationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *levelGaugeRollingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *levelGaugePitchingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *applyCameraSettingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *saveCameraSettingCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書

@end

#pragma mark -

@implementation SPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeBatteryLevel)) forKey:CameraPropertyBatteryLevel];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyActualIsoSensitivityWarning options:0 context:@selector(didChangeIsoSensitivityWarning:)];
	[camera addObserver:self forKeyPath:CameraPropertyExposureWarning options:0 context:@selector(didChangeExposureWarning:)];
	[camera addObserver:self forKeyPath:CameraPropertyExposureMeteringWarning options:0 context:@selector(didChangeExposureMeteringWarning:)];
	[camera addObserver:self forKeyPath:CameraPropertyMediaBusy options:0 context:@selector(didChangeMediaBusy:)];
	[camera addObserver:self forKeyPath:CameraPropertyMediaError options:0 context:@selector(didChangeMediaError:)];
	[camera addObserver:self forKeyPath:CameraPropertyRemainingMediaCapacity options:0 context:@selector(didChangeRemainingMediaCapacity:)];
	[camera addObserver:self forKeyPath:CameraPropertyRemainingImageCapacity options:0 context:@selector(didChangeRemainingImageCapacity:)];
	[camera addObserver:self forKeyPath:CameraPropertyRemainingVideoCapacity options:0 context:@selector(didChangeRemainingVideoCapacity:)];
	[camera addObserver:self forKeyPath:CameraPropertyLevelGauge options:0 context:@selector(didChangeLevelGauge:)];

	// 画面表示を初期表示します。
	NSString *batteryLevelTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyBatteryLevel];
	self.batteryLevelCell.textLabel.text = batteryLevelTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.batteryLevelCell.detailTextLabel.text = emptyDetailTextLabel;
	self.highTemperatureWarningCell.detailTextLabel.text = emptyDetailTextLabel;
	self.isoSensitivityWarningCell.detailTextLabel.text = emptyDetailTextLabel;
	self.exposureWarningCell.detailTextLabel.text = emptyDetailTextLabel;
	self.exposureMeteringWarningCell.detailTextLabel.text = emptyDetailTextLabel;
	self.mediaBusyCell.detailTextLabel.text = emptyDetailTextLabel;
	self.mediaErrorCell.detailTextLabel.text = emptyDetailTextLabel;
	self.remainingMediaCapacityCell.detailTextLabel.text = emptyDetailTextLabel;
	self.remainingImageCapacityCell.detailTextLabel.text = emptyDetailTextLabel;
	self.remainingVideoCapacityCell.detailTextLabel.text = emptyDetailTextLabel;
	self.levelGaugeOrientationCell.detailTextLabel.text = emptyDetailTextLabel;
	self.levelGaugeRollingCell.detailTextLabel.text = emptyDetailTextLabel;
	self.levelGaugePitchingCell.detailTextLabel.text = emptyDetailTextLabel;
	[self tableViewCell:self.applyCameraSettingCell enabled:NO];
	[self tableViewCell:self.saveCameraSettingCell enabled:NO];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	[camera removeObserver:self forKeyPath:CameraPropertyActualIsoSensitivityWarning];
	[camera removeObserver:self forKeyPath:CameraPropertyExposureWarning];
	[camera removeObserver:self forKeyPath:CameraPropertyExposureMeteringWarning];
	[camera removeObserver:self forKeyPath:CameraPropertyMediaBusy];
	[camera removeObserver:self forKeyPath:CameraPropertyMediaError];
	[camera removeObserver:self forKeyPath:CameraPropertyRemainingMediaCapacity];
	[camera removeObserver:self forKeyPath:CameraPropertyRemainingImageCapacity];
	[camera removeObserver:self forKeyPath:CameraPropertyRemainingVideoCapacity];
	[camera removeObserver:self forKeyPath:CameraPropertyLevelGauge];
	[camera removeCameraPropertyDelegate:self];
	_cameraPropertyObserver = nil;
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
	[self updateBatteryLevelCell];
	[self updateHighTemperatureWarningCell];
	[self updateIsoSensitivityWarningCell];
	[self updateExposureWarningCell];
	[self updateExposureMeteringWarningCell];
	[self updateMediaBusyCell];
	[self updateMediaErrorCell];
	[self updateRemainingMediaCapacityCell];
	[self updateRemainingImageCapacityCell];
	[self updateRemainingVideoCapacityCell];
	[self updateLevelGaugeCell];
	[self tableViewCell:self.applyCameraSettingCell enabled:YES];
	[self tableViewCell:self.saveCameraSettingCell enabled:YES];

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
	[self tableViewCell:self.applyCameraSettingCell enabled:NO];
	[self tableViewCell:self.saveCameraSettingCell enabled:NO];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);
	
	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;
	
	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"ApplyCameraSetting"]) {
		[self didSelectRowAtApplyCameraSettingCell];
	} else if ([cellReuseIdentifier isEqualToString:@"SaveCameraSetting"]) {
		[self didSelectRowAtSaveCameraSettingCell];
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
		__weak SPanelViewController *weakSelf = self;
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
		__weak SPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

#pragma mark -

/// バッテリー残量の値が変わった時に呼び出されます。
- (void)didChangeBatteryLevel {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateBatteryLevelCell];
}

/// ISO感度の範囲外警告の状態が変わった時に呼び出されます。
- (void)didChangeIsoSensitivityWarning:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateIsoSensitivityWarningCell];
}

/// 露出連動範囲外警告の状態が変わった時に呼び出されます。
- (void)didChangeExposureWarning:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateExposureWarningCell];
}

/// 測光連動範囲外警告の状態が変わった時に呼び出されます。
- (void)didChangeExposureMeteringWarning:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateExposureMeteringWarningCell];
}

/// メディア書き込み中の状態が変わった時に呼び出されます。
- (void)didChangeMediaBusy:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateMediaBusyCell];
}

/// メディアエラー発生中の状態が変わった時に呼び出されます。
- (void)didChangeMediaError:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateMediaErrorCell];
}

/// 残り容量(バイト数)の状態が変わった時に呼び出されます。
- (void)didChangeRemainingMediaCapacity:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateRemainingMediaCapacityCell];
}

/// 残り容量(撮影枚数)の状態が変わった時に呼び出されます。
- (void)didChangeRemainingImageCapacity:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateRemainingImageCapacityCell];
}

/// 残り容量(撮影秒数)の状態が変わった時に呼び出されます。
- (void)didChangeRemainingVideoCapacity:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateRemainingVideoCapacityCell];
}

/// 水準器の状態が変わった時に呼び出されます。
- (void)didChangeLevelGauge:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateLevelGaugeCell];
}

/// 'Apply Camera Setting'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtApplyCameraSettingCell {
	DEBUG_LOG(@"");

	// カメラ設定のロードを開始します。
	__weak SPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 共有ドキュメントフォルダから設定のスナップショットファイルを読み込みます。
		NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *directoryPath = directoryPaths[0];
		NSString *filePath = [directoryPath stringByAppendingPathComponent:CameraSettingFilePath];
		NSDictionary *snapshot = [NSDictionary dictionaryWithContentsOfFile:filePath];
		DEBUG_LOG(@"filePath=%@", filePath);
		DEBUG_LOG(@"snapshot=%@", snapshot);
		if (!snapshot) {
			[weakSelf showAlertMessage:NSLocalizedString(@"Could not read camera setting from file.", nil) title:NSLocalizedString(@"Could not apply camera setting", nil)];
			return;
		}
		
		// スナップショットからカメラの設定を復元します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSArray *exclude = @[
			CameraPropertyWifiCh, // Wi-Fiチャンネルの設定は復元しません。
		];
		if (![camera restoreSnapshotOfSetting:snapshot exclude:exclude error:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not apply camera setting", nil)];
			return;
		}
		
		// カメラ設定のロードが完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

/// 'Save Camera Setting'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtSaveCameraSettingCell {
	DEBUG_LOG(@"");

	// カメラ設定をセーブを開始します。
	__weak SPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// 現在のカメラ設定のスナップショットを作成します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSDictionary *snapshot = [camera createSnapshotOfSetting:&error];
		if (!snapshot) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not save camera setting", nil)];
			return;
		}
		
		// 取得したカメラプロパティの設定値を共有ドキュメントフォルダのファイルとして保存します。
		NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *directoryPath = directoryPaths[0];
		NSString *filePath = [directoryPath stringByAppendingPathComponent:CameraSettingFilePath];
		DEBUG_LOG(@"filePath=%@", filePath);
		DEBUG_LOG(@"fileContent=%@", snapshot);
		if (![snapshot writeToFile:filePath atomically:YES]) {
			[weakSelf showAlertMessage:NSLocalizedString(@"Could not write camera setting to file. The content of file might be lost.", nil) title:NSLocalizedString(@"Could not save camera setting", nil)];
			return;
		}
		
		// カメラ設定をセーブが完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

#pragma mark -

/// バッテリーレベルを表示します。
- (void)updateBatteryLevelCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.batteryLevelCell name:CameraPropertyBatteryLevel completion:nil];
}

/// 内部高温警告の状態を表示します。
- (void)updateHighTemperatureWarningCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *highTemperatureWarning;
	if (camera.highTemperatureWarning) {
		highTemperatureWarning = NSLocalizedString(@"Yes", nil);
	} else {
		highTemperatureWarning = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.highTemperatureWarningCell.detailTextLabel.text = highTemperatureWarning;
}

/// ISO感度の範囲外警告の状態を表示します。
- (void)updateIsoSensitivityWarningCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *isoSensitivityWarning;
	if (camera.actualIsoSensitivityWarning) {
		isoSensitivityWarning = NSLocalizedString(@"Yes", nil);
	} else {
		isoSensitivityWarning = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.isoSensitivityWarningCell.detailTextLabel.text = isoSensitivityWarning;
}

/// 露出連動範囲外警告の状態を表示します。
- (void)updateExposureWarningCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *exposureWarning;
	if (camera.exposureWarning) {
		exposureWarning = NSLocalizedString(@"Yes", nil);
	} else {
		exposureWarning = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.exposureWarningCell.detailTextLabel.text = exposureWarning;
}

/// 測光連動範囲外警告の状態を表示します。
- (void)updateExposureMeteringWarningCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *exposureMeteringWarning;
	if (camera.exposureMeteringWarning) {
		exposureMeteringWarning = NSLocalizedString(@"Yes", nil);
	} else {
		exposureMeteringWarning = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.exposureMeteringWarningCell.detailTextLabel.text = exposureMeteringWarning;
}

/// メディア書き込み中の状態を表示します。
- (void)updateMediaBusyCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *mediaBusy;
	if (camera.mediaBusy) {
		mediaBusy = NSLocalizedString(@"Yes", nil);
	} else {
		mediaBusy = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.mediaBusyCell.detailTextLabel.text = mediaBusy;
}

/// メディアエラー発生中の状態を表示します。
- (void)updateMediaErrorCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSString *mediaError;
	if (camera.mediaError) {
		mediaError = NSLocalizedString(@"Yes", nil);
	} else {
		mediaError = NSLocalizedString(@"No", nil);
	}
	// 表示を更新します。
	self.mediaErrorCell.detailTextLabel.text = mediaError;
}

/// 残り容量(バイト数)の状態を表示します。
- (void)updateRemainingMediaCapacityCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *remainingMediaCapacityFormattedNumber = [numberFormatter stringFromNumber:@(camera.remainingMediaCapacity)];
	NSString *remainingMediaCapacity = [NSString stringWithFormat:NSLocalizedString(@"%@ Bytes", nil), remainingMediaCapacityFormattedNumber];
	// 表示を更新します。
	self.remainingMediaCapacityCell.detailTextLabel.text = remainingMediaCapacity;
}

/// 残り容量(撮影枚数)の状態を表示します。
- (void)updateRemainingImageCapacityCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *remainingImageCapacityFormattedNumber = [numberFormatter stringFromNumber:@(camera.remainingImageCapacity)];
	NSString *remainingImageCapacity = [NSString stringWithFormat:NSLocalizedString(@"%@ Images", nil), remainingImageCapacityFormattedNumber];
	// 表示を更新します。
	self.remainingImageCapacityCell.detailTextLabel.text = remainingImageCapacity;
}

/// 残り容量(撮影秒数)の状態を表示します。
- (void)updateRemainingVideoCapacityCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	AppCamera *camera = GetAppCamera();
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *remainingVideoCapacityFormattedNumber = [numberFormatter stringFromNumber:@(camera.remainingVideoCapacity)];
	NSString *remainingVideoCapacity = [NSString stringWithFormat:NSLocalizedString(@"%@ Seconds", nil), remainingVideoCapacityFormattedNumber];
	// 表示を更新します。
	self.remainingVideoCapacityCell.detailTextLabel.text = remainingVideoCapacity;
}

/// 水準器の状態を表示します。
- (void)updateLevelGaugeCell {
	DEBUG_LOG(@"");
	
	// MARK: カメラの水準器情報の内容を一時変数の水準器情報にコピーします。
	// カメラプロパティのlevelGaugeを取得してからその中を参照するようにしないと、水準器情報に変化が
	// あるたびにメインスレッド以外のところでlevelGaugeのオブジェクトツリーが丸ごと入れ替わらしく、
	// camra.levelGaugeの要素を直に参照したらメモリ違反で異常終了したりする場合があります。
	AppCamera *camera = GetAppCamera();
	NSDictionary *levelGuageDictionary = camera.levelGauge;
	// プロパティの値を表示用の文言に変換します。
	NSString *levelGuageOrientation = NSLocalizedString(@"Unknown", nil);
	if (levelGuageDictionary[OLYCameraLevelGaugeOrientationKey]) {
		NSString *levelGuageOrientationValue = levelGuageDictionary[OLYCameraLevelGaugeOrientationKey];
		NSDictionary *levelGuageOrientationTitles = @{
			@"landscape": NSLocalizedString(@"Landscape", nil),
			@"portrait_left": NSLocalizedString(@"Portrait", nil),
			@"landscape_upside_down": NSLocalizedString(@"Landscape", nil),
			@"portrait_right": NSLocalizedString(@"Portrait", nil),
			@"faceup": NSLocalizedString(@"Face up", nil),
			@"facedown": NSLocalizedString(@"Face down", nil),
		};
		levelGuageOrientation = levelGuageOrientationTitles[levelGuageOrientationValue];
	}
	NSString *levelGuageRolling = NSLocalizedString(@"Unknown", nil);
	if (levelGuageDictionary[OLYCameraLevelGaugeRollingKey]) {
		float levelGuageRollingValue = [levelGuageDictionary[OLYCameraLevelGaugeRollingKey] floatValue];
		if (!isnan(levelGuageRollingValue)) {
			if (levelGuageRollingValue > 0) {
				levelGuageRolling = [NSString stringWithFormat:NSLocalizedString(@"Left %1.1f", nil), levelGuageRollingValue];
			} else if (levelGuageRollingValue < 0) {
				levelGuageRolling = [NSString stringWithFormat:NSLocalizedString(@"Right %1.1f", nil), -levelGuageRollingValue];
			} else {
				levelGuageRolling = [NSString stringWithFormat:NSLocalizedString(@"%1.1f", nil), levelGuageRollingValue];
			}
		}
	}
	NSString *levelGuagePitching = NSLocalizedString(@"Unknown", nil);
	if (levelGuageDictionary[OLYCameraLevelGaugePitchingKey]) {
		float levelGuagePitchingValue = [levelGuageDictionary[OLYCameraLevelGaugePitchingKey] floatValue];
		if (!isnan(levelGuagePitchingValue)) {
			if (levelGuagePitchingValue > 0) {
				levelGuagePitching = [NSString stringWithFormat:NSLocalizedString(@"Up %1.1f", nil), levelGuagePitchingValue];
			} else if (levelGuagePitchingValue < 0) {
				levelGuagePitching = [NSString stringWithFormat:NSLocalizedString(@"Down %1.1f", nil), -levelGuagePitchingValue];
			} else {
				levelGuagePitching = [NSString stringWithFormat:NSLocalizedString(@"%1.1f", nil), levelGuagePitchingValue];
			}
		}
	}
	// 表示を更新します。
	self.levelGaugeOrientationCell.detailTextLabel.text = levelGuageOrientation;
	self.levelGaugeRollingCell.detailTextLabel.text = levelGuageRolling;
	self.levelGaugePitchingCell.detailTextLabel.text = levelGuagePitching;
}

/// カメラプロパティ値を表示します。
- (void)updateCameraPropertyCell:(UITableViewCell *)cell name:(NSString *)name completion:(void (^)(NSString *value))completion {
	DEBUG_LOG(@"name=%@", name);
	
	__weak UITableViewCell *weakCell = cell;
	__weak SPanelViewController *weakSelf = self;
	BOOL userInteractionEnabled = weakCell.userInteractionEnabled;
	weakCell.userInteractionEnabled = NO; // 表示内容が確定するまでは操作禁止にします。
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラプロパティを取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSString *propertyValue = [camera cameraPropertyValue:name error:&error];
		if (!propertyValue) {
			// カメラプロパティが取得できませんでした。
			// エラーを無視します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakCell.userInteractionEnabled = userInteractionEnabled;
				weakCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
				[weakSelf tableViewCell:weakCell enabled:[camera canSetCameraProperty:name]];
				if (completion) {
					completion(propertyValue);
				}
			}];
			return;
		}
		DEBUG_LOG(@"propertyValue=%@", propertyValue);
		// 取得した値を表示用の文言に変換します。
		NSString *propertyValueTitle = [camera cameraPropertyValueLocalizedTitle:propertyValue];
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakCell.userInteractionEnabled = userInteractionEnabled;
			weakCell.detailTextLabel.text = propertyValueTitle;
			if (weakCell.accessoryType != UITableViewCellAccessoryNone) {
				[weakSelf tableViewCell:weakCell enabled:[camera canSetCameraProperty:name]];
			}
			if (completion) {
				completion(propertyValue);
			}
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
	});
	progress.customView = progressImageView;
	progress.mode = MBProgressHUDModeCustomView;
	[NSThread sleepForTimeInterval:0.5];
}

@end
