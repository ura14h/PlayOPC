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
NSString *const CameraPropertyValueAeAeCenter = @"<AE/AE_CENTER>";
NSString *const CameraPropertyValueAeAeEsp = @"<AE/AE_ESP>";
NSString *const CameraPropertyValueAeAePinpoint = @"<AE/AE_PINPOINT>";
NSString *const CameraPropertyTakemode = @"TAKEMODE";
NSString *const CameraPropertyValueTakemodeIAuto = @"<TAKEMODE/iAuto>";
NSString *const CameraPropertyValueTakemodeP = @"<TAKEMODE/P>";
NSString *const CameraPropertyValueTakemodeA = @"<TAKEMODE/A>";
NSString *const CameraPropertyValueTakemodeS = @"<TAKEMODE/S>";
NSString *const CameraPropertyValueTakemodeM = @"<TAKEMODE/M>";
NSString *const CameraPropertyValueTakemodeArt = @"<TAKEMODE/ART>";
NSString *const CameraPropertyValueTakemodeMovie = @"<TAKEMODE/movie>";
NSString *const CameraPropertyIso = @"ISO";
NSString *const CameraPropertyExprev = @"EXPREV";
NSString *const CameraPropertyTakeDrive = @"TAKE_DRIVE";
NSString *const CameraPropertyValueTakeDriveDriveNormal = @"<TAKE_DRIVE/DRIVE_NORMAL>";
NSString *const CameraPropertyValueTakeDriveDriveContinue = @"<TAKE_DRIVE/DRIVE_CONTINUE>";
NSString *const CameraPropertyAspectRatio = @"ASPECT_RATIO";
NSString *const CameraPropertyValueAspectRatio0403 = @"<ASPECT_RATIO/04_03>";
NSString *const CameraPropertyValueAspectRatio0302 = @"<ASPECT_RATIO/03_02>";
NSString *const CameraPropertyValueAspectRatio1609 = @"<ASPECT_RATIO/16_09>";
NSString *const CameraPropertyValueAspectRatio0304 = @"<ASPECT_RATIO/03_04>";
NSString *const CameraPropertyValueAspectRatio0606 = @"<ASPECT_RATIO/06_06>";
NSString *const CameraPropertyShutter = @"SHUTTER";
NSString *const CameraPropertyContinuousShootingVelocity = @"CONTINUOUS_SHOOTING_VELOCITY";
NSString *const CameraPropertyExposeMovieSelect = @"EXPOSE_MOVIE_SELECT";
NSString *const CameraPropertyValueExposeMovieSelectP = @"<EXPOSE_MOVIE_SELECT/P>";
NSString *const CameraPropertyValueExposeMovieSelectA = @"<EXPOSE_MOVIE_SELECT/A>";
NSString *const CameraPropertyValueExposeMovieSelectS = @"<EXPOSE_MOVIE_SELECT/S>";
NSString *const CameraPropertyValueExposeMovieSelectM = @"<EXPOSE_MOVIE_SELECT/M>";
NSString *const CameraPropertyAeLockState = @"AE_LOCK_STATE";
NSString *const CameraPropertyValueAeLockStateLock = @"<AE_LOCK_STATE/LOCK>";
NSString *const CameraPropertyValueAeLockStateUnlock = @"<AE_LOCK_STATE/UNLOCK>";
NSString *const CameraPropertyImagesize = @"IMAGESIZE";
NSString *const CameraPropertyRaw = @"RAW";
NSString *const CameraPropertyCompressibilityRatio = @"COMPRESSIBILITY_RATIO";
NSString *const CameraPropertyQualityMovie = @"QUALITY_MOVIE";
NSString *const CameraPropertyValueQualityMovieShortMovie = @"<QUALITY_MOVIE/QUALITY_MOVIE_SHORT_MOVIE>";
NSString *const CameraPropertyDestinationFile = @"DESTINATION_FILE";
NSString *const CameraPropertyQualityMovieShortMovieRecordTime = @"QUALITY_MOVIE_SHORT_MOVIE_RECORD_TIME";
NSString *const CameraPropertyFocusStill = @"FOCUS_STILL";
NSString *const CameraPropertyValueFocusStillMf = @"<FOCUS_STILL/FOCUS_MF>";
NSString *const CameraPropertyValueFocusStillSaf = @"<FOCUS_STILL/FOCUS_SAF>";
NSString *const CameraPropertyAfLockState = @"AF_LOCK_STATE";
NSString *const CameraPropertyValueAfLockStateLock = @"<AF_LOCK_STATE/LOCK>";
NSString *const CameraPropertyValueAfLockStateUnlock = @"<AF_LOCK_STATE/UNLOCK>";
NSString *const CameraPropertyFocusMovie = @"FOCUS_MOVIE";
NSString *const CameraPropertyValueFocusMovieMf = @"<FOCUS_MOVIE/FOCUS_MF>";
NSString *const CameraPropertyValueFocusMovieSaf = @"<FOCUS_MOVIE/FOCUS_SAF>";
NSString *const CameraPropertyValueFocusMovieCaf = @"<FOCUS_MOVIE/FOCUS_CAF>";
NSString *const CameraPropertyFullTimeAf = @"FULL_TIME_AF";
NSString *const CameraPropertyBatteryLevel = @"BATTERY_LEVEL";
NSString *const CameraPropertyFaceScan = @"FACE_SCAN";
NSString *const CameraPropertyAntiShakeFocalLength = @"ANTI_SHAKE_FOCAL_LENGTH";
NSString *const CameraPropertyRecview = @"RECVIEW";
NSString *const CameraPropertyValueRecviewOn = @"<RECVIEW/ON>";
NSString *const CameraPropertyValueRecviewOff = @"<RECVIEW/OFF>";
NSString *const CameraPropertyAntiShakeMovie = @"ANTI_SHAKE_MOVIE";
NSString *const CameraPropertySoundVolumeLevel = @"SOUND_VOLUME_LEVEL";
NSString *const CameraPropertyGps = @"GPS";
NSString *const CameraPropertyWifiCh = @"WIFI_CH";
NSString *const CameraPropertyRecentlyArtFilter = @"RECENTLY_ART_FILTER";
NSString *const CameraPropertyValueRecentlyArtFilterPopart = @"<RECENTLY_ART_FILTER/POPART>";
NSString *const CameraPropertyValueRecentlyArtFilterFantasicFocus = @"<RECENTLY_ART_FILTER/FANTASIC_FOCUS>";
NSString *const CameraPropertyValueRecentlyArtFilterDaydream = @"<RECENTLY_ART_FILTER/DAYDREAM>";
NSString *const CameraPropertyValueRecentlyArtFilterLightTone = @"<RECENTLY_ART_FILTER/LIGHT_TONE>";
NSString *const CameraPropertyValueRecentlyArtFilterRoughMonochrome = @"<RECENTLY_ART_FILTER/ROUGH_MONOCHROME>";
NSString *const CameraPropertyValueRecentlyArtFilterToyPhoto = @"<RECENTLY_ART_FILTER/TOY_PHOTO>";
NSString *const CameraPropertyValueRecentlyArtFilterMiniature = @"<RECENTLY_ART_FILTER/MINIATURE>";
NSString *const CameraPropertyValueRecentlyArtFilterCrossProcess = @"<RECENTLY_ART_FILTER/CROSS_PROCESS>";
NSString *const CameraPropertyValueRecentlyArtFilterGentleSepia = @"<RECENTLY_ART_FILTER/GENTLE_SEPIA>";
NSString *const CameraPropertyValueRecentlyArtFilterDramaticTone = @"<RECENTLY_ART_FILTER/DRAMATIC_TONE>";
NSString *const CameraPropertyValueRecentlyArtFilterLigneClair = @"<RECENTLY_ART_FILTER/LIGNE_CLAIR>";
NSString *const CameraPropertyValueRecentlyArtFilterPastel = @"<RECENTLY_ART_FILTER/PASTEL>";
NSString *const CameraPropertyValueRecentlyArtFilterVintage = @"<RECENTLY_ART_FILTER/VINTAGE>";
NSString *const CameraPropertyValueRecentlyArtFilterPartcolor = @"<RECENTLY_ART_FILTER/PARTCOLOR>";
NSString *const CameraPropertyValueRecentlyArtFilterArtBkt = @"<RECENTLY_ART_FILTER/ART_BKT>";
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
NSString *const CameraPropertyValueBracketPictPopartOn = @"<BRACKET_PICT_POPART/ON>";
NSString *const CameraPropertyValueBracketPictPopartOff = @"<BRACKET_PICT_POPART/OFF>";
NSString *const CameraPropertyBracketPictFantasicFocus = @"BRACKET_PICT_FANTASIC_FOCUS";
NSString *const CameraPropertyValueBracketPictFantasicFocusOn = @"<BRACKET_PICT_FANTASIC_FOCUS/ON>";
NSString *const CameraPropertyValueBracketPictFantasicFocusOff = @"<BRACKET_PICT_FANTASIC_FOCUS/OFF>";
NSString *const CameraPropertyBracketPictDaydream = @"BRACKET_PICT_DAYDREAM";
NSString *const CameraPropertyValueBracketPictDaydreamOn = @"<BRACKET_PICT_DAYDREAM/ON>";
NSString *const CameraPropertyValueBracketPictDaydreamOff = @"<BRACKET_PICT_DAYDREAM/OFF>";
NSString *const CameraPropertyBracketPictLightTone = @"BRACKET_PICT_LIGHT_TONE";
NSString *const CameraPropertyValueBracketPictLightToneOn = @"<BRACKET_PICT_LIGHT_TONE/ON>";
NSString *const CameraPropertyValueBracketPictLightToneOff = @"<BRACKET_PICT_LIGHT_TONE/OFF>";
NSString *const CameraPropertyBracketPictRoughMonochrome = @"BRACKET_PICT_ROUGH_MONOCHROME";
NSString *const CameraPropertyValueBracketPictRoughMonochromeOn = @"<BRACKET_PICT_ROUGH_MONOCHROME/ON>";
NSString *const CameraPropertyValueBracketPictRoughMonochromeOff = @"<BRACKET_PICT_ROUGH_MONOCHROME/OFF>";
NSString *const CameraPropertyBracketPictToyPhoto = @"BRACKET_PICT_TOY_PHOTO";
NSString *const CameraPropertyValueBracketPictToyPhotoOn = @"<BRACKET_PICT_TOY_PHOTO/ON>";
NSString *const CameraPropertyValueBracketPictToyPhotoOff = @"<BRACKET_PICT_TOY_PHOTO/OFF>";
NSString *const CameraPropertyBracketPictMiniature = @"BRACKET_PICT_MINIATURE";
NSString *const CameraPropertyValueBracketPictMiniatureOn = @"<BRACKET_PICT_MINIATURE/ON>";
NSString *const CameraPropertyValueBracketPictMiniatureOff = @"<BRACKET_PICT_MINIATURE/OFF>";
NSString *const CameraPropertyBracketPictCrossProcess = @"BRACKET_PICT_CROSS_PROCESS";
NSString *const CameraPropertyValueBracketPictCrossProcessOn = @"<BRACKET_PICT_CROSS_PROCESS/ON>";
NSString *const CameraPropertyValueBracketPictCrossProcessOff = @"<BRACKET_PICT_CROSS_PROCESS/OFF>";
NSString *const CameraPropertyBracketPictGentleSepia = @"BRACKET_PICT_GENTLE_SEPIA";
NSString *const CameraPropertyValueBracketPictGentleSepiaOn = @"<BRACKET_PICT_GENTLE_SEPIA/ON>";
NSString *const CameraPropertyValueBracketPictGentleSepiaOff = @"<BRACKET_PICT_GENTLE_SEPIA/OFF>";
NSString *const CameraPropertyBracketPictDramaticTone = @"BRACKET_PICT_DRAMATIC_TONE";
NSString *const CameraPropertyValueBracketPictDramaticToneOn = @"<BRACKET_PICT_DRAMATIC_TONE/ON>";
NSString *const CameraPropertyValueBracketPictDramaticToneOff = @"<BRACKET_PICT_DRAMATIC_TONE/OFF>";
NSString *const CameraPropertyBracketPictLigneClair = @"BRACKET_PICT_LIGNE_CLAIR";
NSString *const CameraPropertyValueBracketPictLigneClairOn = @"<BRACKET_PICT_LIGNE_CLAIR/ON>";
NSString *const CameraPropertyValueBracketPictLigneClairOff = @"<BRACKET_PICT_LIGNE_CLAIR/OFF>";
NSString *const CameraPropertyBracketPictPastel = @"BRACKET_PICT_PASTEL";
NSString *const CameraPropertyValueBracketPictPastelOn = @"<BRACKET_PICT_PASTEL/ON>";
NSString *const CameraPropertyValueBracketPictPastelOff = @"<BRACKET_PICT_PASTEL/OFF>";
NSString *const CameraPropertyBracketPictVintage = @"BRACKET_PICT_VINTAGE";
NSString *const CameraPropertyValueBracketPictVintageOn = @"<BRACKET_PICT_VINTAGE/ON>";
NSString *const CameraPropertyValueBracketPictVintageOff = @"<BRACKET_PICT_VINTAGE/OFF>";
NSString *const CameraPropertyBracketPictPartcolor = @"BRACKET_PICT_PARTCOLOR";
NSString *const CameraPropertyValueBracketPictPartcolorOn = @"<BRACKET_PICT_PARTCOLOR/ON>";
NSString *const CameraPropertyValueBracketPictPartcolorOff = @"<BRACKET_PICT_PARTCOLOR/OFF>";
NSString *const CameraPropertyColortone = @"COLORTONE";
NSString *const CameraPropertyValueColortoneFlat = @"<COLORTONE/FLAT>";
NSString *const CameraPropertyValueColortoneNatural = @"<COLORTONE/NATURAL>";
NSString *const CameraPropertyValueColortoneMonotone = @"<COLORTONE/Monotone>";
NSString *const CameraPropertyValueColortonePortrait = @"<COLORTONE/Portrait>";
NSString *const CameraPropertyValueColortoneIFinish = @"<COLORTONE/I_FINISH>";
NSString *const CameraPropertyValueColortoneVivid = @"<COLORTONE/VIVID>";
NSString *const CameraPropertyValueColortoneEportrait = @"<COLORTONE/ePortrait>";
NSString *const CameraPropertyValueColortoneColorCreator = @"<COLORTONE/COLOR_CREATOR>";
NSString *const CameraPropertyValueColortonePopart = @"<COLORTONE/POPART>";
NSString *const CameraPropertyValueColortoneFantasicFocus = @"<COLORTONE/FANTASIC_FOCUS>";
NSString *const CameraPropertyValueColortoneDaydream = @"<COLORTONE/DAYDREAM>";
NSString *const CameraPropertyValueColortoneLightTone = @"<COLORTONE/LIGHT_TONE>";
NSString *const CameraPropertyValueColortoneRoughMonochrome = @"<COLORTONE/ROUGH_MONOCHROME>";
NSString *const CameraPropertyValueColortoneToyPhoto = @"<COLORTONE/TOY_PHOTO>";
NSString *const CameraPropertyValueColortoneMiniature = @"<COLORTONE/MINIATURE>";
NSString *const CameraPropertyValueColortoneCrossProcess = @"<COLORTONE/CROSS_PROCESS>";
NSString *const CameraPropertyValueColortoneGentleSepia = @"<COLORTONE/GENTLE_SEPIA>";
NSString *const CameraPropertyValueColortoneDramaticTone = @"<COLORTONE/DRAMATIC_TONE>";
NSString *const CameraPropertyValueColortoneLigneClair = @"<COLORTONE/LIGNE_CLAIR>";
NSString *const CameraPropertyValueColortonePastel = @"<COLORTONE/PASTEL>";
NSString *const CameraPropertyValueColortoneVintage = @"<COLORTONE/VINTAGE>";
NSString *const CameraPropertyValueColortonePartcolor = @"<COLORTONE/PARTCOLOR>";
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
NSString *const CameraPropertyValueWbWbAuto = @"<WB/WB_AUTO>";
NSString *const CameraPropertyValueWbMwbFine = @"<WB/MWB_FINE>";
NSString *const CameraPropertyValueWbMwbShade = @"<WB/MWB_SHADE>";
NSString *const CameraPropertyValueWbMwbCloud = @"<WB/MWB_CLOUD>";
NSString *const CameraPropertyValueWbMwbLamp = @"<WB/MWB_LAMP>";
NSString *const CameraPropertyValueWbMwbFluorescence1 = @"<WB/MWB_FLUORESCENCE1>";
NSString *const CameraPropertyValueWbMwbWater1 = @"<WB/MWB_WATER_1>";
NSString *const CameraPropertyValueWbWbCustom1 = @"<WB/WB_CUSTOM1>";
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
NSString *const CameraPropertyValueAutoWbDenkyuColoredLeavingOff = @"<AUTO_WB_DENKYU_COLORED_LEAVING/OFF>";
NSString *const CameraPropertyValueAutoWbDenkyuColoredLeavingOn = @"<AUTO_WB_DENKYU_COLORED_LEAVING/ON>";

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
NSString *const CameraPropertyIntervalTimerMode = @"intervalTimerMode";
NSString *const CameraPropertyIntervalTimerCount = @"intervalTimerCount";
NSString *const CameraPropertyIntervalTimerTime = @"intervalTimerTime";
NSString *const CameraPropertyRecordingElapsedTime = @"recordingElapsedTime";

static NSString *const CameraSettingSnapshotFormatVersion = @"1.0"; ///< ファイルのフォーマットバージョン
static NSString *const CameraSettingSnapshotFormatVersionKey = @"FormatVersion"; ///< ファイルのフォーマットバージョンの辞書キー
static NSString *const CameraSettingSnapshotPropertyValuesKey = @"PropertyValues"; ///< ファイルのカメラプロパティ値の辞書キー
static NSString *const CameraSettingSnapshotLiveViewSizeKey = @"LiveViewSize"; ///< ファイルのライブビューサイズ設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingModeKey = @"AutoBracketingMode"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingCountKey = @"AutoBracketingCount"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotAutoBracketingStepKey = @"AutoBracketingStep"; ///< オートブラケット撮影設定の辞書キー
static NSString *const CameraSettingSnapshotIntervalTimerModeKey = @"IntervalTimerMode"; ///< インターバルタイマー撮影設定の辞書キー
static NSString *const CameraSettingSnapshotIntervalTimerCountKey = @"IntervalTimerCount"; ///< インターバルタイマー撮影設定の辞書キー
static NSString *const CameraSettingSnapshotIntervalTimerTimeKey = @"IntervalTimerTime"; ///< インターバルタイマー撮影設定の辞書キー
static NSString *const CameraSettingSnapshotMagnifyingLiveViewScaleKey = @"MagnifyingLiveViewScale"; ///< ライブビュー拡大倍率の辞書キー

@interface AppCamera () <OLYCameraConnectionDelegate, OLYCameraPropertyDelegate, OLYCameraPlaybackDelegate, OLYCameraLiveViewDelegate, OLYCameraRecordingDelegate, OLYCameraRecordingSupportsDelegate>

@property (strong, nonatomic, readwrite) NSArray *autoBracketingCountList; ///< オートブラケットで撮影する枚数の選択肢リスト
@property (strong, nonatomic, readwrite) NSArray *autoBracketingStepList; ///< オートブラケットで撮影する際のステップ数の選択肢リスト
@property (strong, nonatomic, readwrite) NSArray *intervalTimerCountList; ///< インターバルタイマーで撮影する回数の選択肢リスト
@property (strong, nonatomic, readwrite) NSArray *intervalTimerTimeList; ///< インターバルタイマーで撮影する際の時間間隔の選択肢リスト
@property (assign, nonatomic, readwrite) NSTimeInterval recordingElapsedTime; ///< 動画撮影経過時間
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
@property (strong, atomic) NSHashTable *takingPictureDelegates; ///< takingPicutreDelegateの集合

@property (assign, nonatomic) BOOL runningLockingAutoFocus; ///< AFロックを実行中か
@property (assign, nonatomic) BOOL runningLockingAutoExposure; ///< AEロックを実行中か
@property (assign, nonatomic) BOOL runningTakingPluralPictures; ///< オートブラケット＋インターバルタイマー撮影中か
@property (assign, nonatomic) BOOL abortTakingPluralPictures; ///< オートブラケット＋インターバルタイマー撮影を中止させようとしているか
@property (assign, nonatomic) BOOL abortedTakingPluralPictures; ///< オートブラケット＋インターバルタイマー撮影を中止したか
@property (strong, nonatomic) dispatch_queue_t takingPictureRunnerQueue; ///< 静止画複数枚撮影を実行するキュー
@property (strong, nonatomic) dispatch_queue_t takingPictureStopperQueue; ///< 静止画複数枚撮影を中止させるキュー
@property (strong, nonatomic) NSDate *recordingVideoStartTime; ///< 動画撮影を開始した時刻
@property (strong, nonatomic) NSTimer *recordingVideoTimer; ///< 動画撮影経過時間を更新するためのタイマー

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

	// 設定ファイルから初期化に使用するリストを構築します。
	NSString *autoBracketingCountListPath = [[NSBundle mainBundle] pathForResource:@"AutoBracketingCountList" ofType:@"plist"];
	NSArray *autoBracketingCountList = [NSArray arrayWithContentsOfFile:autoBracketingCountListPath];
	if (!autoBracketingCountList || autoBracketingCountList.count < 1) {
		DEBUG_LOG(@"could not configure autoBracketingCountList.");
		return nil;
	}
	NSString *autoBracketingStepListPath = [[NSBundle mainBundle] pathForResource:@"AutoBracketingStepList" ofType:@"plist"];
	NSArray *autoBracketingStepList = [NSArray arrayWithContentsOfFile:autoBracketingStepListPath];
	if (!autoBracketingStepList || autoBracketingStepList.count < 1) {
		DEBUG_LOG(@"could not configure autoBracketingStepList.");
		return nil;
	}
	NSString *intervalTimerCountListPath = [[NSBundle mainBundle] pathForResource:@"IntervalTimerCountList" ofType:@"plist"];
	NSArray *intervalTimerCountList = [NSArray arrayWithContentsOfFile:intervalTimerCountListPath];
	if (!intervalTimerCountList || intervalTimerCountList.count < 1) {
		DEBUG_LOG(@"could not configure intervalTimerCountList.");
		return nil;
	}
	NSString *intervalTimerTimeListPath = [[NSBundle mainBundle] pathForResource:@"IntervalTimerTimeList" ofType:@"plist"];
	NSArray *intervalTimerTimeList = [NSArray arrayWithContentsOfFile:intervalTimerTimeListPath];
	if (!intervalTimerTimeList || intervalTimerTimeList.count < 1) {
		DEBUG_LOG(@"could not configure intervalTimerTimeList.");
		return nil;
	}
	
	_autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	_autoBracketingCountList = autoBracketingCountList;
	_autoBracketingCount = 3;
	_autoBracketingStepList = autoBracketingStepList;
	_autoBracketingStep = 1;
	_intervalTimerMode = AppCameraIntervalTimerModeDisabled;
	_intervalTimerCountList = intervalTimerCountList;
	_intervalTimerCount = 3;
	_intervalTimerTimeList = intervalTimerTimeList;
	_intervalTimerTime = 1.0;
	_recordingElapsedTime = 0;
	_minimumDigitalZoomScale = NAN;
	_maximumDigitalZoomScale = NAN;
	_currentDigitalZoomScale = NAN;
	_magnifyingLiveViewScale = OLYCameraMagnifyingLiveViewScaleX5;
	_runningLockingAutoFocus = NO;
	_runningLockingAutoExposure = NO;
	_runningTakingPluralPictures = NO;
	_abortTakingPluralPictures = NO;
	_abortedTakingPluralPictures = NO;
	_takingPictureRunnerQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.takingPictureRunner", DISPATCH_QUEUE_SERIAL);
	_takingPictureStopperQueue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.takingStopperRunner", DISPATCH_QUEUE_SERIAL);
	_recordingVideoStartTime = nil;
	_recordingVideoTimer = nil;
	
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
	
	[_recordingVideoTimer invalidate];
	
	_autoBracketingCountList = nil;
	_autoBracketingStepList = nil;
	_intervalTimerCountList = nil;
	_intervalTimerTimeList = nil;
	_takingPictureRunnerQueue = nil;
	_takingPictureStopperQueue = nil;
	_recordingVideoStartTime = nil;
	_recordingVideoTimer = nil;

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

	// MARK: 撮影モードに遷移する場合は強制的に撮影モードをiAutoに設定します。
	// カメラプロパティの撮影モード(TAKEMODE)をmovieに変更したまま、実行モード変更(changeRunMode:error:)で
	// 撮影モード以外に遷移してから再び撮影モードに入ると、カメラ側はiAuto、ライブラリ側はmovieと認識しているようです。
	// このため、全体としてちぐはぐな動作になります。
	if (result && self.runMode == OLYCameraRunModeRecording) {
		if (![super setCameraPropertyValue:CameraPropertyTakemode value:CameraPropertyValueTakemodeIAuto error:error]) {
			return NO;
		}
	}
	
#if 0 // 以前の状態に復帰しなくても問題ないようなので実装を無効にしておきます。
	// オートブラケット撮影のプロパティを更新します。
	_autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	_autoBracketingCount = 3;
	_autoBracketingStep = 1;
	
	// インターバルタイマー撮影のプロパティを更新します。
	_intervalTimerMode = AppCameraIntervalTimerModeDisabled;
	_intervalTimerCount = 3;
	_intervalTimerTime = 1.0;
#endif
	
	// 動画撮影経過時間を更新します。
	if (self.recordingElapsedTime != 0) {
		self.recordingElapsedTime = 0;
	}

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
	
	// オートブラケット＋インターバルタイマー撮影のフラグを初期化します。
	self.runningTakingPluralPictures = NO;
	self.abortTakingPluralPictures = NO;
	self.abortedTakingPluralPictures = NO;
	
	// 動画撮影の経過時間監視を初期化します。
	[self.recordingVideoTimer invalidate];
	self.recordingVideoStartTime = nil;
	self.recordingVideoTimer = nil;
	
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
	NSArray *filteredProperties = @[
		CameraPropertyAperture,
		CameraPropertyAe,
		CameraPropertyTakemode,
		CameraPropertyIso,
		CameraPropertyExprev,
		CameraPropertyTakeDrive,
		CameraPropertyAspectRatio,
		CameraPropertyShutter,
		CameraPropertyContinuousShootingVelocity,
		CameraPropertyExposeMovieSelect,
		CameraPropertyImagesize,
		CameraPropertyRaw,
		CameraPropertyCompressibilityRatio,
		CameraPropertyQualityMovie,
		CameraPropertyDestinationFile,
		CameraPropertyQualityMovieShortMovieRecordTime,
		CameraPropertyFocusStill,
		CameraPropertyFullTimeAf,
		CameraPropertyFocusMovie,
		CameraPropertyFaceScan,
		CameraPropertyAntiShakeFocalLength,
		CameraPropertyRecview,
		CameraPropertyAntiShakeMovie,
		CameraPropertySoundVolumeLevel,
		CameraPropertyGps,
		CameraPropertyWifiCh,
		CameraPropertyRecentlyArtFilter,
		CameraPropertyColorPhase,
		CameraPropertyArtEffectTypePopart,
		CameraPropertyArtEffectTypeDaydream,
		CameraPropertyArtEffectTypeRoughMonochrome,
		CameraPropertyArtEffectTypeToyPhoto,
		CameraPropertyArtEffectTypeMiniature,
		CameraPropertyArtEffectTypeCrossProcess,
		CameraPropertyArtEffectTypeDramaticTone,
		CameraPropertyArtEffectTypeLigneClair,
		CameraPropertyArtEffectTypePastel,
		CameraPropertyArtEffectTypeVintage,
		CameraPropertyArtEffectTypePartcolor,
		CameraPropertyArtEffectHybridPopart,
		CameraPropertyArtEffectHybridFantasicFocus,
		CameraPropertyArtEffectHybridDaydream,
		CameraPropertyArtEffectHybridLightTone,
		CameraPropertyArtEffectHybridRoughMonochrome,
		CameraPropertyArtEffectHybridToyPhoto,
		CameraPropertyArtEffectHybridMiniature,
		CameraPropertyArtEffectHybridCrossProcess,
		CameraPropertyArtEffectHybridGentleSepia,
		CameraPropertyArtEffectHybridDramaticTone,
		CameraPropertyArtEffectHybridLigneClair,
		CameraPropertyArtEffectHybridPastel,
		CameraPropertyArtEffectHybridVintage,
		CameraPropertyArtEffectHybridPartcolor,
		CameraPropertyBracketPictPopart,
		CameraPropertyBracketPictFantasicFocus,
		CameraPropertyBracketPictDaydream,
		CameraPropertyBracketPictLightTone,
		CameraPropertyBracketPictRoughMonochrome,
		CameraPropertyBracketPictToyPhoto,
		CameraPropertyBracketPictMiniature,
		CameraPropertyBracketPictCrossProcess,
		CameraPropertyBracketPictGentleSepia,
		CameraPropertyBracketPictDramaticTone,
		CameraPropertyBracketPictLigneClair,
		CameraPropertyBracketPictPastel,
		CameraPropertyBracketPictVintage,
		CameraPropertyBracketPictPartcolor,
		CameraPropertyColortone,
		CameraPropertyContrastFlat,
		CameraPropertyContrastNatural,
		CameraPropertyContrastMonochrome,
		CameraPropertyContrastSoft,
		CameraPropertyContrastIFinish,
		CameraPropertyContrastVivid,
		CameraPropertySharpFlat,
		CameraPropertySharpNatural,
		CameraPropertySharpMonochrome,
		CameraPropertySharpSoft,
		CameraPropertySharpIFinish,
		CameraPropertySharpVivid,
		CameraPropertySaturationLevelFlat,
		CameraPropertySaturationLevelNatural,
		CameraPropertySaturationLevelSoft,
		CameraPropertySaturationLevelIFinish,
		CameraPropertySaturationLevelVivid,
		CameraPropertyToneFlat,
		CameraPropertyToneNatural,
		CameraPropertyToneMonochrome,
		CameraPropertyToneSoft,
		CameraPropertyToneIFinish,
		CameraPropertyToneVivid,
		CameraPropertyEffectLevelIFinish,
		CameraPropertyToneControlLow,
		CameraPropertyToneControlMiddle,
		CameraPropertyToneControlHigh,
		CameraPropertyMonotonefilterMonochrome,
		CameraPropertyMonotonefilterRoughMonochrome,
		CameraPropertyMonotonefilterDramaticTone,
		CameraPropertyMonotonecolorMonochrome,
		CameraPropertyMonotonecolorRoughMonochrome,
		CameraPropertyMonotonecolorDramaticTone,
		CameraPropertyColorCreatorColor,
		CameraPropertyColorCreatorVivid,
		CameraPropertyWb,
		CameraPropertyCustomWbKelvin1,
		CameraPropertyWbRevAuto,
		CameraPropertyWbRevGAuto,
		CameraPropertyWbRev5300k,
		CameraPropertyWbRevG5300k,
		CameraPropertyWbRev7500k,
		CameraPropertyWbRevG7500k,
		CameraPropertyWbRev6000k,
		CameraPropertyWbRevG6000k,
		CameraPropertyWbRev3000k,
		CameraPropertyWbRevG3000k,
		CameraPropertyWbRev4000k,
		CameraPropertyWbRevG4000k,
		CameraPropertyWbRevAutoUnderWater,
		CameraPropertyWbRevGAutoUnderWater,
		CameraPropertyAutoWbDenkyuColoredLeaving,
	];
	NSMutableDictionary *patchedValues = [[NSMutableDictionary alloc] init];
	[values enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		if ([filteredProperties containsObject:key]) {
			[patchedValues setObject:value forKey:key];
		}
	}];

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
		if (!recentlyArtFilter) {
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

- (void)startRecordingVideo:(NSDictionary *)options completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");
	
	[super startRecordingVideo:options completionHandler:^() {
		// 完了ハンドラを呼びます。
		completionHandler();
		
		// 動画撮影経過時間を更新するためのタイマーを開始します。
		self.recordingElapsedTime = 0;
		self.recordingVideoStartTime = [NSDate date];
		self.recordingVideoTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(recordingVideoTimerDidFire:) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:self.recordingVideoTimer forMode:NSRunLoopCommonModes];
		
	} errorHandler:errorHandler];
}

- (void)stopRecordingVideo:(void (^)(NSDictionary *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");

	[super stopRecordingVideo:^(NSDictionary *info) {
		// 動画撮影経過時間を更新するためのタイマーを停止します。
		[self.recordingVideoTimer invalidate];
		self.recordingVideoStartTime = nil;
		self.recordingVideoTimer = nil;

		// 完了ハンドラを呼びます。
		completionHandler(info);
	} errorHandler:errorHandler];
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
	
	// 動画撮影経過時間を更新するためのタイマーを開始します。
	self.recordingElapsedTime = 0;
	self.recordingVideoStartTime = [NSDate date];
	self.recordingVideoTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(recordingVideoTimerDidFire:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:self.recordingVideoTimer forMode:NSRunLoopCommonModes];
}

- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera {
	DEBUG_LOG(@"");

	// 動画撮影経過時間を更新するためのタイマーを停止します。
	[self.recordingVideoTimer invalidate];
	self.recordingVideoStartTime = nil;
	self.recordingVideoTimer = nil;
	
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
	// F値の時は特別なローカライズを行います。
	if ([value hasPrefix:@"<APERTURE/"] && [value hasSuffix:@">"]) {
		if (![localizedTitle hasPrefix:@"F"]) {
			// F値が開放の場合など、値がローカライズのリストにない場合は頑張ってローカライズします。
			NSString *format = AppCameraLocalizedString(@"F%@");
			NSString *aperture = [super cameraPropertyValueTitle:value];
			localizedTitle = [NSString stringWithFormat:format, aperture];
		}
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
	// いくつかの項目については特別なローカライズを行います。
	// なんでまた項目ごとにこんなにバラバラの書式になってしまっているのでしょうか...。ハードウェア情報ともカメラプロパティの値ともまた違っているし。
	// MARK: 補正値や角度などの数値型で値の符号がおかしい場合があります。(2の補数を正しく変換できていないようです)
	// MARK: DigitalTelecon(デジタルテレコン有無)は通信仕様書の記述と異なり"ON"または"OFF"で返されるようです。
	// MARK: Location(本体の位置)の値は通信仕様書の記述と異なり実際には"0x0"から"0x5"までの値で返されるようです。
	// MARK: MonotoneFilter(モノクロフィルター効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
	// MARK: MonotoneColor(調色効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
	// MARK: MonotoneColor(調色効果)は先頭の"LIKE_"が取り除かれた形式で返されるようです。
	// MARK: WhiteBalance(ホワイトバランス)が自動の時にWB補正を伴うと通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
	if ([name isEqualToString:@"DateTime"] ||
		[name isEqualToString:@"shootingdatetime"]) {
		// 撮影年月日は書式化し直します。
		NSString *pattern = @"^(....)(..)(..)T(..)(..)$";
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
		NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
		if (matches.numberOfRanges == 6) {
			NSString *years = [value substringWithRange:[matches rangeAtIndex:1]];
			NSString *months = [value substringWithRange:[matches rangeAtIndex:2]];
			NSString *days = [value substringWithRange:[matches rangeAtIndex:3]];
			NSString *hours = [value substringWithRange:[matches rangeAtIndex:4]];
			NSString *minites = [value substringWithRange:[matches rangeAtIndex:5]];
			localizedTitle = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", years, months, days, hours, minites];
		}
	} else if ([name isEqualToString:@"ColorCreatorVivid"] ||
			   [name isEqualToString:@"WBBiasA"] ||
			   [name isEqualToString:@"WBBiasG"]) {
		// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にプラス記号がついている)
		NSScanner *scanner = [NSScanner scannerWithString:value];
		int unsingedInt = 0;
		[scanner scanInt:&unsingedInt];
		SInt16 signedInt16 = (SInt16)unsingedInt;
		localizedTitle = [NSString stringWithFormat:@"%ld", (long)signedInt16];
	} else if ([name isEqualToString:@"ToneControlHigh"] ||
			   [name isEqualToString:@"ToneControlMiddle"] ||
			   [name isEqualToString:@"ToneControlShadow"]) {
		// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にはプラス記号がついていない)
		NSScanner *scanner = [NSScanner scannerWithString:value];
		int unsingedInt = 0;
		[scanner scanInt:&unsingedInt];
		SInt16 signedInt16 = (SInt16)unsingedInt;
		localizedTitle = [NSString stringWithFormat:@"%ld", (long)signedInt16];
	} else if ([name isEqualToString:@"RoleAngle"] ||
			   [name isEqualToString:@"PitchAngle"]) {
		// 16ビット符号なし16進数になっているので書式化し直します。
		NSString *pattern = @"^0x([0-9A-Fa-f]+)$";
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
		NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
		if (matches.numberOfRanges == 2) {
			NSString *hexText = [value substringWithRange:[matches rangeAtIndex:1]];
			unsigned int hexUnsignedInt = 0;
			NSScanner *scanner = [NSScanner scannerWithString:hexText];
			[scanner scanHexInt:&hexUnsignedInt];
			SInt16 hexSignedInt16 = (SInt16)hexUnsignedInt;
			float angle = (float)hexSignedInt16 / 10.0;
			localizedTitle = [NSString stringWithFormat:@"%0.1f", angle];
		}
	} else if ([name isEqualToString:@"LensID"] ||
			   [name isEqualToString:@"AccessaryID"]) {
		// 2つの8ビット10進数に分離しているので、ハードウェア情報取得で得られる形式と同じ、16ビット符号なし16進数に再構築します。
		NSString *pattern = @"^\\(([0-9]+), *([0-9]+)\\)$";
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
		NSTextCheckingResult *matches = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
		if (matches.numberOfRanges == 3) {
			NSString *highHexText = [value substringWithRange:[matches rangeAtIndex:1]];
			NSString *lowHexText = [value substringWithRange:[matches rangeAtIndex:2]];
			NSInteger highInteger = [highHexText integerValue];
			NSInteger lowInteger = [lowHexText integerValue];
			UInt16 unsignedInt16 = (UInt16)(highInteger * 256 + lowInteger);
			localizedTitle = [NSString stringWithFormat:@"%04lx", (long)unsignedInt16];
		}
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

	// 現在設定されているインターバルタイマー撮影の設定を取得します。
	NSNumber *intervalTimerMode = @(self.intervalTimerMode);
	NSNumber *intervalTimerCount = @(self.intervalTimerCount);
	NSNumber *intervalTimerTime = @(self.intervalTimerTime);
	DEBUG_LOG(@"intervalTimerMode=%@", intervalTimerMode);
	DEBUG_LOG(@"intervalTimerCount=%@", intervalTimerCount);
	DEBUG_LOG(@"intervalTimerTime=%@", intervalTimerTime);
	
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
		CameraSettingSnapshotIntervalTimerModeKey: intervalTimerMode,
		CameraSettingSnapshotIntervalTimerCountKey: intervalTimerCount,
		CameraSettingSnapshotIntervalTimerTimeKey: intervalTimerTime,
		CameraSettingSnapshotMagnifyingLiveViewScaleKey: magnifyingLiveViewScale,
	};
	
	return snapshot;
}

- (BOOL)restoreSnapshotOfSetting:(NSDictionary *)snapshot exclude:(NSArray *)exclude fallback:(BOOL)fallback error:(NSError **)error {
	DEBUG_LOG(@"exclude=%@", exclude);

	/// スナップショットがカメラ設定として妥当かを確認します。
	if (![self validateSnapshotOfSetting:snapshot]) {
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:DataFormatIsNotSnapshotOfSetting", @"AppCamera.restoreSnapshotOfSetting")
		};
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
	
	// ライブビュー拡大中だった場合はそれを解除します。
	// (読み込んだカメラプロパティの設定値を反映すると元の拡大中の状況に戻せない可能性があるため)
	if (self.magnifyingLiveView) {
		if (![super stopMagnifyingLiveView:error]) {
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
	if (snapshot[CameraSettingSnapshotLiveViewSizeKey]) {
		OLYCameraLiveViewSize liveViewSize = CGSizeFromString(snapshot[CameraSettingSnapshotLiveViewSizeKey]);
		if (![super changeLiveViewSize:liveViewSize error:error]) {
			return NO;
		}
	} else if (fallback) {
		if (![super changeLiveViewSize:OLYCameraLiveViewSizeQVGA error:error]) {
			return NO;
		}
	}
	
	// 読み込んだオートブラケット撮影を設定します。
	if (snapshot[CameraSettingSnapshotAutoBracketingModeKey]) {
		NSInteger modeValue = [snapshot[CameraSettingSnapshotAutoBracketingModeKey] integerValue];
		self.autoBracketingMode = (AppCameraAutoBracketingMode)modeValue;
	} else if (fallback) {
		self.autoBracketingMode = AppCameraAutoBracketingModeDisabled;
	}
	if (snapshot[CameraSettingSnapshotAutoBracketingCountKey]) {
		NSInteger autoBracketingCount = [snapshot[CameraSettingSnapshotAutoBracketingCountKey] integerValue];
		self.autoBracketingCount = autoBracketingCount;
	} else if (fallback) {
		self.autoBracketingCount = 3;
	}
	if (snapshot[CameraSettingSnapshotAutoBracketingStepKey]) {
		NSInteger autoBracketingStep = [snapshot[CameraSettingSnapshotAutoBracketingStepKey] integerValue];
		self.autoBracketingStep = autoBracketingStep;
	} else if (fallback) {
		self.autoBracketingStep = 1;
	}
	
	// 読み込んだインターバルタイマー撮影を設定します。
	if (snapshot[CameraSettingSnapshotIntervalTimerModeKey]) {
		NSInteger modeValue = [snapshot[CameraSettingSnapshotIntervalTimerModeKey] integerValue];
		self.intervalTimerMode = (AppCameraIntervalTimerMode)modeValue;
	} else if (fallback) {
		self.intervalTimerMode = AppCameraIntervalTimerModeDisabled;
	}
	if (snapshot[CameraSettingSnapshotIntervalTimerCountKey]) {
		NSInteger intervalTimerCount = [snapshot[CameraSettingSnapshotIntervalTimerCountKey] integerValue];
		self.intervalTimerCount = intervalTimerCount;
	} else if (fallback) {
		self.intervalTimerCount = 3;
	}
	if (snapshot[CameraSettingSnapshotIntervalTimerTimeKey]) {
		NSInteger intervalTimerTime = [snapshot[CameraSettingSnapshotIntervalTimerTimeKey] doubleValue];
		self.intervalTimerTime = intervalTimerTime;
	} else if (fallback) {
		self.intervalTimerTime = 1.0;
	}

	// 読み込んだライブビュー拡大倍率を設定します。
	if (snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey]) {
		NSInteger scaleValue = [snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey] integerValue];
		self.magnifyingLiveViewScale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
	} else if (fallback) {
		self.magnifyingLiveViewScale = OLYCameraMagnifyingLiveViewScaleX5;
	}
	
	// ライブビューを再開します。
	if (needToStartLiveView) {
		if (![super startLiveView:error]) {
			return NO;
		}
	}
	
	// 復元完了しました。
	return YES;
}

- (BOOL)validateSnapshotOfSetting:(NSDictionary *)snapshot {
	DEBUG_LOG(@"");

	// フォーマットバージョンは必須で"1.0"でなければなりません。
	if (!snapshot[CameraSettingSnapshotFormatVersionKey] ||
		![snapshot[CameraSettingSnapshotFormatVersionKey] isKindOfClass:[NSString class]] ||
		![snapshot[CameraSettingSnapshotFormatVersionKey] isEqualToString:CameraSettingSnapshotFormatVersion]) {
		DEBUG_LOG(@"CameraSettingSnapshotFormatVersion is incorrect.");
		return NO;
	}
	
	// ライブビューサイズは任意ですが、設定する場合はCGSizeに変換可能でなければなりません。
	if (snapshot[CameraSettingSnapshotLiveViewSizeKey]) {
		if ([snapshot[CameraSettingSnapshotLiveViewSizeKey] isKindOfClass:[NSString class]]) {
			CGSize liveViewSize = CGSizeFromString(snapshot[CameraSettingSnapshotLiveViewSizeKey]);
			if (!CGSizeEqualToSize(liveViewSize, OLYCameraLiveViewSizeQVGA) &&
				!CGSizeEqualToSize(liveViewSize, OLYCameraLiveViewSizeVGA) &&
				!CGSizeEqualToSize(liveViewSize, OLYCameraLiveViewSizeSVGA) &&
				!CGSizeEqualToSize(liveViewSize, OLYCameraLiveViewSizeXGA) &&
				!CGSizeEqualToSize(liveViewSize, OLYCameraLiveViewSizeQuadVGA)) {
				DEBUG_LOG(@"CameraSettingSnapshotLiveViewSize is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotLiveViewSize is incorrect.");
			return NO;
		}
	}

	// オートブラケット撮影は任意ですが、設定する場合は変換可能でなければなりません。
	if (snapshot[CameraSettingSnapshotAutoBracketingModeKey]) {
		if ([snapshot[CameraSettingSnapshotAutoBracketingModeKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotAutoBracketingModeKey] isKindOfClass:[NSString class]]) {
			NSInteger modeValue = [snapshot[CameraSettingSnapshotAutoBracketingModeKey] integerValue];
			AppCameraAutoBracketingMode autoBracketingMode = (AppCameraAutoBracketingMode)modeValue;
			switch (autoBracketingMode) {
				case AppCameraAutoBracketingModeDisabled:
				case AppCameraAutoBracketingModeExposure:
					break;
				default:
					DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingMode is incorrect.");
					return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingMode is incorrect.");
			return NO;
		}
	}
	if (snapshot[CameraSettingSnapshotAutoBracketingCountKey]) {
		if ([snapshot[CameraSettingSnapshotAutoBracketingCountKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotAutoBracketingCountKey] isKindOfClass:[NSString class]]) {
			NSInteger autoBracketingCount = [snapshot[CameraSettingSnapshotAutoBracketingCountKey] integerValue];
			if (autoBracketingCount <  3 ||
				autoBracketingCount >  9 ||
				(autoBracketingCount % 2) == 0) {
				DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingCount is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingCount is incorrect.");
			return NO;
		}
	}
	if (snapshot[CameraSettingSnapshotAutoBracketingStepKey]) {
		if ([snapshot[CameraSettingSnapshotAutoBracketingStepKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotAutoBracketingStepKey] isKindOfClass:[NSString class]]) {
			NSInteger autoBracketingStep = [snapshot[CameraSettingSnapshotAutoBracketingStepKey] integerValue];
			if (autoBracketingStep < 1 ||		// 1 step = 0.3EV
				autoBracketingStep > 9) {		// 9 step = 3.0EV
				DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingStep is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotAutoBracketingStep is incorrect.");
			return NO;
		}
	}
	
	// インターバルタイマー撮影は任意ですが、設定する場合は変換可能でなければなりません。
	if (snapshot[CameraSettingSnapshotIntervalTimerModeKey]) {
		if ([snapshot[CameraSettingSnapshotIntervalTimerModeKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotIntervalTimerModeKey] isKindOfClass:[NSString class]]) {
			NSInteger modeValue = [snapshot[CameraSettingSnapshotIntervalTimerModeKey] integerValue];
			AppCameraIntervalTimerMode intervalTimerMode = (AppCameraIntervalTimerMode)modeValue;
			switch (intervalTimerMode) {
				case AppCameraIntervalTimerModeDisabled:
				case AppCameraIntervalTimerModePriorCount:
				case AppCameraIntervalTimerModePriorTime:
					break;
				default:
					DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerMode is incorrect.");
					return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerMode is incorrect.");
			return NO;
		}
	}
	if (snapshot[CameraSettingSnapshotIntervalTimerCountKey]) {
		if ([snapshot[CameraSettingSnapshotIntervalTimerCountKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotIntervalTimerCountKey] isKindOfClass:[NSString class]]) {
			NSInteger intervalTimerCount = [snapshot[CameraSettingSnapshotIntervalTimerCountKey] integerValue];
			if (intervalTimerCount < 1) {
				DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerCount is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerCount is incorrect.");
			return NO;
		}
	}
	if (snapshot[CameraSettingSnapshotIntervalTimerTimeKey]) {
		if ([snapshot[CameraSettingSnapshotIntervalTimerTimeKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotIntervalTimerTimeKey] isKindOfClass:[NSString class]]) {
			NSInteger intervalTimerTime =  [snapshot[CameraSettingSnapshotIntervalTimerTimeKey] doubleValue];
			if (intervalTimerTime < 1) {
				DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerTime is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotIntervalTimerTime is incorrect.");
			return NO;
		}
	}
	
	// ライブビュー拡大倍率は任意ですが、設定する場合は変換可能でなければなりません。
	if (snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey]) {
		if ([snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey] isKindOfClass:[NSNumber class]] ||
			[snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey] isKindOfClass:[NSString class]]) {
			NSInteger scaleValue = [snapshot[CameraSettingSnapshotMagnifyingLiveViewScaleKey] integerValue];
			OLYCameraMagnifyingLiveViewScale magnifyingLiveViewScale = (OLYCameraMagnifyingLiveViewScale)scaleValue;
			switch (magnifyingLiveViewScale) {
				case OLYCameraMagnifyingLiveViewScaleX5:
				case OLYCameraMagnifyingLiveViewScaleX7:
				case OLYCameraMagnifyingLiveViewScaleX10:
				case OLYCameraMagnifyingLiveViewScaleX14:
					break;
				default:
					DEBUG_LOG(@"CameraSettingSnapshotMagnifyingLiveViewScale is incorrect.");
					return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotMagnifyingLiveViewScale is incorrect.");
			return NO;
		}
	}
	
	// カメラプロパティは任意ですが、設定する場合は変換可能でなければなりません。
	if (snapshot[CameraSettingSnapshotPropertyValuesKey]) {
		if ([snapshot[CameraSettingSnapshotPropertyValuesKey] isKindOfClass:[NSDictionary class]]) {
			NSDictionary *propertyValues = snapshot[CameraSettingSnapshotPropertyValuesKey];
			__block BOOL foundBadFormat = NO;
			[propertyValues enumerateKeysAndObjectsUsingBlock:^(id keyObject, id valueObject, BOOL *stop) {
				// プロパティ名を確認します。
				if ([keyObject isKindOfClass:[NSString class]]) {
					NSString *key = keyObject;
					if (key.length < 1) {
						foundBadFormat = YES;
						*stop = YES;
					}
				}
				// プロパティ値を確認します。
				if ([valueObject isKindOfClass:[NSString class]]) {
					NSString *value = valueObject;
					if (value.length < 1) {
						foundBadFormat = YES;
						*stop = YES;
					}
					if (![value hasPrefix:@"<"] ||
						![value hasSuffix:@">"] ||
						![value containsString:@"/"]) {
						foundBadFormat = YES;
						*stop = YES;
					}
				}
			}];
			if (foundBadFormat) {
				DEBUG_LOG(@"CameraSettingSnapshotPropertyValues is incorrect.");
				return NO;
			}
		} else {
			DEBUG_LOG(@"CameraSettingSnapshotPropertyValues is incorrect.");
			return NO;
		}
	}
	
	return YES;
}

- (NSDictionary *)forgeSnapshotOfSettingWithContentInformation:(NSDictionary *)information metadata:(NSDictionary *)metadata {
	DEBUG_LOG(@"information=%@, metadata=%@", information, metadata);
	
	// 操作モード/撮影モードを決定します。
	NSMutableDictionary *propertyValues = [[NSMutableDictionary alloc] init];
	NSDictionary *exifDictionary = metadata[(NSString *)kCGImagePropertyExifDictionary];
	if (!exifDictionary) {
		DEBUG_LOG(@"no exif dictionary.");
		return nil;
	}
	NSNumber *exifExposureMode = exifDictionary[(NSString *)kCGImagePropertyExifExposureProgram];
	if (!exifExposureMode) {
		DEBUG_LOG(@"no exif exposure mode.");
		return nil;
	}
	switch ([exifExposureMode longValue]) {
		case 1: // マニュアル
			propertyValues[CameraPropertyTakemode] = CameraPropertyValueTakemodeM;
			break;
		case 2: // ノーマルプログラム
			propertyValues[CameraPropertyTakemode] = CameraPropertyValueTakemodeP;
			break;
		case 3: // 絞り優先
			propertyValues[CameraPropertyTakemode] = CameraPropertyValueTakemodeA;
			break;
		case 4: // シャッター優先
			propertyValues[CameraPropertyTakemode] = CameraPropertyValueTakemodeS;
			break;
		case 5: // クリエイティブ
			propertyValues[CameraPropertyTakemode] = CameraPropertyValueTakemodeArt;
			break;
		default:
			DEBUG_LOG(@"not supported exif exposure mode.");
			return nil;
	}
	
	// 操作モード/動画撮影モード ... 扱いません。
	propertyValues[CameraPropertyExposeMovieSelect] = nil;
	// 操作モード/ドライブモード ... 扱いません。
	propertyValues[CameraPropertyTakeDrive] = nil;
	// 操作モード/連写速度 ... 扱いません。
	propertyValues[CameraPropertyContinuousShootingVelocity] = nil;

	// 露出パラメータ/絞り値を決定します。
	NSNumber *exifFNumber = exifDictionary[(NSString *)kCGImagePropertyExifFNumber];
	if (exifFNumber) {
		// 絞り値のカメラプロパティ値リストを取得します。
		NSArray *aperturePropertyValueList = [super cameraPropertyValueList:CameraPropertyAperture error:nil];
		if (aperturePropertyValueList) {
			// 絞り値リストを作成します。
			NSMutableArray *apertureNumberList = [[NSMutableArray alloc] init];
			[aperturePropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *apertureNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				[apertureNumberList addObject:apertureNumber];
			}];
			// 絞り値リストの中で絞り値がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:exifFNumber numberList:apertureNumberList];
			// 探したインデックスに対応するカメラプロパティの絞り値で決定します。
			NSString *apertureValue = aperturePropertyValueList[nearestIndex];
			propertyValues[CameraPropertyAperture] = apertureValue;
		}
	}

	// 露出パラメータ/シャッター速度を決定します。
	NSNumber *exifExposureTime = exifDictionary[(NSString *)kCGImagePropertyExifExposureTime];
	if (exifExposureTime) {
		// シャッター速度のカメラプロパティ値リストを取得します。
		// MARK: 露光時間リストは並びが値の大きい順に並んでいます。のでひっくり返します。
		NSArray *shutterPropertyValueList = [super cameraPropertyValueList:CameraPropertyShutter error:nil];
		shutterPropertyValueList = [[shutterPropertyValueList reverseObjectEnumerator] allObjects];
		if (shutterPropertyValueList) {
			// 露光時間リストを作成します。
			NSMutableArray *exposureTimeNumberList = [[NSMutableArray alloc] init];
			[shutterPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *exposureTimeNumber;
				if ([strippedValue hasSuffix:@"\""]) {
					NSString *moreStrippedValue = [strippedValue substringToIndex:strippedValue.length - 1];
					exposureTimeNumber = [NSNumber numberWithFloat:[moreStrippedValue floatValue]];
				} else {
					exposureTimeNumber = [NSNumber numberWithFloat:(1.0 / [strippedValue floatValue])];
				}
				[exposureTimeNumberList addObject:exposureTimeNumber];
			}];
			// 露光時間リストの中で露光時間がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:exifExposureTime numberList:exposureTimeNumberList];
			// 探したインデックスに対応するカメラプロパティのシャッター速度で決定します。
			NSString *shutterValue = shutterPropertyValueList[nearestIndex];
			propertyValues[CameraPropertyShutter] = shutterValue;
		}
	}

	// 露出パラメータ/露出補正値を決定します。
	NSNumber *exifExposureBiasValue = exifDictionary[(NSString *)kCGImagePropertyExifExposureBiasValue];
	if (exifExposureBiasValue) {
		// 露出補正値のカメラプロパティ値リストを取得します。
		// MARK: SDK 1.1.1では、撮影モード以外では露出補正値のカメラプロパティ値の正しいリストが取得できないようです。
		//NSArray *exprevPropertyValueList = [super cameraPropertyValueList:CameraPropertyExprev error:nil];
		NSArray *exprevPropertyValueList = @[
			@"<EXPREV/-5.0>", @"<EXPREV/-4.7>", @"<EXPREV/-4.3>",
			@"<EXPREV/-4.0>", @"<EXPREV/-3.7>", @"<EXPREV/-3.3>",
			@"<EXPREV/-3.0>", @"<EXPREV/-2.7>", @"<EXPREV/-2.3>",
			@"<EXPREV/-2.0>", @"<EXPREV/-1.7>", @"<EXPREV/-1.3>",
			@"<EXPREV/-1.0>", @"<EXPREV/-0.7>", @"<EXPREV/-0.3>",
			@"<EXPREV/0.0>",
			@"<EXPREV/+0.3>", @"<EXPREV/+0.7>", @"<EXPREV/+1.0>",
			@"<EXPREV/+1.3>", @"<EXPREV/+1.7>", @"<EXPREV/+2.0>",
			@"<EXPREV/+2.3>", @"<EXPREV/+2.7>", @"<EXPREV/+3.0>",
			@"<EXPREV/+3.3>", @"<EXPREV/+3.7>", @"<EXPREV/+4.0>",
			@"<EXPREV/+4.3>", @"<EXPREV/+4.7>", @"<EXPREV/+5.0>",
		];
		if (exprevPropertyValueList) {
			// 露出補正値リストを作成します。
			NSMutableArray *exposureCompensationNumberList = [[NSMutableArray alloc] init];
			[exprevPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *apertureNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				[exposureCompensationNumberList addObject:apertureNumber];
			}];
			// 露出補正値リストの中で絞り値がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:exifExposureBiasValue numberList:exposureCompensationNumberList];
			// 探したインデックスに対応するカメラプロパティの露出補正値で決定します。
			NSString *exprevValue = exprevPropertyValueList[nearestIndex];
			propertyValues[CameraPropertyExprev] = exprevValue;
		}
	}

	// 露出パラメータ/ISO感度を決定します。
	// MARK: ISO感度を自動で撮影した場合は正しい設定値を決定することはできません。
	NSNumber *exifISOSpeedValue = nil;
	NSArray *exifISOSpeedRatings = exifDictionary[(NSString *)kCGImagePropertyExifISOSpeedRatings];
	if (exifISOSpeedRatings && exifISOSpeedRatings.count > 0) {
		exifISOSpeedValue = exifISOSpeedRatings[0];
	}
	if (exifISOSpeedValue) {
		// ISO感度のカメラプロパティ値リストを取得します。
		// MARK: SDK 1.1.1では、撮影モード以外ではISO感度のカメラプロパティ値の正しいリストが取得できなようです。
		//NSArray *isoPropertyValueList = [super cameraPropertyValueList:CameraPropertyIso error:nil];
		NSArray *isoPropertyValueList = @[
			@"<ISO/Auto>",
			@"<ISO/Low>", @"<ISO/200>", @"<ISO/250>", @"<ISO/320>",
			@"<ISO/400>", @"<ISO/500>", @"<ISO/640>", @"<ISO/800>",
			@"<ISO/1000>", @"<ISO/1250>", @"<ISO/1600>", @"<ISO/2000>",
			@"<ISO/2500>", @"<ISO/3200>", @"<ISO/4000>", @"<ISO/5000>",
			@"<ISO/6400>", @"<ISO/8000>", @"<ISO/10000>", @"<ISO/12800>",
		];
		if (isoPropertyValueList) {
			// ISO感度リストを作成します。
			NSMutableArray *isoSensitivityNumberList = [[NSMutableArray alloc] init];
			[isoPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *isoSensitivityNumber;
				if ([strippedValue isEqualToString:@"Auto"]) {
					isoSensitivityNumber = @(0.0f);
				} else if ([strippedValue isEqualToString:@"Low"]) {
					isoSensitivityNumber = @(100.0f);
				} else {
					isoSensitivityNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				}
				[isoSensitivityNumberList addObject:isoSensitivityNumber];
			}];
			// ISO感度リストの中でISO感度がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:exifISOSpeedValue numberList:isoSensitivityNumberList];
			// 探したインデックスに対応するカメラプロパティのISO感度で決定します。
			NSString *isoValue = isoPropertyValueList[nearestIndex];
			propertyValues[CameraPropertyIso] = isoValue;
		}
	}

	// ホワイトバランスを決定します。
	NSString *infoWhiteBalanceValue = information[@"WhiteBalance"];
	if (infoWhiteBalanceValue) {
		// ホワイトバランスのカメラプロパティ値リストを取得します。
		NSArray *wbPropertyValueList = [super cameraPropertyValueList:CameraPropertyWb error:nil];
		if (wbPropertyValueList) {
			// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
			// MARK: WhiteBalance(ホワイトバランス)が自動の時にWB補正を伴うと通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
			NSDictionary *wbPropertyValueMap = @{
				@"AUTO": CameraPropertyValueWbWbAuto,
				@"FINE": CameraPropertyValueWbMwbFine,
				@"SHADE": CameraPropertyValueWbMwbShade,
				@"CLOUD": CameraPropertyValueWbMwbCloud,
				@"LAMP": CameraPropertyValueWbMwbLamp,
				@"FLUORESCENCE1": CameraPropertyValueWbMwbFluorescence1,
				@"WATER1": CameraPropertyValueWbMwbWater1,
				@"CUSTOM1": CameraPropertyValueWbWbCustom1,
				@"ERROR": CameraPropertyValueWbWbAuto,
			};
			NSString *wbValue = wbPropertyValueMap[infoWhiteBalanceValue];
			// 変換したカメラプロパティ値で決定します。
			propertyValues[CameraPropertyWb] = wbValue;
		}
	}
	
	// ホワイトバランス/カスタムWB用色温度を決定します。
	if (propertyValues[CameraPropertyWb] &&
		[propertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbCustom1]) {
		NSNumber *infoCustomWBBiasValue = nil;
		if (information[@"CustomWBBias"]) {
			infoCustomWBBiasValue = [NSNumber numberWithFloat:[information[@"CustomWBBias"] floatValue]];
		}
		if (infoCustomWBBiasValue) {
			// カスタムWB用色温度のカメラプロパティ値リストを取得します。
			NSArray *customWbKelvin1PropertyValueList = [super cameraPropertyValueList:CameraPropertyCustomWbKelvin1 error:nil];
			if (customWbKelvin1PropertyValueList) {
				// カスタムWB用色温度リストを作成します。
				NSMutableArray *customWBBiasNumberList = [[NSMutableArray alloc] init];
				[customWbKelvin1PropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
					NSString *strippedValue = [self stripCameraPropertyValue:value];
					NSNumber *customWBBiasNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
					[customWBBiasNumberList addObject:customWBBiasNumber];
				}];
				// カスタムWB用色温度リストの中で色温度がもっとも近い値のインデックスを検索します。
				NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoCustomWBBiasValue numberList:customWBBiasNumberList];
				// 探したインデックスに対応するカメラプロパティのカスタムWB用色温度で決定します。
				NSString *customWbKelvin1Value = customWbKelvin1PropertyValueList[nearestIndex];
				propertyValues[CameraPropertyCustomWbKelvin1] = customWbKelvin1Value;
			}
		}
	}
	
	// ホワイトバランス/WB補正(琥珀色-青色)を決定します。
	if (propertyValues[CameraPropertyWb] &&
		![propertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbCustom1]) {
		NSNumber *infoWbBiasAValue = nil;
		if (information[@"WBBiasA"]) {
			// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にプラス記号がついている)
			NSScanner *scanner = [NSScanner scannerWithString:information[@"WBBiasA"]];
			int unsingedInt = 0;
			[scanner scanInt:&unsingedInt];
			SInt16 signedInt16 = (SInt16)unsingedInt;
			infoWbBiasAValue = [NSNumber numberWithFloat:(float)signedInt16];
		}
		if (infoWbBiasAValue) {
			// ホワイトバランスの値に対応する、WB補正(琥珀色-青色)のカメラプロパティ名を取得します。
			NSDictionary *wbRevPropertyMap = @{
				CameraPropertyValueWbMwbLamp: CameraPropertyWbRev3000k,
				CameraPropertyValueWbMwbFluorescence1: CameraPropertyWbRev4000k,
				CameraPropertyValueWbMwbFine: CameraPropertyWbRev5300k,
				CameraPropertyValueWbMwbCloud: CameraPropertyWbRev6000k,
				CameraPropertyValueWbMwbShade: CameraPropertyWbRev7500k,
				CameraPropertyValueWbWbAuto: CameraPropertyWbRevAuto,
				CameraPropertyValueWbMwbWater1: CameraPropertyWbRevAutoUnderWater,
			};
			NSString *wbRevProperty = wbRevPropertyMap[propertyValues[CameraPropertyWb]];
			if (wbRevProperty) {
				// WB補正(琥珀色-青色)のカメラプロパティ値リストを取得します。
				NSArray *wbRevPropertyValueList = [super cameraPropertyValueList:wbRevProperty error:nil];
				if (wbRevPropertyValueList) {
					// WB補正値リストを作成します。
					NSMutableArray *wbRevNumberList = [[NSMutableArray alloc] init];
					[wbRevPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
						NSString *strippedValue = [self stripCameraPropertyValue:value];
						NSNumber *wbRevNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
						[wbRevNumberList addObject:wbRevNumber];
					}];
					// WB補正値リストの中で補正値がもっとも近い値のインデックスを検索します。
					NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoWbBiasAValue numberList:wbRevNumberList];
					// 探したインデックスに対応するカメラプロパティのWB補正(琥珀色-青色)で決定します。
					NSString *wbrevValue = wbRevPropertyValueList[nearestIndex];
					propertyValues[wbRevProperty] = wbrevValue;
				}
			}
		}
	}
	
	// ホワイトバランス/WB補正(緑色-赤紫色)を決定します。
	if (propertyValues[CameraPropertyWb] &&
		![propertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbCustom1]) {
		NSNumber *infoWbBiasGValue = nil;
		if (information[@"WBBiasG"]) {
			// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にプラス記号がついている)
			NSScanner *scanner = [NSScanner scannerWithString:information[@"WBBiasG"]];
			int unsingedInt = 0;
			[scanner scanInt:&unsingedInt];
			SInt16 signedInt16 = (SInt16)unsingedInt;
			infoWbBiasGValue = [NSNumber numberWithFloat:(float)signedInt16];
		}
		if (infoWbBiasGValue) {
			// ホワイトバランスの値に対応する、WB補正(琥珀色-青色)のカメラプロパティ名を取得します。
			NSDictionary *wbRevGPropertyMap = @{
				CameraPropertyValueWbMwbLamp: CameraPropertyWbRevG3000k,
				CameraPropertyValueWbMwbFluorescence1: CameraPropertyWbRevG4000k,
				CameraPropertyValueWbMwbFine: CameraPropertyWbRevG5300k,
				CameraPropertyValueWbMwbCloud: CameraPropertyWbRevG6000k,
				CameraPropertyValueWbMwbShade: CameraPropertyWbRevG7500k,
				CameraPropertyValueWbWbAuto: CameraPropertyWbRevGAuto,
				CameraPropertyValueWbMwbWater1: CameraPropertyWbRevGAutoUnderWater,
			};
			NSString *wbRevGProperty = wbRevGPropertyMap[propertyValues[CameraPropertyWb]];
			if (wbRevGProperty) {
				// WB補正(琥珀色-青色)のカメラプロパティ値リストを取得します。
				NSArray *wbRevGPropertyValueList = [super cameraPropertyValueList:wbRevGProperty error:nil];
				if (wbRevGPropertyValueList) {
					// WB補正値リストを作成します。
					NSMutableArray *wbRevGNumberList = [[NSMutableArray alloc] init];
					[wbRevGPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
						NSString *strippedValue = [self stripCameraPropertyValue:value];
						NSNumber *wbRevGNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
						[wbRevGNumberList addObject:wbRevGNumber];
					}];
					// WB補正値リストの中で補正値がもっとも近い値のインデックスを検索します。
					NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoWbBiasGValue numberList:wbRevGNumberList];
					// 探したインデックスに対応するカメラプロパティのWB補正(琥珀色-青色)で決定します。
					NSString *wbrevGValue = wbRevGPropertyValueList[nearestIndex];
					propertyValues[wbRevGProperty] = wbrevGValue;
				}
			}
		}
	}
	
	// ホワイトバランス/電球色残しを決定します。
	if (propertyValues[CameraPropertyWb] &&
		[propertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbAuto]) {
		NSString *infoWbAutoLightBulbColorLeavingValue = information[@"WBAutoLightBulbColorLeaving"];
		if (infoWbAutoLightBulbColorLeavingValue) {
			// 電球色残しのカメラプロパティ値リストを取得します。
			NSArray *autoWbDenkyuColoredLeavingPropertyValueList = [super cameraPropertyValueList:CameraPropertyAutoWbDenkyuColoredLeaving error:nil];
			if (autoWbDenkyuColoredLeavingPropertyValueList) {
				// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
				NSDictionary *autoWbDenkyuColoredLeavingPropertyValueMap = @{
					@"OFF": CameraPropertyValueAutoWbDenkyuColoredLeavingOff,
					@"ON": CameraPropertyValueAutoWbDenkyuColoredLeavingOn,
				};
				NSString *autoWbDenkyuColoredLeavingValue = CameraPropertyValueAutoWbDenkyuColoredLeavingOff;
				if (autoWbDenkyuColoredLeavingPropertyValueMap[infoWbAutoLightBulbColorLeavingValue]) {
					autoWbDenkyuColoredLeavingValue = autoWbDenkyuColoredLeavingPropertyValueMap[infoWhiteBalanceValue];
				}
				propertyValues[CameraPropertyAutoWbDenkyuColoredLeaving] = autoWbDenkyuColoredLeavingValue;
			}
		}
	}
	
	// ピクチャーモードを決定します。
	NSString *infoColortoneValue = information[@"COLORTONE"];
	if (infoColortoneValue) {
		// ピクチャーモードのカメラプロパティ値リストを取得します。
		NSArray *colortonePropertyValueList = [super cameraPropertyValueList:CameraPropertyColortone error:nil];
		if (colortonePropertyValueList) {
			// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
			NSDictionary *colortonePropertyValueMap = @{
				@"I_FINISH": CameraPropertyValueColortoneIFinish,
				@"VIVID": CameraPropertyValueColortoneVivid,
				@"NATURAL": CameraPropertyValueColortoneNatural,
				@"FLAT": CameraPropertyValueColortoneFlat,
				@"Portrait": CameraPropertyValueColortonePortrait,
				@"Monotone": CameraPropertyValueColortoneMonotone,
				@"ePortrait": CameraPropertyValueColortoneEportrait,
				@"COLOR_CREATOR": CameraPropertyValueColortoneColorCreator,
				@"POPART": CameraPropertyValueColortonePopart,
				@"FANTASIC_FOCUS": CameraPropertyValueColortoneFantasicFocus,
				@"DAYDREAM": CameraPropertyValueColortoneDaydream,
				@"LIGHT_TONE": CameraPropertyValueColortoneLightTone,
				@"ROUGH_MONOCHROME": CameraPropertyValueColortoneRoughMonochrome,
				@"TOY_PHOTO": CameraPropertyValueColortoneToyPhoto,
				@"MINIATURE": CameraPropertyValueColortoneMiniature,
				@"CROSS_PROCESS": CameraPropertyValueColortoneCrossProcess,
				@"GENTLE_SEPIA": CameraPropertyValueColortoneGentleSepia,
				@"DRAMATIC_TONE": CameraPropertyValueColortoneDramaticTone,
				@"LIGNE_CLAIR": CameraPropertyValueColortoneLightTone,
				@"PASTEL": CameraPropertyValueColortonePastel,
				@"VINTAGE": CameraPropertyValueColortoneVintage,
				@"PARTCOLOR": CameraPropertyValueColortonePartcolor,
			};
			NSString *colortoneValue = colortonePropertyValueMap[infoColortoneValue];
			// 変換したカメラプロパティ値で決定します。
			propertyValues[CameraPropertyColortone] = colortoneValue;
		}
	}
	
	// 色彩/コントラストを決定します。
	if (propertyValues[CameraPropertyColortone]) {
		NSNumber *infoContrastValue = nil;
		if (information[@"Contrast"]) {
			infoContrastValue = [NSNumber numberWithFloat:[information[@"Contrast"] floatValue]];
		}
		if (infoContrastValue) {
			// ピクチャーモードの値に対応する、コントラストのカメラプロパティ名を取得します。
			NSDictionary *contrastPropertyMap = @{
				CameraPropertyValueColortoneIFinish: CameraPropertyContrastIFinish,
				CameraPropertyValueColortoneVivid: CameraPropertyContrastVivid,
				CameraPropertyValueColortoneNatural: CameraPropertyContrastNatural,
				CameraPropertyValueColortoneFlat: CameraPropertyContrastFlat,
				CameraPropertyValueColortonePortrait: CameraPropertyContrastSoft,
				CameraPropertyValueColortoneMonotone: CameraPropertyContrastMonochrome,
			};
			NSString *contrastProperty = contrastPropertyMap[propertyValues[CameraPropertyColortone]];
			if (contrastProperty) {
				// コントラストのカメラプロパティ値リストを取得します。
				NSArray *contrastPropertyValueList = [super cameraPropertyValueList:contrastProperty error:nil];
				if (contrastPropertyValueList) {
					// コントラスト値リストを作成します。
					NSMutableArray *contrastNumberList = [[NSMutableArray alloc] init];
					[contrastPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
						NSString *strippedValue = [self stripCameraPropertyValue:value];
						NSNumber *contrastNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
						[contrastNumberList addObject:contrastNumber];
					}];
					// コントラスト値リストの中でコントラスト値がもっとも近い値のインデックスを検索します。
					NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoContrastValue numberList:contrastNumberList];
					// 探したインデックスに対応するカメラプロパティのコントラストで決定します。
					NSString *contrastValue = contrastPropertyValueList[nearestIndex];
					propertyValues[contrastProperty] = contrastValue;
				}
			}
		}
	}
	
	// 色彩/シャープネスを決定します。
	if (propertyValues[CameraPropertyColortone]) {
		NSNumber *infoSharpnessValue = nil;
		if (information[@"Sharpness"]) {
			infoSharpnessValue = [NSNumber numberWithFloat:[information[@"Sharpness"] floatValue]];
		}
		if (infoSharpnessValue) {
			// ピクチャーモードの値に対応する、シャープネスのカメラプロパティ名を取得します。
			NSDictionary *sharpPropertyMap = @{
				CameraPropertyValueColortoneIFinish: CameraPropertySharpIFinish,
				CameraPropertyValueColortoneVivid: CameraPropertySharpVivid,
				CameraPropertyValueColortoneNatural: CameraPropertySharpNatural,
				CameraPropertyValueColortoneFlat: CameraPropertySharpFlat,
				CameraPropertyValueColortonePortrait: CameraPropertySharpSoft,
				CameraPropertyValueColortoneMonotone: CameraPropertySharpMonochrome,
			};
			NSString *sharpProperty = sharpPropertyMap[propertyValues[CameraPropertyColortone]];
			if (sharpProperty) {
				// シャープネスのカメラプロパティ値リストを取得します。
				NSArray *sharpPropertyValueList = [super cameraPropertyValueList:sharpProperty error:nil];
				if (sharpPropertyValueList) {
					// シャープネス値リストを作成します。
					NSMutableArray *sharpnessNumberList = [[NSMutableArray alloc] init];
					[sharpPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
						NSString *strippedValue = [self stripCameraPropertyValue:value];
						NSNumber *sharpNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
						[sharpnessNumberList addObject:sharpNumber];
					}];
					// シャープネス値リストの中でシャープネス値がもっとも近い値のインデックスを検索します。
					NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoSharpnessValue numberList:sharpnessNumberList];
					// 探したインデックスに対応するカメラプロパティのシャープネスで決定します。
					NSString *sharpValue = sharpPropertyValueList[nearestIndex];
					propertyValues[sharpProperty] = sharpValue;
				}
			}
		}
	}
	
	// 色彩/彩度を決定します。
	if (propertyValues[CameraPropertyColortone]) {
		NSNumber *infoSaturationValue = nil;
		if (information[@"Saturation"]) {
			infoSaturationValue = [NSNumber numberWithFloat:[information[@"Saturation"] floatValue]];
		}
		if (infoSaturationValue) {
			// ピクチャーモードの値に対応する、彩度のカメラプロパティ名を取得します。
			NSDictionary *saturationLevelPropertyMap = @{
				CameraPropertyValueColortoneIFinish: CameraPropertySaturationLevelIFinish,
				CameraPropertyValueColortoneVivid: CameraPropertySaturationLevelVivid,
				CameraPropertyValueColortoneNatural: CameraPropertySaturationLevelNatural,
				CameraPropertyValueColortoneFlat: CameraPropertySaturationLevelFlat,
				CameraPropertyValueColortonePortrait: CameraPropertySaturationLevelSoft,
			};
			NSString *saturationLevelProperty = saturationLevelPropertyMap[propertyValues[CameraPropertyColortone]];
			if (saturationLevelProperty) {
				// 彩度のカメラプロパティ値リストを取得します。
				NSArray *saturationLevelPropertyValueList = [super cameraPropertyValueList:saturationLevelProperty error:nil];
				if (saturationLevelPropertyValueList) {
					// 彩度値リストを作成します。
					NSMutableArray *saturationNumberList = [[NSMutableArray alloc] init];
					[saturationLevelPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
						NSString *strippedValue = [self stripCameraPropertyValue:value];
						NSNumber *saturationNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
						[saturationNumberList addObject:saturationNumber];
					}];
					// 彩度値リストの中で彩度値がもっとも近い値のインデックスを検索します。
					NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoSaturationValue numberList:saturationNumberList];
					// 探したインデックスに対応するカメラプロパティの彩度で決定します。
					NSString *saturationLevelValue = saturationLevelPropertyValueList[nearestIndex];
					propertyValues[saturationLevelProperty] = saturationLevelValue;
				}
			}
		}
	}
	
	// 色彩/階調を決定します。
	if (propertyValues[CameraPropertyColortone]) {
		NSString *infoToneValue = information[@"Tone"];
		if (infoToneValue) {
			// ピクチャーモードの値に対応する、階調のカメラプロパティ名を取得します。
			NSDictionary *tonePropertyMap = @{
				CameraPropertyValueColortoneIFinish: CameraPropertyToneIFinish,
				CameraPropertyValueColortoneVivid: CameraPropertyToneVivid,
				CameraPropertyValueColortoneNatural: CameraPropertyToneNatural,
				CameraPropertyValueColortoneFlat: CameraPropertyToneFlat,
				CameraPropertyValueColortonePortrait: CameraPropertyToneSoft,
				CameraPropertyValueColortoneMonotone: CameraPropertyToneMonochrome,
			};
			NSString *toneProperty = tonePropertyMap[propertyValues[CameraPropertyColortone]];
			if (toneProperty) {
				// 階調のカメラプロパティ値リストを取得します。
				NSArray *tonePropertyValueList = [super cameraPropertyValueList:toneProperty error:nil];
				if (tonePropertyValueList) {
					// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
					NSDictionary *tonePropertyValueMap = @{
						@"Auto": @"AUTO",
						@"Normal": @"NORMAL",
						@"HighKey": @"HIGHKEY",
						@"LowKey": @"LOWKEY",
					};
					NSString *tonePropertyValue = tonePropertyValueMap[infoToneValue];
					if (tonePropertyValue) {
						tonePropertyValue = [NSString stringWithFormat:@"<%@/%@>", toneProperty, tonePropertyValue];
					}
					// 変換したカメラプロパティ値で決定します。
					propertyValues[toneProperty] = tonePropertyValue;
				}
			}
		}
	}
	
	// 色彩/効果強弱 ... 扱いません。
	propertyValues[CameraPropertyEffectLevel] = nil;
	
	// 色彩/階調補正シャドー部を決定します。
	NSNumber *infoToneControlShadowValue = nil;
	if (information[@"ToneControlShadow"]) {
		// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にはプラス記号がついていない)
		NSScanner *scanner = [NSScanner scannerWithString:information[@"ToneControlShadow"]];
		int unsingedInt = 0;
		[scanner scanInt:&unsingedInt];
		SInt16 signedInt16 = (SInt16)unsingedInt;
		infoToneControlShadowValue = [NSNumber numberWithFloat:(float)signedInt16];
	}
	if (infoToneControlShadowValue) {
		// 階調補正のカメラプロパティ値リストを取得します。
		NSArray *toneControlLowPropertyValueList = [super cameraPropertyValueList:CameraPropertyToneControlLow error:nil];
		if (toneControlLowPropertyValueList) {
			// 階調補正リストを作成します。
			NSMutableArray *toneControlShadowNumberList = [[NSMutableArray alloc] init];
			[toneControlLowPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *toneControlShadowNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				[toneControlShadowNumberList addObject:toneControlShadowNumber];
			}];
			// 階調補正リストの中で階調補正値がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoToneControlShadowValue numberList:toneControlShadowNumberList];
			// 探したインデックスに対応するカメラプロパティの階調補正シャドー部で決定します。
			NSString *toneControlLowValue = toneControlLowPropertyValueList[nearestIndex];
			propertyValues[CameraPropertyToneControlLow] = toneControlLowValue;
		}
	}
	
	// 色彩/階調補正中間部を決定します。
	NSNumber *infoToneControlMiddleValue = nil;
	if (information[@"ToneControlMiddle"]) {
		// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にはプラス記号がついていない)
		NSScanner *scanner = [NSScanner scannerWithString:information[@"ToneControlMiddle"]];
		int unsingedInt = 0;
		[scanner scanInt:&unsingedInt];
		SInt16 signedInt16 = (SInt16)unsingedInt;
		infoToneControlMiddleValue = [NSNumber numberWithFloat:(float)signedInt16];
	}
	if (infoToneControlMiddleValue) {
		// 階調補正のカメラプロパティ値リストを取得します。
		NSArray *toneControlMiddlePropertyValueList = [super cameraPropertyValueList:CameraPropertyToneControlMiddle error:nil];
		if (toneControlMiddlePropertyValueList) {
			// 階調補正リストを作成します。
			NSMutableArray *toneControlMiddleNumberList = [[NSMutableArray alloc] init];
			[toneControlMiddlePropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *toneControlMiddleNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				[toneControlMiddleNumberList addObject:toneControlMiddleNumber];
			}];
			// 階調補正リストの中で階調補正値がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoToneControlMiddleValue numberList:toneControlMiddleNumberList];
			// 探したインデックスに対応するカメラプロパティの階調補正シャドー部で決定します。
			NSString *toneControlMiddleValue = toneControlMiddlePropertyValueList[nearestIndex];
			propertyValues[CameraPropertyToneControlMiddle] = toneControlMiddleValue;
		}
	}
	
	// 色彩/階調補正ハイライト部を決定します。
	NSNumber *infoToneControlHighValue = nil;
	if (information[@"ToneControlMiddle"]) {
		// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にはプラス記号がついていない)
		NSScanner *scanner = [NSScanner scannerWithString:information[@"ToneControlHigh"]];
		int unsingedInt = 0;
		[scanner scanInt:&unsingedInt];
		SInt16 signedInt16 = (SInt16)unsingedInt;
		infoToneControlHighValue = [NSNumber numberWithFloat:(float)signedInt16];
	}
	if (infoToneControlHighValue) {
		// 階調補正のカメラプロパティ値リストを取得します。
		NSArray *toneControlHighPropertyValueList = [super cameraPropertyValueList:CameraPropertyToneControlHigh error:nil];
		if (toneControlHighPropertyValueList) {
			// 階調補正リストを作成します。
			NSMutableArray *toneControlHighNumberList = [[NSMutableArray alloc] init];
			[toneControlHighPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
				NSString *strippedValue = [self stripCameraPropertyValue:value];
				NSNumber *toneControlHighNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
				[toneControlHighNumberList addObject:toneControlHighNumber];
			}];
			// 階調補正リストの中で階調補正値がもっとも近い値のインデックスを検索します。
			NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoToneControlHighValue numberList:toneControlHighNumberList];
			// 探したインデックスに対応するカメラプロパティの階調補正シャドー部で決定します。
			NSString *toneControlHighValue = toneControlHighPropertyValueList[nearestIndex];
			propertyValues[CameraPropertyToneControlHigh] = toneControlHighValue;
		}
	}
	
	// 色彩/モノクロフィルター効果を決定します。
	NSString *infoMonotoneFilterValue = information[@"MonotoneFilter"];
	if (infoMonotoneFilterValue) {
			// ピクチャーモードの値に対応する、モノクロフィルター効果のカメラプロパティ名を取得します。
			NSDictionary *monotonefilterPropertyMap = @{
				CameraPropertyValueColortoneMonotone: CameraPropertyMonotonefilterMonochrome,
				CameraPropertyValueColortoneRoughMonochrome: CameraPropertyMonotonefilterRoughMonochrome,
				CameraPropertyValueColortoneDramaticTone: CameraPropertyMonotonefilterDramaticTone,
			};
			NSString *monotonefilterProperty = monotonefilterPropertyMap[infoMonotoneFilterValue];
			if (monotonefilterProperty) {
				// モノクロフィルター効果のカメラプロパティ値リストを取得します。
				NSArray *monotonefilterPropertyValueList = [super cameraPropertyValueList:monotonefilterProperty error:nil];
				if (monotonefilterPropertyValueList) {
					// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
					// MARK: MonotoneFilter(モノクロフィルター効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
					NSDictionary *monotonefilterPropertyValueMap = @{
						@"NORMAL": @"NORMAL",
						@"YELLOW": @"YELLOW",
						@"ORANGE": @"ORANGE",
						@"RED": @"RED",
						@"GREEN": @"GREEN",
					};
					NSString *monotonefilterPropertyValue = monotonefilterPropertyValueMap[infoMonotoneFilterValue];
					if (monotonefilterPropertyValue) {
						monotonefilterPropertyValue = [NSString stringWithFormat:@"<%@/%@>", monotonefilterProperty, monotonefilterPropertyValue];
					}
					// 変換したカメラプロパティ値で決定します。
					propertyValues[monotonefilterProperty] = monotonefilterPropertyValue;
				}
			}
	}
	
	// 色彩/調色効果を決定します。
	NSString *infoMonotoneColorValue = information[@"MonotoneColor"];
	if (infoMonotoneColorValue) {
			// ピクチャーモードの値に対応する、調色効果のカメラプロパティ名を取得します。
			NSDictionary *monotonecolorPropertyMap = @{
				CameraPropertyValueColortoneMonotone: CameraPropertyMonotonecolorMonochrome,
				CameraPropertyValueColortoneRoughMonochrome: CameraPropertyMonotonecolorRoughMonochrome,
				CameraPropertyValueColortoneDramaticTone: CameraPropertyMonotonecolorDramaticTone,
			};
			NSString *monotonecolorProperty = monotonecolorPropertyMap[infoMonotoneFilterValue];
			if (monotonecolorProperty) {
				// 調色効果のカメラプロパティ値リストを取得します。
				NSArray *monotonecolorPropertyValueList = [super cameraPropertyValueList:monotonecolorProperty error:nil];
				if (monotonecolorPropertyValueList) {
					// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
					// MARK: MonotoneColor(調色効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
					// MARK: MonotoneColor(調色効果)は先頭の"LIKE_"が取り除かれた形式で返されるようです。
					NSDictionary *monotonecolorPropertyValueMap = @{
						@"NORMAL": @"NORMAL",
						@"SEPIA": @"LIKE_SEPIA",
						@"BLUE": @"LIKE_BLUE",
						@"PURPLE": @"LIKE_PURPLE",
						@"GREEN": @"LIKE_GREEN",
					};
					NSString *monotonecolorPropertyValue = monotonecolorPropertyValueMap[infoMonotoneFilterValue];
					if (monotonecolorPropertyValue) {
						monotonecolorPropertyValue = [NSString stringWithFormat:@"<%@/%@>", monotonecolorProperty, monotonecolorPropertyValue];
					}
					// 変換したカメラプロパティ値で決定します。
					propertyValues[monotonecolorProperty] = monotonecolorPropertyValue;
				}
			}
	}

	// 色彩/カラークリエーター用色相を決定します。
	if (propertyValues[CameraPropertyColortone] &&
		[propertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneColorCreator]) {
		NSNumber *infoColorCreatorColorValue = nil;
		if (information[@"ColorCreatorColor"]) {
			infoColorCreatorColorValue = [NSNumber numberWithFloat:[information[@"ColorCreatorColor"] floatValue]];
		}
		if (infoColorCreatorColorValue) {
			// カラークリエーター用色相のカメラプロパティ値リストを取得します。
			// MARK: SDK 1.1.1では、撮影モード以外ではカラークリエーター用色相のカメラプロパティ値の正しいリストが取得できないようです。
			//NSArray *colorCreatorColorPropertyValueList = [super cameraPropertyValueList:CameraPropertyColorCreatorColor error:nil];
			NSArray *colorCreatorColorPropertyValueList = @[
				@"<COLOR_CREATOR_COLOR/0>", @"<COLOR_CREATOR_COLOR/1>", @"<COLOR_CREATOR_COLOR/2>",
				@"<COLOR_CREATOR_COLOR/3>", @"<COLOR_CREATOR_COLOR/4>", @"<COLOR_CREATOR_COLOR/5>",
				@"<COLOR_CREATOR_COLOR/6>", @"<COLOR_CREATOR_COLOR/7>", @"<COLOR_CREATOR_COLOR/8>",
				@"<COLOR_CREATOR_COLOR/9>",
				@"<COLOR_CREATOR_COLOR/10>", @"<COLOR_CREATOR_COLOR/11>", @"<COLOR_CREATOR_COLOR/12>",
				@"<COLOR_CREATOR_COLOR/13>", @"<COLOR_CREATOR_COLOR/14>", @"<COLOR_CREATOR_COLOR/15>",
				@"<COLOR_CREATOR_COLOR/16>", @"<COLOR_CREATOR_COLOR/17>", @"<COLOR_CREATOR_COLOR/18>",
				@"<COLOR_CREATOR_COLOR/19>",
				@"<COLOR_CREATOR_COLOR/20>", @"<COLOR_CREATOR_COLOR/21>", @"<COLOR_CREATOR_COLOR/22>",
				@"<COLOR_CREATOR_COLOR/23>", @"<COLOR_CREATOR_COLOR/24>", @"<COLOR_CREATOR_COLOR/25>",
				@"<COLOR_CREATOR_COLOR/26>", @"<COLOR_CREATOR_COLOR/27>", @"<COLOR_CREATOR_COLOR/28>",
				@"<COLOR_CREATOR_COLOR/29>",
			];
			if (colorCreatorColorPropertyValueList) {
				// カラークリエーター用色相リストを作成します。
				NSMutableArray *colorCreatorColorNumberList = [[NSMutableArray alloc] init];
				[colorCreatorColorPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
					NSString *strippedValue = [self stripCameraPropertyValue:value];
					NSNumber *colorCreatorColorNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
					[colorCreatorColorNumberList addObject:colorCreatorColorNumber];
				}];
				// カラークリエーター用色相リストの中で色相がもっとも近い値のインデックスを検索します。
				NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoColorCreatorColorValue numberList:colorCreatorColorNumberList];
				// 探したインデックスに対応するカメラプロパティのカラークリエーター用色相で決定します。
				NSString *colorCreatorColorValue = colorCreatorColorPropertyValueList[nearestIndex];
				propertyValues[CameraPropertyColorCreatorColor] = colorCreatorColorValue;
			}
		}
	}
	
	// 色彩/カラークリエーター用彩度を決定します。
	if (propertyValues[CameraPropertyColortone] &&
		[propertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneColorCreator]) {
		NSNumber *infoColorCreatorVividValue = nil;
		if (information[@"ColorCreatorVivid"]) {
			// 16ビット符号なし10進数になっているので書式化し直します。(しかも先頭にはプラス記号がついていない)
			NSScanner *scanner = [NSScanner scannerWithString:information[@"ColorCreatorVivid"]];
			int unsingedInt = 0;
			[scanner scanInt:&unsingedInt];
			SInt16 signedInt16 = (SInt16)unsingedInt;
			infoColorCreatorVividValue = [NSNumber numberWithFloat:(float)signedInt16];
		}
		if (infoColorCreatorVividValue) {
			// カラークリエーター用彩度のカメラプロパティ値リストを取得します。
			// MARK: SDK 1.1.1では、撮影モード以外ではカラークリエーター用彩度のカメラプロパティ値の正しいリストが取得できないようです。
			//NSArray *colorCreatorVividPropertyValueList = [super cameraPropertyValueList:CameraPropertyColorCreatorVivid error:nil];
			NSArray *colorCreatorVividPropertyValueList = @[
				@"<COLOR_CREATOR_VIVID/-4>",
				@"<COLOR_CREATOR_VIVID/-3>",
				@"<COLOR_CREATOR_VIVID/-2>",
				@"<COLOR_CREATOR_VIVID/-1>",
				@"<COLOR_CREATOR_VIVID/0>",
				@"<COLOR_CREATOR_VIVID/+1>",
				@"<COLOR_CREATOR_VIVID/+2>",
				@"<COLOR_CREATOR_VIVID/+3>",
			];
			if (colorCreatorVividPropertyValueList) {
				// カラークリエーター用彩度リストを作成します。
				NSMutableArray *colorCreatorVividNumberList = [[NSMutableArray alloc] init];
				[colorCreatorVividPropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
					NSString *strippedValue = [self stripCameraPropertyValue:value];
					NSNumber *colorCreatorVividNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
					[colorCreatorVividNumberList addObject:colorCreatorVividNumber];
				}];
				// カラークリエーター用彩度リストの中で彩度がもっとも近い値のインデックスを検索します。
				NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoColorCreatorVividValue numberList:colorCreatorVividNumberList];
				// 探したインデックスに対応するカメラプロパティのカラークリエーター用彩度で決定します。
				NSString *colorCreatorVividValue = colorCreatorVividPropertyValueList[nearestIndex];
				propertyValues[CameraPropertyColorCreatorVivid] = colorCreatorVividValue;
			}
		}
	}
	
	// 効果/パートカラー用色相を決定します。
	if (propertyValues[CameraPropertyColortone] &&
		[propertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortonePartcolor]) {
		NSNumber *infoColorPhaseValue = nil;
		if (information[@"ColorPhase"]) {
			infoColorPhaseValue = [NSNumber numberWithFloat:[information[@"ColorPhase"] floatValue]];
		}
		if (infoColorPhaseValue) {
			// パートカラー用色相のカメラプロパティ値リストを取得します。
			NSArray *colorPhasePropertyValueList = [super cameraPropertyValueList:CameraPropertyColorPhase error:nil];
			if (colorPhasePropertyValueList) {
				// パートカラー用色相リストを作成します。
				NSMutableArray *colorPhaseNumberList = [[NSMutableArray alloc] init];
				[colorPhasePropertyValueList enumerateObjectsUsingBlock:^(NSString *value, NSUInteger index, BOOL *stop) {
					NSString *strippedValue = [self stripCameraPropertyValue:value];
					NSNumber *colorPhaseNumber = [NSNumber numberWithFloat:[strippedValue floatValue]];
					[colorPhaseNumberList addObject:colorPhaseNumber];
				}];
				// パートカラー用色相リストの中で色相がもっとも近い値のインデックスを検索します。
				NSInteger nearestIndex = [self findNearestIndexOfNumberList:infoColorPhaseValue numberList:colorPhaseNumberList];
				// 探したインデックスに対応するカメラプロパティのパートカラー用色相で決定します。
				NSString *colorPhaseValue = colorPhasePropertyValueList[nearestIndex];
				propertyValues[CameraPropertyColorPhase] = colorPhaseValue;
			}
		}
	}
	
	// 効果/フィルターバリエーションを決定します。
	if (propertyValues[CameraPropertyColortone]) {
		NSString *infoEffectTypeValue = information[@"EffectType"];
		if (infoEffectTypeValue) {
			// ピクチャーモードの値に対応する、フィルターバリエーションのカメラプロパティ名を取得します。
			NSDictionary *artEffectTypePropertyMap = @{
				CameraPropertyValueColortonePopart: CameraPropertyArtEffectTypePopart,
				CameraPropertyValueColortoneDaydream: CameraPropertyArtEffectTypeDaydream,
				CameraPropertyValueColortoneRoughMonochrome: CameraPropertyArtEffectTypeRoughMonochrome,
				CameraPropertyValueColortoneToyPhoto: CameraPropertyArtEffectTypeToyPhoto,
				CameraPropertyValueColortoneMiniature: CameraPropertyArtEffectTypeMiniature,
				CameraPropertyValueColortoneCrossProcess: CameraPropertyArtEffectTypeCrossProcess,
				CameraPropertyValueColortoneDramaticTone: CameraPropertyArtEffectTypeDramaticTone,
				CameraPropertyValueColortoneLigneClair: CameraPropertyArtEffectTypeLigneClair,
				CameraPropertyValueColortonePastel: CameraPropertyArtEffectTypePastel,
				CameraPropertyValueColortoneVintage: CameraPropertyArtEffectTypeVintage,
				CameraPropertyValueColortonePartcolor: CameraPropertyArtEffectTypePartcolor,
			};
			NSString *artEffectTypeProperty = artEffectTypePropertyMap[propertyValues[CameraPropertyColortone]];
			if (artEffectTypeProperty) {
				// フィルターバリエーションのカメラプロパティ値リストを取得します。
				NSArray *artEffectTypePropertyValueList = [super cameraPropertyValueList:artEffectTypeProperty error:nil];
				if (artEffectTypePropertyValueList) {
					// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
					NSDictionary *artEffectTypePropertyValueMap = @{
						@"TYPE1": @"TYPE1",
						@"TYPE2": @"TYPE2",
						@"TYPE3": @"TYPE3",
					};
					NSString *artEffectTypePropertyValue = artEffectTypePropertyValueMap[infoEffectTypeValue];
					if (artEffectTypePropertyValue) {
						artEffectTypePropertyValue = [NSString stringWithFormat:@"<%@/%@>", artEffectTypeProperty, artEffectTypePropertyValue];
					}
					// 変換したカメラプロパティ値で決定します。
					propertyValues[artEffectTypeProperty] = artEffectTypePropertyValue;
				}
			}
		}
	}
	
	// 効果/追加エフェクトを決定します。
	if (propertyValues[CameraPropertyColortone]) {
		// ピクチャーモードの値に対応する、フィルターバリエーションのカメラプロパティ名を取得します。
		NSDictionary *artEffectHybridPropertyMap = @{
			CameraPropertyValueColortonePopart: CameraPropertyArtEffectHybridPopart,
			CameraPropertyValueColortoneFantasicFocus: CameraPropertyArtEffectHybridFantasicFocus,
			CameraPropertyValueColortoneDaydream: CameraPropertyArtEffectHybridDaydream,
			CameraPropertyValueColortoneLightTone: CameraPropertyArtEffectHybridLightTone,
			CameraPropertyValueColortoneRoughMonochrome: CameraPropertyArtEffectHybridRoughMonochrome,
			CameraPropertyValueColortoneToyPhoto: CameraPropertyArtEffectHybridToyPhoto,
			CameraPropertyValueColortoneMiniature: CameraPropertyArtEffectHybridMiniature,
			CameraPropertyValueColortoneCrossProcess: CameraPropertyArtEffectHybridCrossProcess,
			CameraPropertyValueColortoneGentleSepia: CameraPropertyArtEffectHybridGentleSepia,
			CameraPropertyValueColortoneDramaticTone: CameraPropertyArtEffectHybridDramaticTone,
			CameraPropertyValueColortoneLigneClair: CameraPropertyArtEffectHybridLigneClair,
			CameraPropertyValueColortonePastel: CameraPropertyArtEffectHybridPastel,
			CameraPropertyValueColortoneVintage: CameraPropertyArtEffectHybridVintage,
			CameraPropertyValueColortonePartcolor: CameraPropertyArtEffectHybridPartcolor,
		};
		NSString *artEffectHybridProperty = artEffectHybridPropertyMap[propertyValues[CameraPropertyColortone]];
		if (artEffectHybridProperty) {
			// フィルターバリエーションのカメラプロパティ値リストを取得します。
			NSArray *artEffectHybridPropertyValueList = [super cameraPropertyValueList:artEffectHybridProperty error:nil];
			if (artEffectHybridPropertyValueList) {
				// カメラプロパティ値リストに存在する値だけを使って、フィルターバリエーションリストを作成します。
				NSDictionary *artEffectHybridPropertyValueReverseMap = @{
					@"FANTASIC_FOCUS": @"FantasicFocus",
					@"TOY_PHOTO": @"ToyPhoto",
					@"WHITE_EDGE": @"WhiteEdge",
					@"FRAME_JAGGY": @"FrameJaggy",
					@"STARLIGHT": @"Starlight",
					@"MINIATURE_VERTICAL": @"MiniatureVertical",
					@"MINIATURE_HORIZON": @"MiniatureHorizon",
					@"SHADING_VERTICAL": @"ShadingVertical",
					@"SHADING_HORIZON": @"ShadingHorizon",
				};
				NSMutableDictionary *artEffectHybridPropertyValueMap = [[NSMutableDictionary alloc] init];
				[artEffectHybridPropertyValueList enumerateObjectsUsingBlock:^(NSString *propertyValue, NSUInteger index, BOOL *stop) {
					NSString *strippedValue = [self stripCameraPropertyValue:propertyValue];
					if (artEffectHybridPropertyValueReverseMap[strippedValue]) {
						[artEffectHybridPropertyValueMap setObject:strippedValue forKey:artEffectHybridPropertyValueReverseMap[strippedValue]];
					}
				}];
				// フィルターバリエーションリストを検索します。
				__block NSString *artEffectHybridPropertyValue = nil;
				[artEffectHybridPropertyValueMap enumerateKeysAndObjectsUsingBlock:^(NSString *informationKey, NSString *propertyValue, BOOL *stop) {
					if ([information[informationKey] isEqualToString:@"ON"]) {
						artEffectHybridPropertyValue = propertyValue;
						*stop = YES;
					}
				}];
				if (!artEffectHybridPropertyValue) {
					artEffectHybridPropertyValue = @"OFF";
				}
				artEffectHybridPropertyValue = [NSString stringWithFormat:@"<%@/%@>", artEffectHybridProperty, artEffectHybridPropertyValue];
				// 検索したカメラプロパティ値で決定します。
				propertyValues[artEffectHybridProperty] = artEffectHybridPropertyValue;
			}
		}
	}
	
	// AE設定/測光方式を決定します。
	NSNumber *exifMeteringModeValue = exifDictionary[(NSString *)kCGImagePropertyExifMeteringMode];
	if (exifMeteringModeValue) {
		NSString *aeValue;
		switch ([exifMeteringModeValue longValue]) {
			case 2: // 中央重点
				aeValue = CameraPropertyValueAeAeCenter;
				break;
			case 3: // スポット
				aeValue = CameraPropertyValueAeAePinpoint;
				break;
			default:
				aeValue = CameraPropertyValueAeAeEsp;
				break;
		}
		propertyValues[CameraPropertyAe] = aeValue;
	}
	
	// 保存設定/写真アスペクト比を決定します。
	NSString *infoAspectRatioValue = information[@"AspectRatio"];
	if (infoAspectRatioValue) {
		// 写真アスペクト比のカメラプロパティ値リストを取得します。
		NSArray *aspectRatioPropertyValueList = [super cameraPropertyValueList:CameraPropertyAspectRatio error:nil];
		if (aspectRatioPropertyValueList) {
			// 値リストを取得したものの、コンテンツ情報の値との互換性が保たれていないので固定の変換を行います。
			NSDictionary *aspectRatioPropertyValueMap = @{
				@"04_03": CameraPropertyValueAspectRatio0403,
				@"16_09": CameraPropertyValueAspectRatio1609,
				@"03_02": CameraPropertyValueAspectRatio0302,
				@"06_06": CameraPropertyValueAspectRatio0606,
				@"03_04": CameraPropertyValueAspectRatio0304,
			};
			NSString *aspectRatioValue = aspectRatioPropertyValueMap[infoAspectRatioValue];
			// 変換したカメラプロパティ値で決定します。
			propertyValues[CameraPropertyAspectRatio] = aspectRatioValue;
		}
	}
	
	// スナップショットにする情報を集約します。
	NSDictionary *snapshot = @{
		CameraSettingSnapshotFormatVersionKey: CameraSettingSnapshotFormatVersion,
		CameraSettingSnapshotPropertyValuesKey: propertyValues,
#if 0
		CameraSettingSnapshotLiveViewSizeKey: liveViewSize,
		CameraSettingSnapshotAutoBracketingModeKey: autoBracketingMode,
		CameraSettingSnapshotAutoBracketingCountKey: autoBracketingCount,
		CameraSettingSnapshotAutoBracketingStepKey: autoBracketingStep,
		CameraSettingSnapshotIntervalTimerModeKey: intervalTimerMode,
		CameraSettingSnapshotIntervalTimerCountKey: intervalTimerCount,
		CameraSettingSnapshotIntervalTimerTimeKey: intervalTimerTime,
		CameraSettingSnapshotMagnifyingLiveViewScaleKey: magnifyingLiveViewScale,
#endif
	};
	return snapshot;
}

- (NSDictionary *)optimizeSnapshotOfSetting:(NSDictionary *)snapshot {
	DEBUG_LOG(@"snapshot=%@", snapshot);

	// カメラプロパティ値の辞書がない場合は最適化できません。そのまま返します。
	NSDictionary *propertyValues = snapshot[CameraSettingSnapshotPropertyValuesKey];
	if (!propertyValues) {
		return  snapshot;
	}
	
	// カメラプロパティ値の辞書を最適化を開始します。
	// 最適化の出力先を準備します。
	NSMutableDictionary *optimizedPropertyValues = [[NSMutableDictionary alloc] init];
	
	// 撮影モード
	// 動画撮影モード
	NSString *mode = nil;
	NSString *takeMode = propertyValues[CameraPropertyTakemode];
	if (!takeMode) {
		// 撮影モードが未設定の場合は最適化できません。
		return  snapshot;
	}
	if ([takeMode isEqualToString:CameraPropertyValueTakemodeMovie]) {
		NSString *exposeMovieSelect = propertyValues[CameraPropertyExposeMovieSelect];
		if (!exposeMovieSelect) {
			// 撮影モードが動画で動画撮影モードが未設定の場合は最適化できません。
			return  snapshot;
		}
		optimizedPropertyValues[CameraPropertyTakemode] = takeMode;
		optimizedPropertyValues[CameraPropertyExposeMovieSelect] = exposeMovieSelect;
		mode = exposeMovieSelect;
	} else {
		optimizedPropertyValues[CameraPropertyTakemode] = takeMode;
		mode = takeMode;
	}
	
	// 設定可能なカメラプロパティのリストを取得します。
	NSArray *enabledProperties = [self listEnabledPropertiesForTakeMode:mode];

	// 以下、読み書き可能でかつ設定可能な条件に適合するカメラプロパティのみを選んでそのカメラプロパティ値を出力に送ります。
	
	// 絞り値(F値)
	if ([enabledProperties containsObject:CameraPropertyAperture]) {
		optimizedPropertyValues[CameraPropertyAperture] = propertyValues[CameraPropertyAperture];
	}
	// 測光方式
	if ([enabledProperties containsObject:CameraPropertyAe]) {
		optimizedPropertyValues[CameraPropertyAe] = propertyValues[CameraPropertyAe];
	}
	// ISO感度
	if ([enabledProperties containsObject:CameraPropertyIso]) {
		optimizedPropertyValues[CameraPropertyIso] = propertyValues[CameraPropertyIso];
	}
	// 露出補正値
	if ([enabledProperties containsObject:CameraPropertyExprev]) {
		optimizedPropertyValues[CameraPropertyExprev] = propertyValues[CameraPropertyExprev];
	}
	// ドライブモード
	if ([enabledProperties containsObject:CameraPropertyTakeDrive]) {
		optimizedPropertyValues[CameraPropertyTakeDrive] = propertyValues[CameraPropertyTakeDrive];
	}
	// 連写速度
	if ([optimizedPropertyValues[CameraPropertyTakeDrive] isEqualToString:CameraPropertyValueTakeDriveDriveContinue]) {
		// ドライブモードが連写になっていないと意味がありません。
		if ([enabledProperties containsObject:CameraPropertyContinuousShootingVelocity]) {
			optimizedPropertyValues[CameraPropertyContinuousShootingVelocity] = propertyValues[CameraPropertyContinuousShootingVelocity];
		}
	}
	// アスペクト比
	if ([enabledProperties containsObject:CameraPropertyAspectRatio]) {
		optimizedPropertyValues[CameraPropertyAspectRatio] = propertyValues[CameraPropertyAspectRatio];
	}
	// シャッター速度
	if ([enabledProperties containsObject:CameraPropertyShutter]) {
		optimizedPropertyValues[CameraPropertyShutter] = propertyValues[CameraPropertyShutter];
	}
	// 静止画サイズ
	if ([enabledProperties containsObject:CameraPropertyImagesize]) {
		optimizedPropertyValues[CameraPropertyImagesize] = propertyValues[CameraPropertyImagesize];
	}
	// RAW設定
	if ([enabledProperties containsObject:CameraPropertyRaw]) {
		optimizedPropertyValues[CameraPropertyRaw] = propertyValues[CameraPropertyRaw];
	}
	// 圧縮率
	if ([enabledProperties containsObject:CameraPropertyCompressibilityRatio]) {
		optimizedPropertyValues[CameraPropertyCompressibilityRatio] = propertyValues[CameraPropertyCompressibilityRatio];
	}
	// クリップ記録時間
	if ([optimizedPropertyValues[CameraPropertyQualityMovie] isEqualToString:CameraPropertyValueQualityMovieShortMovie]) {
		// 動画画質モードがクリップになっていないと意味がありません。
		if ([enabledProperties containsObject:CameraPropertyQualityMovieShortMovieRecordTime]) {
			optimizedPropertyValues[CameraPropertyQualityMovieShortMovieRecordTime] = propertyValues[CameraPropertyQualityMovieShortMovieRecordTime];
		}
	}
	// 動画画質モード
	if ([enabledProperties containsObject:CameraPropertyQualityMovie]) {
		optimizedPropertyValues[CameraPropertyQualityMovie] = propertyValues[CameraPropertyQualityMovie];
	}
	// 撮影画像保存先
	if ([enabledProperties containsObject:CameraPropertyDestinationFile]) {
		optimizedPropertyValues[CameraPropertyDestinationFile] = propertyValues[CameraPropertyDestinationFile];
	}
	// フォーカスモード静止画用
	if ([enabledProperties containsObject:CameraPropertyFocusStill]) {
		optimizedPropertyValues[CameraPropertyFocusStill] = propertyValues[CameraPropertyFocusStill];
	}
	// フルタイムAF
	if ([enabledProperties containsObject:CameraPropertyFullTimeAf]) {
		optimizedPropertyValues[CameraPropertyFullTimeAf] = propertyValues[CameraPropertyFullTimeAf];
	}
	// フォーカスモード動画用
	if ([enabledProperties containsObject:CameraPropertyFocusMovie]) {
		optimizedPropertyValues[CameraPropertyFocusMovie] = propertyValues[CameraPropertyFocusMovie];
	}
	// 顔検出
	if ([enabledProperties containsObject:CameraPropertyFaceScan]) {
		optimizedPropertyValues[CameraPropertyFaceScan] = propertyValues[CameraPropertyFaceScan];
	}
	// IS焦点距離
	if ([enabledProperties containsObject:CameraPropertyAntiShakeFocalLength]) {
		optimizedPropertyValues[CameraPropertyAntiShakeFocalLength] = propertyValues[CameraPropertyAntiShakeFocalLength];
	}
	// 撮影結果確認用画像
	if ([enabledProperties containsObject:CameraPropertyRecview]) {
		optimizedPropertyValues[CameraPropertyRecview] = propertyValues[CameraPropertyRecview];
	}
	// 動画手ぶれ補正
	if ([enabledProperties containsObject:CameraPropertyAntiShakeMovie]) {
		optimizedPropertyValues[CameraPropertyAntiShakeMovie] = propertyValues[CameraPropertyAntiShakeMovie];
	}
	// 音量レベル
	if ([enabledProperties containsObject:CameraPropertySoundVolumeLevel]) {
		optimizedPropertyValues[CameraPropertySoundVolumeLevel] = propertyValues[CameraPropertySoundVolumeLevel];
	}
	// Exif位置付与設定
	if ([enabledProperties containsObject:CameraPropertyGps]) {
		optimizedPropertyValues[CameraPropertyGps] = propertyValues[CameraPropertyGps];
	}
	// Wi-Fiチャンネル
	if ([enabledProperties containsObject:CameraPropertyWifiCh]) {
		optimizedPropertyValues[CameraPropertyWifiCh] = propertyValues[CameraPropertyWifiCh];
	}

	// 仕上がり・ピクチャーモード
	if ([enabledProperties containsObject:CameraPropertyColortone]) {
		optimizedPropertyValues[CameraPropertyColortone] = propertyValues[CameraPropertyColortone];
	}
	// ピクチャーモード別
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneIFinish]) {
		// ピクチャーモードの仕上がり設定 i-Finish コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastIFinish]) {
			optimizedPropertyValues[CameraPropertyContrastIFinish] = propertyValues[CameraPropertyContrastIFinish];
		}
		// ピクチャーモードの仕上がり設定 i-Finish シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpIFinish]) {
			optimizedPropertyValues[CameraPropertySharpIFinish] = propertyValues[CameraPropertySharpIFinish];
		}
		// ピクチャーモードの仕上がり設定 i-Finish 彩度
		if ([enabledProperties containsObject:CameraPropertySaturationLevelIFinish]) {
			optimizedPropertyValues[CameraPropertySaturationLevelIFinish] = propertyValues[CameraPropertySaturationLevelIFinish];
		}
		// ピクチャーモードの仕上がり設定 i-Finish 階調
		if ([enabledProperties containsObject:CameraPropertyToneIFinish]) {
			optimizedPropertyValues[CameraPropertyToneIFinish] = propertyValues[CameraPropertyToneIFinish];
		}
		// ピクチャーモードの仕上がり設定 i-Finish 効果強弱
		if ([enabledProperties containsObject:CameraPropertyEffectLevelIFinish]) {
			optimizedPropertyValues[CameraPropertyEffectLevelIFinish] = propertyValues[CameraPropertyEffectLevelIFinish];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneVivid]) {
		// ピクチャーモードの仕上がり設定 Vivid コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastVivid]) {
			optimizedPropertyValues[CameraPropertyContrastVivid] = propertyValues[CameraPropertyContrastVivid];
		}
		// ピクチャーモードの仕上がり設定 Vivid シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpVivid]) {
			optimizedPropertyValues[CameraPropertySharpVivid] = propertyValues[CameraPropertySharpVivid];
		}
		// ピクチャーモードの仕上がり設定 Vivid 彩度
		if ([enabledProperties containsObject:CameraPropertySaturationLevelVivid]) {
			optimizedPropertyValues[CameraPropertySaturationLevelVivid] = propertyValues[CameraPropertySaturationLevelVivid];
		}
		// ピクチャーモードの仕上がり設定 Vivid 階調
		if ([enabledProperties containsObject:CameraPropertyToneVivid]) {
			optimizedPropertyValues[CameraPropertyToneVivid] = propertyValues[CameraPropertyToneVivid];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneNatural]) {
		// ピクチャーモードの仕上がり設定 NATURAL コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastNatural]) {
			optimizedPropertyValues[CameraPropertyContrastNatural] = propertyValues[CameraPropertyContrastNatural];
		}
		// ピクチャーモードの仕上がり設定 NATURAL シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpNatural]) {
			optimizedPropertyValues[CameraPropertySharpNatural] = propertyValues[CameraPropertySharpNatural];
		}
		// ピクチャーモードの仕上がり設定 NATURAL 彩度
		if ([enabledProperties containsObject:CameraPropertySaturationLevelNatural]) {
			optimizedPropertyValues[CameraPropertySaturationLevelNatural] = propertyValues[CameraPropertySaturationLevelNatural];
		}
		// ピクチャーモードの仕上がり設定 NATURAL 階調
		if ([enabledProperties containsObject:CameraPropertyToneNatural]) {
			optimizedPropertyValues[CameraPropertyToneNatural] = propertyValues[CameraPropertyToneNatural];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneFlat]) {
		// ピクチャーモードの仕上がり設定 FLAT コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastFlat]) {
			optimizedPropertyValues[CameraPropertyContrastFlat] = propertyValues[CameraPropertyContrastFlat];
		}
		// ピクチャーモードの仕上がり設定 FLAT シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpFlat]) {
			optimizedPropertyValues[CameraPropertySharpFlat] = propertyValues[CameraPropertySharpFlat];
		}
		// ピクチャーモードの仕上がり設定 FLAT 彩度
		if ([enabledProperties containsObject:CameraPropertySaturationLevelFlat]) {
			optimizedPropertyValues[CameraPropertySaturationLevelFlat] = propertyValues[CameraPropertySaturationLevelFlat];
		}
		// ピクチャーモードの仕上がり設定 FLAT 階調
		if ([enabledProperties containsObject:CameraPropertyToneFlat]) {
			optimizedPropertyValues[CameraPropertyToneFlat] = propertyValues[CameraPropertyToneFlat];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortonePopart]) {
		// ピクチャーモードの仕上がり設定 SOFT コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastSoft]) {
			optimizedPropertyValues[CameraPropertyContrastSoft] = propertyValues[CameraPropertyContrastSoft];
		}
		// ピクチャーモードの仕上がり設定 SOFT シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpSoft]) {
			optimizedPropertyValues[CameraPropertySharpSoft] = propertyValues[CameraPropertySharpSoft];
		}
		// ピクチャーモードの仕上がり設定 SOFT 彩度
		if ([enabledProperties containsObject:CameraPropertySaturationLevelSoft]) {
			optimizedPropertyValues[CameraPropertySaturationLevelSoft] = propertyValues[CameraPropertySaturationLevelSoft];
		}
		// ピクチャーモードの仕上がり設定 SOFT 階調
		if ([enabledProperties containsObject:CameraPropertyToneSoft]) {
			optimizedPropertyValues[CameraPropertyToneSoft] = propertyValues[CameraPropertyToneSoft];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneMonotone]) {
		// ピクチャーモードの仕上がり設定 モノトーン コントラスト
		if ([enabledProperties containsObject:CameraPropertyContrastMonochrome]) {
			optimizedPropertyValues[CameraPropertyContrastMonochrome] = propertyValues[CameraPropertyContrastMonochrome];
		}
		// ピクチャーモードの仕上がり設定 モノトーン シャープネス
		if ([enabledProperties containsObject:CameraPropertySharpMonochrome]) {
			optimizedPropertyValues[CameraPropertySharpMonochrome] = propertyValues[CameraPropertySharpMonochrome];
		}
		// ピクチャーモードの仕上がり設定 モノトーン 階調
		if ([enabledProperties containsObject:CameraPropertyToneMonochrome]) {
			optimizedPropertyValues[CameraPropertyToneMonochrome] = propertyValues[CameraPropertyToneMonochrome];
		}
		// モノクロフィルター効果 ピクチャーモード モノトーン
		if ([enabledProperties containsObject:CameraPropertyMonotonefilterMonochrome]) {
			optimizedPropertyValues[CameraPropertyMonotonefilterMonochrome] = propertyValues[CameraPropertyMonotonefilterMonochrome];
		}
		// 調色効果 ピクチャーモード モノトーン
		if ([enabledProperties containsObject:CameraPropertyMonotonecolorMonochrome]) {
			optimizedPropertyValues[CameraPropertyMonotonecolorMonochrome] = propertyValues[CameraPropertyMonotonecolorMonochrome];
		}
	} else if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneColorCreator]) {
		// カラークリエーター用　色相
		if ([enabledProperties containsObject:CameraPropertyColorCreatorColor]) {
			optimizedPropertyValues[CameraPropertyColorCreatorColor] = propertyValues[CameraPropertyColorCreatorColor];
		}
		// カラークリエーター用　彩度
		if ([enabledProperties containsObject:CameraPropertyColorCreatorVivid]) {
			optimizedPropertyValues[CameraPropertyColorCreatorVivid] = propertyValues[CameraPropertyColorCreatorVivid];
		}
	}
	// アートフィルター種別
	if ([enabledProperties containsObject:CameraPropertyRecentlyArtFilter]) {
		optimizedPropertyValues[CameraPropertyRecentlyArtFilter] = propertyValues[CameraPropertyRecentlyArtFilter];
	}
	// ART-BKT別
	if ([optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterArtBkt]) {
		// ART-BKT ポップアート
		if ([enabledProperties containsObject:CameraPropertyBracketPictPopart]) {
			optimizedPropertyValues[CameraPropertyBracketPictPopart] = propertyValues[CameraPropertyBracketPictPopart];
		}
		// ART-BKT ファンタジックフォーカス
		if ([enabledProperties containsObject:CameraPropertyBracketPictFantasicFocus]) {
			optimizedPropertyValues[CameraPropertyBracketPictFantasicFocus] = propertyValues[CameraPropertyBracketPictFantasicFocus];
		}
		// ART-BKT デイドリーム
		if ([enabledProperties containsObject:CameraPropertyBracketPictDaydream]) {
			optimizedPropertyValues[CameraPropertyBracketPictDaydream] = propertyValues[CameraPropertyBracketPictDaydream];
		}
		// ART-BKT ライトトーン
		if ([enabledProperties containsObject:CameraPropertyBracketPictLightTone]) {
			optimizedPropertyValues[CameraPropertyBracketPictLightTone] = propertyValues[CameraPropertyBracketPictLightTone];
		}
		// ART-BKT ラフモノクローム
		if ([enabledProperties containsObject:CameraPropertyBracketPictRoughMonochrome]) {
			optimizedPropertyValues[CameraPropertyBracketPictRoughMonochrome] = propertyValues[CameraPropertyBracketPictRoughMonochrome];
		}
		// ART-BKT トイフォト
		if ([enabledProperties containsObject:CameraPropertyBracketPictToyPhoto]) {
			optimizedPropertyValues[CameraPropertyBracketPictToyPhoto] = propertyValues[CameraPropertyBracketPictToyPhoto];
		}
		// ART-BKT ジオラマ
		if ([enabledProperties containsObject:CameraPropertyBracketPictMiniature]) {
			optimizedPropertyValues[CameraPropertyBracketPictMiniature] = propertyValues[CameraPropertyBracketPictMiniature];
		}
		// ART-BKT クロスプロセス
		if ([enabledProperties containsObject:CameraPropertyBracketPictCrossProcess]) {
			optimizedPropertyValues[CameraPropertyBracketPictCrossProcess] = propertyValues[CameraPropertyBracketPictCrossProcess];
		}
		// ART-BKT ジェントルセピア
		if ([enabledProperties containsObject:CameraPropertyBracketPictGentleSepia]) {
			optimizedPropertyValues[CameraPropertyBracketPictGentleSepia] = propertyValues[CameraPropertyBracketPictGentleSepia];
		}
		// ART-BKT ドラマチックトーン
		if ([enabledProperties containsObject:CameraPropertyBracketPictDramaticTone]) {
			optimizedPropertyValues[CameraPropertyBracketPictDramaticTone] = propertyValues[CameraPropertyBracketPictDramaticTone];
		}
		// ART-BKT リーニュークレール
		if ([enabledProperties containsObject:CameraPropertyBracketPictLigneClair]) {
			optimizedPropertyValues[CameraPropertyBracketPictLigneClair] = propertyValues[CameraPropertyBracketPictLigneClair];
		}
		// ART-BKT ウォーターカラー
		if ([enabledProperties containsObject:CameraPropertyBracketPictPastel]) {
			optimizedPropertyValues[CameraPropertyBracketPictPastel] = propertyValues[CameraPropertyBracketPictPastel];
		}
		// ART-BKT ヴィンテージ
		if ([enabledProperties containsObject:CameraPropertyBracketPictVintage]) {
			optimizedPropertyValues[CameraPropertyBracketPictVintage] = propertyValues[CameraPropertyBracketPictVintage];
		}
		// ART-BKT パートカラー
		if ([enabledProperties containsObject:CameraPropertyBracketPictPartcolor]) {
			optimizedPropertyValues[CameraPropertyBracketPictPartcolor] = propertyValues[CameraPropertyBracketPictPartcolor];
		}
	}
	// アートフィルター ポップアート
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortonePopart] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterPopart] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictPopartOn]) {
		// アートフィルターバリエーション ポップアート
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypePopart]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypePopart] = propertyValues[CameraPropertyArtEffectTypePopart];
		}
		// アートエフェクト ポップアート
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridPopart]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridPopart] = propertyValues[CameraPropertyArtEffectHybridPopart];
		}
	}
	// アートフィルター デイドリーム
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneDaydream] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterDaydream] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictDaydreamOn]) {
		// アートフィルターバリエーション デイドリーム
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeDaydream]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeDaydream] = propertyValues[CameraPropertyArtEffectTypeDaydream];
		}
		// アートエフェクト デイドリーム
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridDaydream]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridDaydream] = propertyValues[CameraPropertyArtEffectHybridDaydream];
		}
	}
	// アートフィルター ラフモノクローム
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneRoughMonochrome] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterRoughMonochrome] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictRoughMonochromeOn]) {
		// アートフィルターバリエーション ラフモノクローム
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeRoughMonochrome]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeRoughMonochrome] = propertyValues[CameraPropertyArtEffectTypeRoughMonochrome];
		}
		// アートエフェクト ラフモノクローム
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridRoughMonochrome]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridRoughMonochrome] = propertyValues[CameraPropertyArtEffectHybridRoughMonochrome];
		}
		// モノクロフィルター効果 アートフィルター ラフモノクローム
		if ([enabledProperties containsObject:CameraPropertyMonotonefilterRoughMonochrome]) {
			optimizedPropertyValues[CameraPropertyMonotonefilterRoughMonochrome] = propertyValues[CameraPropertyMonotonefilterRoughMonochrome];
		}
		// 調色効果 アートフィルター ラフモノクローム
		if ([enabledProperties containsObject:CameraPropertyMonotonecolorRoughMonochrome]) {
			optimizedPropertyValues[CameraPropertyMonotonecolorRoughMonochrome] = propertyValues[CameraPropertyMonotonecolorRoughMonochrome];
		}
	}
	// アートフィルター トイフォト
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneToyPhoto] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterToyPhoto] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictToyPhotoOn]) {
		// アートフィルターバリエーション トイフォト
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeToyPhoto]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeToyPhoto] = propertyValues[CameraPropertyArtEffectTypeToyPhoto];
		}
		// アートエフェクト トイフォト
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridToyPhoto]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridToyPhoto] = propertyValues[CameraPropertyArtEffectHybridToyPhoto];
		}
	}
	// アートフィルター トイフォト
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneMiniature] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterMiniature] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictMiniatureOn]) {
		// アートフィルターバリエーション ジオラマ
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeMiniature]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeMiniature] = propertyValues[CameraPropertyArtEffectTypeMiniature];
		}
		// アートエフェクト ジオラマ
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridMiniature]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridMiniature] = propertyValues[CameraPropertyArtEffectHybridMiniature];
		}
	}
	// アートフィルター クロスプロセス
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneCrossProcess] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterCrossProcess] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictCrossProcessOn]) {
		// アートフィルターバリエーション クロスプロセス
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeCrossProcess]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeCrossProcess] = propertyValues[CameraPropertyArtEffectTypeCrossProcess];
		}
		// アートエフェクト クロスプロセス
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridCrossProcess]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridCrossProcess] = propertyValues[CameraPropertyArtEffectHybridCrossProcess];
		}
	}
	// アートフィルター ドラマチックトーン
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneDramaticTone] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterDramaticTone] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictDramaticToneOn]) {
		// アートフィルターバリエーション ドラマチックトーン
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeDramaticTone]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeDramaticTone] = propertyValues[CameraPropertyArtEffectTypeDramaticTone];
		}
		// アートエフェクト ドラマチックトーン
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridDramaticTone]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridDramaticTone] = propertyValues[CameraPropertyArtEffectHybridDramaticTone];
		}
		// モノクロフィルター効果 アートフィルター ドラマチックトーン
		if ([enabledProperties containsObject:CameraPropertyMonotonefilterDramaticTone]) {
			optimizedPropertyValues[CameraPropertyMonotonefilterDramaticTone] = propertyValues[CameraPropertyMonotonefilterDramaticTone];
		}
		// 調色効果 アートフィルター ドラマチックトーン
		if ([enabledProperties containsObject:CameraPropertyMonotonecolorDramaticTone]) {
			optimizedPropertyValues[CameraPropertyMonotonecolorDramaticTone] = propertyValues[CameraPropertyMonotonecolorDramaticTone];
		}
	}
	// アートフィルター ドラマチックトーン
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneLigneClair] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterLigneClair] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictLigneClairOn]) {
		// アートフィルターバリエーション リーニュクレール
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeLigneClair]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeLigneClair] = propertyValues[CameraPropertyArtEffectTypeLigneClair];
		}
		// アートエフェクト リーニュクレール
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridLigneClair]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridLigneClair] = propertyValues[CameraPropertyArtEffectHybridLigneClair];
		}
	}
	// アートフィルター ウォーターカラー
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortonePastel] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterPastel] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictPastelOn]) {
		// アートフィルターバリエーション ウォーターカラー
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypePastel]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypePastel] = propertyValues[CameraPropertyArtEffectTypePastel];
		}
		// アートエフェクト ウォーターカラー
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridPastel]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridPastel] = propertyValues[CameraPropertyArtEffectHybridPastel];
		}
	}
	// アートフィルター ヴィンテージ
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneVintage] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterVintage] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictVintageOn]) {
		// アートフィルターバリエーション ヴィンテージ
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypeVintage]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypeVintage] = propertyValues[CameraPropertyArtEffectTypeVintage];
		}
		// アートエフェクト ヴィンテージ
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridVintage]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridVintage] = propertyValues[CameraPropertyArtEffectHybridVintage];
		}
	}
	// アートフィルター パートカラー
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortonePartcolor] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterPartcolor] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictPartcolorOn]) {
		// アートフィルターバリエーション パートカラー
		if ([enabledProperties containsObject:CameraPropertyArtEffectTypePartcolor]) {
			optimizedPropertyValues[CameraPropertyArtEffectTypePartcolor] = propertyValues[CameraPropertyArtEffectTypePartcolor];
		}
		// アートエフェクト パートカラー
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridPartcolor]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridPartcolor] = propertyValues[CameraPropertyArtEffectHybridPartcolor];
		}
		// パートカラー用色相
		if ([enabledProperties containsObject:CameraPropertyColorPhase]) {
			optimizedPropertyValues[CameraPropertyColorPhase] = propertyValues[CameraPropertyColorPhase];
		}
	}
	// アートフィルター ファンタジックフォーカス
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneFantasicFocus] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterFantasicFocus] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictFantasicFocusOn]) {
		// アートエフェクト ファンタジックフォーカス
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridFantasicFocus]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridFantasicFocus] = propertyValues[CameraPropertyArtEffectHybridFantasicFocus];
		}
	}
	// アートフィルター ライトトーン
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneLightTone] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterLightTone] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictLightToneOn]) {
		// アートエフェクト ライトトーン
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridLightTone]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridLightTone] = propertyValues[CameraPropertyArtEffectHybridLightTone];
		}
	}
	// アートフィルター ジェントルセピア
	if ([optimizedPropertyValues[CameraPropertyColortone] isEqualToString:CameraPropertyValueColortoneGentleSepia] ||
		[optimizedPropertyValues[CameraPropertyRecentlyArtFilter] isEqualToString:CameraPropertyValueRecentlyArtFilterGentleSepia] ||
		[optimizedPropertyValues[CameraPropertyBracketPictPopart] isEqualToString:CameraPropertyValueBracketPictGentleSepiaOn]) {
		// アートエフェクト ジェントルセピア
		if ([enabledProperties containsObject:CameraPropertyArtEffectHybridGentleSepia]) {
			optimizedPropertyValues[CameraPropertyArtEffectHybridGentleSepia] = propertyValues[CameraPropertyArtEffectHybridGentleSepia];
		}
	}
	// トーンコントロール シャドー部
	if ([enabledProperties containsObject:CameraPropertyToneControlLow]) {
		optimizedPropertyValues[CameraPropertyToneControlLow] = propertyValues[CameraPropertyToneControlLow];
	}
	// トーンコントロール 中間部
	if ([enabledProperties containsObject:CameraPropertyToneControlMiddle]) {
		optimizedPropertyValues[CameraPropertyToneControlMiddle] = propertyValues[CameraPropertyToneControlMiddle];
	}
	// トーンコントロール ハイライト部
	if ([enabledProperties containsObject:CameraPropertyToneControlHigh]) {
		optimizedPropertyValues[CameraPropertyToneControlHigh] = propertyValues[CameraPropertyToneControlHigh];
	}
	
	// ホワイトバランス
	if ([enabledProperties containsObject:CameraPropertyWb]) {
		optimizedPropertyValues[CameraPropertyWb] = propertyValues[CameraPropertyWb];
	}
	// ホワイトバランス別
	if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbAuto]) {
		// Auto WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRevAuto]) {
			optimizedPropertyValues[CameraPropertyWbRevAuto] = propertyValues[CameraPropertyWbRevAuto];
		}
		// Auto WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevGAuto]) {
			optimizedPropertyValues[CameraPropertyWbRevGAuto] = propertyValues[CameraPropertyWbRevGAuto];
		}
		// WBオート 電球色残し
		if ([enabledProperties containsObject:CameraPropertyAutoWbDenkyuColoredLeaving]) {
			optimizedPropertyValues[CameraPropertyAutoWbDenkyuColoredLeaving] = propertyValues[CameraPropertyAutoWbDenkyuColoredLeaving];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbFine]) {
		// 晴天 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRev5300k]) {
			optimizedPropertyValues[CameraPropertyWbRev5300k] = propertyValues[CameraPropertyWbRev5300k];
		}
		// 晴天 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevG5300k]) {
			optimizedPropertyValues[CameraPropertyWbRevG5300k] = propertyValues[CameraPropertyWbRevG5300k];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbShade]) {
		// 日陰 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRev7500k]) {
			optimizedPropertyValues[CameraPropertyWbRev7500k] = propertyValues[CameraPropertyWbRev7500k];
		}
		// 日陰 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevG7500k]) {
			optimizedPropertyValues[CameraPropertyWbRevG7500k] = propertyValues[CameraPropertyWbRevG7500k];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbCloud]) {
		// 雲天 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRev6000k]) {
			optimizedPropertyValues[CameraPropertyWbRev6000k] = propertyValues[CameraPropertyWbRev6000k];
		}
		// 雲天 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevG6000k]) {
			optimizedPropertyValues[CameraPropertyWbRevG6000k] = propertyValues[CameraPropertyWbRevG6000k];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbLamp]) {
		// 電球 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRev3000k]) {
			optimizedPropertyValues[CameraPropertyWbRev3000k] = propertyValues[CameraPropertyWbRev3000k];
		}
		// 電球 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevG3000k]) {
			optimizedPropertyValues[CameraPropertyWbRevG3000k] = propertyValues[CameraPropertyWbRevG3000k];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbFluorescence1]) {
		// 蛍光灯 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRev4000k]) {
			optimizedPropertyValues[CameraPropertyWbRev4000k] = propertyValues[CameraPropertyWbRev4000k];
		}
		// 蛍光灯 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevG4000k]) {
			optimizedPropertyValues[CameraPropertyWbRevG4000k] = propertyValues[CameraPropertyWbRevG4000k];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbMwbWater1]) {
		// 水中 WB補正A
		if ([enabledProperties containsObject:CameraPropertyWbRevAutoUnderWater]) {
			optimizedPropertyValues[CameraPropertyWbRevAutoUnderWater] = propertyValues[CameraPropertyWbRevAutoUnderWater];
		}
		// 水中 WB補正G
		if ([enabledProperties containsObject:CameraPropertyWbRevGAutoUnderWater]) {
			optimizedPropertyValues[CameraPropertyWbRevGAutoUnderWater] = propertyValues[CameraPropertyWbRevGAutoUnderWater];
		}
	} else if ([optimizedPropertyValues[CameraPropertyWb] isEqualToString:CameraPropertyValueWbWbCustom1]) {
		// カスタムWB K指定
		if ([enabledProperties containsObject:CameraPropertyCustomWbKelvin1]) {
			optimizedPropertyValues[CameraPropertyCustomWbKelvin1] = propertyValues[CameraPropertyCustomWbKelvin1];
		}
	}
	
	// 最適化したカメラプロパティ値の辞書に入れ替えます。
	NSMutableDictionary *optimizedSnapshot = [snapshot mutableCopy];
	optimizedSnapshot[CameraSettingSnapshotPropertyValuesKey] = optimizedPropertyValues;
	
	return optimizedSnapshot;
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
	} else if ([focusMode isEqualToString:CameraPropertyValueFocusStillMf] ||
			   [focusMode isEqualToString:CameraPropertyValueFocusMovieMf]) {
		// マニュアルフォーカス
		return AppCameraFocusModeMF;
	} else if ([focusMode isEqualToString:CameraPropertyValueFocusStillSaf] ||
			   [focusMode isEqualToString:CameraPropertyValueFocusMovieSaf]) {
		// シングルオートフォーカス
		return AppCameraFocusModeSAF;
	} else if ([focusMode isEqualToString:CameraPropertyValueFocusMovieCaf]) {
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
			if (self.runningTakingPluralPictures) {
				return AppCameraActionStatusTakingPictureAutoBracketing;
			}
			break;
		case AppCameraActionTypeTakingPictureIntervalTimer:
			// 静止画をインターバルタイマーで撮影中
			if (self.runningTakingPluralPictures) {
				return AppCameraActionStatusTakingPictureIntervalTimer;
			}
		case AppCameraActionTypeTakingPictureCombination:
			// 静止画をオートブラケット＋インターバルタイマーで撮影中
			if (self.runningTakingPluralPictures) {
				return AppCameraActionStatusTakingPictureCombination;
			}
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

	// オートブラケット撮影が有効か検査します。
	BOOL autoBracketingModeEnabled = NO;
	if (self.autoBracketingMode != AppCameraAutoBracketingModeDisabled) {
		NSError *error = nil;
		NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
		if ([takemode isEqualToString:CameraPropertyValueTakemodeP] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeA] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeS] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeM]) {
			autoBracketingModeEnabled = YES;
		}
	}
	
	// インターバルタイマー撮影が有効か検査します。
	BOOL intervalTimerModeEnabled = NO;
	if (self.intervalTimerMode != AppCameraIntervalTimerModeDisabled) {
		NSError *error = nil;
		NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
		if ([takemode isEqualToString:CameraPropertyValueTakemodeIAuto] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeP] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeA] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeS] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeM] ||
			[takemode isEqualToString:CameraPropertyValueTakemodeArt]) {
			intervalTimerModeEnabled = YES;
		}
	}
	
	// 撮影モードを総合的に判断します。
	if (autoBracketingModeEnabled && intervalTimerModeEnabled) {
		return AppCameraActionTypeTakingPictureCombination;
	} else if (autoBracketingModeEnabled) {
		return AppCameraActionTypeTakingPictureAutoBracketing;
	} else if (intervalTimerModeEnabled) {
		return AppCameraActionTypeTakingPictureIntervalTimer;
	}
	return AppCameraActionTypeTakingPictureSingle;
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
	if ([takemode isEqualToString:CameraPropertyValueTakemodeP] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeA] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeS] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeM]) {
		return YES;
	}
	return NO;
}

- (BOOL)canSetIntervalTimer {
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
	
	// インターバルタイマー撮影が有効かを検査します。
	NSError *error = nil;
	NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
	if ([takemode isEqualToString:CameraPropertyValueTakemodeIAuto] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeP] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeA] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeS] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeM] ||
		[takemode isEqualToString:CameraPropertyValueTakemodeArt]) {
		return YES;
	}
	return NO;
}

- (void)startTakingPluralPictures:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress, NSDictionary *))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");
	
	// 撮影モードが妥当か検査します。
	AppCameraActionType actionType = [self cameraActionType];
	if (actionType != AppCameraActionTypeTakingPictureAutoBracketing &&
		actionType != AppCameraActionTypeTakingPictureIntervalTimer &&
		actionType != AppCameraActionTypeTakingPictureCombination) {
		// オートブラケット＋インターバルタイマー撮影は無効です。
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:TakingPluralPicturesIsNotAvailable", @"AppCamera.startTakingPluralPictures")
		};
		NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
		errorHandler(error);
		return;
	}
	// オートブラケット撮影の設定が妥当かを検査します。
	if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
		actionType == AppCameraActionTypeTakingPictureCombination) {
		if (self.autoBracketingCount <  3 ||
			self.autoBracketingCount >  9 ||
			(self.autoBracketingCount % 2) == 0) {
			// 撮影枚数は3以上の奇数でなければなりません。
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:AutoBrackettingCountIsIncorrect", @"AppCamera.startTakingPluralPictures")
			};
			NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
			errorHandler(error);
			return;
		}
		if (self.autoBracketingStep < 1 ||		// 1 step = 0.3EV
			self.autoBracketingStep > 9) {		// 9 step = 3.0EV
			// カメラプロパティ値を変更するステップ数は1以上でなければなりません。
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:AutoBrackettingStepIsIncorrect", @"AppCamera.startTakingPluralPictures")
			};
			NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
			errorHandler(error);
			return;
		}
	}
	// インターバルタイマー撮影の設定が妥当かを検査します。
	if (actionType == AppCameraActionTypeTakingPictureIntervalTimer ||
		actionType == AppCameraActionTypeTakingPictureCombination) {
		if (self.intervalTimerCount < 1) {
			// 撮影回数は1以上でなければなりません。
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:IntervalTimerCountIsIncorrect", @"AppCamera.startTakingPluralPictures")
			};
			NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
			errorHandler(error);
			return;
		}
		if (self.intervalTimerTime < 1.0) {
			// 撮影間隔は1秒以上でなければなりません。
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:IntervalTimerTimeIsIncorrect", @"AppCamera.startTakingPluralPictures")
			};
			NSError *error = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidParameters userInfo:userInfo];
			errorHandler(error);
			return;
		}
	}

	// オートブラケット＋インターバルタイマー撮影の状態管理を初期化します。
	__weak AppCamera *weakSelf = self;
	weakSelf.runningTakingPluralPictures = YES;
	weakSelf.abortTakingPluralPictures = NO;
	weakSelf.abortedTakingPluralPictures = NO;
	NSInteger autoBracketingCount = weakSelf.autoBracketingCount;
	NSInteger autoBracketingStep = weakSelf.autoBracketingStep;
	NSInteger intervalTimerCount = weakSelf.intervalTimerCount;
	NSTimeInterval intervalTimerTime = weakSelf.intervalTimerTime;
	NSTimeInterval estimateTotalTime = intervalTimerCount * intervalTimerTime;
	
	// おっと、オートブラケット撮影のみの場合はインターバル撮影は1回分しか撮影しないように細工します。
	if (actionType == AppCameraActionTypeTakingPictureAutoBracketing) {
		intervalTimerCount = 1;
	}
	
	/// メインスレッド以外で非同期に処理ブロックを実行します。
	dispatch_async(weakSelf.takingPictureRunnerQueue, ^{

		// オートブラケットで変更するカメラプロパティ値のリストを作成します。
		NSString *autoBracketingProperty = nil;
		NSMutableArray *autoBracketingPropertyValues = nil;
		NSString *currentPropertyValue = nil;
		if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
			actionType == AppCameraActionTypeTakingPictureCombination) {
			if (weakSelf.autoBracketingMode == AppCameraAutoBracketingModeExposure) {
				// オートブラケットするプロパティを撮影モードから決定します。
				NSError *error = nil;
				NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
				if ([takemode isEqualToString:CameraPropertyValueTakemodeP] ||
					[takemode isEqualToString:CameraPropertyValueTakemodeA] ||
					[takemode isEqualToString:CameraPropertyValueTakemodeS]) {
					// 露出補正値
					autoBracketingProperty = CameraPropertyExprev;
				} else if ([takemode isEqualToString:CameraPropertyValueTakemodeM]) {
					// シャッター速度
					autoBracketingProperty = CameraPropertyShutter;
				} else {
					// 未対応
					weakSelf.runningTakingPluralPictures = NO;
					dispatch_async(dispatch_get_main_queue(), ^{
						errorHandler(error);
					});
					return;
				}
				// ブラケット撮影の基本にする現在のプロパティ値を取得します。
				currentPropertyValue = [super cameraPropertyValue:autoBracketingProperty error:&error];
				if (!currentPropertyValue) {
					weakSelf.runningTakingPluralPictures = NO;
					dispatch_async(dispatch_get_main_queue(), ^{
						errorHandler(error);
					});
					return;
				}
				// オートブラケットするプロパティの設定可能値リストを取得します。
				NSArray *valueList = [super cameraPropertyValueList:autoBracketingProperty error:&error];
				if (!valueList) {
					weakSelf.runningTakingPluralPictures = NO;
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
				NSInteger minimumIndex = currentIndex - autoBracketingStep * ((autoBracketingCount - 1) / 2);
				NSInteger maximumIndex = currentIndex + autoBracketingStep * ((autoBracketingCount - 1) / 2);
				autoBracketingPropertyValues = [[NSMutableArray alloc] init];
				for (NSInteger index = minimumIndex; index <= maximumIndex; index += autoBracketingStep) {
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
		}
		DEBUG_LOG(@"currentPropertyValue=%@", currentPropertyValue);
		DEBUG_LOG(@"autoBracketingProperty=%@", autoBracketingProperty);
		DEBUG_LOG(@"autoBracketingPropertyValues=%@", autoBracketingPropertyValues);
		
		// 現在の自動測光ロックとフォーカスロック状態状態を取得します。
		NSError *error = nil;
		NSString *aeLockState = [super cameraPropertyValue:CameraPropertyAeLockState error:&error];
		if (!aeLockState) {
			weakSelf.runningTakingPluralPictures = NO;
			dispatch_async(dispatch_get_main_queue(), ^{
				errorHandler(error);
			});
			return;
		}
		NSString *afLockState = [super cameraPropertyValue:CameraPropertyAfLockState error:&error];
		if (!afLockState) {
			weakSelf.runningTakingPluralPictures = NO;
			dispatch_async(dispatch_get_main_queue(), ^{
				errorHandler(error);
			});
			return;
		}
		
		// 自動測光ロックをしていない場合は、複数枚撮影中に露出が揺れないようにロックします。
		if ([aeLockState isEqualToString:CameraPropertyValueAeLockStateUnlock]) {
			if (![super lockAutoExposure:&error]) {
				weakSelf.runningTakingPluralPictures = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
		}
		// フォーカスロックしていない場合は、複数枚撮影中にピント位置が揺れないようにロックします。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
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
				weakSelf.runningTakingPluralPictures = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				lockingFailed = YES;
			}];
			
			// オートフォーカスのロックが完了するのを待ちます。
			while (!lockingCompleted && !lockingFailed) {
				[NSThread sleepForTimeInterval:0.05];
			}
			if (lockingFailed) {
				// オートフォーカスのロックに失敗したようです。
				return;
			}
		}
	
		// 撮影後確認画像を非表示にします。
		// MARK: 非表示にしておかないと、露出を変えながらの撮影で調子が悪くなる傾向があるようです。
		NSString *recview = [super cameraPropertyValue:CameraPropertyRecview error:&error];
		if ([recview isEqualToString:CameraPropertyValueRecviewOn]) {
			if (![super setCameraPropertyValue:CameraPropertyRecview value:CameraPropertyValueRecviewOff error:&error]) {
				weakSelf.runningTakingPluralPictures = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					errorHandler(error);
				});
				return;
			}
		}

		// 呼び出し元に撮影開始の完了を伝えます。
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *info = nil;
			if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
				actionType == AppCameraActionTypeTakingPictureCombination) {
				info = @{
					@"autoBracketingProperty": autoBracketingProperty,
					@"autoBracketingPropertyValues": autoBracketingPropertyValues,
				};
			}
			completionHandler(info);
		});
		
		// オートブラケット＋インターバルタイマー撮影を開始します。
		dispatch_async(dispatch_get_main_queue(), ^{
			for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
				if ([delegate respondsToSelector:@selector(cameraDidStartTakingPluralPictures:)]) {
					[delegate cameraDidStartTakingPluralPictures:weakSelf];
				}
			}
		});

		// おっと、インターバルタイマー撮影のみの場合はオートブラケット撮影は1枚分しか撮影しないように細工します。
		NSInteger autoBracketingCount;
		if (autoBracketingPropertyValues) {
			autoBracketingCount = autoBracketingPropertyValues.count;
		} else {
			autoBracketingCount = 1;
		}
		
		// インターバルタイマー撮影を開始します。
		NSDate *intervalTimerStartTime = [NSDate date];
		__block NSError *takingError = nil;
		for (NSInteger count = 0; count < intervalTimerCount; count++) {

			// インターバルタイマー撮影の1回分を開始します。
			NSDate *takingTimerStartTime = [NSDate date];
			if (actionType == AppCameraActionTypeTakingPictureIntervalTimer ||
				actionType == AppCameraActionTypeTakingPictureCombination) {
				NSInteger current = count * autoBracketingCount;
				NSInteger total = intervalTimerCount * autoBracketingCount;
				dispatch_async(dispatch_get_main_queue(), ^{
					for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
						if ([delegate respondsToSelector:@selector(cameraWillTakePictureByIntervalTimer:currentCount:totalCount:)]) {
							[delegate cameraWillTakePictureByIntervalTimer:weakSelf currentCount:current totalCount:total];
						}
					}
				});
			}
			
			// オートブラケット撮影を開始します。
			for (NSInteger index = 0; index < autoBracketingCount; index++) {
				
				if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
					actionType == AppCameraActionTypeTakingPictureCombination) {
					
					// オートブラケットで変更するカメラプロパティ値を設定します。
					NSString *propertyValue = autoBracketingPropertyValues[index];
					NSInteger retry = 0;
					while (![super setCameraPropertyValue:autoBracketingProperty value:propertyValue error:&error]) {
						if (error.domain == OLYCameraErrorDomain && error.code == OLYCameraErrorCommandFailed) {
							// カメラ内部エラーの場合はリトライしてみます。リトライが規定回数を超えた場合はこの撮影ループは異常終了です。
							retry++;
							if (retry > 2) {
								takingError = error;
								goto ExitTakingPluralPicturesLoop;
							}
							// 次のリトライまで少し時間を空けます。
							[NSThread sleepForTimeInterval:1.0];
						} else {
							// カメラ内部エラー以外は復帰の見込みがないのでこの撮影ループはすぐに異常終了です。
							takingError = error;
							goto ExitTakingPluralPicturesLoop;
						}
					}
					
					// 設定した値が実際に適用されたかを確認します。
					NSTimeInterval timeout;
					if (weakSelf.connectionType == OLYCameraConnectionTypeWiFi) {
						timeout = 3.0;
					} else if (weakSelf.connectionType == OLYCameraConnectionTypeBluetoothLE) {
						timeout = 5.0; // MARK: Bluetoothだとかなり遅れて設定されるようです。
					} else {
						// 異常事態が発生している場合は撮影は中止です。
						NSDictionary *userInfo = @{
							NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotConnected", @"AppCamera.startTakingPluralPictures")
						};
						takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorNotConnected userInfo:userInfo];
						goto ExitTakingPluralPicturesLoop;
					}
					if ([autoBracketingProperty isEqualToString:CameraPropertyExprev]) {
						// 露出補正値
						NSDate *startTime = [NSDate date];
						while (![weakSelf.actualExposureCompensation isEqualToString:propertyValue]) {
							if ([[NSDate date] timeIntervalSinceDate:startTime] > timeout) {
								// 設定がある程度の時間内に適用されない場合は撮影は中止です。
								NSDictionary *userInfo = @{
									NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraCouldNotChangeValueOfProperty", @"AppCamera.startTakingPluralPictures")
								};
								takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorCameraBusy userInfo:userInfo];
								break;
							}
							if (weakSelf.runMode == OLYCameraRunModeRecording) {
								[NSThread sleepForTimeInterval:0.05];
							} else {
								// 異常事態が発生している場合は撮影は中止です。
								NSDictionary *userInfo = @{
									NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotRecordingMode", @"AppCamera.startTakingPluralPictures")
								};
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
								NSDictionary *userInfo = @{
									NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraCouldNotChangeValueOfProperty", @"AppCamera.startTakingPluralPictures")
								};
								takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorCameraBusy userInfo:userInfo];
								break;
							}
							if (weakSelf.runMode == OLYCameraRunModeRecording) {
								[NSThread sleepForTimeInterval:0.05];
							} else {
								// 異常事態が発生している場合は撮影は中止です。
								NSDictionary *userInfo = @{
									NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotRecordingMode", @"AppCamera.startTakingPluralPictures")
								};
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
						goto ExitTakingPluralPicturesLoop;
					}
				
					// オートブラケット撮影の1枚分を開始します。
					NSInteger current = count * autoBracketingCount + index;
					NSInteger total = intervalTimerCount * autoBracketingCount;
					dispatch_async(dispatch_get_main_queue(), ^{
						for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
							if ([delegate respondsToSelector:@selector(cameraWillTakePictureByAutoBracketing:currentCount:totalCount:)]) {
								[delegate cameraWillTakePictureByAutoBracketing:weakSelf currentCount:current totalCount:total];
							}
						}
					});
				}

				// 写真撮影します。
				DEBUG_LOG(@"start taking a picture: count=%ld, index=%ld", (long)count, (long)index);
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
					[NSThread sleepForTimeInterval:0.05];
				}
				if (takingFailed) {
					// 写真撮影に失敗したようです。
					goto ExitTakingPluralPicturesLoop;
				}

				// オートブラケット撮影の1枚分を完了します。
				if (actionType == AppCameraActionTypeTakingPictureAutoBracketing ||
					actionType == AppCameraActionTypeTakingPictureCombination) {
					NSInteger current = count * autoBracketingCount + (index + 1);
					NSInteger total = intervalTimerCount * autoBracketingCount;
					dispatch_async(dispatch_get_main_queue(), ^{
						for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
							if ([delegate respondsToSelector:@selector(cameraDidTakePictureByAutoBracketing:currentCount:totalCount:)]) {
								[delegate cameraDidTakePictureByAutoBracketing:weakSelf currentCount:current totalCount:total];
							}
						}
					});
				}
				
				// メディアへの書き込みが終わるまで待ちます。
				// MARK: これがないと次のカメラプロパティ設定がエラーになる場合があります。
				if (weakSelf.connectionType == OLYCameraConnectionTypeWiFi) {
					// MARK: Wi-Fiの場合はメディア書き込み中を示すプロパティで完了を確認できます。
					while (weakSelf.mediaBusy) {
						if (weakSelf.runMode == OLYCameraRunModeRecording) {
							[NSThread sleepForTimeInterval:0.05];
						} else {
							// 異常事態が発生している場合は撮影は中止です。
							NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotRecordingMode", @"AppCamera.startTakingPluralPictures")
							};
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
							[NSThread sleepForTimeInterval:0.05];
						} else {
							// 異常事態が発生している場合は撮影は中止です。
							NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotRecordingMode", @"AppCamera.startTakingPluralPictures")
							};
							takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
							break;
						}
					}
				}
				if (takingError) {
					// 待ち合わせに失敗したようです。
					goto ExitTakingPluralPicturesLoop;
				}
				
				// ここで一枚撮影完了です。
				DEBUG_LOG(@"finish taking a picture: count=%ld, index=%ld", (long)count, (long)index);
				
				// オートブラケット撮影の中止を要求されているか確認します。
				if (weakSelf.abortTakingPluralPictures) {
					DEBUG_LOG(@"ABORT!");
					weakSelf.abortedTakingPluralPictures = YES;
					goto ExitTakingPluralPicturesLoop;
				}
			}

			// インターバルタイマー撮影の1回分を完了します。
			if (actionType == AppCameraActionTypeTakingPictureIntervalTimer ||
				actionType == AppCameraActionTypeTakingPictureCombination) {
				NSInteger current = (count + 1) * autoBracketingCount;
				NSInteger total = intervalTimerCount * autoBracketingCount;
				dispatch_async(dispatch_get_main_queue(), ^{
					for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
						if ([delegate respondsToSelector:@selector(cameraDidTakePictureByIntervalTimer:currentCount:totalCount:)]) {
							[delegate cameraDidTakePictureByIntervalTimer:weakSelf currentCount:current totalCount:total];
						}
					}
				});
			}
			
			// 次の撮影時刻まで待ちます。
			if (count == (intervalTimerCount - 1)) {
				// 最後の撮影については、わざわざ待つ必要はありません。
				continue;
			}
			NSTimeInterval pastTime = [[NSDate date] timeIntervalSinceDate:takingTimerStartTime];
			NSTimeInterval notifiedTime = pastTime + 0.25; // 最初の通知を0.5秒遅らせて直前の進捗表示を継続させます。
			while (pastTime < intervalTimerTime) {
				if (weakSelf.runMode != OLYCameraRunModeRecording) {
					// 異常事態が発生している場合は撮影は中止です。
					NSDictionary *userInfo = @{
						NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:CameraIsNotRecordingMode", @"AppCamera.startTakingPluralPictures")
					};
					takingError = [NSError errorWithDomain:OLYCameraErrorDomain code:OLYCameraErrorInvalidOperations userInfo:userInfo];
					break;
				}
				// インターバルタイマー撮影の中止を要求されているか確認します。
				if (weakSelf.abortTakingPluralPictures) {
					break;
				}
				// 0.25秒ごとに次までの撮影時間を更新したことを通知します。
				// ただし、最後の通知が残り0.5秒に足りない場合は進捗表示の更新を止めます。
				if ((pastTime - notifiedTime) > 0.25) {
					if ((intervalTimerTime - pastTime) > 0.5) {
						NSTimeInterval remain = intervalTimerTime - pastTime;
						NSInteger current = (count + 1) * autoBracketingCount;
						NSInteger total = intervalTimerCount * autoBracketingCount;
						dispatch_async(dispatch_get_main_queue(), ^{
							for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
								if ([delegate respondsToSelector:@selector(cameraDidPauseTakingPictureForIntervalTimer:remainTime:currentCount:totalCount:)]) {
									[delegate cameraDidPauseTakingPictureForIntervalTimer:weakSelf remainTime:remain currentCount:current totalCount:total];
								}
							}
						});
						notifiedTime = pastTime;
					}
				}
				// 経過時間を更新します。
				[NSThread sleepForTimeInterval:0.05];
				pastTime = [[NSDate date] timeIntervalSinceDate:takingTimerStartTime];
			}
			if (takingError) {
				// 時間待ちに失敗したようです。
				goto ExitTakingPluralPicturesLoop;
			}
			if (weakSelf.abortTakingPluralPictures) {
				// 中止したいようです。
				DEBUG_LOG(@"ABORT!");
				weakSelf.abortedTakingPluralPictures = YES;
				goto ExitTakingPluralPicturesLoop;
			}
			// 撮影時間がオーバーしているか確認します。
			NSTimeInterval actualTotalTime = [[NSDate date] timeIntervalSinceDate:intervalTimerStartTime];
			if (actualTotalTime > estimateTotalTime) {
				// 撮影時間がオーバーしたようです。
				DEBUG_LOG(@"taking a picture runs over: %ld sec", (long)(actualTotalTime - estimateTotalTime));
				if (weakSelf.intervalTimerMode == AppCameraIntervalTimerModePriorTime) {
					DEBUG_LOG(@"TIME OVER! GIVE UP!");
					goto ExitTakingPluralPicturesLoop;
				}
			}
		}
	ExitTakingPluralPicturesLoop:
		if (takingError) {
			DEBUG_LOG(@"exited taking plural pictures loop: error=%@", takingError);
		}
		
		// この処理でフォーカスをロックした場合はそのロックを解除します。
		if ([afLockState isEqualToString:CameraPropertyValueAfLockStateUnlock]) {
			if (![self unlockAutoFocus:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		// この処理で自動測光をロックした場合はそのロックを解除します。
		if ([aeLockState isEqualToString:CameraPropertyValueAeLockStateUnlock]) {
			if (![super unlockAutoExposure:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// ブラケット撮影の基本にしたプロパティ値に戻します。
		if (currentPropertyValue) {
			if (![super setCameraPropertyValue:autoBracketingProperty value:currentPropertyValue error:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// 撮影後確認画像を元に戻します。
		if ([recview isEqualToString:CameraPropertyValueRecviewOn]) {
			if (![super setCameraPropertyValue:CameraPropertyRecview value:recview error:&error]) {
				// エラーを無視して続行します。
				if (!takingError) {
					takingError = error;
				}
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}

		// 完了です。
		weakSelf.runningTakingPluralPictures = NO;
		weakSelf.abortTakingPluralPictures = NO;
		weakSelf.abortedTakingPluralPictures = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
			for (id<AppCameraTakingPictureDelegate> delegate in weakSelf.takingPictureDelegates) {
				if ([delegate respondsToSelector:@selector(cameraDidStopTakingPluralPictures:error:)]) {
					[delegate cameraDidStopTakingPluralPictures:weakSelf error:takingError];
				}
			}
		});
	});
}

- (void)stopTakingPluralPictures:(void (^)(NSDictionary *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
	DEBUG_LOG(@"");

	/// メインスレッド以外で非同期に処理ブロックを実行します。
	__weak AppCamera *weakSelf = self;
	dispatch_async(weakSelf.takingPictureStopperQueue, ^{
		// オートブラケット＋インターバルタイマー撮影を中止します。
		weakSelf.abortTakingPluralPictures = YES;
		
		// オートブラケット撮影の実行が完了するのを待ちます。
		while (weakSelf.runningTakingPluralPictures &&
			   weakSelf.abortTakingPluralPictures &&
			   !weakSelf.abortedTakingPluralPictures) {
			[NSThread sleepForTimeInterval:0.05];
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

/// 動画撮影経過時間を更新するためのタイマーが発火した時に呼び出されます。
- (void)recordingVideoTimerDidFire:(NSTimer *)timer {
	DEBUG_DETAIL_LOG(@"");
	
	if (!self.recordingVideo ||
		!self.recordingVideoStartTime) {
		// 通常はあり得ません。
		return;
	}
	
	// MARK: 経過時間を更新します。
	// 録画終了のタイミングが正確ではないので、Wi-Fiで接続している時に限っては
	// 自前で開始時刻から計算するよりも、開始時のカメラの残り録画可能時間と現在の残り録画可能時間を使って逆算したほうが正確かもしれない。
	NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.recordingVideoStartTime];
	if (self.recordingElapsedTime != time) {
		self.recordingElapsedTime = time;
	}
}

/// カメラプロパティ値の冗長で不要な部分("<プロパティ名/"と">")を取り除きます。
- (NSString *)stripCameraPropertyValue:(NSString *)value {
	DEBUG_DETAIL_LOG(@"value=%@", value);
	
	NSRange delimitterRange = [value rangeOfString:@"/" options:NSBackwardsSearch];
	if (delimitterRange.location == NSNotFound) {
		return nil;
	}
	NSUInteger valueLocation = delimitterRange.location + 1;
	NSUInteger valueLength = value.length - valueLocation - 1;
	NSRange valueRange = NSMakeRange(valueLocation, valueLength);
	NSString *strippedValue = [value substringWithRange:valueRange];
	
	return strippedValue;
}

/// リスト上のもっとも近い値のインデックスを返します。
- (NSInteger)findNearestIndexOfNumberList:(NSNumber *)number numberList:(NSArray *)numberList {
	DEBUG_DETAIL_LOG(@"");
	
	NSInteger nearestIndex;
	
	float numberValue = [number floatValue];
	if (numberValue < [numberList[0] floatValue]) {
		nearestIndex = 0;
		
	} else if (numberValue > [numberList[numberList.count - 1] floatValue]) {
		nearestIndex = numberList.count - 1;
		
	} else {
		nearestIndex = 0;
		for (NSInteger index = 0; index < numberList.count - 1; index++) {
			float boundaryLowValue = [numberList[index] floatValue];
			float boundaryHighValue = [numberList[index + 1] floatValue];
			if (fabsf(boundaryLowValue - numberValue) < FLT_EPSILON) {
				nearestIndex = index;
				break;
			}
			if (fabsf(boundaryHighValue - numberValue) < FLT_EPSILON) {
				nearestIndex = index + 1;
				break;
			}
			float nearestValue = [numberList[nearestIndex] floatValue];
			float distanceFromNearestValue = fabsf(numberValue - nearestValue);
			float distanceFromBoundaryLowValue = fabsf(numberValue - boundaryLowValue);
			float distanceFromBoundaryHighValue = fabsf(numberValue - boundaryHighValue);
			if (distanceFromBoundaryLowValue < distanceFromNearestValue) {
				nearestIndex = index;
			}
			if (distanceFromBoundaryHighValue < distanceFromNearestValue) {
				nearestIndex = index + 1;
			}
		}
	}
	
	return nearestIndex;
}

/// 指定された撮影モードで使用可能なカメラプロパティのリストを返します。
- (NSArray *)listEnabledPropertiesForTakeMode:(NSString *)mode {
	
	// カメラプロパティの使用可否を撮影モード別に調べるための辞書を構築します。
	// SDKのリファレンスマニュアルにあるカメラプロパティセクションを読み取って表計算ソフトで機械的に生成しました。
	NSDictionary *enabledPropertiesByMode = @{
		CameraPropertyAperture: @[CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyAe: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyTakemode: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyIso: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyExprev: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS],
		CameraPropertyTakeDrive: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyAspectRatio: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyShutter: @[CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContinuousShootingVelocity: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyExposeMovieSelect: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyAeLockState: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyImagesize: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyRaw: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyCompressibilityRatio: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyQualityMovie: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyDestinationFile: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyQualityMovieShortMovieRecordTime: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyFocusStill: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyAfLockState: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyFullTimeAf: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyFocusMovie: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyFaceScan: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyAntiShakeFocalLength: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyRecview: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyAntiShakeMovie: @[CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySoundVolumeLevel: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyGps: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWifiCh: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyRecentlyArtFilter: @[CameraPropertyValueTakemodeArt],
		CameraPropertyColorPhase: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypePopart: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeDaydream: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeRoughMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeToyPhoto: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeMiniature: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeCrossProcess: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeDramaticTone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeLigneClair: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypePastel: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypeVintage: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectTypePartcolor: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridPopart: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridFantasicFocus: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridDaydream: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridLightTone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridRoughMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridToyPhoto: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridMiniature: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridCrossProcess: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridGentleSepia: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridDramaticTone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridLigneClair: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridPastel: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridVintage: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyArtEffectHybridPartcolor: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyBracketPictPopart: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictFantasicFocus: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictDaydream: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictLightTone: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictRoughMonochrome: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictToyPhoto: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictMiniature: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictCrossProcess: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictGentleSepia: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictDramaticTone: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictLigneClair: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictPastel: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictVintage: @[CameraPropertyValueTakemodeArt],
		CameraPropertyBracketPictPartcolor: @[CameraPropertyValueTakemodeArt],
		CameraPropertyColortone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastFlat: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastNatural: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastSoft: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastIFinish: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyContrastVivid: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpFlat: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpNatural: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpSoft: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpIFinish: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySharpVivid: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySaturationLevelFlat: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySaturationLevelNatural: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySaturationLevelSoft: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySaturationLevelIFinish: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertySaturationLevelVivid: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneFlat: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneNatural: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneSoft: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneIFinish: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneVivid: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyEffectLevelIFinish: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyToneControlLow: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyToneControlMiddle: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyToneControlHigh: @[CameraPropertyValueTakemodeIAuto, CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt],
		CameraPropertyMonotonefilterMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyMonotonefilterRoughMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyMonotonefilterDramaticTone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyMonotonecolorMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyMonotonecolorRoughMonochrome: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyMonotonecolorDramaticTone: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyColorCreatorColor: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyColorCreatorVivid: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWb: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyCustomWbKelvin1: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevAuto: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevGAuto: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRev5300k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevG5300k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRev7500k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevG7500k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRev6000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevG6000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRev3000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevG3000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRev4000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevG4000k: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevAutoUnderWater: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyWbRevGAutoUnderWater: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
		CameraPropertyAutoWbDenkyuColoredLeaving: @[CameraPropertyValueTakemodeP, CameraPropertyValueTakemodeA, CameraPropertyValueTakemodeS, CameraPropertyValueTakemodeM, CameraPropertyValueTakemodeArt, CameraPropertyValueExposeMovieSelectP, CameraPropertyValueExposeMovieSelectA, CameraPropertyValueExposeMovieSelectS, CameraPropertyValueExposeMovieSelectM],
	};
	NSMutableArray *enableProperties = [[NSMutableArray alloc] init];
	[enabledPropertiesByMode enumerateKeysAndObjectsUsingBlock:^(NSString *property, NSArray *modes, BOOL *stop) {
		if ([modes containsObject:mode]) {
			[enableProperties addObject:property];
		}
	}];
	
	return enableProperties;
}

@end
