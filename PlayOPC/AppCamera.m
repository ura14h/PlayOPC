//
//  AppCamera.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppCamera.h"

// このクラス用の表示文言ローカライズ ... ローカライズされた表示文言はAppCamera.stringsに格納されます。
#define AppCameraLocalizedString(key) \
	[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"AppCamera"]

NSString *const CameraPropertyAperture = @"APERTURE";
NSString *const CameraPropertyAe = @"AE";
NSString *const CameraPropertyTakemode = @"TAKEMODE";
NSString *const CameraPropertyTakemodeP = @"<TAKEMODE/P>";
NSString *const CameraPropertyTakemodeA = @"<TAKEMODE/A>";
NSString *const CameraPropertyTakemodeS = @"<TAKEMODE/S>";
NSString *const CameraPropertyTakemodeM = @"<TAKEMODE/M>";
NSString *const CameraPropertyIso = @"ISO";
NSString *const CameraPropertyExprev = @"EXPREV";
NSString *const CameraPropertyTakeDrive = @"TAKE_DRIVE";
NSString *const CameraPropertyAspectRatio = @"ASPECT_RATIO";
NSString *const CameraPropertyShutter = @"SHUTTER";
NSString *const CameraPropertyContinuousShootingVelocity = @"CONTINUOUS_SHOOTING_VELOCITY";
NSString *const CameraPropertyExposeMovieSelect = @"EXPOSE_MOVIE_SELECT";
NSString *const CameraPropertyAeLockState = @"AE_LOCK_STATE";
NSString *const CameraPropertyAeLockStateLock = @"<AE_LOCK_STATE/LOCK>";
NSString *const CameraPropertyAeLockStateUnlock = @"<AE_LOCK_STATE/UNLOCK>";
NSString *const CameraPropertyImagesize = @"IMAGESIZE";
NSString *const CameraPropertyRaw = @"RAW";
NSString *const CameraPropertyCompressibilityRatio = @"COMPRESSIBILITY_RATIO";
NSString *const CameraPropertyQualityMovie = @"QUALITY_MOVIE";
NSString *const CameraPropertyDestinationFile = @"DESTINATION_FILE";
NSString *const CameraPropertyQualityMovieShortMovieRecordTime = @"QUALITY_MOVIE_SHORT_MOVIE_RECORD_TIME";
NSString *const CameraPropertyFocusStill = @"FOCUS_STILL";
NSString *const CameraPropertyFocusStillMf = @"<FOCUS_STILL/FOCUS_MF>";
NSString *const CameraPropertyFocusStillSaf = @"<FOCUS_STILL/FOCUS_SAF>";
NSString *const CameraPropertyAfLockState = @"AF_LOCK_STATE";
NSString *const CameraPropertyAfLockStateLock = @"<AF_LOCK_STATE/LOCK>";
NSString *const CameraPropertyAfLockStateUnlock = @"<AF_LOCK_STATE/UNLOCK>";
NSString *const CameraPropertyFocusMovie = @"FOCUS_MOVIE";
NSString *const CameraPropertyFocusMovieMf = @"<FOCUS_MOVIE/FOCUS_MF>";
NSString *const CameraPropertyFocusMovieSaf = @"<FOCUS_MOVIE/FOCUS_SAF>";
NSString *const CameraPropertyFocusMovieCaf = @"<FOCUS_MOVIE/FOCUS_CAF>";
NSString *const CameraPropertyFullTimeAf = @"FULL_TIME_AF";
NSString *const CameraPropertyBatteryLevel = @"BATTERY_LEVEL";
NSString *const CameraPropertyFaceScan = @"FACE_SCAN";
NSString *const CameraPropertyAntiShakeFocalLength = @"ANTI_SHAKE_FOCAL_LENGTH";
NSString *const CameraPropertyRecview = @"RECVIEW";
NSString *const CameraPropertyAntiShakeMovie = @"ANTI_SHAKE_MOVIE";
NSString *const CameraPropertySoundVolumeLevel = @"SOUND_VOLUME_LEVEL";
NSString *const CameraPropertyGps = @"GPS";
NSString *const CameraPropertyWifiCh = @"WIFI_CH";
NSString *const CameraPropertyRecentlyArtFilter = @"RECENTLY_ART_FILTER";
NSString *const CameraPropertyRecentlyArtFilterPopart = @"<RECENTLY_ART_FILTER/POPART>";
NSString *const CameraPropertyRecentlyArtFilterFantasicFocus = @"<RECENTLY_ART_FILTER/FANTASIC_FOCUS>";
NSString *const CameraPropertyRecentlyArtFilterDaydream = @"<RECENTLY_ART_FILTER/DAYDREAM>";
NSString *const CameraPropertyRecentlyArtFilterLightTone = @"<RECENTLY_ART_FILTER/LIGHT_TONE>";
NSString *const CameraPropertyRecentlyArtFilterRoughMonochrome = @"<RECENTLY_ART_FILTER/ROUGH_MONOCHROME>";
NSString *const CameraPropertyRecentlyArtFilterToyPhoto = @"<RECENTLY_ART_FILTER/TOY_PHOTO>";
NSString *const CameraPropertyRecentlyArtFilterMiniature = @"<RECENTLY_ART_FILTER/MINIATURE>";
NSString *const CameraPropertyRecentlyArtFilterCrossProcess = @"<RECENTLY_ART_FILTER/CROSS_PROCESS>";
NSString *const CameraPropertyRecentlyArtFilterGentleSepia = @"<RECENTLY_ART_FILTER/GENTLE_SEPIA>";
NSString *const CameraPropertyRecentlyArtFilterDramaticTone = @"<RECENTLY_ART_FILTER/DRAMATIC_TONE>";
NSString *const CameraPropertyRecentlyArtFilterLigneClair = @"<RECENTLY_ART_FILTER/LIGNE_CLAIR>";
NSString *const CameraPropertyRecentlyArtFilterPastel = @"<RECENTLY_ART_FILTER/PASTEL>";
NSString *const CameraPropertyRecentlyArtFilterVintage = @"<RECENTLY_ART_FILTER/VINTAGE>";
NSString *const CameraPropertyRecentlyArtFilterPartcolor = @"<RECENTLY_ART_FILTER/PARTCOLOR>";
NSString *const CameraPropertyColorPhase = @"COLOR_PHASE";
NSString *const CameraPropertyArtEffectTypePopart = @"ART_EFFECT_TYPE_POPART";
NSString *const CameraPropertyArtEffectTypeDaydream = @"ART_EFFECT_TYPE_DAYDREAM";
NSString *const CameraPropertyArtEffectTypeRoughMonochrome = @"ART_EFFECT_TYPE_ROUGH_MONOCHROME";
NSString *const CameraPropertyArtEffectTypeToyPhoto = @"ART_EFFECT_TYPE_TOY_PHOTO";
NSString *const CameraPropertyArtEffectTypeMiniature = @"ART_EFFECT_TYPE_MINIATURE";
NSString *const CameraPropertyArtEffectTypeCrossProcess = @"ART_EFFECT_TYPE_CROSS_PROCESS";
NSString *const CameraPropertyArtEffectTypeDramaticTone = @"ART_EFFECT_TYPE_DRAMATIC_TONE";
NSString *const CameraPropertyArtEffectTypeLigneClair = @"ART_EFFECT_TYPE_LIGNE_CLAIR";
NSString *const CameraPropertyArtEffectTypePastel = @"ART_EFFECT_TYPE_PASTEL";
NSString *const CameraPropertyArtEffectTypeVintage = @"ART_EFFECT_TYPE_VINTAGE";
NSString *const CameraPropertyArtEffectTypePartcolor = @"ART_EFFECT_TYPE_PARTCOLOR";
NSString *const CameraPropertyArtEffectHybridPopart = @"ART_EFFECT_HYBRID_POPART";
NSString *const CameraPropertyArtEffectHybridFantasicFocus = @"ART_EFFECT_HYBRID_FANTASIC_FOCUS";
NSString *const CameraPropertyArtEffectHybridDaydream = @"ART_EFFECT_HYBRID_DAYDREAM";
NSString *const CameraPropertyArtEffectHybridLightTone = @"ART_EFFECT_HYBRID_LIGHT_TONE";
NSString *const CameraPropertyArtEffectHybridRoughMonochrome = @"ART_EFFECT_HYBRID_ROUGH_MONOCHROME";
NSString *const CameraPropertyArtEffectHybridToyPhoto = @"ART_EFFECT_HYBRID_TOY_PHOTO";
NSString *const CameraPropertyArtEffectHybridMiniature = @"ART_EFFECT_HYBRID_MINIATURE";
NSString *const CameraPropertyArtEffectHybridCrossProcess = @"ART_EFFECT_HYBRID_CROSS_PROCESS";
NSString *const CameraPropertyArtEffectHybridGentleSepia = @"ART_EFFECT_HYBRID_GENTLE_SEPIA";
NSString *const CameraPropertyArtEffectHybridDramaticTone = @"ART_EFFECT_HYBRID_DRAMATIC_TONE";
NSString *const CameraPropertyArtEffectHybridLigneClair = @"ART_EFFECT_HYBRID_LIGNE_CLAIR";
NSString *const CameraPropertyArtEffectHybridPastel = @"ART_EFFECT_HYBRID_PASTEL";
NSString *const CameraPropertyArtEffectHybridVintage = @"ART_EFFECT_HYBRID_VINTAGE";
NSString *const CameraPropertyArtEffectHybridPartcolor = @"ART_EFFECT_HYBRID_PARTCOLOR";
NSString *const CameraPropertyBracketPictPopart = @"BRACKET_PICT_POPART";
NSString *const CameraPropertyBracketPictFantasicFocus = @"BRACKET_PICT_FANTASIC_FOCUS";
NSString *const CameraPropertyBracketPictDaydream = @"BRACKET_PICT_DAYDREAM";
NSString *const CameraPropertyBracketPictLightTone = @"BRACKET_PICT_LIGHT_TONE";
NSString *const CameraPropertyBracketPictRoughMonochrome = @"BRACKET_PICT_ROUGH_MONOCHROME";
NSString *const CameraPropertyBracketPictToyPhoto = @"BRACKET_PICT_TOY_PHOTO";
NSString *const CameraPropertyBracketPictMiniature = @"BRACKET_PICT_MINIATURE";
NSString *const CameraPropertyBracketPictCrossProcess = @"BRACKET_PICT_CROSS_PROCESS";
NSString *const CameraPropertyBracketPictGentleSepia = @"BRACKET_PICT_GENTLE_SEPIA";
NSString *const CameraPropertyBracketPictDramaticTone = @"BRACKET_PICT_DRAMATIC_TONE";
NSString *const CameraPropertyBracketPictLigneClair = @"BRACKET_PICT_LIGNE_CLAIR";
NSString *const CameraPropertyBracketPictPastel = @"BRACKET_PICT_PASTEL";
NSString *const CameraPropertyBracketPictVintage = @"BRACKET_PICT_VINTAGE";
NSString *const CameraPropertyBracketPictPartcolor = @"BRACKET_PICT_PARTCOLOR";
NSString *const CameraPropertyColortone = @"COLORTONE";
NSString *const CameraPropertyColortoneFlat = @"<COLORTONE/FLAT>";
NSString *const CameraPropertyColortoneNatural = @"<COLORTONE/NATURAL>";
NSString *const CameraPropertyColortoneMonotone = @"<COLORTONE/Monotone>";
NSString *const CameraPropertyColortonePortrait = @"<COLORTONE/Portrait>";
NSString *const CameraPropertyColortoneIFinish = @"<COLORTONE/I_FINISH>";
NSString *const CameraPropertyColortoneVivid = @"<COLORTONE/VIVID>";
NSString *const CameraPropertyColortoneEportrait = @"<COLORTONE/ePortrait>";
NSString *const CameraPropertyColortoneColorCreator = @"<COLORTONE/COLOR_CREATOR>";
NSString *const CameraPropertyColortonePopart = @"<COLORTONE/POPART>";
NSString *const CameraPropertyColortoneFantasicFocus = @"<COLORTONE/FANTASIC_FOCUS>";
NSString *const CameraPropertyColortoneDaydream = @"<COLORTONE/DAYDREAM>";
NSString *const CameraPropertyColortoneLightTone = @"<COLORTONE/LIGHT_TONE>";
NSString *const CameraPropertyColortoneRoughMonochrome = @"<COLORTONE/ROUGH_MONOCHROME>";
NSString *const CameraPropertyColortoneToyPhoto = @"<COLORTONE/TOY_PHOTO>";
NSString *const CameraPropertyColortoneMiniature = @"<COLORTONE/MINIATURE>";
NSString *const CameraPropertyColortoneCrossProcess = @"<COLORTONE/CROSS_PROCESS>";
NSString *const CameraPropertyColortoneGentleSepia = @"<COLORTONE/GENTLE_SEPIA>";
NSString *const CameraPropertyColortoneDramaticTone = @"<COLORTONE/DRAMATIC_TONE>";
NSString *const CameraPropertyColortoneLigneClair = @"<COLORTONE/LIGNE_CLAIR>";
NSString *const CameraPropertyColortonePastel = @"<COLORTONE/PASTEL>";
NSString *const CameraPropertyColortoneVintage = @"<COLORTONE/VINTAGE>";
NSString *const CameraPropertyColortonePartcolor = @"<COLORTONE/PARTCOLOR>";
NSString *const CameraPropertyContrastFlat = @"CONTRAST_FLAT";
NSString *const CameraPropertyContrastNatural = @"CONTRAST_NATURAL";
NSString *const CameraPropertyContrastMonochrome = @"CONTRAST_MONOCHROME";
NSString *const CameraPropertyContrastSoft = @"CONTRAST_SOFT";
NSString *const CameraPropertyContrastIFinish = @"CONTRAST_I_FINISH";
NSString *const CameraPropertyContrastVivid = @"CONTRAST_VIVID";
NSString *const CameraPropertySharpFlat = @"SHARP_FLAT";
NSString *const CameraPropertySharpNatural = @"SHARP_NATURAL";
NSString *const CameraPropertySharpMonochrome = @"SHARP_MONOCHROME";
NSString *const CameraPropertySharpSoft = @"SHARP_SOFT";
NSString *const CameraPropertySharpIFinish = @"SHARP_I_FINISH";
NSString *const CameraPropertySharpVivid = @"SHARP_VIVID";
NSString *const CameraPropertySaturationLevelFlat = @"SATURATION_LEVEL_FLAT";
NSString *const CameraPropertySaturationLevelNatural = @"SATURATION_LEVEL_NATURAL";
NSString *const CameraPropertySaturationLevelSoft = @"SATURATION_LEVEL_SOFT";
NSString *const CameraPropertySaturationLevelIFinish = @"SATURATION_LEVEL_I_FINISH";
NSString *const CameraPropertySaturationLevelVivid = @"SATURATION_LEVEL_VIVID";
NSString *const CameraPropertyToneFlat = @"TONE_FLAT";
NSString *const CameraPropertyToneNatural = @"TONE_NATURAL";
NSString *const CameraPropertyToneMonochrome = @"TONE_MONOCHROME";
NSString *const CameraPropertyToneSoft = @"TONE_SOFT";
NSString *const CameraPropertyToneIFinish = @"TONE_I_FINISH";
NSString *const CameraPropertyToneVivid = @"TONE_VIVID";
NSString *const CameraPropertyEffectLevelIFinish = @"EFFECT_LEVEL_I_FINISH";
NSString *const CameraPropertyToneControlLow = @"TONE_CONTROL_LOW";
NSString *const CameraPropertyToneControlMiddle = @"TONE_CONTROL_MIDDLE";
NSString *const CameraPropertyToneControlHigh = @"TONE_CONTROL_HIGH";
NSString *const CameraPropertyMonotonefilterMonochrome = @"MONOTONEFILTER_MONOCHROME";
NSString *const CameraPropertyMonotonefilterRoughMonochrome = @"MONOTONEFILTER_ROUGH_MONOCHROME";
NSString *const CameraPropertyMonotonefilterDramaticTone = @"MONOTONEFILTER_DRAMATIC_TONE";
NSString *const CameraPropertyMonotonecolorMonochrome = @"MONOTONECOLOR_MONOCHROME";
NSString *const CameraPropertyMonotonecolorRoughMonochrome = @"MONOTONECOLOR_ROUGH_MONOCHROME";
NSString *const CameraPropertyMonotonecolorDramaticTone = @"MONOTONECOLOR_DRAMATIC_TONE";
NSString *const CameraPropertyColorCreatorColor = @"COLOR_CREATOR_COLOR";
NSString *const CameraPropertyColorCreatorVivid = @"COLOR_CREATOR_VIVID";
NSString *const CameraPropertyWb = @"WB";
NSString *const CameraPropertyWbWbAuto = @"<WB/WB_AUTO>";
NSString *const CameraPropertyWbMwbFine = @"<WB/MWB_FINE>";
NSString *const CameraPropertyWbMwbShade = @"<WB/MWB_SHADE>";
NSString *const CameraPropertyWbMwbCloud = @"<WB/MWB_CLOUD>";
NSString *const CameraPropertyWbMwbLamp = @"<WB/MWB_LAMP>";
NSString *const CameraPropertyWbMwbFluorescence1 = @"<WB/MWB_FLUORESCENCE1>";
NSString *const CameraPropertyWbMwbWater1 = @"<WB/MWB_WATER_1>";
NSString *const CameraPropertyWbWbCustom1 = @"<WB/WB_CUSTOM1>";
NSString *const CameraPropertyCustomWbKelvin1 = @"CUSTOM_WB_KELVIN_1";
NSString *const CameraPropertyWbRevAuto = @"WB_REV_AUTO";
NSString *const CameraPropertyWbRevGAuto = @"WB_REV_G_AUTO";
NSString *const CameraPropertyWbRev5300k = @"WB_REV_5300K";
NSString *const CameraPropertyWbRevG5300k = @"WB_REV_G_5300K";
NSString *const CameraPropertyWbRev7500k = @"WB_REV_7500K";
NSString *const CameraPropertyWbRevG7500k = @"WB_REV_G_7500K";
NSString *const CameraPropertyWbRev6000k = @"WB_REV_6000K";
NSString *const CameraPropertyWbRevG6000k = @"WB_REV_G_6000K";
NSString *const CameraPropertyWbRev3000k = @"WB_REV_3000K";
NSString *const CameraPropertyWbRevG3000k = @"WB_REV_G_3000K";
NSString *const CameraPropertyWbRev4000k = @"WB_REV_4000K";
NSString *const CameraPropertyWbRevG4000k = @"WB_REV_G_4000K";
NSString *const CameraPropertyWbRevAutoUnderWater = @"WB_REV_AUTO_UNDER_WATER";
NSString *const CameraPropertyWbRevGAutoUnderWater = @"WB_REV_G_AUTO_UNDER_WATER";
NSString *const CameraPropertyAutoWbDenkyuColoredLeaving = @"AUTO_WB_DENKYU_COLORED_LEAVING";

NSString *const CameraPropertyHighTemperatureWarning = @"highTemperatureWarning";
NSString *const CameraPropertyLensMountStatus = @"lensMountStatus";
NSString *const CameraPropertyMediaMountStatus = @"mediaMountStatus";
NSString *const CameraPropertyMediaBusy = @"mediaBusy";
NSString *const CameraPropertyMediaError = @"mediaError";
NSString *const CameraPropertyRemainingImageCapacity = @"remainingImageCapacity";
NSString *const CameraPropertyRemainingMediaCapacity = @"remainingMediaCapacity";
NSString *const CameraPropertyRemainingVideoCapacity = @"remainingVideoCapacity";
NSString *const CameraPropertyCurrentFocalLength = @"actualFocalLength";
NSString *const CameraPropertyMinimumFocalLength = @"minimumFocalLength";
NSString *const CameraPropertyMaximumFocalLength = @"maximumFocalLength";
NSString *const CameraPropertyActualApertureValue = @"actualApertureValue";
NSString *const CameraPropertyActualShutterSpeed = @"actualShutterSpeed";
NSString *const CameraPropertyActualExposureCompensation = @"actualExposureCompensation";
NSString *const CameraPropertyActualIsoSensitivity = @"actualIsoSensitivity";
NSString *const CameraPropertyActualIsoSensitivityWarning = @"actualIsoSensitivityWarning";
NSString *const CameraPropertyExposureWarning = @"exposureWarning";
NSString *const CameraPropertyExposureMeteringWarning = @"exposureMeteringWarning";
NSString *const CameraPropertyLevelGauge = @"levelGauge";
NSString *const CameraPropertyDetectedHumanFaces = @"detectedHumanFaces";
NSString *const CameraPropertyLiveViewSize = @"liveViewSize";
NSString *const CameraPropertyMinimumDigitalZoomScale = @"minimumDigitalZoomScale";
NSString *const CameraPropertyMaximumDigitalZoomScale = @"maximumDigitalZoomScale";
NSString *const CameraPropertyCurrentDigitalZoomScale = @"currentDigitalZoomScale";
NSString *const CameraPropertyOpticalZoomingSpeed = @"opticalZoomingSpeed";
NSString *const CameraPropertyMagnifyingLiveView = @"magnifyingLiveView";
NSString *const CameraPropertyMagnifyingLiveViewScale = @"magnifyingLiveViewScale";
NSString *const CameraPropertyArtEffectType = @"ART_EFFECT_TYPE";
NSString *const CameraPropertyArtEffectHybrid = @"ART_EFFECT_HYBRID";
NSString *const CameraPropertyArtFilterAutoBracket = @"BRACKET_PICT_POPART";
NSString *const CameraPropertyContrast = @"CONTRAST";
NSString *const CameraPropertySharp = @"SHARP";
NSString *const CameraPropertySaturationLevel = @"SATURATION_LEVEL";
NSString *const CameraPropertyTone = @"TONE";
NSString *const CameraPropertyEffectLevel = @"EFFECT_LEVEL";
NSString *const CameraPropertyMonotonecolor = @"MONOTONECOLOR";
NSString *const CameraPropertyMonotonefilter = @"MONOTONEFILTER";
NSString *const CameraPropertyWbRev = @"WB_REV";
NSString *const CameraPropertyWbRevG = @"WB_REV_G";
NSString *const CameraPropertyAutoBracketingMode = @"autoBracketingMode";
NSString *const CameraPropertyAutoBracketingCount = @"autoBrackettingCount";
NSString *const CameraPropertyAutoBracketingStep = @"autoBrackettingStep";

static NSString *const CameraSettingSnapshotFormatVersion = @"1.0"; ///< ファイルのフォーマットバージョン
static NSString *const CameraSettingSnapshotFormatVersionKey = @"FormatVersion"; ///< ファイルのフォーマットバージョンの辞書キー
static NSString *const CameraSettingSnapshotPropertyValuesKey = @"PropertyValues"; ///< ファイルのカメラプロパティ値の辞書キー
static NSString *const CameraSettingSnapshotLiveViewSizeKey = @"LiveViewSize"; ///< ファイルのライブビューサイズ設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingModeKey = @"AutoBracketingMode"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingCountKey = @"AutoBracketingCount"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingStepKey = @"AutoBracketingStep"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotMagnifyingLiveViewScaleKey = @"MagnifyingLiveViewScale"; ///< ライブビュー拡大倍率の辞書キー

@interface AppCamera () <OLYCameraConnectionDelegate, OLYCameraPropertyDelegate, OLYCameraPlaybackDelegate, OLYCameraLiveViewDelegate, OLYCameraRecordingDelegate, OLYCameraRecordingSupportsDelegate>

@property (assign, nonatomic, readwrite) float minimumDigitalZoomScale;	///< デジタルズームの最小倍率
@property (assign, nonatomic, readwrite) float maximumDigitalZoomScale;	///< デジタルズームの最大倍率
@property (assign, nonatomic, readwrite) float currentDigitalZoomScale;	///< 現在のデジタルズームの倍率
@property (assign, nonatomic, readwrite) OLYCameraMagnifyingLiveViewScale magnifyingLiveViewScale;	///< 現在のライブビュー拡大の倍率

// MARK: このプロパティ群は複数スレッドが参照するのでatomicにしておかないとタイミングによってはクラッシュしてしまいます。
@property (strong, atomic) NSHashTable *connectionDelegates; ///< connectionDelegateの集合
@property (strong, atomic) NSHashTable *cameraPropertyDelegates; ///< cameraPropertyDelegateの集合
@property (strong, atomic) NSHashTable *playbackDelegates; ///< playbackDelegateの集合
@property (strong, atomic) NSHashTable *liveViewDelegates; ///< liveViewDelegateの集合
@property (strong, atomic) NSHashTable *recordingDelegates; ///< recordingDelegateの集合
@property (strong, atomic) NSHashTable *recordingSupportsDelegates; ///< recordingSupportsDelegateの集合
@property (strong, atomic) NSHashTable *takingPictureDelegates; // takingPicutreDelegateの集合

@property (assign, nonatomic) BOOL runningLockingAutoFocus; ///< AFロックを実行中か
@property (assign, nonatomic) BOOL runningLockingAutoExposure; ///< AEロックを実行中か
@property (assign, nonatomic) BOOL runningAutoBracketing; /// オートブラケット撮影中か
@property (assign, nonatomic) BOOL abortAutoBracketing; /// オートブラケット撮影を中止させようとしているか
@property (assign, nonatomic) BOOL abortedAutoBracketing; /// オートブラケット撮影を中止させようとしているか
@property (strong, nonatomic) dispatch_queue_t takingPictureRunnerQueue; /// 静止画複数枚撮影を実行するキュー
@property (strong, nonatomic) dispatch_queue_t takingPictureStopperQueue; /// 静止画複数枚撮影を中止させるキュー

@end

#pragma mark -

@implementation AppCamera

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");
	
    self = [super init];
    if (!self) {
		return nil;
    }
	
	_autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	_autoBracketingCount = 3;
	_autoBracketingStep = 1;
	_minimumDigitalZoomScale = NAN;
	_maximumDigitalZoomScale = NAN;
	_currentDigitalZoomScale = NAN;
	_magnifyingLiveViewScale = OLYCameraMagnifyingLiveViewScaleX5;
	_runningLockingAutoFocus = NO;
	_runningLockingAutoExposure = NO;
	_runningAutoBracketing = NO;
	_abortAutoBracketing = NO;
	_abortedAutoBracketing = NO;
	_takingPictureRunnerQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.takingPictureRunner", DISPATCH_QUEUE_SERIAL);
	_takingPictureStopperQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.takingStopperRunner", DISPATCH_QUEUE_SERIAL);
	
	// 弱い参照を格納できる集合を生成します。
	_connectionDelegates = [NSHashTable weakObjectsHashTable];
	_cameraPropertyDelegates = [NSHashTable weakObjectsHashTable];
	_playbackDelegates = [NSHashTable weakObjectsHashTable];
	_liveViewDelegates = [NSHashTable weakObjectsHashTable];
	_recordingDelegates = [NSHashTable weakObjectsHashTable];
	_recordingSupportsDelegates = [NSHashTable weakObjectsHashTable];
	_takingPictureDelegates = [NSHashTable weakObjectsHashTable];
	
	self.connectionDelegate = self;
	self.cameraPropertyDelegate = self;
	self.playbackDelegate = self;
	self.liveViewDelegate = self;
	self.recordingDelegate = self;
	self.recordingSupportsDelegate = self;
	
    return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_takingPictureRunnerQueue = nil;
	_takingPictureStopperQueue = nil;

	_connectionDelegates = nil;
	_cameraPropertyDelegates = nil;
	_playbackDelegates = nil;
	_liveViewDelegates = nil;
	_recordingDelegates = nil;
	_recordingSupportsDelegates = nil;
	_takingPictureDelegates = nil;

	self.connectionDelegate = nil;
	self.cameraPropertyDelegate = nil;
	self.playbackDelegate = nil;
	self.liveViewDelegate = nil;
	self.recordingDelegate = nil;
	self.recordingSupportsDelegate = nil;
}

#pragma mark -

- (BOOL)changeRunMode:(OLYCameraRunMode)mode error:(NSError **)error {
	DEBUG_LOG(@"mode=%ld", (long)mode);
	
	OLYCameraRunMode previousRunMode = self.runMode;
	BOOL result = [super changeRunMode:mode error:error];
	
	if (result && self.runMode == previousRunMode) {
		return result;
	}

#if 0 // 以前の状態に復帰しなくても問題ないようなので実装を無効にしておきます。
	// オートブラケット撮影のプロパティを更新します。
	_autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	_autoBracketingCount = 3;
	_autoBracketingStep = 1;
#endif
	
	// デジタルズームのプロパティを更新します。
	float minimumDigitalZoomScale = NAN;
	float maximumDigitalZoomScale = NAN;
	float currentDigitalZoomScale = NAN;
	if (self.runMode == OLYCameraRunModeRecording) {
		NSDictionary *range = [super digitalZoomScaleRange:error];
		if (range &&
			range[OLYCameraDigitalZoomScaleRangeMinimumKey] &&
			range[OLYCameraDigitalZoomScaleRangeMaximumKey]) {
			minimumDigitalZoomScale = [range[OLYCameraDigitalZoomScaleRangeMinimumKey] floatValue];
			maximumDigitalZoomScale = [range[OLYCameraDigitalZoomScaleRangeMaximumKey] floatValue];
			currentDigitalZoomScale = MIN(MAX(1.0, minimumDigitalZoomScale), maximumDigitalZoomScale);
		}
	}
	if ((isnan(self.minimumDigitalZoomScale) && !isnan(minimumDigitalZoomScale)) ||
		(!isnan(self.minimumDigitalZoomScale) && isnan(minimumDigitalZoomScale)) ||
		self.minimumDigitalZoomScale != minimumDigitalZoomScale) {
		self.minimumDigitalZoomScale = minimumDigitalZoomScale;
	}
	if ((isnan(self.maximumDigitalZoomScale) && !isnan(maximumDigitalZoomScale)) ||
		(!isnan(self.maximumDigitalZoomScale) && isnan(maximumDigitalZoomScale)) ||
		self.maximumDigitalZoomScale != maximumDigitalZoomScale) {
		self.maximumDigitalZoomScale = maximumDigitalZoomScale;
	}
	if ((isnan(self.currentDigitalZoomScale) && !isnan(currentDigitalZoomScale)) ||
		(!isnan(self.currentDigitalZoomScale) && isnan(currentDigitalZoomScale)) ||
		self.currentDigitalZoomScale != currentDigitalZoomScale) {
		self.currentDigitalZoomScale = currentDigitalZoomScale;
	}

#if 0 // 以前の状態に復帰しなくても問題ないようなので実装を無効にしておきます。
	// ライブビュー拡大のプロパティを更新します。
	_magnifyingLiveViewScale = OLYCameraMagnifyingLiveViewScaleX5;
#endif
	
	// オートフォーカスと自動測光のフラグを初期化します。
	self.runningLockingAutoFocus = NO;
	self.runningLockingAutoExposure = NO;
	
	// オートブラケット撮影のフラグを初期化します。
	self.runningAutoBracketing = NO;
	self.abortAutoBracketing = NO;
	self.abortedAutoBracketing = NO;

	return result;
}

- (BOOL)setCameraPropertyValue:(NSString *)name value:(NSString *)value error:(NSError **)error {
	DEBUG_LOG(@"name=%@, value=%@", name, value);

	// MARK: フォーカスモードが変わったらフォーカスロックは解除する必要があるようです。
	// MARK: MF以外からMFに変更するとレンズのフォーカスリングがロックしたままになっているため。
	if ([name isEqualToString:CameraPropertyFocusStill] ||
		[name isEqualToString:CameraPropertyFocusMovie]) {
		[super unlockAutoFocus:nil];
		[super clearAutoFocusPoint:nil];
	}
	
	return [super setCameraPropertyValue:name value:value error:error];
}

- (BOOL)setCameraPropertyValues:(NSDictionary *)values error:(NSError **)error {
	DEBUG_LOG(@"values.count=%ld", (long)values.count);
	
	// MARK: 読み取り専用のカメラプロパティに設定しようとするとカメラが再起動してしまうようです。
	NSMutableDictionary *patchedValues = [values mutableCopy];
	[patchedValues removeObjectForKey:@"AE_LOCK_STATE"];
	[patchedValues removeObjectForKey:@"AF_LOCK_STATE"];
	[patchedValues removeObjectForKey:@"BATTERY_LEVEL"];
	[patchedValues removeObjectForKey:@"TOUCH_EFFECTIVE_AREA_UPPER_LEFT"];
	[patchedValues removeObjectForKey:@"TOUCH_EFFECTIVE_AREA_LOWER_RIGHT"];
	[patchedValues removeObjectForKey:@"TOUCH_AE_EFFECTIVE_AREA_UPPER_LEFT"];
	[patchedValues removeObjectForKey:@"TOUCH_AE_EFFECTIVE_AREA_LOWER_RIGHT"];

	// MARK: カメラかライブラリ内部で、カメラプロパティの設定同士が干渉しあって正しい状態を復元できないようです。
	//
	// 少なくとも、
	//  - 撮影モード(TAKEMODE)
	//  - 動画撮影モード(EXPOSE_MOVIE_SELECT)
	//  - アートフィルター種別(RECENTLY_ART_FILTER)
	// は互いに密接が関連があるようで、どれかの設定を変更すると他のどれかの値が勝手に変わってしまうようです。
	// このため、プロパティ一括設定を1回だけを使って全てのカメラプロパティ値を設定できないので、
	// 干渉し合うカメラプロパティ値の設定を保存しておいて、一括設定が終わった後に、一つづつ設定し直します。
	//
	// MARK: この実装で完全かどうかは確認できていません。
	// 少なくとも上述している4つのカメラプロパティの間の干渉はこの実装で回避できています。
	//
	NSString *takemode = values[CameraPropertyTakemode];
	NSString *exposeMovieSelect = values[CameraPropertyExposeMovieSelect];
	NSString *recentlyArtFilter = values[CameraPropertyRecentlyArtFilter];
	if (!takemode) {
		// 撮影モードに設定する値がプロパティ一括設定に含まれない場合はカメラに設定されている値を取得して代用します。
		takemode = [super cameraPropertyValue:CameraPropertyTakemode error:error];
		if (!takemode) {
			return NO;
		}
	}
	if (!exposeMovieSelect) {
		// 動画撮影モードに設定する値がプロパティ一括設定に含まれない場合はカメラに設定されている値を取得して代用します。
		exposeMovieSelect = [super cameraPropertyValue:CameraPropertyExposeMovieSelect error:error];
		if (!exposeMovieSelect) {
			return NO;
		}
	}
	if (!recentlyArtFilter) {
		// アートフィルター種別に設定する値がプロパティ一括設定に含まれない場合はカメラに設定されている値を取得して代用します。
		recentlyArtFilter = [super cameraPropertyValue:CameraPropertyRecentlyArtFilter error:error];
		if (recentlyArtFilter) {
			return NO;
		}
	}
	
	// 読み取り専用のカメラプロパティを取り除いた設定値リストをカメラに渡します。
	if (![super setCameraPropertyValues:patchedValues error:error]) {
		return NO;
	}
	
	// 干渉し合うカメラプロパティ値を手順に従って設定し直します。
	// 動画撮影モードを設定します。
	if (![super setCameraPropertyValue:CameraPropertyTakemode value:@"<TAKEMODE/movie>" error:error]) {
		return NO;
	}
	if (![super setCameraPropertyValue:CameraPropertyExposeMovieSelect value:exposeMovieSelect error:error]) {
		return NO;
	}
	// アートフィルター種別を設定します。
	if (![super setCameraPropertyValue:CameraPropertyTakemode value:@"<TAKEMODE/ART>" error:error]) {
		return NO;
	}
	if (![super setCameraPropertyValue:CameraPropertyRecentlyArtFilter value:recentlyArtFilter error:error]) {
		return NO;
	}
	// 最後に、撮影モードを設定します。
	if (![super setCameraPropertyValue:CameraPropertyTakemode value:takemode error:error]) {
		return NO;
	}
	
	return YES;
}

- (void)lockAutoFocus:(void (^)(NSDictionary *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");
	
	self.runningLockingAutoFocus = YES;
	[super lockAutoFocus:^(NSDictionary *info) {
		DEBUG_LOG(@"info=%p", info);
		self.runningLockingAutoFocus = NO;
		if (completionHandler) {
			completionHandler(info);
		}
	}errorHandler:^(NSError *error) {
		DEBUG_LOG(@"error=%p", error);
		self.runningLockingAutoFocus = NO;
		if (errorHandler) {
			errorHandler(error);
		}
	}];
}

- (BOOL)unlockAutoFocus:(NSError **)error {
	DEBUG_LOG(@"");
	
	self.runningLockingAutoFocus = NO;
	return [super unlockAutoFocus:error];
}

- (BOOL)unlockAutoExposure:(NSError **)error {
	DEBUG_LOG(@"");
	
	self.runningLockingAutoExposure = NO;
	return [super unlockAutoExposure:error];
}

- (BOOL)changeDigitalZoomScale:(float)scale error:(NSError **)error {
	DEBUG_LOG(@"scale=%f", scale);
	
	BOOL result = [super changeDigitalZoomScale:scale error:error];
	if (result) {
		// デジタルズームの倍率変更に成功した場合はプロパティの値も変更します。
		if ((isnan(self.currentDigitalZoomScale) && !isnan(scale)) ||
			(!isnan(self.currentDigitalZoomScale) && isnan(scale)) ||
			self.currentDigitalZoomScale != scale) {
			self.currentDigitalZoomScale = scale;
		}
	}
	return result;
}

- (BOOL)startMagnifyingLiveView:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error {
	DEBUG_LOG(@"scale=%ld", (long)scale);
	
	// ライブビュー拡大が成功したらその時の倍率を保持しておきます。
	BOOL result = [super startMagnifyingLiveView:scale error:error];
	if (result) {
		self.magnifyingLiveViewScale = scale;
	}
	return result;
}

- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point scale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error {
	DEBUG_LOG(@"scale=%ld", (long)scale);

	// ライブビュー拡大が成功したらその時の倍率を保持しておきます。
	BOOL result = [super startMagnifyingLiveViewAtPoint:point scale:scale error:error];
	if (result) {
		self.magnifyingLiveViewScale = scale;
	}
	return result;
}

- (BOOL)changeMagnifyingLiveViewScale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error {
	DEBUG_LOG(@"scale=%ld", (long)scale);

	// ライブビュー拡大を開始していない場合は変更されたことにします。
	if (!self.magnifyingLiveView) {
		self.magnifyingLiveViewScale = scale;
		return YES;
	}
	
	// ライブビュー拡大の倍率変更が成功したらその時の倍率を保持しておきます。
	BOOL result = [super changeMagnifyingLiveViewScale:scale error:error];
	if (result) {
		self.magnifyingLiveViewScale = scale;
	}
	return result;
}

#pragma mark -

- (void)camera:(OLYCamera *)camera disconnectedByError:(NSError *)error {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.connectionDelegates.count == 0) {
			return;
		}
		delegates = [self.connectionDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraConnectionDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:disconnectedByError:)]) {
			[delegate camera:camera disconnectedByError:error];
		}
	}
}

- (void)camera:(OLYCamera *)camera didChangeCameraProperty:(NSString *)name {
	DEBUG_LOG(@"name=%@", name);

	// MARK: AFロック実行中に呼び出された場合は無視します。
	// AFロック済みの状態でさらにAFロックするとカメラ内部的に一度ロック解除が行われ、
	// その影響でカメラプロパティのフォーカス固定(AFロック)の値が変化した通知が届きます。
	// ここでは、AFロック実行中に届いた不要な通知をすべて無視します。
	if ([name isEqualToString:CameraPropertyAfLockState] && self.runningLockingAutoFocus) {
		DEBUG_LOG(@"ignore %@", name);
		return;
	}

	// MARK: AEロック実行中に呼び出された場合は無視します。
	// AEロック済みの状態でさらにAEロックするとカメラ内部的に一度ロック解除が行われ、
	// その影響でカメラプロパティの露出固定(AEロック)の値が変化した通知が届きます。
	// ここでは、AEロック実行中に届いた不要な通知をすべて無視します。
	if ([name isEqualToString:CameraPropertyAeLockState] && self.runningLockingAutoExposure) {
		DEBUG_LOG(@"ignore %@", name);
		return;
	}

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.cameraPropertyDelegates.count == 0) {
			return;
		}
		delegates = [self.cameraPropertyDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraPropertyDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didChangeCameraProperty:)]) {
			[delegate camera:camera didChangeCameraProperty:name];
		}
	}
}

- (void)camera:(OLYCamera *)camera didUpdateLiveView:(NSData *)data metadata:(NSDictionary *)metadata {
	DEBUG_DETAIL_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.liveViewDelegates.count == 0) {
			return;
		}
		delegates = [self.liveViewDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraLiveViewDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didUpdateLiveView:metadata:)]) {
			[delegate camera:camera didUpdateLiveView:data metadata:metadata];
		}
	}
}

- (void)cameraDidStartRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(cameraDidStartRecordingVideo:)]) {
			[delegate cameraDidStartRecordingVideo:camera];
		}
	}
}

- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");
	
	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(cameraDidStopRecordingVideo:)]) {
			[delegate cameraDidStopRecordingVideo:camera];
		}
	}
}

- (void)camera:(OLYCamera *)camera didChangeAutoFocusResult:(NSDictionary *)result {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didChangeAutoFocusResult:)]) {
			[delegate camera:camera didChangeAutoFocusResult:result];
		}
	}
}

- (void)cameraWillReceiveCapturedImagePreview:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(cameraWillReceiveCapturedImagePreview:)]) {
			[delegate cameraWillReceiveCapturedImagePreview:camera];
		}
	}
}

- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didReceiveCapturedImagePreview:metadata:)]) {
			[delegate camera:camera didReceiveCapturedImagePreview:data metadata:metadata];
		}
	}
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImagePreviewWithError:(NSError *)error {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}

	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didFailToReceiveCapturedImagePreviewWithError:)]) {
			[delegate camera:camera didFailToReceiveCapturedImagePreviewWithError:error];
		}
	}
}

- (void)cameraWillReceiveCapturedImage:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}

	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(cameraWillReceiveCapturedImage:)]) {
			[delegate cameraWillReceiveCapturedImage:camera];
		}
	}
}

- (void)camera:(OLYCamera *)camera didReceiveCapturedImage:(NSData *)data {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didReceiveCapturedImage:)]) {
			[delegate camera:camera didReceiveCapturedImage:data];
		}
	}
}

- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImageWithError:(NSError *)error {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(camera:didFailToReceiveCapturedImageWithError:)]) {
			[delegate camera:camera didFailToReceiveCapturedImageWithError:error];
		}
	}
}

- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// デリゲート集合を取得します。
	// 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
	// FIXME: 処理効率が悪いですが他に良い方法が見つからず。
	NSHashTable *delegates = nil;
	@synchronized (self) {
		if (self.recordingSupportsDelegates.count == 0) {
			return;
		}
		delegates = [self.recordingSupportsDelegates copy];
	}
	
	// デリゲート集合のそれぞれにイベントを伝達します。
	for (id<OLYCameraRecordingSupportsDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(cameraDidStopDrivingZoomLens:)]) {
			[delegate cameraDidStopDrivingZoomLens:camera];
		}
	}
}

#pragma mark -

- (void)addConnectionDelegate:(id<OLYCameraConnectionDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);
	
	@synchronized (self) {
		NSHashTable *delegates = self.connectionDelegates;
		[delegates addObject:delegate];
		self.connectionDelegates = delegates;
	}
}

- (void)removeConnectionDelegate:(id<OLYCameraConnectionDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.connectionDelegates;
		[delegates removeObject:delegate];
		self.connectionDelegates = delegates;
	}
}

- (void)addCameraPropertyDelegate:(id<OLYCameraPropertyDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.cameraPropertyDelegates;
		[delegates addObject:delegate];
		self.cameraPropertyDelegates = delegates;
	}
}

- (void)removeCameraPropertyDelegate:(id<OLYCameraPropertyDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.cameraPropertyDelegates;
		[delegates removeObject:delegate];
		self.cameraPropertyDelegates = delegates;
	}
}

- (void)addPlaybackDelegate:(id<OLYCameraPlaybackDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.playbackDelegates;
		[delegates addObject:delegate];
		self.playbackDelegates = delegates;
	}
}

- (void)removePlaybackDelegate:(id<OLYCameraPlaybackDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.playbackDelegates;
		[delegates removeObject:delegate];
		self.playbackDelegates = delegates;
	}
}

- (void)addLiveViewDelegate:(id<OLYCameraLiveViewDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.liveViewDelegates;
		[delegates addObject:delegate];
		self.liveViewDelegates = delegates;
	}
}

- (void)removeLiveViewDelegate:(id<OLYCameraLiveViewDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.liveViewDelegates;
		[delegates removeObject:delegate];
		self.liveViewDelegates = delegates;
	}
}

- (void)addRecordingDelegate:(id<OLYCameraRecordingDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.recordingDelegates;
		[delegates addObject:delegate];
		self.recordingDelegates = delegates;
	}
}

- (void)removeRecordingDelegate:(id<OLYCameraRecordingDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.recordingDelegates;
		[delegates removeObject:delegate];
		self.recordingDelegates = delegates;
	}
}

- (void)addRecordingSupportsDelegate:(id<OLYCameraRecordingSupportsDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.recordingSupportsDelegates;
		[delegates addObject:delegate];
		self.recordingSupportsDelegates = delegates;
	}
}

- (void)removeRecordingSupportsDelegate:(id<OLYCameraRecordingSupportsDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);

	@synchronized (self) {
		NSHashTable *delegates = self.recordingSupportsDelegates;
		[delegates removeObject:delegate];
		self.recordingSupportsDelegates = delegates;
	}
}

- (void)addTakingPictureDelegate:(id<AppCameraTakingPictureDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);
	
	@synchronized (self) {
		NSHashTable *delegates = self.takingPictureDelegates;
		[delegates addObject:delegate];
		self.takingPictureDelegates = delegates;
	}
}

- (void)removeTakingPictureDelegate:(id<AppCameraTakingPictureDelegate>)delegate {
	DEBUG_LOG(@"delegate=%@", [delegate description]);
	
	@synchronized (self) {
		NSHashTable *delegates = self.takingPictureDelegates;
		[delegates removeObject:delegate];
		self.takingPictureDelegates = delegates;
	}
}

- (void)lockAutoExposure:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");

	// AEロックはAFロックと異なり同期式なので、AFロックと同様の非同期式APIに拡張します。
	__weak AppCamera *weakSelf = self;
	weakSelf.runningLockingAutoExposure = YES;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		BOOL result = [weakSelf lockAutoExposure:&error];
		dispatch_async(dispatch_get_main_queue(), ^{
			weakSelf.runningLockingAutoExposure = NO;
			if (result) {
				if (completionHandler) {
					completionHandler();
				}
			} else {
				if (errorHandler) {
					errorHandler(error);
				}
			}
		});
	});
}

- (void)camera:(OLYCamera *)camera notifyDidChangeCameraProperty:(NSString *)name sender:(id<OLYCameraPropertyDelegate>)sender {
	DEBUG_LOG(@"");
	
	for (id<OLYCameraPropertyDelegate> delegate in self.cameraPropertyDelegates) {
		if (delegate == sender) {
			continue;
		}
		if ([delegate respondsToSelector:@selector(camera:didChangeCameraProperty:)]) {
			[delegate camera:camera didChangeCameraProperty:name];
		}
	}
}

- (NSString *)cameraPropertyLocalizedTitle:(NSString *)name {
	DEBUG_DETAIL_LOG(@"name=%@", name);

	// プロパティ名が直接ローカライズできるならそれを用います。
	// 直接ローカライズできないなら表示用文言を取得してそれをローカライズします。
	NSString *nameKey = [NSString stringWithFormat:@"<%@>", name];
	NSString *localizedTitle = AppCameraLocalizedString(nameKey);
	if ([localizedTitle isEqualToString:nameKey]) {
		NSString *title = [super cameraPropertyTitle:name];
		localizedTitle = AppCameraLocalizedString(title);
	}
	return localizedTitle;
}

- (NSString *)cameraPropertyValueLocalizedTitle:(NSString *)value {
	DEBUG_DETAIL_LOG(@"value=%@", value);
	
	// プロパティ値が直接ローカライズできるならそれを用います。
	// 直接ローカライズできないなら表示用文言を取得してそれをローカライズします。
	NSString *localizedTitle = AppCameraLocalizedString(value);
	if ([localizedTitle isEqualToString:value]) {
		NSString *title = [super cameraPropertyValueTitle:value];
		localizedTitle = AppCameraLocalizedString(title);
	}
	return localizedTitle;
}

- (NSString *)contentInformationLocalizedTitle:(NSString *)name {
	DEBUG_DETAIL_LOG(@"name=%@", name);

	// コンテンツ情報のキーが直接ローカライズできるならそれを用います。
	// 直接ローカライズできないならキーそのものを表示用文言とします。
	NSString *nameKey = [NSString stringWithFormat:@"[%@]", name];
	NSString *localizedTitle = AppCameraLocalizedString(nameKey);
	if ([localizedTitle isEqualToString:nameKey]) {
		localizedTitle = name;
	}
	return localizedTitle;
}

- (NSString *)contentInformationValueLocalizedTitle:(NSString *)name value:(NSString *)value {
	DEBUG_DETAIL_LOG(@"name=%@, value=%@", name, value);

	// コンテンツ情報の値名が直接ローカライズできるならそれを用います。
	// 直接ローカライズできないなら値そのものを表示用文言とします。
	NSString *valueKey = [NSString stringWithFormat:@"[%@/%@]", name, value];
	NSString *localizedTitle = AppCameraLocalizedString(valueKey);
	if ([localizedTitle isEqualToString:valueKey]) {
		localizedTitle = value;
	}
	return localizedTitle;
}

// 現在位置をNMEA0183形式の設定パラメータに変換します。
- (BOOL)setGeolocationWithCoreLocation:(CLLocation *)location error:(NSError **)error {
	DEBUG_LOG(@"location=%@", location.description);

	// 10進数の緯度経度を60進数の緯度経度に変換します。
	CLLocationDegrees latitude = [self convertCLLocationDegreesToNmea:location.coordinate.latitude];
	CLLocationDegrees longitude = [self convertCLLocationDegreesToNmea:location.coordinate.longitude];
	
	// GPGGAレコード
	NSMutableString *nmea0183GPGGA = [[NSMutableString alloc] init];
	{
		NSDateFormatter *nmea0183GPGGATimestampFormatter = [[NSDateFormatter alloc] init];
		[nmea0183GPGGATimestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[nmea0183GPGGATimestampFormatter setDateFormat:@"HHmmss.SSS"];
		
		[nmea0183GPGGA appendString:@"GPGGA,"];
		[nmea0183GPGGA appendFormat:@"%@,", [nmea0183GPGGATimestampFormatter stringFromDate:location.timestamp]]; // 測位時刻
		[nmea0183GPGGA appendFormat:@"%08.4f,", latitude]; // 緯度
		[nmea0183GPGGA appendFormat:@"%@,", (latitude > 0.0 ? @"N" : @"S")]; // 北緯、南緯
		[nmea0183GPGGA appendFormat:@"%08.4f,", longitude]; // 経度
		[nmea0183GPGGA appendFormat:@"%@,", (longitude > 0.0 ? @"E" : @"W")]; // 東経、西経
		[nmea0183GPGGA appendString:@"1,"]; // 位置特定品質: 単独測位
		[nmea0183GPGGA appendString:@"08,"]; // 受信衛星数: 8?
		[nmea0183GPGGA appendString:@"1.0,"]; // 水平精度低下率: 1.0?
		[nmea0183GPGGA appendFormat:@"%1.1f,", location.altitude]; // アンテナの海抜高さ
		[nmea0183GPGGA appendString:@"M,"]; // アンテナの海抜高さ単位: メートル
		[nmea0183GPGGA appendFormat:@"%1.1f,", location.altitude]; // ジオイド高さ
		[nmea0183GPGGA appendString:@"M,"]; // ジオイド高さ: メートル
		[nmea0183GPGGA appendString:@","]; // DGPSデータの寿命: 不使用
		[nmea0183GPGGA appendString:@","]; // 差動基準地点ID: 不使用
		
		unichar nmea0183GPGGAChecksum = 0;
		for (NSInteger index = 0; index < nmea0183GPGGA.length; index++) {
			nmea0183GPGGAChecksum ^= [nmea0183GPGGA characterAtIndex:index];
		}
		nmea0183GPGGAChecksum &= 0x0ff;
		
		[nmea0183GPGGA insertString:@"$" atIndex:0];
		[nmea0183GPGGA appendString:@"*"];
		[nmea0183GPGGA appendFormat:@"%02lX", (long)nmea0183GPGGAChecksum]; // チェックサム
	}
	DEBUG_DETAIL_LOG(@"nmea0183GPGGA=\"%@\"", nmea0183GPGGA);

	// GPRMCレコード
	NSMutableString *nmea0183GPRMC = [[NSMutableString alloc] init];
	{
		NSDateFormatter *nmea0183GPRMCTimestampFormatter = [[NSDateFormatter alloc] init];
		[nmea0183GPRMCTimestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[nmea0183GPRMCTimestampFormatter setDateFormat:@"HHmmss.SSS"];
		NSDateFormatter *nmea0183GPRMCDateFormatter = [[NSDateFormatter alloc] init];
		[nmea0183GPRMCDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[nmea0183GPRMCDateFormatter setDateFormat:@"ddMMyy"];
		
		[nmea0183GPRMC appendString:@"GPRMC,"];
		[nmea0183GPRMC appendFormat:@"%@,", [nmea0183GPRMCTimestampFormatter stringFromDate:location.timestamp]]; // 測位時刻
		[nmea0183GPRMC appendString:@"A,"]; // ステータス: 有効
		[nmea0183GPRMC appendFormat:@"%08.4f,", latitude]; // 緯度
		[nmea0183GPRMC appendFormat:@"%@,", (latitude > 0.0 ? @"N" : @"S")]; // 北緯、南緯
		[nmea0183GPRMC appendFormat:@"%08.4f,", longitude]; // 経度
		[nmea0183GPRMC appendFormat:@"%@,", (longitude > 0.0 ? @"E" : @"W")]; // 東経、西経
		[nmea0183GPRMC appendFormat:@"%04.1f,", (location.course > 0.0 ? location.speed * 3600.0 / 1000.0 * 0.54 : 0.0)]; // 移動速度(ノット毎時)
		[nmea0183GPRMC appendFormat:@"%04.1f,", (location.course > 0.0 ? location.course : 0.0)]; // 移動方向
		[nmea0183GPRMC appendFormat:@"%@,", [nmea0183GPRMCDateFormatter stringFromDate:location.timestamp]]; // 測位日付
		[nmea0183GPRMC appendString:@","]; // 地磁気の偏角: 不使用
		[nmea0183GPRMC appendString:@","]; // 地磁気の偏角の方向: 不使用
		[nmea0183GPRMC appendString:@"A"]; // モード: 単独測位
		
		unichar nmea0183GPRMCChecksum = 0;
		for (NSInteger index = 0; index < nmea0183GPRMC.length; index++) {
			nmea0183GPRMCChecksum ^= [nmea0183GPRMC characterAtIndex:index];
		}
		nmea0183GPRMCChecksum &= 0x0ff;
		
		[nmea0183GPRMC insertString:@"$" atIndex:0];
		[nmea0183GPRMC appendString:@"*"];
		[nmea0183GPRMC appendFormat:@"%02lX", (long)nmea0183GPRMCChecksum]; // チェックサム
	}
	DEBUG_DETAIL_LOG(@"nmea0183GPRMC=\"%@\"", nmea0183GPRMC);

	// カメラに位置情報を設定します。
	NSString *nmea0183 = [NSString stringWithFormat:@"%@\n%@\n", nmea0183GPGGA, nmea0183GPRMC];
	return [super setGeolocation:nmea0183 error:error];
}

- (NSDictionary *)createSnapshotOfSetting:(NSError **)error {
	DEBUG_LOG(@"");

	// 現在のカメラプロパティの設定値を全て取得します。
	// MARK: プロパティの一覧がNSArrayで取得できてプロパティ値の取得はNSSetで指定しなければならない仕様になっています。
	NSError *internalError = nil;
	NSSet *properties = [NSSet setWithArray:[super cameraPropertyNames]];
	NSDictionary *propertyValues = [super cameraPropertyValues:properties error:&internalError];
	if (!propertyValues) {
		if (error) {
			*error = internalError;
		}
		return nil;
	}
	DEBUG_LOG(@"propertyValues=%@", propertyValues);
	
	// 現在設定されているライブビューのサイズを取得します。
	NSString *liveViewSize = NSStringFromCGSize(self.liveViewSize);
	DEBUG_LOG(@"liveViewSize=%@", liveViewSize);

	// 現在設定されているオートブラケット撮影の設定を取得します。
	NSNumber *autoBracketingMode = @(self.autoBracketingMode);
	NSNumber *autoBracketingCount = @(self.autoBracketingCount);
	NSNumber *autoBracketingStep = @(self.autoBracketingStep);
	DEBUG_LOG(@"autoBracketingMode=%@", autoBracketingMode);
	DEBUG_LOG(@"autoBracketingCount=%@", autoBracketingCount);
	DEBUG_LOG(@"autoBracketingStep=%@", autoBracketingStep);
	
	// 現在設定されているライブビュー拡大倍率を取得します。
	NSNumber *magnifyingLiveViewScale = @(self.magnifyingLiveViewScale);
	DEBUG_LOG(@"magnifyingLiveViewScale=%@", magnifyingLiveViewScale);
	
	// スナップショットにする情報を集約します。
	NSDictionary *snapshot = @{
		CameraSettingSnapshotFormatVersionKey: CameraSettingSnapshotFormatVersion,
		CameraSettingSnapshotPropertyValuesKey: propertyValues,
		CameraSettingSnapshotLiveViewSizeKey: liveViewSize,
		CameraSettingSnapshotAutoBracketingModeKey: autoBracketingMode,
		CameraSettingSnapshotAutoBracketingCountKey: autoBracketingCount,
		CameraSettingSnapshotAutoBracketingStepKey: autoBracketingStep,
		CameraSettingSnapshotMagnifyingLiveViewScaleKey: magnifyingLiveViewScale,
	};
	
	return snapshot;
}

- (BOOL)restoreSnapshotOfSetting:(NSDictionary *)snapshot exclude:(NSArray *)exclude error:(NSError **)error {
	DEBUG_LOG(@"exclude=%@", exclude);

	// スナップショットから復元する情報を取り出します。
	if (!snapshot[CameraSettingSnapshotFormatVersionKey] ||
		![snapshot[CameraSettingSnapshotFormatVersionKey] isEqualToString:CameraSettingSnapshotFormatVersion]) {
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"$desc:CameraSettingSnapshotFormatVersionUnmatched" };
		NSError *internalError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	
	// 一時的にライブビューを止めて表示のチラツキを食い止めます。
	BOOL needToStartLiveView = self.liveViewEnabled;
	if (needToStartLiveView) {
		if (![super stopLiveView:error]) {
			return NO;
		}
	}
	
	// 読み込んだカメラプロパティの設定値をカメラに反映します。
	NSMutableDictionary *propertyValues = [snapshot[CameraSettingSnapshotPropertyValuesKey] mutableCopy];
	if (exclude) {
		// 除外するカメラプロパティが指定されている場合はそれを取り除きます。
		[exclude enumerateObjectsUsingBlock:^(NSString *property, NSUInteger index, BOOL *stop) {
			if (propertyValues[property]) {
				[propertyValues removeObjectForKey:property];
			}
		}];
	}
	if (![self setCameraPropertyValues:propertyValues error:error]) {
		return NO;
	}
	
	// 読み込んだライブビューサイズの設定値をカメラに反映します。
	OLYCameraLiveViewSize liveViewSize = OLYCameraLiveViewSizeQVGA;
	if (snapshot[CameraSettingSnapshotLiveViewSizeKey]) {
		liveViewSize = CGSizeFromString(snapshot[CameraSettingSnapshotLiveViewSizeKey]);
	}
	if (![super changeLiveViewSize:liveViewSize error:error]) {
		return NO;
	}
	
	// 読み込んだオートブラケット撮影を設定します。
	AppCameraAutoBracketingMode autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	if (snapshot[CameraSettingSnapshotAutoBracketingModeKey]) {
		NSInteger modeValue = [snapshot[CameraSettingSnapshotAutoBracketingModeKey] integerValue];
		autoBracketingMode = (AppCameraAutoBracketingMode)modeValue;
	}
	self.autoBracketingMode = autoBracketingMode;
	NSInteger autoBracketingCount = 3;
	if (snapshot[CameraSettingSnapshotAutoBracketingCountKey]) {
		autoBracketingCount = [snapshot[CameraSettingSnapshotAutoBracketingCountKey] integerValue];
	}
	self.autoBracketingCount = autoBracketingCount;
	NSInteger autoBracketingStep = 1;
	if (snapshot[CameraSettingSnapshotAutoBracketingStepKey]) {
		autoBracketingStep = [snapshot[CameraSettingSnapshotAutoBracketingStepKey] integerValue];
	}
	self.autoBracketingStep = autoBracketingStep;
	
	// 読み込んだライブビュー拡大倍率を設定します。
	OLYCameraMagnifyingLiveViewScale magnifyingLiveViewScale = OLYCameraMagnifyingLiveViewScaleX5;
	if (snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey]) {
		NSInteger scaleValue = [snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey] integerValue];
		magnifyingLiveViewScale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
	}
	self.magnifyingLiveViewScale = magnifyingLiveViewScale;
	
	// ライブビューを再開します。
	if (needToStartLiveView) {
		if (![super startLiveView:error]) {
			return NO;
		}
	}
	
	// 復元完了しました。
	return YES;
}

- (AppCameraFocusMode)focusMode:(NSError **)error {
	DEBUG_LOG(@"");

	// 撮影モード別のフォーカスモードを取得します。
	NSString *focusMode = nil;
	OLYCameraActionType actionType = [super actionType];
	switch (actionType) {
		case OLYCameraActionTypeSingle:
			// 静止画を単写で撮影
			// 次へ
		case OLYCameraActionTypeSequential:
			// 静止画を連写で撮影
			focusMode = [super cameraPropertyValue:CameraPropertyFocusStill error:error];
			break;
		case OLYCameraActionTypeMovie:
			// 動画を撮影
			focusMode = [super cameraPropertyValue:CameraPropertyFocusMovie error:error];
			break;
		default:
			break;
	}
	
	// 取得したフォーカスモードから統合的なフォーカスモードに変換します。
	if (!focusMode) {
		return AppCameraFocusModeUnknown;
	} else if ([focusMode isEqualToString:CameraPropertyFocusStillMf] ||
			   [focusMode isEqualToString:CameraPropertyFocusMovieMf]) {
		// マニュアルフォーカス
		return AppCameraFocusModeMF;
	} else if ([focusMode isEqualToString:CameraPropertyFocusStillSaf] ||
			   [focusMode isEqualToString:CameraPropertyFocusMovieSaf]) {
		// シングルオートフォーカス
		return AppCameraFocusModeSAF;
	} else if ([focusMode isEqualToString:CameraPropertyFocusMovieCaf]) {
		// コンティニュアスオートフォーカス
		return AppCameraFocusModeCAF;
	} else {
		// ありえません。
		return AppCameraFocusModeUnknown;
	}
}

- (AppCameraActionStatus)cameraActionStatus {
	DEBUG_LOG(@"");
	
	// 撮影タイプ別に検査します。
	switch ([self cameraActionType]) {
		case AppCameraActionTypeTakingPictureSingle:
			// 静止画を単写で撮影中
			if (self.takingPicture) {
				return AppCameraActionStatusTakingPictureSingle;
			}
			break;
		case AppCameraActionTypeTakingPictureSequential:
			// 静止画を連写で撮影中
			if (self.takingPicture) {
				return AppCameraActionStatusTakingPictureSequential;
			}
			break;
		case AppCameraActionTypeTakingPictureAutoBracketing:
			// 静止画をオートブラケットで撮影中
			if (self.runningAutoBracketing) {
				return AppCameraActionStatusTakingPictureAutoBracketing;
			}
			break;
		case AppCameraActionTypeRecordingVideo:
			// 動画を撮影中
			if (self.recordingVideo) {
				return AppCameraActionStatusRecordingVideo;
			}
			break;
		case OLYCameraActionTypeUnknown:
		default:
			// ありえません。
			break;
	}
	
	// 撮影していません。
	return AppCameraActionStatusReady;
}

- (AppCameraActionType)cameraActionType {
	DEBUG_LOG(@"");
	
	// 撮影モード/ドライブモードの種別を検査します。
	switch ([super actionType]) {
		case OLYCameraActionTypeSingle:
			// 静止画を単写で撮影
			// 次の検査へ
			break;
		case OLYCameraActionTypeSequential:
			// 静止画を連写で撮影
			return AppCameraActionTypeTakingPictureSequential;
		case OLYCameraActionTypeMovie:
			// 動画を撮影
			return AppCameraActionTypeRecordingVideo;
		case OLYCameraActionTypeUnknown:
		default:
			// ありえません。
			return AppCameraActionTypeUnknown;
	}

	// オートブラケット撮影が有効かを検査します。
	NSError *error = nil;
	NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
	if (![takemode isEqualToString:CameraPropertyTakemodeP] &&
		![takemode isEqualToString:CameraPropertyTakemodeA] &&
		![takemode isEqualToString:CameraPropertyTakemodeS] &&
		![takemode isEqualToString:CameraPropertyTakemodeM]) {
		// これらの撮影モード以外ではオートブラケット撮影はできません。
		return AppCameraActionTypeTakingPictureSingle;
	}
	if (self.autoBracketingMode == AppCameraAutoBracketingModeDisabled) {
		// 無効になっている場合はオートブラケット撮影はできません。
		return AppCameraActionTypeTakingPictureSingle;
	}
	return AppCameraActionTypeTakingPictureAutoBracketing;
}

- (BOOL)canSetAutoBracketing {
	DEBUG_LOG(@"");

	// 撮影モード/ドライブモードの種別を検査します。
	switch ([super actionType]) {
		case OLYCameraActionTypeSingle:
			// 静止画を単写で撮影
			// 次の検査へ
			break;
		case OLYCameraActionTypeSequential:
			// 静止画を連写で撮影
			return NO;
		case OLYCameraActionTypeMovie:
			// 動画を撮影
			return NO;
		case OLYCameraActionTypeUnknown:
		default:
			// ありえません。
			return NO;
	}
	
	// オートブラケット撮影が有効かを検査します。
	NSError *error = nil;
	NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
	if (![takemode isEqualToString:CameraPropertyTakemodeP] &&
		![takemode isEqualToString:CameraPropertyTakemodeA] &&
		![takemode isEqualToString:CameraPropertyTakemodeS] &&
		![takemode isEqualToString:CameraPropertyTakemodeM]) {
		// これらの撮影モード以外ではオートブラケット撮影はできません。
		return NO;
	}
	return YES;
}

- (void)startTakingPictureByAutoBracketing:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress, NSDictionary *))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");

	// オートブラケット撮影の設定が妥当かを検査します。
	if ([self cameraActionType] != AppCameraActionTypeTakingPictureAutoBracketing) {
		// オートブラケット撮影は無効です。
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"auto bracketting is not available." };
		NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
		errorHandler(error);
		return;
	}
	if (self.autoBracketingCount <  3 ||
		self.autoBracketingCount >  9 ||
		(self.autoBracketingCount % 2) == 0) {
		// 撮影枚数は3以上の奇数でなければなりません。
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"auto bracketting count is incorrect." };
		NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
		errorHandler(error);
		return;
	}
	if (self.autoBracketingStep < 1 ||		// 1 step = 0.3EV
		self.autoBracketingStep > 9) {		// 9 step = 3.0EV
		// カメラプロパティ値を変更するステップ数は1以上でなければなりません。
		NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"auto bracketting step is incorrect." };
		NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
		errorHandler(error);
		return;
	}

	// オートブラケット撮影の状態管理を初期化します。
	__weak AppCamera *weakSelf = self;
	weakSelf.runningAutoBracketing = YES;
	weakSelf.abortAutoBracketing = NO;
	weakSelf.abortedAutoBracketing = NO;
	
	/// メインスレッド以外で非同期に処理ブロックを実行します。
	dispatch_async(weakSelf.takingPictureRunnerQueue, ^{

		// オートブラケットで変更するカメラプロパティ値のリストを作成します。
		NSString *autoBracketingProperty = nil;
		NSMutableArray *autoBracketingPropertyValues = nil;
		NSString *currentPropertyValue = nil;
		if (weakSelf.autoBracketingMode == AppCameraAutoBracketingModeExposure) {
			// オートブラケットするプロパティを撮影モードから決定します。
			NSError *error = nil;
			NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
			if ([takemode isEqualToString:CameraPropertyTakemodeP] ||
				[takemode isEqualToString:CameraPropertyTakemodeA] ||
				[takemode isEqualToString:CameraPropertyTakemodeS]) {
				// 露出補正値
				autoBracketingProperty = CameraPropertyExprev;
			} else if ([takemode isEqualToString:CameraPropertyTakemodeM]) {
				// シャッター速度
				autoBracketingProperty = CameraPropertyShutter;
			} else {
				// 未対応
				weakSelf.runningAutoBracketing = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
			// ブラケット撮影の基本にする現在のプロパティ値を取得します。
			currentPropertyValue = [super cameraPropertyValue:autoBracketingProperty error:&error];
			if (!currentPropertyValue) {
				weakSelf.runningAutoBracketing = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
			// オートブラケットするプロパティの設定可能値リストを取得します。
			NSArray *valueList = [super cameraPropertyValueList:autoBracketingProperty error:&error];
			if (!valueList) {
				weakSelf.runningAutoBracketing = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
			if (![autoBracketingProperty isEqualToString:CameraPropertyExprev]) {
				// 露出補正値以外は値がプラス露出とマイナス露出が逆に並んでいるので補正します。
				valueList = [[valueList reverseObjectEnumerator] allObjects];
			}
			// オートブラケットで使用するプロパティ値を拾い集めます。
			NSInteger currentIndex = [valueList indexOfObject:currentPropertyValue];
			NSInteger minimumIndex = currentIndex - weakSelf.autoBracketingStep * ((weakSelf.autoBracketingCount - 1) / 2);
			NSInteger maximumIndex = currentIndex + weakSelf.autoBracketingStep * ((weakSelf.autoBracketingCount - 1) / 2);
			autoBracketingPropertyValues = [[NSMutableArray alloc] init];
			for (NSInteger index = minimumIndex; index <= maximumIndex; index += weakSelf.autoBracketingStep) {
				// 値のインデックスがプロパティ値リストの範囲に収まるように補正します。
				NSInteger correctedIndex = index;
				if (correctedIndex < 0) {
					correctedIndex = 0;
				}
				if (correctedIndex > valueList.count - 1) {
					correctedIndex = valueList.count - 1;
				}
				// 値をオートブラケットで変更するカメラプロパティ値のリストに付け加えます。
				NSString *value = valueList[correctedIndex];
				[autoBracketingPropertyValues addObject:value];
			}
		} else {
			// ありえません。
			assert(NO);
			return;
		}
		DEBUG_LOG(@"autoBracketingProperty=%@", autoBracketingProperty);
		DEBUG_LOG(@"autoBracketingPropertyValues=%@", autoBracketingPropertyValues);
	
		// 現在の自動測光ロックとフォーカスロック状態状態を取得します。
		NSError *error = nil;
		NSString *aeLockState = [super cameraPropertyValue:CameraPropertyAeLockState error:&error];
		if (!aeLockState) {
			weakSelf.runningAutoBracketing = NO;
			dispatch_async(dispatch_get_main_queue(), ^{
				errorHandler(error);
			});
			return;
		}
		NSString *afLockState = [super cameraPropertyValue:CameraPropertyAfLockState error:&error];
		if (!afLockState) {
			weakSelf.runningAutoBracketing = NO;
			dispatch_async(dispatch_get_main_queue(), ^{
				errorHandler(error);
			});
			return;
		}
		
		// 自動測光ロックをしていない場合は、複数枚撮影中に露出が揺れないようにロックします。
		if ([aeLockState isEqualToString:CameraPropertyAeLockStateUnlock]) {
			if (![super lockAutoExposure:&error]) {
				weakSelf.runningAutoBracketing = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
		}
		// フォーカスロックしていない場合は、複数枚撮影中にピント位置が揺れないようにロックします。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			// オートフォーカスを開始しました。
			dispatch_async(dispatch_get_main_queue(), ^{
				progressHandler(OLYCameraTakingProgressBeginFocusing, nil);
			});
			
			// オートフォーカスをロックします。
			__block BOOL lockingCompleted = NO;
			__block BOOL lockingFailed = NO;
			[self lockAutoFocus:^(NSDictionary *info) {
				// オートフォーカスを終了しました。
				dispatch_async(dispatch_get_main_queue(), ^{
					progressHandler(OLYCameraTakingProgressEndFocusing, info);
				});
				lockingCompleted = YES;
			} errorHandler:^(NSError *error) {
				weakSelf.runningAutoBracketing = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				lockingFailed = YES;
			}];
			
			// オートフォーカスのロックが完了するのを待ちます。
			while (!lockingCompleted && !lockingFailed) {
				[NSThread sleepForTimeInterval:0.1];
			}
			if (lockingFailed) {
				// オートフォーカスのロックに失敗したようです。
				return;
			}
		}
	
		// オートブラケット撮影を開始します。
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *info = @{
				@"autoBracketingProperty": autoBracketingProperty,
				@"autoBracketingPropertyValues": autoBracketingPropertyValues,
			};
			completionHandler(info);
		});
		dispatch_async(dispatch_get_main_queue(), ^{
			for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
				if ([delegate respondsToSelector:@selector(cameraDidStartTakingPictureByAutoBracketing:)]) {
					[delegate cameraDidStartTakingPictureByAutoBracketing:weakSelf];
				}
			}
		});
		__block NSError *takingError = nil;
		for (NSInteger index = 0; index < autoBracketingPropertyValues.count; index++) {
			NSString *propertyValue = autoBracketingPropertyValues[index];
			DEBUG_LOG(@"start taking a picture: %@", propertyValue);

			// 中止を要求されているか確認します。
			if (weakSelf.abortAutoBracketing) {
				DEBUG_LOG(@"ABORT!");
				weakSelf.abortedAutoBracketing = YES;
				break;
			}
			
			// オートブラケットで変更するカメラプロパティ値を設定します。
			if (![super setCameraPropertyValue:autoBracketingProperty value:propertyValue error:&error]) {
				takingError = error;
				break;
			}
			// 設定した値が実際に適用されたかを確認します。
			NSTimeInterval timeout;
			if (weakSelf.connectionType == OLYCameraConnectionTypeWiFi) {
				timeout = 3.0;
			} else if (weakSelf.connectionType == OLYCameraConnectionTypeBluetoothLE) {
				timeout = 5.0; // MARK: Bluetoothだとかなり遅れて設定されるようです。
			} else {
				// 異常事態が発生している場合は撮影は中止です。
				NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera is not connected." };
				takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorNotConnected userInfo:userInfo];
				break;
			}
			if ([autoBracketingProperty isEqualToString:CameraPropertyExprev]) {
				// 露出補正値
				NSDate *startTime = [NSDate date];
				while (![weakSelf.actualExposureCompensation isEqualToString:propertyValue]) {
					if ([[NSDate date] timeIntervalSinceDate:startTime] > timeout) {
						// 設定がある程度の時間内に適用されない場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera could not change a value of property." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorCameraBusy userInfo:userInfo];
						break;
					}
					if (weakSelf.runMode == OLYCameraRunModeRecording) {
						[NSThread sleepForTimeInterval:0.1];
					} else {
						// 異常事態が発生している場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera is not recording mode." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
						break;
					}
				}
			} else if ([autoBracketingProperty isEqualToString:CameraPropertyShutter]) {
				// シャッター速度
				NSDate *startTime = [NSDate date];
				while (![weakSelf.actualShutterSpeed isEqualToString:propertyValue]) {
					if ([[NSDate date] timeIntervalSinceDate:startTime] > timeout) {
						// 設定がある程度の時間内に適用されない場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera could not change a value of property." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorCameraBusy userInfo:userInfo];
						break;
					}
					if (weakSelf.runMode == OLYCameraRunModeRecording) {
						[NSThread sleepForTimeInterval:0.1];
					} else {
						// 異常事態が発生している場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera is not recording mode." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
						break;
					}
				}
			} else {
				// ありえません。
				assert(NO);
			}
			if (takingError) {
				// 設定に失敗したようです。
				break;
			}
			
			// 写真撮影します。
			dispatch_async(dispatch_get_main_queue(), ^{
				for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
					if ([delegate respondsToSelector:@selector(cameraWillTakePictureByAutoBracketing:current:)]) {
						[delegate cameraWillTakePictureByAutoBracketing:weakSelf current:index];
					}
				}
			});
			__block BOOL takingCompleted = NO;
			__block BOOL takingFailed = NO;
			[super takePicture:options progressHandler:^(OLYCameraTakingProgress progress, NSDictionary *info) {
				// 進捗情報はすべて無視します。
			} completionHandler:^(NSDictionary *info) {
				takingCompleted = YES;
			} errorHandler:^(NSError *error) {
				takingError = error;
				takingFailed = YES;
			}];
			
			// 写真撮影が完了するのを待ちます。
			while (!takingCompleted && !takingFailed) {
				[NSThread sleepForTimeInterval:0.1];
			}
			if (takingFailed) {
				// 写真撮影に失敗したようです。
				break;
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
					if ([delegate respondsToSelector:@selector(cameraDidTakePictureByAutoBracketing:current:)]) {
						[delegate cameraDidTakePictureByAutoBracketing:weakSelf current:index];
					}
				}
			});

			// メディアへの書き込みが終わるまで待ちます。
			// MARK: これがないと次のカメラプロパティ設定がエラーになる場合があります。
			if (weakSelf.connectionType == OLYCameraConnectionTypeWiFi) {
				// MARK: Wi-Fiの場合はメディア書き込み中を示すプロパティで完了を確認できます。
				while (weakSelf.mediaBusy) {
					if (weakSelf.runMode == OLYCameraRunModeRecording) {
						[NSThread sleepForTimeInterval:0.1];
					} else {
						// 異常事態が発生している場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera is not recording mode." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
						break;
					}
				}
				
			} else if (weakSelf.connectionType == OLYCameraConnectionTypeBluetoothLE) {
				// Bluetoothの場合はメディア書き込み中を示すプロパティで完了を確認できないので少し待ちます。
				NSTimeInterval timeout = 3.0;
				NSDate *startTime = [NSDate date];
				while ([[NSDate date] timeIntervalSinceDate:startTime] < timeout) {
					if (weakSelf.runMode == OLYCameraRunModeRecording) {
						[NSThread sleepForTimeInterval:0.1];
					} else {
						// 異常事態が発生している場合は撮影は中止です。
						NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"camera is not recording mode." };
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
						break;
					}
				}
			}
			if (takingError) {
				// 待ち合わせに失敗したようです。
				break;
			}
			
			// ここで一枚撮影完了です。
			DEBUG_LOG(@"finish taking a picture: %@", propertyValue);
		}

		// ブラケット撮影の基本にしたプロパティ値に戻します。
		if (![super setCameraPropertyValue:autoBracketingProperty value:currentPropertyValue error:&error]) {
			// エラーを無視して続行します。
			if (!takingError) {
				takingError = error;
			}
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// この処理でフォーカスをロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyAfLockStateUnlock]) {
			if (![self unlockAutoFocus:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		// この処理で自動測光をロックした場合はそのロックを解除します。
		if ([aeLockState isEqualToString:CameraPropertyAeLockStateUnlock]) {
			if (![super unlockAutoExposure:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// 完了です。
		weakSelf.runningAutoBracketing = NO;
		weakSelf.abortAutoBracketing = NO;
		weakSelf.abortedAutoBracketing = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
				if ([delegate respondsToSelector:@selector(cameraDidStopTakingPictureByAutoBracketing:error:)]) {
					[delegate cameraDidStopTakingPictureByAutoBracketing:weakSelf error:takingError];
				}
			}
		});
	});
}

- (void)stopTakingPictureByAutoBracketing:(void (^)(NSDictionary *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");
	
	/// メインスレッド以外で非同期に処理ブロックを実行します。
	__weak AppCamera *weakSelf = self;
	dispatch_async(weakSelf.takingPictureStopperQueue, ^{
		// オートブラケット撮影を中止します。
		weakSelf.abortAutoBracketing = YES;
		
		// オートブラケット撮影の実行が完了するのを待ちます。
		while (weakSelf.runningAutoBracketing &&
			   weakSelf.abortAutoBracketing &&
			   !weakSelf.abortedAutoBracketing) {
			[NSThread sleepForTimeInterval:0.1];
		}
		
		// 完了です。
		// 実はエラーは発生しません。
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler(nil);
		});
	});
}

- (BOOL)startMagnifyingLiveView:(NSError **)error {
	DEBUG_LOG(@"");
	
	return [super startMagnifyingLiveView:self.magnifyingLiveViewScale error:error];
}

- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point error:(NSError **)error {
	DEBUG_LOG(@"point=%@", NSStringFromCGPoint(point));
	
	return [super startMagnifyingLiveViewAtPoint:point scale:self.magnifyingLiveViewScale error:error];
}

#pragma mark -

/// CoreLocationで用いられる10進数の緯度経度を、NMEA0183形式で用いられる60進数の緯度経度に変換します。
- (double)convertCLLocationDegreesToNmea:(CLLocationDegrees)degrees {
	DEBUG_DETAIL_LOG(@"degrees=%lf", degrees);
	
	// MARK: 単位を度分(度分秒ではない)にします。
	double degreeSign = ((degrees > 0.0) ? +1 : ((degrees < 0.0) ? -1 : 0));
	double degree = ABS(degrees);
	double degreeDecimal = floor(degree);
	double degreeFraction = degree - degreeDecimal;
	double minutes = degreeFraction * 60.0;
	double nmea = degreeSign * (degreeDecimal * 100.0 + minutes);
	
	DEBUG_DETAIL_LOG(@"nmea=%lf", nmea);
	return nmea;
}

@end
