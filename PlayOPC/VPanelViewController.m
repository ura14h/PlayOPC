//
//  VPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "VPanelViewController.h"
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "RecordingLocationManager.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface VPanelViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *showLiveViewGridSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *showLiveViewSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showSoundVolumeLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showFaceScanCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showRecviewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAspectRatioCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showImagesizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showCompressibilityRatioCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showRawCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showQualityMovieCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showQualityMovieShortMovieRecordTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showGpsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showDestinationFileCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *setCurrentGeolocationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearGelocationCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書
@property (strong, nonatomic) NSArray *liveViewSizes; ///< ライブビューサイズの選択肢

@end

#pragma mark -

@implementation VPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// ライブビューサイズの選択肢を構築します。
	NSMutableArray *liveViewSizes = [[NSMutableArray alloc] init];
	NSDictionary *liveViewSizeQVGA = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:LiveViewSizeIsQVGA", @"VPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:[NSValue valueWithCGSize:OLYCameraLiveViewSizeQVGA]
	};
	NSDictionary *liveViewSizeVGA = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:LiveViewSizeIsVGA", @"VPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:[NSValue valueWithCGSize:OLYCameraLiveViewSizeVGA]
	};
	NSDictionary *liveViewSizeSVGA = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:LiveViewSizeIsSVGA", @"VPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:[NSValue valueWithCGSize:OLYCameraLiveViewSizeSVGA]
	};
	NSDictionary *liveViewSizeXVGA = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:LiveViewSizeIsXGA", @"VPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:[NSValue valueWithCGSize:OLYCameraLiveViewSizeXGA]
	};
	NSDictionary *liveViewSizeQuadVGA = @{
		ItemSelectionViewItemTitleKey:NSLocalizedString(@"$cell:LiveViewSizeIsQuadVGA", @"VPanelViewController.viewDidLoad"),
		ItemSelectionViewItemValueKey:[NSValue valueWithCGSize:OLYCameraLiveViewSizeQuadVGA]
	};
	[liveViewSizes addObject:liveViewSizeQVGA];
	[liveViewSizes addObject:liveViewSizeVGA];
	[liveViewSizes addObject:liveViewSizeSVGA];
	[liveViewSizes addObject:liveViewSizeXVGA];
	[liveViewSizes addObject:liveViewSizeQuadVGA];
	self.liveViewSizes = liveViewSizes;
	
	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeFaceScan)) forKey:CameraPropertyFaceScan];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeRecview)) forKey:CameraPropertyRecview];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAspectRatio)) forKey:CameraPropertyAspectRatio];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeImagesize)) forKey:CameraPropertyImagesize];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeCompressibilityRatio)) forKey:CameraPropertyCompressibilityRatio];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeRaw)) forKey:CameraPropertyRaw];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeQualityMovie)) forKey:CameraPropertyQualityMovie];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeQualityMovieShortMovieRecordTime)) forKey:CameraPropertyQualityMovieShortMovieRecordTime];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeGps)) forKey:CameraPropertyGps];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeDestinationFile)) forKey:CameraPropertyDestinationFile];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];

	// 画面表示を初期表示します。
	NSString *soundVolumeLevelTitle = [camera cameraPropertyLocalizedTitle:CameraPropertySoundVolumeLevel];
	NSString *faceScanTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyFaceScan];
	NSString *recviewTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyRecview];
	NSString *aspectRatioTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAspectRatio];
	NSString *imagesizeTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyImagesize];
	NSString *compressibilityRatioTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyCompressibilityRatio];
	NSString *rawTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyRaw];
	NSString *qualityMovieTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyQualityMovie];
	NSString *qualityMovieShortMovieRecordTimeTitle =[camera cameraPropertyLocalizedTitle:CameraPropertyQualityMovieShortMovieRecordTime];
	NSString *gpsTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyGps];
	NSString *destinationFileTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyDestinationFile];
	self.showSoundVolumeLevelCell.textLabel.text = soundVolumeLevelTitle;
	self.showFaceScanCell.textLabel.text = faceScanTitle;
	self.showRecviewCell.textLabel.text = recviewTitle;
	self.showAspectRatioCell.textLabel.text = aspectRatioTitle;
	self.showImagesizeCell.textLabel.text = imagesizeTitle;
	self.showCompressibilityRatioCell.textLabel.text = compressibilityRatioTitle;
	self.showRawCell.textLabel.text = rawTitle;
	self.showQualityMovieCell.textLabel.text = qualityMovieTitle;
	self.showQualityMovieShortMovieRecordTimeCell.textLabel.text = qualityMovieShortMovieRecordTimeTitle;
	self.showGpsCell.textLabel.text = gpsTitle;
	self.showDestinationFileCell.textLabel.text = destinationFileTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.showFaceScanCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showRecviewCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showAspectRatioCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showImagesizeCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showCompressibilityRatioCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showRawCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showQualityMovieCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showQualityMovieShortMovieRecordTimeCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showGpsCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showDestinationFileCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showLiveViewGridSwitch.enabled = NO;
	[self tableViewCell:self.showLiveViewSizeCell enabled:NO];
	[self tableViewCell:self.showFaceScanCell enabled:NO];
	[self tableViewCell:self.showRecviewCell enabled:NO];
	[self tableViewCell:self.showAspectRatioCell enabled:NO];
	[self tableViewCell:self.showImagesizeCell enabled:NO];
	[self tableViewCell:self.showCompressibilityRatioCell enabled:NO];
	[self tableViewCell:self.showRawCell enabled:NO];
	[self tableViewCell:self.showQualityMovieCell enabled:NO];
	[self tableViewCell:self.showQualityMovieShortMovieRecordTimeCell enabled:NO];
	[self tableViewCell:self.showGpsCell enabled:NO];
	[self tableViewCell:self.showDestinationFileCell enabled:NO];
	[self tableViewCell:self.setCurrentGeolocationCell enabled:NO];
	[self tableViewCell:self.clearGelocationCell enabled:NO];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	[camera removeCameraPropertyDelegate:self];
	_cameraPropertyObserver = nil;
	_liveViewSizes = nil;
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
	[self updateShowLiveViewGridSwitch];
	[self updateShowLiveViewSizeCell];
	[self updateShowSoundVolumeLevelCell];
	[self updateShowFaceScanCell];
	[self updateShowRecviewCell];
	[self updateShowAspectRatioCell];
	[self updateShowImagesizeCell];
	[self updateShowCompressibilityRatioCell];
	[self updateShowRawCell];
	[self updateShowQualityMovieCell];
	[self updateShowQualityMovieShortMovieRecordTimeCell];
	[self updateShowGpsCell];
	[self updateShowDestinationFileCell];
	[self tableViewCell:self.setCurrentGeolocationCell enabled:YES];
	[self tableViewCell:self.clearGelocationCell enabled:YES];

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
	self.showLiveViewGridSwitch.enabled = NO;
	[self tableViewCell:self.showLiveViewSizeCell enabled:NO];
	[self tableViewCell:self.showFaceScanCell enabled:NO];
	[self tableViewCell:self.showRecviewCell enabled:NO];
	[self tableViewCell:self.showAspectRatioCell enabled:NO];
	[self tableViewCell:self.showImagesizeCell enabled:NO];
	[self tableViewCell:self.showCompressibilityRatioCell enabled:NO];
	[self tableViewCell:self.showRawCell enabled:NO];
	[self tableViewCell:self.showQualityMovieCell enabled:NO];
	[self tableViewCell:self.showQualityMovieShortMovieRecordTimeCell enabled:NO];
	[self tableViewCell:self.showGpsCell enabled:NO];
	[self tableViewCell:self.showDestinationFileCell enabled:NO];
	[self tableViewCell:self.setCurrentGeolocationCell enabled:NO];
	[self tableViewCell:self.clearGelocationCell enabled:NO];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowSoundVolumeLevel"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertySoundVolumeLevel;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowLiveViewSize"]) {
		ItemSelectionViewController *viewController = segue.destinationViewController;
		viewController.title = self.showLiveViewSizeCell.textLabel.text;
		viewController.tag = [CameraPropertyLiveViewSize hash];
		viewController.items = self.liveViewSizes;
		AppCamera *camera = GetAppCamera();
		[self.liveViewSizes enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger index, BOOL *stop) {
			NSValue *itemValue = item[ItemSelectionViewItemValueKey];
			OLYCameraLiveViewSize itemSize = [itemValue CGSizeValue];
			if (CGSizeEqualToSize(itemSize, camera.liveViewSize)) {
				viewController.selectedItemIndex = index;
				*stop = YES;
			}
		}];
		viewController.itemCellIdentifier = @"ItemCell";
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowFaceScan"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyFaceScan;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowRecview"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyRecview;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowAspectRatio"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyAspectRatio;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowImagesize"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyImagesize;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowCompressibilityRatio"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyCompressibilityRatio;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowRaw"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyRaw;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowQualityMovie"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyQualityMovie;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowQualityMovieShortMovieRecordTime"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyQualityMovieShortMovieRecordTime;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowGps"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyGps;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowDestinationFile"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyDestinationFile;
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
	if ([cellReuseIdentifier isEqualToString:@"SetCurrentGeolocation"]) {
		[self didSelectRowAtSetCurrentGeolocationCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ClearGelocation"]) {
		[self didSelectRowAtClearGelocationCell];
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	// カメラプロパティに応じた処理を呼び出します。
	if ([controller isMemberOfClass:[ItemSelectionViewController class]]) {
		NSUInteger hash = controller.tag;
		if (hash == [CameraPropertyLiveViewSize hash]) {
			[self didSelectLiveViewSizeItem:index];
		} else {
			DEBUG_LOG(@"Unknown hash: %lu", (unsigned long)hash);
		}
	} else if ([controller isMemberOfClass:[CameraPropertyValueSelectionViewController class]]) {
		NSString *property = ((CameraPropertyValueSelectionViewController *)controller).property;
		if ([property isEqualToString:CameraPropertySoundVolumeLevel]) {
			[self didChangeSoundVolumeLevel];
		} else if ([property isEqualToString:CameraPropertyFaceScan]) {
			[self didChangeFaceScan];
		} else if ([property isEqualToString:CameraPropertyRecview]) {
			[self didChangeRecview];
		} else if ([property isEqualToString:CameraPropertyAspectRatio]) {
			[self didChangeAspectRatio];
		} else if ([property isEqualToString:CameraPropertyImagesize]) {
			[self didChangeImagesize];
		} else if ([property isEqualToString:CameraPropertyCompressibilityRatio]) {
			[self didChangeCompressibilityRatio];
		} else if ([property isEqualToString:CameraPropertyRaw]) {
			[self didChangeRaw];
		} else if ([property isEqualToString:CameraPropertyQualityMovie]) {
			[self didChangeQualityMovie];
		} else if ([property isEqualToString:CameraPropertyQualityMovieShortMovieRecordTime]) {
			[self didChangeQualityMovieShortMovieRecordTime];
		} else if ([property isEqualToString:CameraPropertyGps]) {
			[self didChangeGps];
		} else if ([property isEqualToString:CameraPropertyDestinationFile]) {
			[self didChangeDestinationFile];
		} else {
			DEBUG_LOG(@"Unknown property: %@", property);
		}
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
		__weak VPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

#pragma mark -

/// ライブビューのグリッドスイッチが変わった時に呼び出されます。
- (IBAction)didChangeLiveViewGridSwithValue:(UISwitch *)sender {
	DEBUG_LOG(@"");

	// グリッド表示非表示の設定値を変更します。
	AppSetting *setting = GetAppSetting();
	setting.showLiveImageGrid = sender.on;
}

/// 音量レベルの値が変わった時に呼び出されます。
- (void)didChangeSoundVolumeLevel {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowSoundVolumeLevelCell];
}

/// 顔検出の値が変わった時に呼び出されます。
- (void)didChangeFaceScan {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowFaceScanCell];
}

/// 撮影結果確認用画像の値が変わった時に呼び出されます。
- (void)didChangeRecview {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowRecviewCell];
}

/// アスペクト比の値が変わった時に呼び出されます。
- (void)didChangeAspectRatio {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowAspectRatioCell];
}

/// 静止画サイズの値が変わった時に呼び出されます。
- (void)didChangeImagesize {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowImagesizeCell];
}

/// 圧縮率の値が変わった時に呼び出されます。
- (void)didChangeCompressibilityRatio {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowCompressibilityRatioCell];
}

/// RAW設定の値が変わった時に呼び出されます。
- (void)didChangeRaw {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowRawCell];
}

/// 動画画質モードの値が変わった時に呼び出されます。
- (void)didChangeQualityMovie {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowQualityMovieCell];
}

/// ショートムービー記録時間の値が変わった時に呼び出されます。
- (void)didChangeQualityMovieShortMovieRecordTime {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowQualityMovieShortMovieRecordTimeCell];
}

/// Exif位置付与設定の値が変わった時に呼び出されます。
- (void)didChangeGps {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowGpsCell];
}

/// 撮影画像保存先の値が変わった時に呼び出されます。
- (void)didChangeDestinationFile {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowDestinationFileCell];
}

/// ライブビューサイズの選択肢が選択された時に呼び出されます。
- (void)didSelectLiveViewSizeItem:(NSUInteger)itemIndex {
	DEBUG_LOG(@"itemIndex=%ld", (long)itemIndex);
	
	// 選択されたライブビューサイズを取得します。
	NSDictionary *item = self.liveViewSizes[itemIndex];
	NSValue *itemValue = item[ItemSelectionViewItemValueKey];
	OLYCameraLiveViewSize itemSize = [itemValue CGSizeValue];
	
	// ライブビューサイズの変更を開始します。
	__weak VPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// ライブビューサイズを変更します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera changeLiveViewSize:itemSize error:&error]) {
			// サイズを変更できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotChangeLiveViewSize", @"VPanelViewController.didSelectLiveViewSizeItem")];
			return;
		}
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowLiveViewSizeCell];
		}];
	}];
}

/// 'Set　Current　Geolocation'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtSetCurrentGeolocationCell {
	DEBUG_LOG(@"");

	// 位置情報の設定を開始します。
	__weak VPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// 現在位置を取得します。
		RecordingLocationManager *locationManager = [[RecordingLocationManager alloc] init];
		NSError *error = nil;
		CLLocation *location = [locationManager currentLocation:10.0 error:&error];
		if (!location) {
			// 現在位置が取得できませんでした。
			[weakSelf showAlertMessage:error.description title:NSLocalizedString(@"$title:CouldNotSetCurrentGeolocation", @"VPanelViewController.didSelectRowAtSetCurrentGeolocationCell")];
			return;
		}
		DEBUG_LOG(@"location=%@", location.description);
		
		// カメラに位置情報を設定します。
		AppCamera *camera = GetAppCamera();
		if (![camera setGeolocationWithCoreLocation:location error:&error]) {
			// 位置情報を設定できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotSetCurrentGeolocation", @"VPanelViewController.didSelectRowAtSetCurrentGeolocationCell")];
			return;
		}
		
		// 位置情報の設定が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

/// 'Clear　Geolocation'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtClearGelocationCell {
	DEBUG_LOG(@"");

	// 位置情報のクリアを開始します。
	__weak VPanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラに設定されている位置情報をクリアします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera clearGeolocation:&error]) {
			// 位置情報をクリアできませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotClearGelocation", @"VPanelViewController.didSelectRowAtClearGelocationCell")];
			return;
		}
		
		// 位置情報のクリアが完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
	}];
}

#pragma mark -

/// ライブビューのグリッド表示非表示設定を表示します。
- (void)updateShowLiveViewGridSwitch {
	DEBUG_LOG(@"");
	
	AppSetting *setting = GetAppSetting();
	self.showLiveViewGridSwitch.enabled = YES;
	self.showLiveViewGridSwitch.on = setting.showLiveImageGrid;
}

/// ライブビューのピクセルサイズを表示します。
- (void)updateShowLiveViewSizeCell {
	DEBUG_LOG(@"");
	
	// 選択肢の値を表示用の文言に変換します。
	__block NSString *liveViewSize = NSLocalizedString(@"$cell:LiveViewSizeUnknown", @"VPanelViewController.updateShowLiveViewSizeCell");
	AppCamera *camera = GetAppCamera();
	[self.liveViewSizes enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger index, BOOL *stop) {
		NSValue *itemValue = item[ItemSelectionViewItemValueKey];
		OLYCameraLiveViewSize itemSize = [itemValue CGSizeValue];
		if (CGSizeEqualToSize(itemSize, camera.liveViewSize)) {
			liveViewSize = item[ItemSelectionViewItemTitleKey];
			*stop = YES;
		}
	}];
	// 表示を更新します。
	self.showLiveViewSizeCell.detailTextLabel.text = liveViewSize;
	[self tableViewCell:self.showLiveViewSizeCell enabled:YES];
}

/// 音量レベルを表示します。
- (void)updateShowSoundVolumeLevelCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showSoundVolumeLevelCell name:CameraPropertySoundVolumeLevel completion:nil];
}

/// 顔検出を表示します。
- (void)updateShowFaceScanCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showFaceScanCell name:CameraPropertyFaceScan completion:nil];
}

/// 撮影結果確認用画像を表示します。
- (void)updateShowRecviewCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showRecviewCell name:CameraPropertyRecview completion:nil];
}

/// アスペクト比を表示します。
- (void)updateShowAspectRatioCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showAspectRatioCell name:CameraPropertyAspectRatio completion:nil];
}

/// 静止画サイズを表示します。
- (void)updateShowImagesizeCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showImagesizeCell name:CameraPropertyImagesize completion:nil];
}

/// 圧縮率を表示します。
- (void)updateShowCompressibilityRatioCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showCompressibilityRatioCell name:CameraPropertyCompressibilityRatio completion:nil];
}

/// RAW設定を表示します。
- (void)updateShowRawCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showRawCell name:CameraPropertyRaw completion:nil];
}

/// 動画画質モードを表示します。
- (void)updateShowQualityMovieCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showQualityMovieCell name:CameraPropertyQualityMovie completion:nil];
}

/// ショートムービー記録時間を表示します。
- (void)updateShowQualityMovieShortMovieRecordTimeCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showQualityMovieShortMovieRecordTimeCell name:CameraPropertyQualityMovieShortMovieRecordTime completion:nil];
}

/// Exif位置付与設定を表示します。
- (void)updateShowGpsCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showGpsCell name:CameraPropertyGps completion:nil];
}

/// 撮影画像保存先を表示します。
- (void)updateShowDestinationFileCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showDestinationFileCell name:CameraPropertyDestinationFile completion:nil];
}

/// カメラプロパティ値を表示します。
- (void)updateCameraPropertyCell:(UITableViewCell *)cell name:(NSString *)name completion:(void (^)(NSString *value))completion {
	DEBUG_LOG(@"name=%@", name);
	
	__weak UITableViewCell *weakCell = cell;
	__weak VPanelViewController *weakSelf = self;
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
				weakCell.detailTextLabel.text = NSLocalizedString(@"$cell:CouldNotGetCameraPropertyValue", @"VPanelViewController.updateCameraPropertyCell");
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
