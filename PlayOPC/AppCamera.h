//
//  AppCamera.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <OLYCameraKit/OLYCamera.h>
#import <CoreLocation/CoreLocation.h>

/// フォーカスモード
typedef enum : NSInteger {
	AppCameraFocusModeUnknown = 0, ///< 不明
	AppCameraFocusModeMF,  ///< マニュアルフォーカス
	AppCameraFocusModeSAF, ///< シングルオートフォーカス
	AppCameraFocusModeCAF, ///< コンティニュアスオートフォーカス
} AppCameraFocusMode;

/// オートブラケット撮影モード
typedef enum : NSInteger {
	AppCameraAutoBracketingModeDisabled = 0, ///< 無効(通常撮影)
	AppCameraAutoBracketingModeExposure, ///< 露出補正でオートブラケット撮影
} AppCameraAutoBracketingMode;

/// インターバルタイマー撮影モード
typedef enum : NSInteger {
	AppCameraIntervalTimerModeDisabled = 0, ///< 無効(通常撮影)
	AppCameraIntervalTimerModePriorCount, ///< 撮影回数優先でインターバルタイマー撮影
	AppCameraIntervalTimerModePriorTime, ///< 撮影時間優先でインターバルタイマー撮影
} AppCameraIntervalTimerMode;

/// カメラの撮影動作タイプ
typedef enum : NSInteger {
	AppCameraActionTypeUnknown, ///< 不明
	AppCameraActionTypeTakingPictureSingle, ///< 静止画を単写で撮影
	AppCameraActionTypeTakingPictureSequential, ///< 静止画を連写で撮影
	AppCameraActionTypeTakingPictureAutoBracketing, ///< 静止画をオートブラケットで撮影
	AppCameraActionTypeTakingPictureIntervalTimer, ///< 静止画をインターバルタイマーで撮影
	AppCameraActionTypeTakingPictureCombination, ///< 静止画をオートブラケット＋インターバルタイマーで撮影
	AppCameraActionTypeRecordingVideo, ///< 動画を撮影
} AppCameraActionType;

/// カメラの撮影動作ステータス
typedef enum : NSInteger {
	AppCameraActionStatusReady, ///< 撮影の開始を待機中
	AppCameraActionStatusTakingPictureSingle, ///< 静止画を単写で撮影中
	AppCameraActionStatusTakingPictureSequential, ///< 静止画を連写で撮影中
	AppCameraActionStatusTakingPictureAutoBracketing, ///< 静止画をオートブラケットで撮影中
	AppCameraActionStatusTakingPictureIntervalTimer, ///< 静止画をインターバルタイマーで撮影中
	AppCameraActionStatusTakingPictureCombination, ///< 静止画をオートブラケット＋インターバルタイマーで撮影中
	AppCameraActionStatusRecordingVideo, ///< 動画を撮影中
} AppCameraActionStatus;

// カメラプロパティ
extern NSString *const CameraPropertyAperture;
extern NSString *const CameraPropertyAe;
extern NSString *const CameraPropertyValueAeAeCenter;
extern NSString *const CameraPropertyValueAeAeEsp;
extern NSString *const CameraPropertyValueAeAePinpoint;
extern NSString *const CameraPropertyTakemode;
extern NSString *const CameraPropertyValueTakemodeIAuto;
extern NSString *const CameraPropertyValueTakemodeP;
extern NSString *const CameraPropertyValueTakemodeA;
extern NSString *const CameraPropertyValueTakemodeS;
extern NSString *const CameraPropertyValueTakemodeM;
extern NSString *const CameraPropertyValueTakemodeArt;
extern NSString *const CameraPropertyValueTakemodeMovie;
extern NSString *const CameraPropertyIso;
extern NSString *const CameraPropertyExprev;
extern NSString *const CameraPropertyTakeDrive;
extern NSString *const CameraPropertyValueTakeDriveDriveNormal;
extern NSString *const CameraPropertyValueTakeDriveDriveContinue;
extern NSString *const CameraPropertyAspectRatio;
extern NSString *const CameraPropertyValueAspectRatio0403;
extern NSString *const CameraPropertyValueAspectRatio0302;
extern NSString *const CameraPropertyValueAspectRatio1609;
extern NSString *const CameraPropertyValueAspectRatio0304;
extern NSString *const CameraPropertyValueAspectRatio0606;
extern NSString *const CameraPropertyShutter;
extern NSString *const CameraPropertyContinuousShootingVelocity;
extern NSString *const CameraPropertyExposeMovieSelect;
extern NSString *const CameraPropertyValueExposeMovieSelectP;
extern NSString *const CameraPropertyValueExposeMovieSelectA;
extern NSString *const CameraPropertyValueExposeMovieSelectS;
extern NSString *const CameraPropertyValueExposeMovieSelectM;
extern NSString *const CameraPropertyAeLockState;
extern NSString *const CameraPropertyValueAeLockStateLock;
extern NSString *const CameraPropertyValueAeLockStateUnlock;
extern NSString *const CameraPropertyImagesize;
extern NSString *const CameraPropertyRaw;
extern NSString *const CameraPropertyCompressibilityRatio;
extern NSString *const CameraPropertyQualityMovie;
extern NSString *const CameraPropertyValueQualityMovieShortMovie;
extern NSString *const CameraPropertyDestinationFile;
extern NSString *const CameraPropertyQualityMovieShortMovieRecordTime;
extern NSString *const CameraPropertyFocusStill;
extern NSString *const CameraPropertyValueFocusStillMf;
extern NSString *const CameraPropertyValueFocusStillSaf;
extern NSString *const CameraPropertyAfLockState;
extern NSString *const CameraPropertyValueAfLockStateLock;
extern NSString *const CameraPropertyValueAfLockStateUnlock;
extern NSString *const CameraPropertyFullTimeAf;
extern NSString *const CameraPropertyFocusMovie;
extern NSString *const CameraPropertyValueFocusMovieMf;
extern NSString *const CameraPropertyValueFocusMovieSaf;
extern NSString *const CameraPropertyValueFocusMovieCaf;
extern NSString *const CameraPropertyBatteryLevel;
extern NSString *const CameraPropertyFaceScan;
extern NSString *const CameraPropertyAntiShakeFocalLength;
extern NSString *const CameraPropertyRecview;
extern NSString *const CameraPropertyValueRecviewOn;
extern NSString *const CameraPropertyValueRecviewOff;
extern NSString *const CameraPropertyAntiShakeMovie;
extern NSString *const CameraPropertySoundVolumeLevel;
extern NSString *const CameraPropertyGps;
extern NSString *const CameraPropertyWifiCh;
extern NSString *const CameraPropertyRecentlyArtFilter;
extern NSString *const CameraPropertyValueRecentlyArtFilterPopart;
extern NSString *const CameraPropertyValueRecentlyArtFilterFantasicFocus;
extern NSString *const CameraPropertyValueRecentlyArtFilterDaydream;
extern NSString *const CameraPropertyValueRecentlyArtFilterLightTone;
extern NSString *const CameraPropertyValueRecentlyArtFilterRoughMonochrome;
extern NSString *const CameraPropertyValueRecentlyArtFilterToyPhoto;
extern NSString *const CameraPropertyValueRecentlyArtFilterMiniature;
extern NSString *const CameraPropertyValueRecentlyArtFilterCrossProcess;
extern NSString *const CameraPropertyValueRecentlyArtFilterGentleSepia;
extern NSString *const CameraPropertyValueRecentlyArtFilterDramaticTone;
extern NSString *const CameraPropertyValueRecentlyArtFilterLigneClair;
extern NSString *const CameraPropertyValueRecentlyArtFilterPastel;
extern NSString *const CameraPropertyValueRecentlyArtFilterVintage;
extern NSString *const CameraPropertyValueRecentlyArtFilterPartcolor;
extern NSString *const CameraPropertyValueRecentlyArtFilterArtBkt;
extern NSString *const CameraPropertyColorPhase;
extern NSString *const CameraPropertyArtEffectTypePopart;
extern NSString *const CameraPropertyArtEffectTypeDaydream;
extern NSString *const CameraPropertyArtEffectTypeRoughMonochrome;
extern NSString *const CameraPropertyArtEffectTypeToyPhoto;
extern NSString *const CameraPropertyArtEffectTypeMiniature;
extern NSString *const CameraPropertyArtEffectTypeCrossProcess;
extern NSString *const CameraPropertyArtEffectTypeDramaticTone;
extern NSString *const CameraPropertyArtEffectTypeLigneClair;
extern NSString *const CameraPropertyArtEffectTypePastel;
extern NSString *const CameraPropertyArtEffectTypeVintage;
extern NSString *const CameraPropertyArtEffectTypePartcolor;
extern NSString *const CameraPropertyArtEffectHybridPopart;
extern NSString *const CameraPropertyArtEffectHybridFantasicFocus;
extern NSString *const CameraPropertyArtEffectHybridDaydream;
extern NSString *const CameraPropertyArtEffectHybridLightTone;
extern NSString *const CameraPropertyArtEffectHybridRoughMonochrome;
extern NSString *const CameraPropertyArtEffectHybridToyPhoto;
extern NSString *const CameraPropertyArtEffectHybridMiniature;
extern NSString *const CameraPropertyArtEffectHybridCrossProcess;
extern NSString *const CameraPropertyArtEffectHybridGentleSepia;
extern NSString *const CameraPropertyArtEffectHybridDramaticTone;
extern NSString *const CameraPropertyArtEffectHybridLigneClair;
extern NSString *const CameraPropertyArtEffectHybridPastel;
extern NSString *const CameraPropertyArtEffectHybridVintage;
extern NSString *const CameraPropertyArtEffectHybridPartcolor;
extern NSString *const CameraPropertyBracketPictPopart;
extern NSString *const CameraPropertyValueBracketPictPopartOn;
extern NSString *const CameraPropertyValueBracketPictPopartOff;
extern NSString *const CameraPropertyBracketPictFantasicFocus;
extern NSString *const CameraPropertyValueBracketPictFantasicFocusOn;
extern NSString *const CameraPropertyValueBracketPictFantasicFocusOff;
extern NSString *const CameraPropertyBracketPictDaydream;
extern NSString *const CameraPropertyValueBracketPictDaydreamOn;
extern NSString *const CameraPropertyValueBracketPictDaydreamOff;
extern NSString *const CameraPropertyBracketPictLightTone;
extern NSString *const CameraPropertyValueBracketPictLightToneOn;
extern NSString *const CameraPropertyValueBracketPictLightToneOff;
extern NSString *const CameraPropertyBracketPictRoughMonochrome;
extern NSString *const CameraPropertyValueBracketPictRoughMonochromeOn;
extern NSString *const CameraPropertyValueBracketPictRoughMonochromeOff;
extern NSString *const CameraPropertyBracketPictToyPhoto;
extern NSString *const CameraPropertyValueBracketPictToyPhotoOn;
extern NSString *const CameraPropertyValueBracketPictToyPhotoOff;
extern NSString *const CameraPropertyBracketPictMiniature;
extern NSString *const CameraPropertyValueBracketPictMiniatureOn;
extern NSString *const CameraPropertyValueBracketPictMiniatureOff;
extern NSString *const CameraPropertyBracketPictCrossProcess;
extern NSString *const CameraPropertyValueBracketPictCrossProcessOn;
extern NSString *const CameraPropertyValueBracketPictCrossProcessOff;
extern NSString *const CameraPropertyBracketPictGentleSepia;
extern NSString *const CameraPropertyValueBracketPictGentleSepiaOn;
extern NSString *const CameraPropertyValueBracketPictGentleSepiaOff;
extern NSString *const CameraPropertyBracketPictDramaticTone;
extern NSString *const CameraPropertyValueBracketPictDramaticToneOn;
extern NSString *const CameraPropertyValueBracketPictDramaticToneOff;
extern NSString *const CameraPropertyBracketPictLigneClair;
extern NSString *const CameraPropertyValueBracketPictLigneClairOn;
extern NSString *const CameraPropertyValueBracketPictLigneClairOff;
extern NSString *const CameraPropertyBracketPictPastel;
extern NSString *const CameraPropertyValueBracketPictPastelOn;
extern NSString *const CameraPropertyValueBracketPictPastelOff;
extern NSString *const CameraPropertyBracketPictVintage;
extern NSString *const CameraPropertyValueBracketPictVintageOn;
extern NSString *const CameraPropertyValueBracketPictVintageOff;
extern NSString *const CameraPropertyBracketPictPartcolor;
extern NSString *const CameraPropertyValueBracketPictPartcolorOn;
extern NSString *const CameraPropertyValueBracketPictPartcolorOff;
extern NSString *const CameraPropertyColortone;
extern NSString *const CameraPropertyValueColortoneFlat;
extern NSString *const CameraPropertyValueColortoneNatural;
extern NSString *const CameraPropertyValueColortoneMonotone;
extern NSString *const CameraPropertyValueColortonePortrait;
extern NSString *const CameraPropertyValueColortoneIFinish;
extern NSString *const CameraPropertyValueColortoneVivid;
extern NSString *const CameraPropertyValueColortoneEportrait;
extern NSString *const CameraPropertyValueColortoneColorCreator;
extern NSString *const CameraPropertyValueColortonePopart;
extern NSString *const CameraPropertyValueColortoneFantasicFocus;
extern NSString *const CameraPropertyValueColortoneDaydream;
extern NSString *const CameraPropertyValueColortoneLightTone;
extern NSString *const CameraPropertyValueColortoneRoughMonochrome;
extern NSString *const CameraPropertyValueColortoneToyPhoto;
extern NSString *const CameraPropertyValueColortoneMiniature;
extern NSString *const CameraPropertyValueColortoneCrossProcess;
extern NSString *const CameraPropertyValueColortoneGentleSepia;
extern NSString *const CameraPropertyValueColortoneDramaticTone;
extern NSString *const CameraPropertyValueColortoneLigneClair;
extern NSString *const CameraPropertyValueColortonePastel;
extern NSString *const CameraPropertyValueColortoneVintage;
extern NSString *const CameraPropertyValueColortonePartcolor;
extern NSString *const CameraPropertyContrastFlat;
extern NSString *const CameraPropertyContrastNatural;
extern NSString *const CameraPropertyContrastMonochrome;
extern NSString *const CameraPropertyContrastSoft;
extern NSString *const CameraPropertyContrastIFinish;
extern NSString *const CameraPropertyContrastVivid;
extern NSString *const CameraPropertySharpFlat;
extern NSString *const CameraPropertySharpNatural;
extern NSString *const CameraPropertySharpMonochrome;
extern NSString *const CameraPropertySharpSoft;
extern NSString *const CameraPropertySharpIFinish;
extern NSString *const CameraPropertySharpVivid;
extern NSString *const CameraPropertySaturationLevelFlat;
extern NSString *const CameraPropertySaturationLevelNatural;
extern NSString *const CameraPropertySaturationLevelSoft;
extern NSString *const CameraPropertySaturationLevelIFinish;
extern NSString *const CameraPropertySaturationLevelVivid;
extern NSString *const CameraPropertyToneFlat;
extern NSString *const CameraPropertyToneNatural;
extern NSString *const CameraPropertyToneMonochrome;
extern NSString *const CameraPropertyToneSoft;
extern NSString *const CameraPropertyToneIFinish;
extern NSString *const CameraPropertyToneVivid;
extern NSString *const CameraPropertyEffectLevelIFinish;
extern NSString *const CameraPropertyToneControlLow;
extern NSString *const CameraPropertyToneControlMiddle;
extern NSString *const CameraPropertyToneControlHigh;
extern NSString *const CameraPropertyMonotonefilterMonochrome;
extern NSString *const CameraPropertyMonotonefilterRoughMonochrome;
extern NSString *const CameraPropertyMonotonefilterDramaticTone;
extern NSString *const CameraPropertyMonotonecolorMonochrome;
extern NSString *const CameraPropertyMonotonecolorRoughMonochrome;
extern NSString *const CameraPropertyMonotonecolorDramaticTone;
extern NSString *const CameraPropertyColorCreatorColor;
extern NSString *const CameraPropertyColorCreatorVivid;
extern NSString *const CameraPropertyWb;
extern NSString *const CameraPropertyValueWbWbAuto;
extern NSString *const CameraPropertyValueWbMwbFine;
extern NSString *const CameraPropertyValueWbMwbShade;
extern NSString *const CameraPropertyValueWbMwbCloud;
extern NSString *const CameraPropertyValueWbMwbLamp;
extern NSString *const CameraPropertyValueWbMwbFluorescence1;
extern NSString *const CameraPropertyValueWbMwbWater1;
extern NSString *const CameraPropertyValueWbWbCustom1;
extern NSString *const CameraPropertyCustomWbKelvin1;
extern NSString *const CameraPropertyWbRevAuto;
extern NSString *const CameraPropertyWbRevGAuto;
extern NSString *const CameraPropertyWbRev5300k;
extern NSString *const CameraPropertyWbRevG5300k;
extern NSString *const CameraPropertyWbRev7500k;
extern NSString *const CameraPropertyWbRevG7500k;
extern NSString *const CameraPropertyWbRev6000k;
extern NSString *const CameraPropertyWbRevG6000k;
extern NSString *const CameraPropertyWbRev3000k;
extern NSString *const CameraPropertyWbRevG3000k;
extern NSString *const CameraPropertyWbRev4000k;
extern NSString *const CameraPropertyWbRevG4000k;
extern NSString *const CameraPropertyWbRevAutoUnderWater;
extern NSString *const CameraPropertyWbRevGAutoUnderWater;
extern NSString *const CameraPropertyAutoWbDenkyuColoredLeaving;
extern NSString *const CameraPropertyValueAutoWbDenkyuColoredLeavingOff;
extern NSString *const CameraPropertyValueAutoWbDenkyuColoredLeavingOn;

// 正式なカメラプロパティではない、アプリで便宜上用意した仮想カメラプロパティ
extern NSString *const CameraPropertyHighTemperatureWarning;
extern NSString *const CameraPropertyLensMountStatus;
extern NSString *const CameraPropertyMediaMountStatus;
extern NSString *const CameraPropertyMediaBusy;
extern NSString *const CameraPropertyMediaError;
extern NSString *const CameraPropertyRemainingImageCapacity;
extern NSString *const CameraPropertyRemainingMediaCapacity;
extern NSString *const CameraPropertyRemainingVideoCapacity;
extern NSString *const CameraPropertyCurrentFocalLength;
extern NSString *const CameraPropertyMinimumFocalLength;
extern NSString *const CameraPropertyMaximumFocalLength;
extern NSString *const CameraPropertyActualApertureValue;
extern NSString *const CameraPropertyActualShutterSpeed;
extern NSString *const CameraPropertyActualExposureCompensation;
extern NSString *const CameraPropertyActualIsoSensitivity;
extern NSString *const CameraPropertyActualIsoSensitivityWarning;
extern NSString *const CameraPropertyExposureWarning;
extern NSString *const CameraPropertyExposureMeteringWarning;
extern NSString *const CameraPropertyLevelGauge;
extern NSString *const CameraPropertyDetectedHumanFaces;
extern NSString *const CameraPropertyLiveViewSize;
extern NSString *const CameraPropertyMinimumDigitalZoomScale;
extern NSString *const CameraPropertyMaximumDigitalZoomScale;
extern NSString *const CameraPropertyCurrentDigitalZoomScale;
extern NSString *const CameraPropertyOpticalZoomingSpeed;
extern NSString *const CameraPropertyMagnifyingLiveView;
extern NSString *const CameraPropertyMagnifyingLiveViewScale;
extern NSString *const CameraPropertyArtEffectType;
extern NSString *const CameraPropertyArtEffectHybrid;
extern NSString *const CameraPropertyArtFilterAutoBracket;
extern NSString *const CameraPropertyContrast;
extern NSString *const CameraPropertySharp;
extern NSString *const CameraPropertySaturationLevel;
extern NSString *const CameraPropertyTone;
extern NSString *const CameraPropertyEffectLevel;
extern NSString *const CameraPropertyMonotonecolor;
extern NSString *const CameraPropertyMonotonefilter;
extern NSString *const CameraPropertyWbRev;
extern NSString *const CameraPropertyWbRevG;
extern NSString *const CameraPropertyAutoBracketingMode;
extern NSString *const CameraPropertyAutoBracketingCount;
extern NSString *const CameraPropertyAutoBracketingStep;
extern NSString *const CameraPropertyIntervalTimerMode;
extern NSString *const CameraPropertyIntervalTimerCount;
extern NSString *const CameraPropertyIntervalTimerTime;
extern NSString *const CameraPropertyRecordingElapsedTime;

@protocol AppCameraTakingPictureDelegate;

/// OLYCameraクラスにアプリ独自の機能を追加拡張したクラス。
/// OLYCameraに関連するデリゲートのマルチ配信をサポートしています。
@interface AppCamera : OLYCamera

@property (assign, nonatomic) AppCameraAutoBracketingMode autoBracketingMode; ///< オートブラケット撮影モード
@property (strong, nonatomic, readonly) NSArray *autoBracketingCountList; ///< オートブラケットで撮影する枚数の選択肢リスト
@property (assign, nonatomic) NSInteger autoBracketingCount; ///< オートブラケットで撮影する枚数(3以上の奇数)
@property (strong, nonatomic, readonly) NSArray *autoBracketingStepList; ///< オートブラケットで撮影する際のステップ数の選択肢リスト
@property (assign, nonatomic) NSInteger autoBracketingStep; ///< オートブラケットで撮影する際にカメラプロパティ値を変更するステップ数(1以上)
@property (assign, nonatomic) AppCameraIntervalTimerMode intervalTimerMode; ///< インターバルタイマー撮影モード
@property (strong, nonatomic, readonly) NSArray *intervalTimerCountList; ///< インターバルタイマーで撮影する回数の選択肢リスト
@property (assign, nonatomic) NSInteger intervalTimerCount; ///< インターバルタイマーで撮影する回数(2回以上)
@property (strong, nonatomic, readonly) NSArray *intervalTimerTimeList; ///< インターバルタイマーで撮影する際の時間間隔の選択肢リスト
@property (assign, nonatomic) NSTimeInterval intervalTimerTime; ///< インターバルタイマーで撮影する際の前回撮影開始から次の撮影開始までの時間間隔(秒数)
@property (assign, nonatomic, readonly) NSTimeInterval recordingElapsedTime; ///< 動画撮影経過時間
@property (assign, nonatomic, readonly) float minimumDigitalZoomScale;	///< デジタルズームの最小倍率
@property (assign, nonatomic, readonly) float maximumDigitalZoomScale;	///< デジタルズームの最大倍率
@property (assign, nonatomic, readonly) float currentDigitalZoomScale;	///< 現在のデジタルズームの倍率
@property (assign, nonatomic, readonly) OLYCameraMagnifyingLiveViewScale magnifyingLiveViewScale;	///< 現在のライブビュー拡大の倍率

/// connectionDelegateのリストに登録します。
/// connectionDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addConnectionDelegate:(id<OLYCameraConnectionDelegate>)delegate;

/// connectionDelegateのリストから削除します。
- (void)removeConnectionDelegate:(id<OLYCameraConnectionDelegate>)delegate;

/// cameraPropertyDelegateのリストに登録します。
/// cameraPropertyDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addCameraPropertyDelegate:(id<OLYCameraPropertyDelegate>)delegate;

/// cameraPropertyDelegateのリストから削除します。
- (void)removeCameraPropertyDelegate:(id<OLYCameraPropertyDelegate>)delegate;

/// playbackDelegateのリストに登録します。
/// playbackDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addPlaybackDelegate:(id<OLYCameraPlaybackDelegate>)delegate;

/// playbackDelegateのリストから削除します。
- (void)removePlaybackDelegate:(id<OLYCameraPlaybackDelegate>)delegate;

/// liveViewDelegateのリストに登録します。
/// liveViewDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addLiveViewDelegate:(id<OLYCameraLiveViewDelegate>)delegate;

/// liveViewDelegateのリストから削除します。
- (void)removeLiveViewDelegate:(id<OLYCameraLiveViewDelegate>)delegate;

/// recordingDelegateのリストに登録します。
/// recordingDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addRecordingDelegate:(id<OLYCameraRecordingDelegate>)delegate;

/// recordingDelegateのリストから削除します。
- (void)removeRecordingDelegate:(id<OLYCameraRecordingDelegate>)delegate;

/// recordingSupportsDelegateのリストに登録します。
/// recordingSupportsDelegateプロパティには直接代入せずにこのメソッドでデリゲートを登録してください。
- (void)addRecordingSupportsDelegate:(id<OLYCameraRecordingSupportsDelegate>)delegate;

/// recordingSupportsDelegateのリストから削除します。
- (void)removeRecordingSupportsDelegate:(id<OLYCameraRecordingSupportsDelegate>)delegate;

/// takingPictureDelegateのリストに登録します。
- (void)addTakingPictureDelegate:(id<AppCameraTakingPictureDelegate>)delegate;

/// takingPictureDelegateのリストから削除します。
- (void)removeTakingPictureDelegate:(id<AppCameraTakingPictureDelegate>)delegate;

/// 自動露光制御の動作をロックします。 非同期実行バージョンです。
- (void)lockAutoExposure:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler;

/// カメラプロパティに変化があったことをデリゲート集合のそれぞれに通知します。(ただし通知元は除きます)
- (void)camera:(OLYCamera *)camera notifyDidChangeCameraProperty:(NSString *)name sender:(id<OLYCameraPropertyDelegate>)sender;

/// カメラプロパティのローカライズされたタイトルを取得します。
/// 先ず、AppCamera.stringsに"<カメラプロパティ名>"で定義があればそのローカライズを使用します。
/// なければ、AppCamera.stringsにcameraPropertyTitle:で取得した文言が定義としてあればそのローカライズを使用します。
/// それでもなければ、cameraPropertyTitle:で取得した文言がそのまま使用されます。
- (NSString *)cameraPropertyLocalizedTitle:(NSString *)name;

/// カメラプロパティ値のローカライズされたタイトルを取得します。
/// 先ず、AppCamera.stringsに"<カメラプロパティ名/カメラプロパティ値>"で定義があればそのローカライズを使用します。
/// なければ、AppCamera.stringsにcameraPropertyValueTitle:で取得した文言が定義としてあればそのローカライズを使用します。
/// それでもなければ、cameraPropertyValueTitle:で取得した文言がそのまま使用されます。
- (NSString *)cameraPropertyValueLocalizedTitle:(NSString *)value;

/// コンテンツ情報のローカライズされたタイトルを取得します。
/// 先ず、AppCamera.stringsに"<コンテンツ情報の要素名>"で定義があればそのローカライズを使用します。
/// なければ、要素名がそのまま使用されます。
- (NSString *)contentInformationLocalizedTitle:(NSString *)name;

/// コンテンツ情報の値のローカライズされたタイトルを取得します。
/// 先ず、AppCamera.stringsに"<コンテンツ情報の要素名/値>"で定義があればそのローカライズを使用します。
/// なければ、要素名がそのまま使用されます。
- (NSString *)contentInformationValueLocalizedTitle:(NSString *)name value:(NSString *)value;

/// Core Locationから得た位置情報をカメラに登録します。
- (BOOL)setGeolocationWithCoreLocation:(CLLocation *)location error:(NSError **)error;

/// 現在のカメラ設定のスナップショットを作成します。
- (NSDictionary *)createSnapshotOfSetting:(NSError **)error;

/// 指定されたスナップショットを用いて当時のカメラ設定を復元します。
/// 復元しないカメラプロパティのリストを指定することもできます。
/// スナップショットにないいくつかの設定はデフォルト値を設定することもできます。
- (BOOL)restoreSnapshotOfSetting:(NSDictionary *)snapshot exclude:(NSArray *)exclude fallback:(BOOL)fallback error:(NSError **)error;

/// スナップショットがカメラ設定として妥当かを確認します。
- (BOOL)validateSnapshotOfSetting:(NSDictionary *)snapshot;

/// コンテンツ情報とメタデータからそれっぽいカメラ設定のスナップショットを作成します。
- (NSDictionary *)forgeSnapshotOfSettingWithContentInformation:(NSDictionary *)information metadata:(NSDictionary *)metadata;

/// カメラ設定のスナップショットを最適化します。
- (NSDictionary *)optimizeSnapshotOfSetting:(NSDictionary *)snapshot;

/// 動作ステータスを示します。
- (AppCameraActionStatus)cameraActionStatus;

/// 撮影タイプを示します。
- (AppCameraActionType)cameraActionType;

/// オートブラケット撮影の設定が可能かどうかを示します。
- (BOOL)canSetAutoBracketing;

/// インターバルタイマー撮影の設定が可能かどうかを示します。
- (BOOL)canSetIntervalTimer;

/// オートブラケット＋インターバルタイマー撮影を開始します。
- (void)startTakingPluralPictures:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress, NSDictionary *))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler;

/// オートブラケット＋インターバルタイマー撮影終了します。
- (void)stopTakingPluralPictures:(void (^)(NSDictionary *))completionHandler errorHandler:(void (^)(NSError *))errorHandler;

/// 現在設定されている撮影モードでのフォーカスモードを取得します。
- (AppCameraFocusMode)focusMode:(NSError **)error;

/// 現在設定されている倍率でライブビュー拡大を開始します。
- (BOOL)startMagnifyingLiveView:(NSError **)error;

/// 現在設定されている倍率でライブビュー拡大を位置指定で開始します。
- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point error:(NSError **)error;

@end

/// 静止画連続撮影中に起きたイベントを通知します。
@protocol AppCameraTakingPictureDelegate <NSObject>
@optional

/// オートブラケット＋インターバルタイマー撮影が開始した時に呼び出されます。
- (void)cameraDidStartTakingPluralPictures:(AppCamera *)camera;

/// オートブラケットによる1コマ撮影が開始する時に呼び出されます。
- (void)cameraWillTakePictureByAutoBracketing:(AppCamera *)camera currentCount:(NSInteger)current totalCount:(NSInteger)total;

/// オートブラケットによる1コマ撮影が完了した時に呼び出されます。
- (void)cameraDidTakePictureByAutoBracketing:(AppCamera *)camera currentCount:(NSInteger)current totalCount:(NSInteger)total;

/// インターバルタイマーによる1コマ撮影が開始する時に呼び出されます。
- (void)cameraWillTakePictureByIntervalTimer:(AppCamera *)camera currentCount:(NSInteger)current totalCount:(NSInteger)total;

/// インターバルタイマーによる1コマ撮影が完了した時に呼び出されます。
- (void)cameraDidTakePictureByIntervalTimer:(AppCamera *)camera currentCount:(NSInteger)current totalCount:(NSInteger)total;

/// インターバルタイマーによる次の1コマ撮影までの残り時間を更新した時に呼び出されます。
- (void)cameraDidPauseTakingPictureForIntervalTimer:(AppCamera *)camera remainTime:(NSTimeInterval)remain currentCount:(NSInteger)current totalCount:(NSInteger)total;

/// オートブラケット＋インターバルタイマー撮影が終了した時に呼び出されます。
- (void)cameraDidStopTakingPluralPictures:(AppCamera *)camera error:(NSError *)error;

@end
