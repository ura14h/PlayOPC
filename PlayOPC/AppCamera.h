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

/// オートブラケットモード
typedef enum : NSInteger {
	AppCameraAutoBracketingModeDisabled = 0, ///< 無効(通常撮影)
	AppCameraAutoBracketingModeExposure, ///< 露出補正でオートブラケット
} AppCameraAutoBracketingMode;

// カメラプロパティ
extern NSString *const CameraPropertyAperture;
extern NSString *const CameraPropertyAe;
extern NSString *const CameraPropertyTakemode;
extern NSString *const CameraPropertyTakemodeP;
extern NSString *const CameraPropertyTakemodeA;
extern NSString *const CameraPropertyTakemodeS;
extern NSString *const CameraPropertyTakemodeM;
extern NSString *const CameraPropertyIso;
extern NSString *const CameraPropertyExprev;
extern NSString *const CameraPropertyTakeDrive;
extern NSString *const CameraPropertyAspectRatio;
extern NSString *const CameraPropertyShutter;
extern NSString *const CameraPropertyContinuousShootingVelocity;
extern NSString *const CameraPropertyExposeMovieSelect;
extern NSString *const CameraPropertyAeLockState;
extern NSString *const CameraPropertyAeLockStateLock;
extern NSString *const CameraPropertyAeLockStateUnlock;
extern NSString *const CameraPropertyImagesize;
extern NSString *const CameraPropertyRaw;
extern NSString *const CameraPropertyCompressibilityRatio;
extern NSString *const CameraPropertyQualityMovie;
extern NSString *const CameraPropertyDestinationFile;
extern NSString *const CameraPropertyQualityMovieShortMovieRecordTime;
extern NSString *const CameraPropertyFocusStill;
extern NSString *const CameraPropertyFocusStillMf;
extern NSString *const CameraPropertyFocusStillSaf;
extern NSString *const CameraPropertyAfLockState;
extern NSString *const CameraPropertyAfLockStateLock;
extern NSString *const CameraPropertyAfLockStateUnlock;
extern NSString *const CameraPropertyFullTimeAf;
extern NSString *const CameraPropertyFocusMovie;
extern NSString *const CameraPropertyFocusMovieMf;
extern NSString *const CameraPropertyFocusMovieSaf;
extern NSString *const CameraPropertyFocusMovieCaf;
extern NSString *const CameraPropertyBatteryLevel;
extern NSString *const CameraPropertyFaceScan;
extern NSString *const CameraPropertyAntiShakeFocalLength;
extern NSString *const CameraPropertyRecview;
extern NSString *const CameraPropertyAntiShakeMovie;
extern NSString *const CameraPropertySoundVolumeLevel;
extern NSString *const CameraPropertyGps;
extern NSString *const CameraPropertyWifiCh;
extern NSString *const CameraPropertyRecentlyArtFilter;
extern NSString *const CameraPropertyRecentlyArtFilterPopart;
extern NSString *const CameraPropertyRecentlyArtFilterFantasicFocus;
extern NSString *const CameraPropertyRecentlyArtFilterDaydream;
extern NSString *const CameraPropertyRecentlyArtFilterLightTone;
extern NSString *const CameraPropertyRecentlyArtFilterRoughMonochrome;
extern NSString *const CameraPropertyRecentlyArtFilterToyPhoto;
extern NSString *const CameraPropertyRecentlyArtFilterMiniature;
extern NSString *const CameraPropertyRecentlyArtFilterCrossProcess;
extern NSString *const CameraPropertyRecentlyArtFilterGentleSepia;
extern NSString *const CameraPropertyRecentlyArtFilterDramaticTone;
extern NSString *const CameraPropertyRecentlyArtFilterLigneClair;
extern NSString *const CameraPropertyRecentlyArtFilterPastel;
extern NSString *const CameraPropertyRecentlyArtFilterVintage;
extern NSString *const CameraPropertyRecentlyArtFilterPartcolor;
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
extern NSString *const CameraPropertyBracketPictFantasicFocus;
extern NSString *const CameraPropertyBracketPictDaydream;
extern NSString *const CameraPropertyBracketPictLightTone;
extern NSString *const CameraPropertyBracketPictRoughMonochrome;
extern NSString *const CameraPropertyBracketPictToyPhoto;
extern NSString *const CameraPropertyBracketPictMiniature;
extern NSString *const CameraPropertyBracketPictCrossProcess;
extern NSString *const CameraPropertyBracketPictGentleSepia;
extern NSString *const CameraPropertyBracketPictDramaticTone;
extern NSString *const CameraPropertyBracketPictLigneClair;
extern NSString *const CameraPropertyBracketPictPastel;
extern NSString *const CameraPropertyBracketPictVintage;
extern NSString *const CameraPropertyBracketPictPartcolor;
extern NSString *const CameraPropertyColortone;
extern NSString *const CameraPropertyColortoneFlat;
extern NSString *const CameraPropertyColortoneNatural;
extern NSString *const CameraPropertyColortoneMonotone;
extern NSString *const CameraPropertyColortonePortrait;
extern NSString *const CameraPropertyColortoneIFinish;
extern NSString *const CameraPropertyColortoneVivid;
extern NSString *const CameraPropertyColortoneEportrait;
extern NSString *const CameraPropertyColortoneColorCreator;
extern NSString *const CameraPropertyColortonePopart;
extern NSString *const CameraPropertyColortoneFantasicFocus;
extern NSString *const CameraPropertyColortoneDaydream;
extern NSString *const CameraPropertyColortoneLightTone;
extern NSString *const CameraPropertyColortoneRoughMonochrome;
extern NSString *const CameraPropertyColortoneToyPhoto;
extern NSString *const CameraPropertyColortoneMiniature;
extern NSString *const CameraPropertyColortoneCrossProcess;
extern NSString *const CameraPropertyColortoneGentleSepia;
extern NSString *const CameraPropertyColortoneDramaticTone;
extern NSString *const CameraPropertyColortoneLigneClair;
extern NSString *const CameraPropertyColortonePastel;
extern NSString *const CameraPropertyColortoneVintage;
extern NSString *const CameraPropertyColortonePartcolor;
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
extern NSString *const CameraPropertyWbWbAuto;
extern NSString *const CameraPropertyWbMwbFine;
extern NSString *const CameraPropertyWbMwbShade;
extern NSString *const CameraPropertyWbMwbCloud;
extern NSString *const CameraPropertyWbMwbLamp;
extern NSString *const CameraPropertyWbMwbFluorescence1;
extern NSString *const CameraPropertyWbMwbWater1;
extern NSString *const CameraPropertyWbWbCustom1;
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

/// OLYCameraクラスにアプリ独自の機能を追加拡張したクラス。
/// OLYCameraに関連するデリゲートのマルチ配信をサポートしています。
@interface AppCamera : OLYCamera

@property (assign, nonatomic) AppCameraAutoBracketingMode autoBracketingMode; ///< オートブラケットモード
@property (assign, nonatomic) NSInteger autoBracketingCount; ///< オートブラケットで撮影する枚数(3以上の奇数)
@property (assign, nonatomic) NSInteger autoBracketingStep; ///< オートブラケットで撮影する際にカメラプロパティ値を変更するステップ数(1以上)
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
- (BOOL)restoreSnapshotOfSetting:(NSDictionary *)snapshot exclude:(NSArray *)exclude error:(NSError **)error;

/// オートブラケット撮影の設定が可能かどうかを示します。
- (BOOL)canSetAutoBracketing;

/// 現在設定されている撮影モードでのフォーカスモードを取得します。
- (AppCameraFocusMode)focusMode:(NSError **)error;

/// 現在設定されている倍率でライブビュー拡大を開始します。
- (BOOL)startMagnifyingLiveView:(NSError **)error;

/// 現在設定されている倍率でライブビュー拡大を位置指定で開始します。
- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point error:(NSError **)error;

@end
