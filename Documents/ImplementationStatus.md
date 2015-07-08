# PLAY OPC - Camera Kit API 使用状況

## クラスとメソッド

### OACentralConfiguration

* initWithConfigurationURL:
* requestConfigurationURL:
* bleCode
* bleName

### OLYCamera(CameraConnection)

* bluetoothServices
* connect:
* connect:error:
* connectingRequiresBluetoothPassword:
* disconnectWithPowerOff:error:
* wakeup:
* bluetoothPassword
* bluetoothPeripheral
* bluetoothPrepareForRecordingWhenPowerOn
* connected
* connectionDelegate
* connectionType

### OLYCamera(CameraSystem)

* cameraPropertyTitle:
* cameraPropertyValue:error:
* cameraPropertyValueList:error:
* cameraPropertyValues:error:
* cameraPropertyValueTitle:
* canSetCameraProperty:
* changeRunMode:error:
* changeTime:error: (1.1.0)
* clearGeolocation:
* inquireHardwareInformation:
* setCameraPropertyValue:value:error:
* setCameraPropertyValues:error:
* setGeolocation:error:
* cameraPropertyDelegate
* cameraPropertyNames
* highTemperatureWarning
* lensMountStatus
* mediaBusy
* mediaError
* mediaMountStatus
* remainingImageCapacity
* remainingMediaCapacity
* remainingVideoCapacity
* runMode

### OLYCamera(Recording)

* actionType
* autoExposureEffectiveArea:
* autoFocusEffectiveArea:
* changeLiveViewSize:error:
* clearAutoExposurePoint:
* clearAutoFocusPoint:
* lockAutoExposure:
* lockAutoFocus:errorHandler:
* setAutoExposurePoint:error:
* setAutoFocusPoint:error:
* startLiveView:
* startRecordingVideo:completionHandler:errorHandler:
* startTakingPicture:progressHandler:completionHandler:errorHandler:
* stopLiveView:
* stopRecordingVideo:errorHandler:
* stopTakingPicture:completionHandler:errorHandler:
* takePicture:progressHandler:completionHandler:errorHandler:
* unlockAutoExposure:
* unlockAutoFocus:
* actualApertureValue
* ~~actualAutoFocusPoint~~
* actualExposureCompensation
* actualFocalLength
* actualIsoSensitivity
* actualIsoSensitivityWarning
* actualShutterSpeed
* autoStartLiveView
* exposureMeteringWarning
* exposureWarning
* liveViewDelegate
* liveViewEnabled
* liveViewSize
* maximumFocalLength
* minimumFocalLength
* recordingDelegate
* recordingVideo
* takingPicture

### OLYCamera(RecordingSupports)

* changeDigitalZoomScale:error:
* changeMagnifyingLiveViewScale:error: (1.1.0)
* *changeMagnifyingLiveViewArea:error: (1.1.0)*
* digitalZoomScaleRange:
* startDrivingZoomLensForDirection:speed:error:
* startDrivingZoomLensToFocalLength:error:
* startMagnifyingLiveView:error: (1.1.0)
* *startMagnifyingLiveViewAtPoint:scale:error: (1.1.0)*
* stopMagnifyingLiveView: (1.1.0)
* stopDrivingZoomLens:
* detectedHumanFaces
* drivingZoomLens
* levelGauge
* magnifyingLiveView (1.1.0)
* recordingSupportsDelegate

### OLYCamera(Playback)

* countNumberOfContents:
* downloadContent:progressHandler:completionHandler:errorHandler:
* downloadContentList:
* downloadContentScreennail:progressHandler:completionHandler:errorHandler:
* downloadContentThumbnail:progressHandler:completionHandler:errorHandler:
* downloadImage:withResize:progressHandler:completionHandler:errorHandler:
* inquireContentInformation:error:
* downloadLargeContent:progressHandler:completionHandler:errorHandler: (1.1.0)
* resizeVideoFrame:size:quality:progressHandler:completionHandler:errorHandler:
* playbackDelegate

### OLYCamera(PlaybackMaintenance)

* protectContent:error: (1.1.0)
* unprotectContent:error: (1.1.0)
* unprotectAllContents:completionHandler:errorHandler: (1.1.0)
* eraseContent:error: (1.1.0)

### OLYCameraConnectionDelegate

* camera:disconnectedByError:

### OLYCameraPropertyDelegate

* camera:didChangeCameraProperty:

### OLYCameraLiveViewDelegate

* camera:didUpdateLiveView:metadata:

### OLYCameraRecordingDelegate

* ~~camera:didChangeAutoFocusResult:~~
* cameraDidStartRecordingVideo:
* cameraDidStopRecordingVideo:

### OLYCameraRecordingSupportsDelegate

* camera:didFailToReceiveCapturedImagePreviewWithError:
* camera:didFailToReceiveCapturedImageWithError:
* camera:didReceiveCapturedImage:
* camera:didReceiveCapturedImagePreview:metadata:
* cameraDidStopDrivingZoomLens:
* cameraWillReceiveCapturedImage:
* cameraWillReceiveCapturedImagePreview:

## カメラプロパティ

### 基本設定

* APERTURE - 絞り値（F値）
* AE - 測光方式
* TAKEMODE - 撮影モード
* ISO - ISO感度
* EXPREV - 露出補正値
* TAKE\_DRIVE - ドライブモード
* ASPECT\_RATIO - アスペクト比
* SHUTTER - シャッター速度
* CONTINUOUS\_SHOOTING\_VELOCITY - 連写速度
* EXPOSE\_MOVIE\_SELECT - 動画撮影モード
* AE\_LOCK\_STATE - 露出固定（AEロック）

### 画質・画像保存

* IMAGESIZE - 静止画サイズ
* RAW - RAW設定
* COMPRESSIBILITY\_RATIO - 圧縮率
* QUALITY\_MOVIE - 動画画質モード
* DESTINATION\_FILE - 撮影画像保存先
* QUALITY\_MOVIE\_SHORT\_MOVIE\_RECORD\_TIME - クリップ記録時間

### フォーカス

* FOCUS\_STILL - フォーカスモード 静止画用
* AF\_LOCK\_STATE - フォーカス固定(AFロック)
* FULL\_TIME\_AF - フルタイムAF
* FOCUS\_MOVIE - フォーカスモード 動画用

### 撮影補助

* FACE\_SCAN - 顔検出
* ANTI\_SHAKE\_FOCAL\_LENGTH - IS焦点距離 (1.1.0)
* ~~TOUCH\_EFFECTIVE\_AREA\_UPPER\_LEFT - タッチAF可能範囲（左上座標）~~
* ~~TOUCH\_EFFECTIVE\_AREA\_LOWER\_RIGHT - タッチAF可能範囲（右下座標）~~
* RECVIEW - 撮影結果確認用画像
* ~~TOUCH\_AE\_EFFECTIVE\_AREA\_UPPER\_LEFT - タッチAE可能範囲（左上座標）~~
* ~~TOUCH\_AE_EFFECTIVE\_AREA\_LOWER\_RIGHT - タッチAE可能範囲（右下座標）~~
* ANTI\_SHAKE\_MOVIE - 動画手ぶれ補正 (1.1.0)

### そのほか

* BATTERY\_LEVEL - バッテリーレベル
* SOUND\_VOLUME\_LEVEL - 音量レベル
* GPS - Exif位置付与設定
* WIFI\_CH - Wi-Fiチャンネル (1.1.0)

### アートフィルター

* RECENTLY\_ART\_FILTER - アートフィルター種別
* COLOR\_PHASE - パートカラー用　色相
* ART\_EFFECT\_TYPE\_POPART - アートフィルターバリエーション ポップアート (1.1.0)
* ART\_EFFECT\_TYPE\_DAYDREAM - アートフィルターバリエーション デイドリーム (1.1.0)
* ART\_EFFECT\_TYPE\_ROUGH\_MONOCHROME - アートフィルターバリエーション ラフモノクローム (1.1.0)
* ART\_EFFECT\_TYPE\_TOY\_PHOTO - アートフィルターバリエーション トイフォト (1.1.0)
* ART\_EFFECT\_TYPE\_MINIATURE - アートフィルターバリエーション ジオラマ (1.1.0)
* ART\_EFFECT\_TYPE\_CROSS\_PROCESS - アートフィルターバリエーション クロスプロセス (1.1.0)
* ART\_EFFECT\_TYPE\_DRAMATIC\_TONE - アートフィルターバリエーション ドラマチックトーン (1.1.0)
* ART\_EFFECT\_TYPE\_LIGNE\_CLAIR - アートフィルターバリエーション リーニュクレール (1.1.0)
* ART\_EFFECT\_TYPE\_PASTEL - アートフィルターバリエーション ウォーターカラー (1.1.0)
* ART\_EFFECT\_TYPE\_VINTAGE - アートフィルターバリエーション ヴィンテージ (1.1.0)
* ART\_EFFECT\_TYPE\_PARTCOLOR - アートフィルターバリエーション パートカラー (1.1.0)
* ART\_EFFECT\_HYBRID\_POPART - アートエフェクト ポップアート (1.1.0)
* ART\_EFFECT\_HYBRID\_FANTASIC_FOCUS - アートエフェクト ファンタジックフォーカス (1.1.0)
* ART\_EFFECT\_HYBRID\_DAYDREAM - アートエフェクト デイドリーム (1.1.0)
* ART\_EFFECT\_HYBRID\_LIGHT\_TONE - アートエフェクト ライトトーン (1.1.0)
* ART\_EFFECT\_HYBRID\_ROUGH\_MONOCHROME - アートエフェクト ラフモノクローム (1.1.0)
* ART\_EFFECT\_HYBRID\_TOY\_PHOTO - アートエフェクト トイフォト (1.1.0)
* ART\_EFFECT\_HYBRID\_MINIATURE - アートエフェクト ジオラマ (1.1.0)
* ART\_EFFECT\_HYBRID\_CROSS\_PROCESS - アートエフェクト クロスプロセス (1.1.0)
* ART\_EFFECT\_HYBRID\_GENTLE\_SEPIA - アートエフェクト ジェントルセピア (1.1.0)
* ART\_EFFECT\_HYBRID\_DRAMATIC\_TONE - アートエフェクト ドラマチックトーン (1.1.0)
* ART\_EFFECT\_HYBRID\_LIGNE\_CLAIR - アートエフェクト リーニュクレール (1.1.0)
* ART\_EFFECT\_HYBRID\_PASTEL - アートエフェクト ウォーターカラー (1.1.0)
* ART\_EFFECT\_HYBRID\_VINTAGE - アートエフェクト ヴィンテージ (1.1.0)
* ART\_EFFECT\_HYBRID\_PARTCOLOR - アートエフェクト パートカラー (1.1.0)
* BRACKET\_PICT\_POPART - ART-BKT ポップアート
* BRACKET\_PICT\_FANTASIC\_FOCUS - ART-BKT ファンタジックフォーカス
* BRACKET\_PICT\_DAYDREAM - ART-BKT デイドリーム
* BRACKET\_PICT\_LIGHT\_TONE - ART-BKT ライトトーン
* BRACKET\_PICT\_ROUGH\_MONOCHROME - ART-BKT ラフモノクローム
* BRACKET\_PICT\_TOY\_PHOTO - ART-BKT トイフォト
* BRACKET\_PICT\_MINIATURE - ART-BKT ジオラマ
* BRACKET\_PICT\_CROSS\_PROCESS - ART-BKT クロスプロセス
* BRACKET\_PICT\_GENTLE\_SEPIA - ART-BKT ジェントルセピア
* BRACKET\_PICT\_DRAMATIC\_TONE - ART-BKT ドラマチックトーン
* BRACKET\_PICT\_LIGNE\_CLAIR - ART-BKT リーニュークレール
* BRACKET\_PICT\_PASTEL - ART-BKT ウォーターカラー
* BRACKET\_PICT\_VINTAGE - ART-BKT ヴィンテージ
* BRACKET\_PICT\_PARTCOLOR - ART-BKT パートカラー
* COLORTONE\_I\_FINISH - 仕上がり・ピクチャーモード
* CONTRAST\_I\_FINISH - ピクチャーモードの仕上がり設定 i-Finish コントラスト (1.1.0)
* SHARP\_I\_FINISH - ピクチャーモードの仕上がり設定 i-Finish シャープネス (1.1.0)
* SATURATION\_LEVEL\_I\_FINISH - ピクチャーモードの仕上がり設定 i-Finish 彩度 (1.1.0)
* TONE\_I\_FINISH - ピクチャーモードの仕上がり設定 i-Finish 階調 (1.1.0)
* EFFECT\_LEVEL\_I\_FINISH - ピクチャーモードの仕上がり設定 i-Finish 効果強弱 (1.1.0)
* CONTRAST\_VIVID - ピクチャーモードの仕上がり設定 Vivid コントラスト (1.1.0)
* SHARP\_VIVID - ピクチャーモードの仕上がり設定 Vivid シャープネス (1.1.0)
* SATURATION\_LEVEL\_VIVID - ピクチャーモードの仕上がり設定 Vivid 彩度 (1.1.0)
* TONE\_VIVID - ピクチャーモードの仕上がり設定 Vivid 階調 (1.1.0)
* CONTRAST\_NATURAL - ピクチャーモードの仕上がり設定 NATURAL コントラスト (1.1.0)
* SHARP\_NATURAL - ピクチャーモードの仕上がり設定 NATURAL シャープネス (1.1.0)
* SATURATION\_LEVEL\_NATURAL - ピクチャーモードの仕上がり設定 NATURAL 彩度 (1.1.0)
* TONE\_NATURAL - ピクチャーモードの仕上がり設定 NATURAL 階調 (1.1.0)
* CONTRAST\_FLAT - ピクチャーモードの仕上がり設定 FLAT コントラスト (1.1.0)
* SHARP\_FLAT - ピクチャーモードの仕上がり設定 FLAT シャープネス (1.1.0)
* SATURATION\_LEVEL\_FLAT - ピクチャーモードの仕上がり設定 FLAT 彩度 (1.1.0)
* TONE\_FLAT - ピクチャーモードの仕上がり設定 FLAT 階調 (1.1.0)
* CONTRAST\_SOFT - ピクチャーモードの仕上がり設定 SOFT コントラスト (1.1.0)
* SHARP\_SOFT - ピクチャーモードの仕上がり設定 SOFT シャープネス (1.1.0)
* SATURATION\_LEVEL\_SOFT - ピクチャーモードの仕上がり設定 SOFT 彩度 (1.1.0)
* TONE\_SOFT - ピクチャーモードの仕上がり設定 SOFT 階調 (1.1.0)
* CONTRAST\_ MONOCHROME- ピクチャーモードの仕上がり設定 モノトーン コントラスト (1.1.0)
* SHARP\_MONOCHROME - ピクチャーモードの仕上がり設定 モノトーン シャープネス (1.1.0)
* TONE\_MONOCHROME - ピクチャーモードの仕上がり設定 モノトーン 階調 (1.1.0)
* TONE\_CONTROL\_LOW - トーンコントロール シャドー部 (1.1.0)
* TONE\_CONTROL\_MIDDLE - トーンコントロール 中間部 (1.1.0)
* TONE\_CONTROL\_HIGH - トーンコントロール ハイライト部 (1.1.0)
* MONOTONEFILTER\_MONOCHROME - モノクロフィルター効果 ピクチャーモード モノトーン (1.1.0)
* MONOTONEFILTER\_ROUGH\_MONOCHROME - モノクロフィルター効果 アートフィルター ラフモノクローム (1.1.0)
* MONOTONEFILTER\_DRAMATIC\_TONE - モノクロフィルター効果 アートフィルター ドラマチックトーン (1.1.0)
* MONOTONECOLOR\_MONOCHROME - 調色効果 ピクチャーモード モノトーン (1.1.0)
* MONOTONECOLOR\_ROUGH\_MONOCHROME - 調色効果 アートフィルター ラフモノクローム (1.1.0)
* MONOTONECOLOR\_DRAMATIC\_TONE - 調色効果 アートフィルター ドラマチックトーン (1.1.0)
* COLOR\_CREATOR\_COLOR - カラークリエーター用　色相
* COLOR\_CREATOR\_VIVID - カラークリエーター用　彩度

### ホワイトバランス

* WB - ホワイトバランス
* CUSTOM\_WB\_KELVIN\_1 - カスタムWB K指定
* WB\_REV_3000K - 電球 WB補正A (1.1.0)
* WB\_REV_G_3000K - 電球 WB補正G (1.1.0)
* WB\_REV_4000K - 蛍光灯 WB補正A (1.1.0)
* WB\_REV_G_4000K - 蛍光灯 WB補正G (1.1.0)
* WB\_REV_5300K - 晴天 WB補正A (1.1.0)
* WB\_REV_G_5300K - 晴天 WB補正G (1.1.0)
* WB\_REV_6000K - 雲天 WB補正A (1.1.0)
* WB\_REV_G_6000K - 雲天 WB補正G (1.1.0)
* WB\_REV_7500K - 日陰 WB補正A (1.1.0)
* WB\_REV_G_7500K - 日陰 WB補正G (1.1.0)
* WB\_REV_ AUTO - Auto WB補正A (1.1.0)
* WB\_REV_G_AUTO - Auto WB補正G (1.1.0)
* WB\_REV_AUTO_UNDER_WATER - 水中 WB補正A (1.1.0)
* WB\_REV_G_AUTO_UNDER_WATER - 水中 WB補正G (1.1.0)
* AUTO\_WB\_DENKYU\_COLORED\_LEAVING - WBオート 電球色残し (1.1.0)

## 凡例

* 末尾の(1.1.0)は、初めてライブラリに登場した時のバージョン番号。省略時は1.0.0。
* *斜体* - 現バージョンのアプリでは未使用。
* ~~打消線~~ - アプリで使用する予定なし。
