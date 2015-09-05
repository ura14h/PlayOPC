//
//  CPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CPanelViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

static NSString *const WhiteBalanceMapWbRevKey = @"WhiteBalanceMapWbRevKey"; ///< WB補正Aのカメラプロパティ名
static NSString *const WhiteBalanceMapWbRevGKey = @"WhiteBalanceMapWbRevGKey"; ///< WB補正Gのカメラプロパティ名
static NSString *const ArtFilterContrastKey = @"ArtFilterContrastKey"; ///< コントラストのプロパティ名
static NSString *const ArtFilterSharpKey = @"ArtFilterSharpKey"; ///< シャープネスのプロパティ名
static NSString *const ArtFilterSaturationLevelKey = @"ArtFilterSaturationLevelKey"; ///< 彩度のプロパティ名
static NSString *const ArtFilterToneKey = @"ArtFilterToneKey"; ///< 階調のプロパティ名
static NSString *const ArtFilterEffectLevelKey = @"ArtFilterEffectLevelKey"; ///< 効果強弱のプロパティ名
static NSString *const ArtFilterMonotonefilterKey = @"ArtFilterMonotonefilterKey"; ///< モノクロフィルター効果のプロパティ名
static NSString *const ArtFilterMonotonecolorKey = @"ArtFilterMonotonecolorKey"; ///< 調色効果のプロパティ名
static NSString *const ArtFilterArtEffectTypeKey = @"ArtFilterArtEffectTypeKey"; ///< アートフィルターバリエーションのプロパティ名
static NSString *const ArtFilterArtEffectHybridKey = @"ArtFilterArtEffectHybridKey"; ///< アートエフェクトのプロパティ名

@interface CPanelViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate>

// アートフィルターパラメータ操作のUIに関する設計メモ:
//
// アートフィルター種別と仕上がりピクチャーモードはほとんど排他的に動作するようなのと、フィルターパラメータ
// (コントラストからアートエフェクトまで)の数が多すぎてそのままUIとすると操作が煩雑になるため、現在選択されている
// アートフィルター(アートフィルター種別かもしくは仕上がりピクチャーモード)に応じて操作とするフィルターパラメータを
// 同じ表示位置で切り替えるようにしました。

@property (weak, nonatomic) IBOutlet UITableViewCell *showWbCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showCustomWbKelvin1Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showWbRevCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showWbRevGCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAutoWbDenkyuColoredLeavingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColortoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showRecentlyArtFilterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showArtFilterAutoBracketCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showContrastCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showSharpCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showSaturationLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showToneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showEffectLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showToneControlLowCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showToneControlMiddleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showToneControlHighCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showMonotonefilterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showMonotonecolorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorCreatorColorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorCreatorVividCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorPhaseCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showArtEffectTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showArtEffectHybridCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書
@property (strong, nonatomic) NSDictionary *whiteBalanceMap; ///< ホワイトバランスのプロパティ値とホワイトバランス補正のプロパティ名を対応付けする辞書
@property (strong, nonatomic) NSString *currentWhiteBalance; ///< 現在選択されているホワイトバランスのプロパティ値
@property (strong, nonatomic) NSString *showWbRevCellTitle; ///< WB補正Aの暫定表示名称
@property (strong, nonatomic) NSString *showWbRevGCellTitle; ///< WB補正Gの暫定表示名称
@property (strong, nonatomic) NSDictionary *artFilterMap; ///< アートフィルターに関連するフィルターパラメータのプロパティ名を対応付けする辞書
@property (strong, nonatomic) NSString *currentArtFilter; ///< 現在選択されているアートフィルター
@property (strong, nonatomic) NSString *showContrastCellTitle; ///< コントラストの暫定表示名称
@property (strong, nonatomic) NSString *showSharpCellTitle; ///< シャープネスの暫定表示名称
@property (strong, nonatomic) NSString *showSaturationLevelCellTitle; ///< 彩度の暫定表示名称
@property (strong, nonatomic) NSString *showToneCellTitle; ///< 階調の暫定表示名称
@property (strong, nonatomic) NSString *showEffectLevelCellTitle; ///< 効果強弱の暫定表示名称
@property (strong, nonatomic) NSString *showMonotonefilterCellTitle; ///< モノクロフィルター効果の暫定表示名称
@property (strong, nonatomic) NSString *showMonotonecolorCellTitle; ///< 調色効果の暫定表示名称
@property (strong, nonatomic) NSString *showArtEffectTypeCellTitle; ///< アートフィルターバリエーションの暫定表示名称
@property (strong, nonatomic) NSString *showArtEffectHybridCellTitle; ///< アートエフェクトの暫定表示名称

@end

#pragma mark -

@implementation CPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	
	// ホワイトバランスのプロパティ値とホワイトバランス補正のプロパティ名を対応付けする辞書をセットアップします。
	NSMutableDictionary *whiteBalanceMap = [[NSMutableDictionary alloc] init];
	NSDictionary *wbRevAuto = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRevAuto,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevGAuto,
	};
	NSDictionary *wbRev5300k = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRev5300k,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevG5300k,
	};
	NSDictionary *wbRev7500k = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRev7500k,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevG7500k,
	};
	NSDictionary *wbRev6000k = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRev6000k,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevG6000k,
	};
	NSDictionary *wbRev3000k = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRev3000k,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevG3000k,
	};
	NSDictionary *wbRev4000k = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRev4000k,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevG4000k,
	};
	NSDictionary *wbRevAutoUnderWater = @{
		WhiteBalanceMapWbRevKey: CameraPropertyWbRevAutoUnderWater,
		WhiteBalanceMapWbRevGKey: CameraPropertyWbRevGAutoUnderWater,
	};
	[whiteBalanceMap setObject:wbRevAuto forKey:CameraPropertyWbWbAuto];
	[whiteBalanceMap setObject:wbRev5300k forKey:CameraPropertyWbMwbFine];
	[whiteBalanceMap setObject:wbRev7500k forKey:CameraPropertyWbMwbShade];
	[whiteBalanceMap setObject:wbRev6000k forKey:CameraPropertyWbMwbCloud];
	[whiteBalanceMap setObject:wbRev3000k forKey:CameraPropertyWbMwbLamp];
	[whiteBalanceMap setObject:wbRev4000k forKey:CameraPropertyWbMwbFluorescence1];
	[whiteBalanceMap setObject:wbRevAutoUnderWater forKey:CameraPropertyWbMwbWater1];
	self.whiteBalanceMap = whiteBalanceMap;
	
	// 現在選択されているホワイトバランスのプロパティ値を初期化します。
	self.currentWhiteBalance = nil;

	// アートフィルターに関連するフィルターパラメータのプロパティ名を対応付けする辞書をセットアップします。
	NSMutableDictionary *artFilterMap = [[NSMutableDictionary alloc] init];
	NSDictionary *filterFlat = @{
		ArtFilterContrastKey: CameraPropertyContrastFlat,
		ArtFilterSharpKey: CameraPropertySharpFlat,
		ArtFilterSaturationLevelKey: CameraPropertySaturationLevelFlat,
		ArtFilterToneKey: CameraPropertyToneFlat,
	};
	NSDictionary *filterNatural = @{
		ArtFilterContrastKey: CameraPropertyContrastNatural,
		ArtFilterSharpKey: CameraPropertySharpNatural,
		ArtFilterSaturationLevelKey: CameraPropertySaturationLevelNatural,
		ArtFilterToneKey: CameraPropertyToneNatural,
	};
	NSDictionary *filterMonotone = @{
		ArtFilterContrastKey: CameraPropertyContrastMonochrome,
		ArtFilterSharpKey: CameraPropertySharpMonochrome,
		ArtFilterToneKey: CameraPropertyToneMonochrome,
		ArtFilterMonotonefilterKey: CameraPropertyMonotonefilterMonochrome,
		ArtFilterMonotonecolorKey: CameraPropertyMonotonecolorMonochrome,
	};
	NSDictionary *filterPortrait = @{
		ArtFilterContrastKey: CameraPropertyContrastSoft,
		ArtFilterSharpKey: CameraPropertySharpSoft,
		ArtFilterSaturationLevelKey: CameraPropertySaturationLevelSoft,
		ArtFilterToneKey: CameraPropertyToneSoft,
	};
	NSDictionary *filterIFinish = @{
		ArtFilterContrastKey: CameraPropertyContrastIFinish,
		ArtFilterSharpKey: CameraPropertySharpIFinish,
		ArtFilterSaturationLevelKey: CameraPropertySaturationLevelIFinish,
		ArtFilterToneKey: CameraPropertyToneIFinish,
		ArtFilterEffectLevelKey: CameraPropertyEffectLevelIFinish,
	};
	NSDictionary *filterVivid = @{
		ArtFilterContrastKey: CameraPropertyContrastVivid,
		ArtFilterSharpKey: CameraPropertySharpVivid,
		ArtFilterSaturationLevelKey: CameraPropertySaturationLevelVivid,
		ArtFilterToneKey: CameraPropertyToneVivid,
	};
	NSDictionary *filterEportrait = @{
	};
	NSDictionary *filterColorCreator = @{
	};
	NSDictionary *filterPopart = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypePopart,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridPopart,
	};
	NSDictionary *filterFantasicFocus = @{
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridFantasicFocus,
	};
	NSDictionary *filterDaydream = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeDaydream,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridDaydream,
	};
	NSDictionary *filterLightTone = @{
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridLightTone,
	};
	NSDictionary *filterRoughMonochrome = @{
		ArtFilterMonotonefilterKey: CameraPropertyMonotonefilterRoughMonochrome,
		ArtFilterMonotonecolorKey: CameraPropertyMonotonecolorRoughMonochrome,
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeRoughMonochrome,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridRoughMonochrome,
	};
	NSDictionary *filterToyPhoto = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeToyPhoto,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridToyPhoto,
	};
	NSDictionary *filterMiniature = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeMiniature,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridMiniature,
	};
	NSDictionary *filterCrossProcess = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeCrossProcess,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridCrossProcess,
	};
	NSDictionary *filterGentleSepia = @{
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridGentleSepia,
	};
	NSDictionary *filterDramaticTone = @{
		ArtFilterMonotonefilterKey: CameraPropertyMonotonefilterDramaticTone,
		ArtFilterMonotonecolorKey: CameraPropertyMonotonecolorDramaticTone,
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeDramaticTone,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridDramaticTone,
	};
	NSDictionary *filterLigneClair = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeLigneClair,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridLightTone,
	};
	NSDictionary *filterPastel = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypePastel,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridPastel,
	};
	NSDictionary *filterVintage = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypeVintage,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridVintage,
	};
	NSDictionary *filterPartcolor = @{
		ArtFilterArtEffectTypeKey: CameraPropertyArtEffectTypePartcolor,
		ArtFilterArtEffectHybridKey: CameraPropertyArtEffectHybridPartcolor,
	};
	[artFilterMap setObject:filterFlat forKey:CameraPropertyColortoneFlat];
	[artFilterMap setObject:filterNatural forKey:CameraPropertyColortoneNatural];
	[artFilterMap setObject:filterMonotone forKey:CameraPropertyColortoneMonotone];
	[artFilterMap setObject:filterPortrait forKey:CameraPropertyColortonePortrait];
	[artFilterMap setObject:filterIFinish forKey:CameraPropertyColortoneIFinish];
	[artFilterMap setObject:filterVivid forKey:CameraPropertyColortoneVivid];
	[artFilterMap setObject:filterEportrait forKey:CameraPropertyColortoneEportrait];
	[artFilterMap setObject:filterColorCreator forKey:CameraPropertyColortoneColorCreator];
	[artFilterMap setObject:filterPopart forKey:CameraPropertyColortonePopart];
	[artFilterMap setObject:filterFantasicFocus forKey:CameraPropertyColortoneFantasicFocus];
	[artFilterMap setObject:filterDaydream forKey:CameraPropertyColortoneDaydream];
	[artFilterMap setObject:filterLightTone forKey:CameraPropertyColortoneLightTone];
	[artFilterMap setObject:filterRoughMonochrome forKey:CameraPropertyColortoneRoughMonochrome];
	[artFilterMap setObject:filterToyPhoto forKey:CameraPropertyColortoneToyPhoto];
	[artFilterMap setObject:filterMiniature forKey:CameraPropertyColortoneMiniature];
	[artFilterMap setObject:filterCrossProcess forKey:CameraPropertyColortoneCrossProcess];
	[artFilterMap setObject:filterGentleSepia forKey:CameraPropertyColortoneGentleSepia];
	[artFilterMap setObject:filterDramaticTone forKey:CameraPropertyColortoneDramaticTone];
	[artFilterMap setObject:filterLigneClair forKey:CameraPropertyColortoneLigneClair];
	[artFilterMap setObject:filterPastel forKey:CameraPropertyColortonePastel];
	[artFilterMap setObject:filterVintage forKey:CameraPropertyColortoneVintage];
	[artFilterMap setObject:filterPartcolor forKey:CameraPropertyColortonePartcolor];
	[artFilterMap setObject:filterPopart forKey:CameraPropertyRecentlyArtFilterPopart];
	[artFilterMap setObject:filterFantasicFocus forKey:CameraPropertyRecentlyArtFilterFantasicFocus];
	[artFilterMap setObject:filterDaydream forKey:CameraPropertyRecentlyArtFilterDaydream];
	[artFilterMap setObject:filterLightTone forKey:CameraPropertyRecentlyArtFilterLightTone];
	[artFilterMap setObject:filterRoughMonochrome forKey:CameraPropertyRecentlyArtFilterRoughMonochrome];
	[artFilterMap setObject:filterToyPhoto forKey:CameraPropertyRecentlyArtFilterToyPhoto];
	[artFilterMap setObject:filterMiniature forKey:CameraPropertyRecentlyArtFilterMiniature];
	[artFilterMap setObject:filterCrossProcess forKey:CameraPropertyRecentlyArtFilterCrossProcess];
	[artFilterMap setObject:filterGentleSepia forKey:CameraPropertyRecentlyArtFilterGentleSepia];
	[artFilterMap setObject:filterDramaticTone forKey:CameraPropertyRecentlyArtFilterDramaticTone];
	[artFilterMap setObject:filterLigneClair forKey:CameraPropertyRecentlyArtFilterLigneClair];
	[artFilterMap setObject:filterPastel forKey:CameraPropertyRecentlyArtFilterPastel];
	[artFilterMap setObject:filterVintage forKey:CameraPropertyRecentlyArtFilterVintage];
	[artFilterMap setObject:filterPartcolor forKey:CameraPropertyRecentlyArtFilterPartcolor];
	self.artFilterMap = artFilterMap;
	
	// 現在選択されているアートフィルターを初期化します。
	self.currentArtFilter = nil;
	
	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWb)) forKey:CameraPropertyWb];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeCustomWbKelvin1)) forKey:CameraPropertyCustomWbKelvin1];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRev3000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRev4000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRev5300k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRev6000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRev7500k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRevAuto];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRev)) forKey:CameraPropertyWbRevAutoUnderWater];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevG3000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevG4000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevG5300k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevG6000k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevG7500k];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevGAuto];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWbRevG)) forKey:CameraPropertyWbRevGAutoUnderWater];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColortone)) forKey:CameraPropertyColortone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeRecentlyArtFilter)) forKey:CameraPropertyRecentlyArtFilter];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastFlat];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastNatural];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastSoft];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastIFinish];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeContrast)) forKey:CameraPropertyContrastVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpFlat];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpNatural];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpSoft];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpIFinish];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSharp)) forKey:CameraPropertySharpVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSaturationLevel)) forKey:CameraPropertySaturationLevelFlat];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSaturationLevel)) forKey:CameraPropertySaturationLevelNatural];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSaturationLevel)) forKey:CameraPropertySaturationLevelSoft];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSaturationLevel)) forKey:CameraPropertySaturationLevelIFinish];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeSaturationLevel)) forKey:CameraPropertySaturationLevelVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneFlat];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneNatural];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneSoft];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneIFinish];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeTone)) forKey:CameraPropertyToneVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeEffectLevel)) forKey:CameraPropertyEffectLevelIFinish];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeToneControlLow)) forKey:CameraPropertyToneControlLow];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeToneControlMiddle)) forKey:CameraPropertyToneControlMiddle];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeToneControlHigh)) forKey:CameraPropertyToneControlHigh];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonefilter)) forKey:CameraPropertyMonotonefilterMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonefilter)) forKey:CameraPropertyMonotonefilterRoughMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonefilter)) forKey:CameraPropertyMonotonefilterDramaticTone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonecolor)) forKey:CameraPropertyMonotonecolorMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonecolor)) forKey:CameraPropertyMonotonecolorRoughMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeMonotonecolor)) forKey:CameraPropertyMonotonecolorDramaticTone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorCreatorColor)) forKey:CameraPropertyColorCreatorColor];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorCreatorVivid)) forKey:CameraPropertyColorCreatorVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorPhase)) forKey:CameraPropertyColorPhase];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypePopart];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeDaydream];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeRoughMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeToyPhoto];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeMiniature];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeCrossProcess];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeDramaticTone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeLigneClair];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypePastel];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypeVintage];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectType)) forKey:CameraPropertyArtEffectTypePastel];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridPopart];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridFantasicFocus];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridDaydream];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridLightTone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridRoughMonochrome];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridToyPhoto];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridMiniature];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridCrossProcess];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridGentleSepia];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridDramaticTone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridLigneClair];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridPastel];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridVintage];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeArtEffectHybrid)) forKey:CameraPropertyArtEffectHybridPartcolor];
	
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	
	// 画面表示を初期表示します。
	NSString *wbTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyWb];
	NSString *customWbKelvin1Title = [camera cameraPropertyLocalizedTitle:CameraPropertyCustomWbKelvin1];
	self.showWbRevCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyWbRev];
	self.showWbRevGCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyWbRevG];
	NSString *AutoWbDenkyuColoredLeavingTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAutoWbDenkyuColoredLeaving];
	NSString *colortoneTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColortone];
	NSString *recentlyArtFilterTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyRecentlyArtFilter];
	self.showContrastCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyContrast];
	self.showSharpCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertySharp];
	self.showSaturationLevelCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertySaturationLevel];
	self.showToneCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyTone];
	self.showEffectLevelCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyEffectLevel];
	NSString *toneControlLowCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyToneControlLow];
	NSString *toneControlMiddleCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyToneControlMiddle];
	NSString *toneControlHightCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyToneControlHigh];
	self.showMonotonefilterCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyMonotonefilter];
	self.showMonotonecolorCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyMonotonecolor];
	NSString *colorCreatorColorTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorCreatorColor];
	NSString *colorCreatorVividTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorCreatorVivid];
	NSString *colorPhaseTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorPhase];
	self.showArtEffectTypeCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyArtEffectType];
	self.showArtEffectHybridCellTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyArtEffectHybrid];
	self.showWbCell.textLabel.text = wbTitle;
	self.showCustomWbKelvin1Cell.textLabel.text = customWbKelvin1Title;
	self.showWbRevCell.textLabel.text = self.showWbRevCellTitle;
	self.showWbRevGCell.textLabel.text = self.showWbRevGCellTitle;
	self.showAutoWbDenkyuColoredLeavingCell.textLabel.text = AutoWbDenkyuColoredLeavingTitle;
	self.showColortoneCell.textLabel.text = colortoneTitle;
	self.showRecentlyArtFilterCell.textLabel.text = recentlyArtFilterTitle;
	self.showContrastCell.textLabel.text = self.showContrastCellTitle;
	self.showSharpCell.textLabel.text = self.showSharpCellTitle;
	self.showSaturationLevelCell.textLabel.text = self.showSaturationLevelCellTitle;
	self.showToneCell.textLabel.text = self.showToneCellTitle;
	self.showEffectLevelCell.textLabel.text = self.showEffectLevelCellTitle;
	self.showToneControlLowCell.textLabel.text = toneControlLowCellTitle;
	self.showToneControlMiddleCell.textLabel.text = toneControlMiddleCellTitle;
	self.showToneControlHighCell.textLabel.text = toneControlHightCellTitle;
	self.showMonotonefilterCell.textLabel.text = self.showMonotonefilterCellTitle;
	self.showMonotonecolorCell.textLabel.text = self.showMonotonecolorCellTitle;
	self.showColorCreatorColorCell.textLabel.text = colorCreatorColorTitle;
	self.showColorCreatorVividCell.textLabel.text = colorCreatorVividTitle;
	self.showColorPhaseCell.textLabel.text = colorPhaseTitle;
	self.showArtEffectTypeCell.textLabel.text = self.showArtEffectTypeCellTitle;
	self.showArtEffectHybridCell.textLabel.text = self.showArtEffectHybridCellTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.showWbCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showCustomWbKelvin1Cell.detailTextLabel.text = emptyDetailTextLabel;
	self.showWbRevCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showWbRevGCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showAutoWbDenkyuColoredLeavingCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColortoneCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showRecentlyArtFilterCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showArtFilterAutoBracketCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showContrastCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showSharpCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showSaturationLevelCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showToneCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showEffectLevelCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showToneControlLowCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showToneControlMiddleCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showToneControlHighCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showMonotonefilterCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showMonotonecolorCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorCreatorColorCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorCreatorVividCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorPhaseCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showArtEffectTypeCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showArtEffectHybridCell.detailTextLabel.text = emptyDetailTextLabel;
	[self tableViewCell:self.showWbCell enabled:NO];
	[self tableViewCell:self.showCustomWbKelvin1Cell enabled:NO];
	[self tableViewCell:self.showWbRevCell enabled:NO];
	[self tableViewCell:self.showWbRevGCell enabled:NO];
	[self tableViewCell:self.showAutoWbDenkyuColoredLeavingCell enabled:NO];
	[self tableViewCell:self.showColortoneCell enabled:NO];
	[self tableViewCell:self.showRecentlyArtFilterCell enabled:NO];
	[self tableViewCell:self.showArtFilterAutoBracketCell enabled:NO];
	[self tableViewCell:self.showContrastCell enabled:NO];
	[self tableViewCell:self.showSharpCell enabled:NO];
	[self tableViewCell:self.showSaturationLevelCell enabled:NO];
	[self tableViewCell:self.showToneCell enabled:NO];
	[self tableViewCell:self.showEffectLevelCell enabled:NO];
	[self tableViewCell:self.showToneControlLowCell enabled:NO];
	[self tableViewCell:self.showToneControlMiddleCell enabled:NO];
	[self tableViewCell:self.showToneControlHighCell enabled:NO];
	[self tableViewCell:self.showMonotonefilterCell enabled:NO];
	[self tableViewCell:self.showMonotonecolorCell enabled:NO];
	[self tableViewCell:self.showColorCreatorColorCell enabled:NO];
	[self tableViewCell:self.showColorCreatorVividCell enabled:NO];
	[self tableViewCell:self.showColorPhaseCell enabled:NO];
	[self tableViewCell:self.showArtEffectTypeCell enabled:NO];
	[self tableViewCell:self.showArtEffectHybridCell enabled:NO];
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
	_whiteBalanceMap = nil;
	_currentWhiteBalance = nil;
	_showWbRevCellTitle = nil;
	_showWbRevGCellTitle = nil;
	_artFilterMap = nil;
	_currentArtFilter = nil;
	_showContrastCellTitle = nil;
	_showSharpCellTitle = nil;
	_showSaturationLevelCellTitle = nil;
	_showToneCellTitle = nil;
	_showEffectLevelCellTitle = nil;
	_showMonotonefilterCellTitle = nil;
	_showMonotonecolorCellTitle = nil;
	_showArtEffectTypeCellTitle = nil;
	_showArtEffectHybridCellTitle = nil;
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
	[self updateShowWbCell];
	// updateShowWbRevCellはupdateShowWbCellから呼ばれます。
	// updateShowWbRevGCellはupdateShowWbCellから呼ばれます。
	[self updateShowCustomWbKelvin1Cell];
	[self updateShowAutoWbDenkyuColoredLeavingCell];
	[self updateShowColortoneCellAndShowRecentlyArtFilterCell];
	[self updateShowArtFilterAutoBracketCell];
	// updateShowContrastCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowSharpCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowSaturationLevelCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowToneCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowEffectLevelCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowMonotonefilterCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowMonotonecolorCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	[self updateShowToneControlLowCell];
	[self updateShowToneControlMiddleCell];
	[self updateShowToneControlHighCell];
	[self updateShowColorCreatorColorCell];
	[self updateShowColorCreatorVividCell];
	[self updateShowColorPhaseCell];
	// updateShowArtEffectTypeCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	// updateShowArtEffectHybridCellは、updateShowColortoneCellもしくはupdateShowRecentlyArtFilterCellから呼ばれます。
	
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
	[self tableViewCell:self.showWbCell enabled:NO];
	[self tableViewCell:self.showCustomWbKelvin1Cell enabled:NO];
	[self tableViewCell:self.showWbRevCell enabled:NO];
	[self tableViewCell:self.showWbRevGCell enabled:NO];
	[self tableViewCell:self.showAutoWbDenkyuColoredLeavingCell enabled:NO];
	[self tableViewCell:self.showColortoneCell enabled:NO];
	[self tableViewCell:self.showRecentlyArtFilterCell enabled:NO];
	[self tableViewCell:self.showArtFilterAutoBracketCell enabled:NO];
	[self tableViewCell:self.showContrastCell enabled:NO];
	[self tableViewCell:self.showSharpCell enabled:NO];
	[self tableViewCell:self.showSaturationLevelCell enabled:NO];
	[self tableViewCell:self.showToneCell enabled:NO];
	[self tableViewCell:self.showEffectLevelCell enabled:NO];
	[self tableViewCell:self.showToneControlLowCell enabled:NO];
	[self tableViewCell:self.showToneControlMiddleCell enabled:NO];
	[self tableViewCell:self.showToneControlHighCell enabled:NO];
	[self tableViewCell:self.showMonotonefilterCell enabled:NO];
	[self tableViewCell:self.showMonotonecolorCell enabled:NO];
	[self tableViewCell:self.showColorCreatorColorCell enabled:NO];
	[self tableViewCell:self.showColorCreatorVividCell enabled:NO];
	[self tableViewCell:self.showColorPhaseCell enabled:NO];
	[self tableViewCell:self.showArtEffectTypeCell enabled:NO];
	[self tableViewCell:self.showArtEffectHybridCell enabled:NO];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowWb"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyWb;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowCustomWbKelvin1"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyCustomWbKelvin1;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowWbRev"]) {
		if (!self.currentWhiteBalance) {
			DEBUG_LOG(@"Program Error !");
			return;
		}
		// 現在のホワイトバランスに対応するホワイトバランス補正値(A)の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *whiteBalance = self.whiteBalanceMap[self.currentWhiteBalance];
		viewController.property = whiteBalance[WhiteBalanceMapWbRevKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowWbRevG"]) {
		if (!self.currentWhiteBalance) {
			DEBUG_LOG(@"Program Error !");
			return;
		}
		// 現在のホワイトバランスに対応するホワイトバランス補正値(G)の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *whiteBalance = self.whiteBalanceMap[self.currentWhiteBalance];
		viewController.property = whiteBalance[WhiteBalanceMapWbRevGKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowAutoWbDenkyuColoredLeaving"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyAutoWbDenkyuColoredLeaving;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColortone"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColortone;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowRecentlyArtFilter"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyRecentlyArtFilter;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowArtFilterAutoBracket"]) {
		// 専用のビューコントローラで処理されるのでここで行う初期化はありません。
	} else if ([segueIdentifier isEqualToString:@"ShowContrast"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応するコントラストの選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterContrastKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowSharp"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応するシャープの選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterSharpKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowSaturationLevel"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応する彩度の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterSaturationLevelKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowTone"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応する階調の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterToneKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowEffectLevel"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応する効果強弱の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterEffectLevelKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowToneControlLow"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyToneControlLow;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowToneControlMiddle"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyToneControlMiddle;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowToneControlHigh"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyToneControlHigh;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowMonotonefilter"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応するモノクロフィルター効果の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterMonotonefilterKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowMonotonecolor"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応する調色効果の選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterMonotonecolorKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorCreatorColor"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorCreatorColor;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorCreatorVivid"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorCreatorVivid;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorPhase"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorPhase;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowArtEffectType"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応するアートフィルターバリエーションの選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterArtEffectTypeKey];
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowArtEffectHybrid"]) {
		if (!self.currentArtFilter) {
			DEBUG_LOG(@"Program Error !");
		}
		// 現在のアートフィルターに対応するアートエフェクトの選択肢を表示します。
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
		viewController.property = artFilter[ArtFilterArtEffectHybridKey];
		viewController.itemSelectionDeleage = self;
	} else {
		// 何もしません。
	}
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	// カメラプロパティに応じた処理を呼び出します。
	NSString *property = ((CameraPropertyValueSelectionViewController *)controller).property;
	if ([property isEqualToString:CameraPropertyWb]) {
		[self didChangeWb];
	} else if ([property isEqualToString:CameraPropertyCustomWbKelvin1]) {
		[self didChangeCustomWbKelvin1];
	} else if ([property isEqualToString:CameraPropertyWbRevG3000k] ||
			   [property isEqualToString:CameraPropertyWbRevG4000k] ||
			   [property isEqualToString:CameraPropertyWbRevG5300k] ||
			   [property isEqualToString:CameraPropertyWbRevG6000k] ||
			   [property isEqualToString:CameraPropertyWbRevG7500k] ||
			   [property isEqualToString:CameraPropertyWbRevGAuto] ||
			   [property isEqualToString:CameraPropertyWbRevGAutoUnderWater]) {
		[self didChangeWbRev];
	} else if ([property isEqualToString:CameraPropertyWbRev3000k] ||
			   [property isEqualToString:CameraPropertyWbRev4000k] ||
			   [property isEqualToString:CameraPropertyWbRev5300k] ||
			   [property isEqualToString:CameraPropertyWbRev6000k] ||
			   [property isEqualToString:CameraPropertyWbRev7500k] ||
			   [property isEqualToString:CameraPropertyWbRevAuto] ||
			   [property isEqualToString:CameraPropertyWbRevAutoUnderWater]) {
		[self didChangeWbRevG];
	} else if ([property isEqualToString:CameraPropertyAutoWbDenkyuColoredLeaving]) {
		[self didChangeAutoWbDenkyuColoredLeaving];
	} else if ([property isEqualToString:CameraPropertyColortone]) {
		[self didChangeColortone];
	} else if ([property isEqualToString:CameraPropertyRecentlyArtFilter]) {
		[self didChangeRecentlyArtFilter];
	} else if ([property isEqualToString:CameraPropertyContrastFlat] ||
			   [property isEqualToString:CameraPropertyContrastNatural] ||
			   [property isEqualToString:CameraPropertyContrastMonochrome] ||
			   [property isEqualToString:CameraPropertyContrastSoft] ||
			   [property isEqualToString:CameraPropertyContrastIFinish] ||
			   [property isEqualToString:CameraPropertyContrastVivid]) {
		[self didChangeContrast];
	} else if ([property isEqualToString:CameraPropertySharpFlat] ||
			   [property isEqualToString:CameraPropertySharpNatural] ||
			   [property isEqualToString:CameraPropertySharpMonochrome] ||
			   [property isEqualToString:CameraPropertySharpSoft] ||
			   [property isEqualToString:CameraPropertySharpIFinish] ||
			   [property isEqualToString:CameraPropertySharpVivid]) {
		[self didChangeSharp];
	} else if ([property isEqualToString:CameraPropertySaturationLevelFlat] ||
			   [property isEqualToString:CameraPropertySaturationLevelNatural] ||
			   [property isEqualToString:CameraPropertySaturationLevelSoft] ||
			   [property isEqualToString:CameraPropertySaturationLevelIFinish] ||
			   [property isEqualToString:CameraPropertySaturationLevelVivid]) {
		[self didChangeSaturationLevel];
	} else if ([property isEqualToString:CameraPropertyToneFlat] ||
			   [property isEqualToString:CameraPropertyToneNatural] ||
			   [property isEqualToString:CameraPropertyToneMonochrome] ||
			   [property isEqualToString:CameraPropertyToneSoft] ||
			   [property isEqualToString:CameraPropertyToneIFinish] ||
			   [property isEqualToString:CameraPropertyToneVivid]) {
		[self didChangeTone];
	} else if ([property isEqualToString:CameraPropertyEffectLevelIFinish]) {
		[self didChangeEffectLevel];
	} else if ([property isEqualToString:CameraPropertyToneControlLow]) {
		[self didChangeToneControlLow];
	} else if ([property isEqualToString:CameraPropertyToneControlMiddle]) {
		[self didChangeToneControlMiddle];
	} else if ([property isEqualToString:CameraPropertyToneControlHigh]) {
		[self didChangeToneControlHigh];
	} else if ([property isEqualToString:CameraPropertyMonotonefilterMonochrome] ||
			   [property isEqualToString:CameraPropertyMonotonefilterRoughMonochrome] ||
			   [property isEqualToString:CameraPropertyMonotonefilterDramaticTone]) {
		[self didChangeMonotonefilter];
	} else if ([property isEqualToString:CameraPropertyMonotonecolorMonochrome] ||
			   [property isEqualToString:CameraPropertyMonotonecolorRoughMonochrome] ||
			   [property isEqualToString:CameraPropertyMonotonecolorDramaticTone]) {
		[self didChangeMonotonecolor];
	} else if ([property isEqualToString:CameraPropertyColorCreatorColor]) {
		[self didChangeColorCreatorColor];
	} else if ([property isEqualToString:CameraPropertyColorCreatorVivid]) {
		[self didChangeColorCreatorVivid];
	} else if ([property isEqualToString:CameraPropertyColorPhase]) {
		[self didChangeColorPhase];
	} else if ([property isEqualToString:CameraPropertyArtEffectTypePopart] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeDaydream] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeRoughMonochrome] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeToyPhoto] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeMiniature] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeCrossProcess] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeDramaticTone] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeLigneClair] ||
			   [property isEqualToString:CameraPropertyArtEffectTypePastel] ||
			   [property isEqualToString:CameraPropertyArtEffectTypeVintage] ||
			   [property isEqualToString:CameraPropertyArtEffectTypePartcolor]) {
		[self didChangeArtEffectType];
	} else if ([property isEqualToString:CameraPropertyArtEffectHybridPopart] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridFantasicFocus] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridDaydream] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridLightTone] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridRoughMonochrome] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridToyPhoto] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridMiniature] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridCrossProcess] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridGentleSepia] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridDramaticTone] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridLigneClair] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridPastel] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridVintage] ||
			   [property isEqualToString:CameraPropertyArtEffectHybridPartcolor]) {
		[self didChangeArtEffectHybrid];
	} else {
		DEBUG_LOG(@"Unknown property: %@", property);
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
		__weak CPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

#pragma mark -

/// ホワイトバランスの値が変わった時に呼び出されます。
- (void)didChangeWb {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowWbCell];
}

/// カスタムWBの値が変わった時に呼び出されます。
- (void)didChangeCustomWbKelvin1 {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowCustomWbKelvin1Cell];
}

/// WB補正Aの値が変わった時に呼び出されます。
- (void)didChangeWbRev {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowWbRevCell];
}

/// WB補正Gの値が変わった時に呼び出されます。
- (void)didChangeWbRevG {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowWbRevGCell];
}

/// WBオート電球色残しの値が変わった時に呼び出されます。
- (void)didChangeAutoWbDenkyuColoredLeaving {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowAutoWbDenkyuColoredLeavingCell];
}

/// 仕上がりピクチャーモードの値が変わった時に呼び出されます。
- (void)didChangeColortone {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	// MARK: アートフィルター種別と仕上がりピクチャーモードの値が同時に変わった時は処理効率が悪くなります。
	[self updateShowColortoneCellAndShowRecentlyArtFilterCell];
}

/// アートフィルター種別の値が変わった時に呼び出されます。
- (void)didChangeRecentlyArtFilter {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	// MARK: アートフィルター種別と仕上がりピクチャーモードの値が同時に変わった時は処理効率が悪くなります。
	[self updateShowColortoneCellAndShowRecentlyArtFilterCell];
}

/// コントラストの値が変わった時に呼び出されます。
- (void)didChangeContrast {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowContrastCell];
}

/// シャープネスの値が変わった時に呼び出されます。
- (void)didChangeSharp {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowSharpCell];
}

/// 彩度の値が変わった時に呼び出されます。
- (void)didChangeSaturationLevel {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowSaturationLevelCell];
}

/// 階調の値が変わった時に呼び出されます。
- (void)didChangeTone {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowToneCell];
}

/// 効果強弱の値が変わった時に呼び出されます。
- (void)didChangeEffectLevel {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowEffectLevelCell];
}

/// トーンコントロール(シャドー部)の値が変わった時に呼び出されます。
- (void)didChangeToneControlLow {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowToneControlLowCell];
}

/// トーンコントロール(中間部)の値が変わった時に呼び出されます。
- (void)didChangeToneControlMiddle {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowToneControlMiddleCell];
}

/// トーンコントロール(ハイライト部)の値が変わった時に呼び出されます。
- (void)didChangeToneControlHigh {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowToneControlHighCell];
}

/// モノクロフィルター効果の値が変わった時に呼び出されます。
- (void)didChangeMonotonefilter {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowMonotonefilterCell];
}

/// 調色効果の値が変わった時に呼び出されます。
- (void)didChangeMonotonecolor {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowMonotonecolorCell];
}

/// カラークリエーター用色相の値が変わった時に呼び出されます。
- (void)didChangeColorCreatorColor {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorCreatorColorCell];
}

/// カラークリエーター用彩度の値が変わった時に呼び出されます。
- (void)didChangeColorCreatorVivid {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorCreatorVividCell];
}

/// パートカラー用色相の値が変わった時に呼び出されます。
- (void)didChangeColorPhase {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorPhaseCell];
}

/// アートフィルターバリエーションの値が変わった時に呼び出されます。
- (void)didChangeArtEffectType {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowArtEffectTypeCell];
}

/// アートエフェクトの値が変わった時に呼び出されます。
- (void)didChangeArtEffectHybrid {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowArtEffectHybridCell];
}

#pragma mark -

/// ホワイトバランスを表示します。
- (void)updateShowWbCell {
	DEBUG_LOG(@"");
	
	__weak CPanelViewController *weakSelf = self;
	[self updateCameraPropertyCell:self.showWbCell name:CameraPropertyWb completion:^(NSString *value) {
		// ホワイトバランスを表示する場合はホワイトバランス補正値も表示します。
		weakSelf.currentWhiteBalance = value;
		[weakSelf updateShowWbRevCell];
		[weakSelf updateShowWbRevGCell];
	}];
}

/// カスタムWBを表示します。
- (void)updateShowCustomWbKelvin1Cell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showCustomWbKelvin1Cell name:CameraPropertyCustomWbKelvin1 completion:nil];
}

/// WB補正Aを表示します。
- (void)updateShowWbRevCell {
	DEBUG_LOG(@"");
	
	// 現在のホワイトバランスからホワイトバランス補正値(A)のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentWhiteBalance) {
		self.showWbRevCell.textLabel.text = self.showWbRevCellTitle;
		self.showWbRevCell.detailTextLabel.text = NSLocalizedString(@"$cell:WbRevUnknown", @"CPanelViewController.updateShowWbRevCell");
		[self tableViewCell:self.showWbRevCell enabled:NO];
		return;
	}
	NSDictionary *whiteBalance = self.whiteBalanceMap[self.currentWhiteBalance];
	NSString *property = whiteBalance[WhiteBalanceMapWbRevKey];
	if (!property) {
		self.showWbRevCell.textLabel.text = self.showWbRevCellTitle;
		self.showWbRevCell.detailTextLabel.text = NSLocalizedString(@"$cell:WbRevNotAvailable", @"CPanelViewController.updateShowWbRevCell");
		[self tableViewCell:self.showWbRevCell enabled:NO];
		return;
	}
	
	// ホワイトバランスに対応するホワイトバランス補正値(A)の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showWbRevCell.textLabel.text = propertyTitle;
	
	// ホワイトバランスに対応するホワイトバランス補正値(A)を表示します。
	[self updateCameraPropertyCell:self.showWbRevCell name:property completion:nil];
}

/// WB補正Gを表示します。
- (void)updateShowWbRevGCell {
	DEBUG_LOG(@"");
	
	// 現在のホワイトバランスからホワイトバランス補正値(G)のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentWhiteBalance) {
		self.showWbRevGCell.textLabel.text = self.showWbRevGCellTitle;
		self.showWbRevGCell.detailTextLabel.text = NSLocalizedString(@"$cell:WbRevGUnknown", @"CPanelViewController.updateShowWbRevGCell");
		[self tableViewCell:self.showWbRevGCell enabled:NO];
		return;
	}
	NSDictionary *whiteBalance = self.whiteBalanceMap[self.currentWhiteBalance];
	NSString *property = whiteBalance[WhiteBalanceMapWbRevGKey];
	if (!property) {
		self.showWbRevGCell.textLabel.text = self.showWbRevGCellTitle;
		self.showWbRevGCell.detailTextLabel.text = NSLocalizedString(@"$cell:WbRevGNotAvailable", @"CPanelViewController.updateShowWbRevGCell");
		[self tableViewCell:self.showWbRevGCell enabled:NO];
		return;
	}
	
	// ホワイトバランスに対応するホワイトバランス補正値(G)の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showWbRevGCell.textLabel.text = propertyTitle;

	// ホワイトバランスに対応するホワイトバランス補正値(G)を表示します。
	[self updateCameraPropertyCell:self.showWbRevGCell name:property completion:nil];
}

/// WBオート電球色残しを表示します。
- (void)updateShowAutoWbDenkyuColoredLeavingCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showAutoWbDenkyuColoredLeavingCell name:CameraPropertyAutoWbDenkyuColoredLeaving completion:nil];
}

/// 仕上がりピクチャーモードとアートフィルター種別を表示します。
- (void)updateShowColortoneCellAndShowRecentlyArtFilterCell {
	DEBUG_LOG(@"");

	__weak CPanelViewController *weakSelf = self;
	__block NSString *colortoneValue = nil;
	__block NSString *recentlyArtFilterValue = nil;
	[self updateCameraPropertyCell:weakSelf.showColortoneCell name:CameraPropertyColortone completion:^(NSString *value) {
		colortoneValue = value;
		[self updateCameraPropertyCell:weakSelf.showRecentlyArtFilterCell name:CameraPropertyRecentlyArtFilter completion:^(NSString *value) {
			recentlyArtFilterValue = value;
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				AppCamera *camera = GetAppCamera();
				// アートフィルター種別と仕上がりピクチャーモードのどちらの設定モードが有効かを判定します。
				// 有効な方を現在選択しているアートフィルターとします。
				if (![camera canSetCameraProperty:CameraPropertyColortone] &&
					![camera canSetCameraProperty:CameraPropertyRecentlyArtFilter]) {
					weakSelf.currentArtFilter = nil;
				} else if ([camera canSetCameraProperty:CameraPropertyColortone]) {
					weakSelf.currentArtFilter = colortoneValue;
				} else if ([camera canSetCameraProperty:CameraPropertyRecentlyArtFilter]) {
					weakSelf.currentArtFilter = recentlyArtFilterValue;
				} else {
					DEBUG_LOG(@"Program Error !");
					weakSelf.currentArtFilter = nil;
				}
				// アートフィルター種別と仕上がりピクチャーモードに影響を受けるフィルターパラメータを表示します。
				[weakSelf updateShowContrastCell];
				[weakSelf updateShowSharpCell];
				[weakSelf updateShowSaturationLevelCell];
				[weakSelf updateShowToneCell];
				[weakSelf updateShowEffectLevelCell];
				[weakSelf updateShowMonotonefilterCell];
				[weakSelf updateShowMonotonecolorCell];
				[weakSelf updateShowArtEffectTypeCell];
				[weakSelf updateShowArtEffectHybridCell];
			}];
		}];
	}];
}

/// アートフィルター自動ブラケットを表示します。
- (void)updateShowArtFilterAutoBracketCell {
	DEBUG_LOG(@"");
	
	// TAKEMODEプロパティをARTに設定し、RECENTLY_ART_FILTERプロパティがART_BKTに設定されているときに有効です。
	// 設定可不可の条件が複雑なので(処理コストが高いので)、代理としてアートフィルターブラケットのポップアートを参照します。
	AppCamera *camera = GetAppCamera();
	[self tableViewCell:self.showArtFilterAutoBracketCell enabled:[camera canSetCameraProperty:CameraPropertyArtFilterAutoBracket]];
}

/// コントラストを表示します。
- (void)updateShowContrastCell {
	DEBUG_LOG(@"");
	
	// 現在のアートフィルターからコントラストのプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showContrastCell.textLabel.text = self.showContrastCellTitle;
		self.showContrastCell.detailTextLabel.text = NSLocalizedString(@"$cell:ContrastUnknown", @"CPanelViewController.updateShowContrastCell");
		[self tableViewCell:self.showContrastCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterContrastKey];
	if (!property) {
		self.showContrastCell.textLabel.text = self.showContrastCellTitle;
		self.showContrastCell.detailTextLabel.text = NSLocalizedString(@"$cell:ContrastNotAvailable", @"CPanelViewController.updateShowContrastCell");
		[self tableViewCell:self.showContrastCell enabled:NO];
		return;
	}

	// アートフィルターに対応するコントラストの名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showContrastCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応するコントラストを表示します。
	[self updateCameraPropertyCell:self.showContrastCell name:property completion:nil];
}

/// シャープネスを表示します。
- (void)updateShowSharpCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターからシャープネスのプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showSharpCell.textLabel.text = self.showSharpCellTitle;
		self.showSharpCell.detailTextLabel.text = NSLocalizedString(@"$cell:SharpUnknown", @"CPanelViewController.updateShowSharpCell");
		[self tableViewCell:self.showSharpCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterSharpKey];
	if (!property) {
		self.showSharpCell.textLabel.text = self.showSharpCellTitle;
		self.showSharpCell.detailTextLabel.text = NSLocalizedString(@"$cell:SharpNotAvailable", @"CPanelViewController.updateShowSharpCell");
		[self tableViewCell:self.showSharpCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応するシャープネスの名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showSharpCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応するシャープネスを表示します。
	[self updateCameraPropertyCell:self.showSharpCell name:property completion:nil];
}

/// 彩度を表示します。
- (void)updateShowSaturationLevelCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターから彩度のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showSaturationLevelCell.textLabel.text = self.showSaturationLevelCellTitle;
		self.showSaturationLevelCell.detailTextLabel.text = NSLocalizedString(@"$cell:SaturationUnknown", @"CPanelViewController.updateShowSaturationLevelCell");
		[self tableViewCell:self.showSaturationLevelCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterSaturationLevelKey];
	if (!property) {
		self.showSaturationLevelCell.textLabel.text = self.showSaturationLevelCellTitle;
		self.showSaturationLevelCell.detailTextLabel.text = NSLocalizedString(@"$cell:SaturationNotAvailable", @"CPanelViewController.updateShowSaturationLevelCell");
		[self tableViewCell:self.showSaturationLevelCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応する彩度の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showSaturationLevelCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応する彩度を表示します。
	[self updateCameraPropertyCell:self.showSaturationLevelCell name:property completion:nil];
}

/// 階調を表示します。
- (void)updateShowToneCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターから階調のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showToneCell.textLabel.text = self.showToneCellTitle;
		self.showToneCell.detailTextLabel.text = NSLocalizedString(@"$cell:ToneUnknown", @"CPanelViewController.updateShowToneCell");
		[self tableViewCell:self.showToneCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterToneKey];
	if (!property) {
		self.showToneCell.textLabel.text = self.showToneCellTitle;
		self.showToneCell.detailTextLabel.text = NSLocalizedString(@"$cell:ToneNotAvailable", @"CPanelViewController.updateShowToneCell");
		[self tableViewCell:self.showToneCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応する階調の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showToneCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応する階調を表示します。
	[self updateCameraPropertyCell:self.showToneCell name:property completion:nil];
}

/// 効果強弱を表示します。
- (void)updateShowEffectLevelCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターから効果強弱のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showEffectLevelCell.textLabel.text = self.showEffectLevelCellTitle;
		self.showEffectLevelCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectUnknown", @"CPanelViewController.updateShowEffectLevelCell");
		[self tableViewCell:self.showEffectLevelCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterEffectLevelKey];
	if (!property) {
		self.showEffectLevelCell.textLabel.text = self.showEffectLevelCellTitle;
		self.showEffectLevelCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectNotAvailable", @"CPanelViewController.updateShowEffectLevelCell");
		[self tableViewCell:self.showEffectLevelCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応する効果強弱の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showEffectLevelCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応する効果強弱を表示します。
	[self updateCameraPropertyCell:self.showEffectLevelCell name:property completion:nil];
}

/// トーンコントロール(シャドー部)を表示します。
- (void)updateShowToneControlLowCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showToneControlLowCell name:CameraPropertyToneControlLow completion:nil];
}

/// トーンコントロール(中間部)を表示します。
- (void)updateShowToneControlMiddleCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showToneControlMiddleCell name:CameraPropertyToneControlMiddle completion:nil];
}

/// トーンコントロール(ハイライト部)を表示します。
- (void)updateShowToneControlHighCell {
	DEBUG_LOG(@"");

	[self updateCameraPropertyCell:self.showToneControlHighCell name:CameraPropertyToneControlHigh completion:nil];
}

/// モノクロフィルター効果を表示します。
- (void)updateShowMonotonefilterCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターからモノクロフィルター効果のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showMonotonefilterCell.textLabel.text = self.showMonotonefilterCellTitle;
		self.showMonotonefilterCell.detailTextLabel.text = NSLocalizedString(@"$cell:MonotonefilterUnknown", @"CPanelViewController.updateShowMonotonefilterCell");
		[self tableViewCell:self.showMonotonefilterCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterMonotonefilterKey];
	if (!property) {
		self.showMonotonefilterCell.textLabel.text = self.showMonotonefilterCellTitle;
		self.showMonotonefilterCell.detailTextLabel.text = NSLocalizedString(@"$cell:MonotonefilterNotAvailable", @"CPanelViewController.updateShowMonotonefilterCell");
		[self tableViewCell:self.showMonotonefilterCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応するモノクロフィルター効果の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showMonotonefilterCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応するモノクロフィルター効果を表示します。
	[self updateCameraPropertyCell:self.showMonotonefilterCell name:property completion:nil];
}

/// 調色効果のを表示します。
- (void)updateShowMonotonecolorCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターから調色効果のプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showMonotonecolorCell.textLabel.text = self.showMonotonecolorCellTitle;
		self.showMonotonecolorCell.detailTextLabel.text = NSLocalizedString(@"$cell:MonotonecolorUnknown", @"CPanelViewController.updateShowMonotonecolorCell");
		[self tableViewCell:self.showMonotonecolorCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterMonotonecolorKey];
	if (!property) {
		self.showMonotonecolorCell.textLabel.text = self.showMonotonecolorCellTitle;
		self.showMonotonecolorCell.detailTextLabel.text = NSLocalizedString(@"$cell:MonotonecolorNotAvailable", @"CPanelViewController.updateShowMonotonecolorCell");
		[self tableViewCell:self.showMonotonecolorCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応する調色効果の名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showMonotonecolorCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応する調色効果を表示します。
	[self updateCameraPropertyCell:self.showMonotonecolorCell name:property completion:nil];
}

/// カラークリエーター用色相を表示します。
- (void)updateShowColorCreatorColorCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorCreatorColorCell name:CameraPropertyColorCreatorColor completion:nil];
}

/// カラークリエーター用彩度を表示します。
- (void)updateShowColorCreatorVividCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorCreatorVividCell name:CameraPropertyColorCreatorVivid completion:nil];
}

/// パートカラー用色相を表示します。
- (void)updateShowColorPhaseCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorPhaseCell name:CameraPropertyColorPhase completion:nil];
}

/// アートフィルターバリエーションを表示します。
- (void)updateShowArtEffectTypeCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターからアートフィルターバリエーションのプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showArtEffectTypeCell.textLabel.text = self.showArtEffectTypeCellTitle;
		self.showArtEffectTypeCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectTypeUnknown", @"CPanelViewController.updateShowArtEffectTypeCell");
		[self tableViewCell:self.showArtEffectTypeCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterArtEffectTypeKey];
	if (!property) {
		self.showArtEffectTypeCell.textLabel.text = self.showArtEffectTypeCellTitle;
		self.showArtEffectTypeCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectTypeNotAvailable", @"CPanelViewController.updateShowArtEffectTypeCell");
		[self tableViewCell:self.showArtEffectTypeCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応するアートフィルターバリエーションの名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showArtEffectTypeCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応するアートフィルターバリエーションを表示します。
	[self updateCameraPropertyCell:self.showArtEffectTypeCell name:property completion:nil];
}

/// アートエフェクトを表示します。
- (void)updateShowArtEffectHybridCell {
	DEBUG_LOG(@"");

	// 現在のアートフィルターからアートエフェクトのプロパティ名を取得します。
	AppCamera *camera = GetAppCamera();
	if (!self.currentArtFilter) {
		self.showArtEffectHybridCell.textLabel.text = self.showArtEffectHybridCellTitle;
		self.showArtEffectHybridCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectHybridUnknown", @"CPanelViewController.updateShowArtEffectHybridCell");
		[self tableViewCell:self.showArtEffectHybridCell enabled:NO];
		return;
	}
	NSDictionary *artFilter = self.artFilterMap[self.currentArtFilter];
	NSString *property = artFilter[ArtFilterArtEffectHybridKey];
	if (!property) {
		self.showArtEffectHybridCell.textLabel.text = self.showArtEffectHybridCellTitle;
		self.showArtEffectHybridCell.detailTextLabel.text = NSLocalizedString(@"$cell:EffectHybridNotAvailable", @"CPanelViewController.updateShowArtEffectHybridCell");
		[self tableViewCell:self.showArtEffectHybridCell enabled:NO];
		return;
	}
	
	// アートフィルターに対応するアートエフェクトの名称を表示します。
	NSString *propertyTitle = [camera cameraPropertyLocalizedTitle:property];
	self.showArtEffectHybridCell.textLabel.text = propertyTitle;
	
	// アートフィルターに対応するアートエフェクトを表示します。
	[self updateCameraPropertyCell:self.showArtEffectHybridCell name:property completion:nil];
}

/// カメラプロパティ値を表示します。
- (void)updateCameraPropertyCell:(UITableViewCell *)cell name:(NSString *)name completion:(void (^)(NSString *value))completion {
	DEBUG_LOG(@"name=%@", name);
	
	__weak UITableViewCell *weakCell = cell;
	__weak CPanelViewController *weakSelf = self;
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
				weakCell.detailTextLabel.text = NSLocalizedString(@"$cell:CouldNotGetCameraPropertyValue", @"CPanelViewController.updateCameraPropertyCell");
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

@end
