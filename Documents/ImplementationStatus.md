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
* digitalZoomScaleRange:
* startDrivingZoomLensForDirection:speed:error:
* startDrivingZoomLensToFocalLength:error:
* stopDrivingZoomLens:
* detectedHumanFaces
* drivingZoomLens
* levelGauge
* recordingSupportsDelegate

### OLYCamera(Playback)

* countNumberOfContents:
* downloadContent:progressHandler:completionHandler:errorHandler:
* downloadContentList:
* downloadContentScreennail:progressHandler:completionHandler:errorHandler:
* downloadContentThumbnail:progressHandler:completionHandler:errorHandler:
* downloadImage:withResize:progressHandler:completionHandler:errorHandler:
* inquireContentInformation:error:
* resizeVideoFrame:size:quality:progressHandler:completionHandler:errorHandler:
* playbackDelegate

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
* QUALITY\_MOVIE\_SHORT\_MOVIE\_RECORD\_TIME - ショートムービー記録時間

### フォーカス

* FOCUS\_STILL - フォーカスモード 静止画用
* AF\_LOCK\_STATE - フォーカス固定(AFロック)
* FULL\_TIME\_AF - フルタイムAF
* FOCUS\_MOVIE - フォーカスモード 動画用

### 色合い・仕上がり

* CUSTOM\_WB\_KELVIN\_1 - カスタムWB K指定
* COLORTONE - 仕上がり・ピクチャーモード
* WB - ホワイトバランス
* COLOR\_CREATOR\_COLOR - カラークリエーター用　色相
* COLOR\_CREATOR\_VIVID - カラークリエーター用　彩度
* RECENTLY\_ART\_FILTER - アートフィルター種別
* COLOR\_PHASE - パートカラー用　色相
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

### 撮影補助

* BATTERY\_LEVEL - バッテリーレベル
* FACE\_SCAN - 顔検出
* ~~TOUCH\_EFFECTIVE\_AREA\_UPPER\_LEFT - タッチAF可能範囲（左上座標）~~
* ~~TOUCH\_EFFECTIVE\_AREA\_LOWER\_RIGHT - タッチAF可能範囲（右下座標）~~
* RECVIEW - 撮影結果確認用画像
* SOUND\_VOLUME\_LEVEL - 音量レベル
* ~~TOUCH\_AE\_EFFECTIVE\_AREA\_UPPER\_LEFT - タッチAE可能範囲（左上座標）~~
* ~~TOUCH\_AE_EFFECTIVE\_AREA\_LOWER\_RIGHT - タッチAE可能範囲（右下座標）~~
* GPS - Exif位置付与設定

