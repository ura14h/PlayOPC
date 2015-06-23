/**
 * @~english
 * @file	OLYCamera+Recording.h
 * @brief	OLYCamera(Recording) class interface file.
 *
 * @~japanese
 * @file	OLYCamera+Recording.h
 * @brief	OLYCamera(Recording) クラスインターフェースファイル
 *
 * @~
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 * 
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 * 
 * @{
 */
/**
 * 
 * @name Olympus camera class: recording category
 *
 * 
 * @{
 */

/**
 * 
 * Type of shooting mode and drive mode.
 *
 * 
 */
enum OLYCameraActionType {	
	
	/**
     * 
	 * Mode is unknown.
	 *
     * 
     */
	OLYCameraActionTypeUnknown,	
	
	/**
     * 
	 * Still image single shooting mode.
	 *
	 * Mode that takes 1 image after a single tap.
	 *
     * 
     */
	OLYCameraActionTypeSingle,	
	
	/**
     * 
	 * Still image continuous shooting mode.
	 *
	 * Mode that quickly takes multiple images while a user is touching the device.
	 *
     * 
     */
	OLYCameraActionTypeSequential,	
	
	/**
     * 
	 * Movie recording mode.
	 *
	 * Mode that starts recording when user taps device and stops recording when user again taps device.
	 *
     * 
     */
	OLYCameraActionTypeMovie,	
	
};
typedef enum OLYCameraActionType OLYCameraActionType;

/**
 * 
 * Progress of the capturing operation.
 *
 * 
 */
enum OLYCameraTakingProgress {	
	/**
	 * 
	 * Start auto focus.
	 *
	 * This notification is called even if focus is locked.
	 *
     * 
     */
	OLYCameraTakingProgressBeginFocusing,	
	
	/**
	 * 
	 * End auto focus.
	 *
	 * This timing is appropriate for the application to play a sound effect or
	 * display the focus result.
	 *
     * 
     */
	OLYCameraTakingProgressEndFocusing,	
	
	/**
	 * 
	 * Preparation of the exposure has been completed.
	 *
     * 
     */
	OLYCameraTakingProgressReadyCapturing,	
	
	/**
	 * 
	 * Start exposure.
	 *
	 * This timing is appropriate for the application to play a sound effect or
	 * display that the shutter is open. 
	 *
     * 
     */
	OLYCameraTakingProgressBeginCapturing,	
	
	/**
	 * 
	 * This is reserved for future use.
	 *
     * 
     */
	OLYCameraTakingProgressBeginNoiseReduction,	
	
	/**
	 * 
 	 * This is reserved for future use.
	 *
     * 
     */
	OLYCameraTakingProgressEndNoiseReduction,	
	
	/**
	 * 
	 * Exposure is complete.
	 *
	 * This timing is appropriate for the application to play a sound effect or display that the shutter is closed.
	 *
     * 
     */
	OLYCameraTakingProgressEndCapturing,	
	
	/**
	 * 
	 * Shooting action is complete.
	 *
     * 
     */
	OLYCameraTakingProgressFinished,	
};
typedef enum OLYCameraTakingProgress OLYCameraTakingProgress;

/**
 * 
 * Size of live view that the camera supports.
 *
 * 
 */
typedef CGSize OLYCameraLiveViewSize;	

/** @} */
/** @} */

/**
 * 
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 * 
 * @{
 */
/**
 * 
 * @name Olympus camera class: recording category
 *
 * 
 * @{
 */

/**
 * Display in QVGA (320x240) size live view.
 * 
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeQVGA;	

/**
 * Display in VGA (640x480) size live view.
 * 
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeVGA;	

/**
 * Display in SVGA (800x600) size live view.
 * 
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeSVGA;	

/**
 * Display in XGA (1024x768) size live view.
 * 
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeXGA;	

/**
 * Display in Quad-VGA (1280x960) size live view.
 * 
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeQuadVGA;	

/**
 * 
 * Dictionary key to access elements that specifies maximum number of shots at beginning of continuous shooting.
 * 
 */
extern NSString *const OLYCameraStartTakingPictureOptionLimitShootingsKey;	

/**
 * 
 * Dictionary key to access focusing result given as parameter of progressHandler when shooting.
 * 
 */
extern NSString *const OLYCameraTakingPictureProgressInfoFocusResultKey;	

/**
 * 
 * Dictionary key to access coordinates of focus given as parameter of progressHandler when shooting.
 * 
 */
extern NSString *const OLYCameraTakingPictureProgressInfoFocusRectKey;	

/** @} */
/** @} */

@protocol OLYCameraLiveViewDelegate;
@protocol OLYCameraRecordingDelegate;

#pragma mark -

/**
 * 
 * Recording category of Olympus camera class.
 *
 * This category takes still pictures, records video, and controls exposure and focus.
 *
 * Application can configure exposure parameters, focus, color and tone using camera property control methods in
 * @ref OLYCamera(CameraSystem) categories.
 * Please refer to list of camera properties for more information.
 *
 * 
 * @category OLYCamera(Recording)
 */
@interface OLYCamera(Recording)

/**
 * 
 * Indicate that live view starts automatically when run mode is changed to Recording mode.
 *
 * If false, call API to start live view after changing run mode to Recording mode.
 *
 * @see OLYCamera::startLiveView:
 * @see OLYCamera::stopLiveView:
 *
 * 
 */
@property (assign, nonatomic) BOOL autoStartLiveView;	

/**
 * 
 * Indicate that live view started.
 *
 * @see OLYCamera::startLiveView:
 * @see OLYCamera::stopLiveView:
 *
 * 
 */
@property (assign, nonatomic ,readonly) BOOL liveViewEnabled;	

/**
 * 
 * Frame size of live view in pixels.
 *
 * @see OLYCamera::changeLiveViewSize:error:
 *
 * 
 */
@property (assign, nonatomic, readonly) OLYCameraLiveViewSize liveViewSize;	

/**
 * 
 * Delegate object that notifies state of live view image when it changes.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraLiveViewDelegate> liveViewDelegate;	

/**
 * 
 * Delegate object that notifies camera state when it changes. The camera state relates to capturing operation which affects still image or movie.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraRecordingDelegate> recordingDelegate;	

/**
 * 
 * Indicate that photo shooting is in progress on the camera.
 *
 * When shooting is in progress, the application cannot change the value of the camera properties.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL takingPicture;	

/**
 * 
 * Indicate that video recording is in progress on the camera.
 *
 * When recording is in progress, the application cannot change the value of the camera properties.
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL recordingVideo;	

/**
 * 
 * Current focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 * @see OLYCamera::stopDrivingZoomLens:
 *
 * 
 */
@property (assign, nonatomic, readonly) float actualFocalLength;	

/**
 * 
 * Focal length at the wide end of the lens.
 * This is the shortest focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 *
 * 
 */
@property (assign, nonatomic, readonly) float minimumFocalLength;	

/**
 * 
 * Focal length at the telephoto end of the lens.
 * This is the longest focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 *
 * 
 */
@property (assign, nonatomic, readonly) float maximumFocalLength;	

/**
 * 
 * Coordinates focused with autofocus.
 *
 * These coordinates are expressed in viewfinder coordinate system.
 * The application can convert the coordinates in the live view image using
 * the coordinate conversion utility #OLYCameraConvertPointOnViewfinderIntoLiveImage.
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 * @see OLYCamera::clearAutoFocusPoint:
 *
 * 
 */
@property (assign, nonatomic, readonly) CGPoint actualAutoFocusPoint;	

/**
 * 
 * F value used by lens and camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * This value can be changed when zooming where the focal length is set to the minimum aperture.
 * Aperture value is set to the minimum value if the value to be set is smaller than the minimum value.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *actualApertureValue;	


/**
 * 
 * Shutter speed used by the camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 * 
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *actualShutterSpeed;	

/**
 * 
 * Exposure compensation value used by the camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 * 
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *actualExposureCompensation;	

/**
 * 
 * ISO sensitivity used by camera.
 *
 * When ISO sensitivity of the camera property is set to automatic,
 * the value that the camera has chosen will be set.
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *actualIsoSensitivity;	

/**
 * 
 * Indicate that out of range warning of ISO sensitivity is occurring in the camera.
 *
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL actualIsoSensitivityWarning;	

/**
 * 
 * Indicate that out of range warning of the exposure is occurring in the camera.
 *
 * The camera can not determine ISO sensitivity, shutter speed or aperture value corresponding
 * to current exposure value.
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL exposureWarning;	

/**
 * 
 * Indicate that warning of the exposure metering is occurring in the camera.
 *
 * Subject is too dark or too bright to be measured by the camera's exposure meter.
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL exposureMeteringWarning;	

/** 
 * 
 * Start live view.
 * 
 * If live view is not started, some properties cannot update their values, and
 * some methods for taking pictures and recording movies return an error.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::autoStartLiveView
 * @see OLYCamera::stopLiveView:
 *
 * 
 */
- (BOOL)startLiveView:(NSError **)error;	

/** 
 * 
 * Stop live view.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::autoStartLiveView
 * @see OLYCamera::startLiveView:
 *
 * 
 */
- (BOOL)stopLiveView:(NSError **)error;	

/**
 * 
 * Change the size of live view.
 *
 * @param size Size of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 *
 * @see OLYCamera::liveViewSize
 *
 */
- (BOOL)changeLiveViewSize:(OLYCameraLiveViewSize)size error:(NSError **)error;	

/**
 * 
 * Get the shooting mode and drive mode.
 *
 * The application can determine whether to perform any shooting
 * as a response to a user tap by referring to this value.
 * Please refer to the description of #OLYCameraActionType.
 *
 * 
 */
- (OLYCameraActionType)actionType;	

/**
 * 
 * Start shooting photo.
 *
 * Call this method only when shooting process is not in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param options Optional parameters of the shooting.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Optional shooting parameters.
 *   - Set the parameter in dictionary format to customize shooting.
 *     - #OLYCameraStartTakingPictureOptionLimitShootingsKey ... The maximum number of pictures taken by one continuous shooting. Range is 1 to 200, and default is 20.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Focus information is set in the dictionary format at the time of the end of auto focus.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       These coordinates are in viewfinder coordinate system.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * The application can convert the rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 * 
 */
- (void)startTakingPicture:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Finish shooting photo.
 *
 * Call this method only when shooting process is in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Not used in current version.
 *
 * Argument of completionHandler
 *   - info ... Not used in current version.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 * 
 */
- (void)stopTakingPicture:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Execute batch operation from start of shooting photos to end of shooting.
 *
 * Call this method only when shooting process is not in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param options Optional parameters of the shooting.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Optional shooting parameters
 *   - Set the parameter in dictionary format to customize shooting action.
 *     - #OLYCameraStartTakingPictureOptionLimitShootingsKey ... The maximum number of pictures taken by one continuous shooting. Range is 1 to 200, and default is 20.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Focus information is set in dictionary format when auto-focus ends.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       Coordinates are in viewfinder coordinate system.
 *
 * Argument of completionHandler
 *   - info ... Not used in current version.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * Application can convert rectangular coordinates in live view image using
 * coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 *
 * 
 */
- (void)takePicture:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Start recording movie.
 *
 * Call this method only when recording process is not in progress.
 * Do not call this method under still image shooting mode.
 *
 * @param options Not used in current version.
 * @param completionHandler Callback used when start of recording is complete.
 * @param errorHandler Callback used when the start of recording is aborted.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 * 
 */
- (void)startRecordingVideo:(NSDictionary *)options completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Finish recording movie.
 *
 * Call this method only when recording process is in progress.
 * Do not call this method under still image shooting mode.
 *
 * @param completionHandler Callback used when end of recording is complete.
 * @param errorHandler Callback used when end of recording is aborted.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 * 
 */
- (void)stopRecordingVideo:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Lock autofocus operation.
 *
 * Focus the camera to the specified coordinates, and then lock so that focus does not later change.
 * The application must have previously set the coordinates for auto focus.
 * The application must call unlock to resume auto focus.
 *
 * @param completionHandler Callback used when lock is complete.
 * @param errorHandler Callback used when lock was aborted.
 *
 * Argument of completionHandler
 *   - info ... Focus information is set in dictionary format at the time of the S-AF modes of auto focus.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       Coordinates are in viewfinder coordinate system.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * The application can convert rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 * @see OLYCamera::unlockAutoFocus:
 * @see OLYCameraRecordingDelegate::camera:didChangeAutoFocusResult:
 *
 * 
 */
- (void)lockAutoFocus:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Unlock autofocus operation.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoFocus:errorHandler:
 *
 * 
 */
- (BOOL)unlockAutoFocus:(NSError **)error;	

/**
 * 
 * Set coordinates to use for auto focus.
 *
 * Prior to locking focus,
 * the application sets the coordinates to focus with this method.
 * The application will get an error if value exceeds the valid range of focus coordinates.
 *
 * @param point Coordinates where to focus.
 * Coordinates are in viewfinder coordinate system.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * The application can convert the focusing coordinates from coordinates in live view image
 * using the coordinate conversion utility #OLYCameraConvertPointOnLiveImageIntoViewfinder.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoFocus:errorHandler:
 * @see OLYCamera::autoFocusEffectiveArea:
 * @see OLYCameraRecordingDelegate::camera:didChangeAutoFocusResult:
 *
 * 
 */
- (BOOL)setAutoFocusPoint:(CGPoint)point error:(NSError **)error;	

/**
 * 
 * Clear coordinates used for auto focus.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 *
 * 
 */
- (BOOL)clearAutoFocusPoint:(NSError **)error;	

/**
 * 
 * Lock operation of automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::unlockAutoExposure:
 *
 * 
 */
- (BOOL)lockAutoExposure:(NSError **)error;	

/**
 * 
 * Release lock of automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoExposure:
 *
 * 
 */
- (BOOL)unlockAutoExposure:(NSError **)error;	

/**
 * 
 * Specify coordinates of reference exposure for automatic exposure control.
 *
 * Application must set coordinates with this method prior
 * to locking automatic exposure control.
 * Application will get an error if value exceeds the valid range of target coordinates.
 *
 * Set camera property "AE" to "AE_PINPOINT" before calling this method.
 *
 * @param point Target coordinates.
 * Coordinates are in viewfinder coordinate system.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * Application can convert the focusing coordinates from the coordinates in live view image
 * using the coordinate conversion utility #OLYCameraConvertPointOnLiveImageIntoViewfinder.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::clearAutoExposurePoint:
 * @see OLYCamera::autoExposureEffectiveArea:
 *
 * 
 */
- (BOOL)setAutoExposurePoint:(CGPoint)point error:(NSError **)error;	

/**
 * 
 * Release specified coordinates of reference exposure for automatic exposure control.
 *
 * Set camera property "AE" to "AE_PINPOINT" before calling this method.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoExposurePoint:error:
 *
 * 
 */
- (BOOL)clearAutoExposurePoint:(NSError **)error;	

/**
 * 
 * Get valid range of coordinates to use for auto focus.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Rectangular coordinates indicating the effective range.
 * Coordinates are in viewfinder coordinate system.
 *
 * The application can convert to rectangular coordinates from live view image in the rectangular coordinates
 * indicating the range using the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 *
 * 
 */
- (CGRect)autoFocusEffectiveArea:(NSError **)error;	

/**
 * 
 * Get valid range of coordinates to use for automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Rectangular coordinates indicating the effective range.
 * Coordinates are in viewfinder coordinate system.
 *
 * The application can convert to rectangular coordinates for live view image on the rectangular coordinates
 * indicating the range using the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoExposurePoint:error:
 *
 * 
 */
- (CGRect)autoExposureEffectiveArea:(NSError **)error;	

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to notify state of live view image when it changes.
 *
 * 
 */
@protocol OLYCameraLiveViewDelegate <NSObject>	
@optional

/**
 * 
 * Notify that image for live view is updated.
 *
 * The application's live view can be updated in real time by using an image that has been attached to this notice.
 *
 * @param camera Instance that detects change in live view.
 * @param data Image of the new live view.
 * @param metadata Metadata of the image of the new live view.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didUpdateLiveView:(NSData *)data metadata:(NSDictionary *)metadata;	

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to notify camera state when it changes. 
 * The camera state relates to capturing operation which affects still image or movie.
 *
 * 
 */
@protocol OLYCameraRecordingDelegate <NSObject>	
@optional

/**
 * 
 * Notify that recording was started from the camera side.
 *
 * @param camera Instance that detects the camera starts recording.
 *
 *
 * 
 */
- (void)cameraDidStartRecordingVideo:(OLYCamera *)camera;	

/**
 * 
 * Notify that recording was stopped from the camera side.
 *
 * The following are possible causes.
 *   - Recording time reaches specified time.
 *   - Memory card becomes full during recording.
 *
 * @param camera Instance that detects the camera stops recording
 *
 * 
 */
- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera;	

/**
 * 
 * Notify result of auto focus when it changes.
 *
 * @param camera Instances it is detected that the focus result changes.
 * @param result Focusing result.
 *
 * Focusing result is passed in dictionary format.
 *   - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *     - "ok" ... In focus.
 *     - "ng" ... Did not focus.
 *     - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *   - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates for focus.
 *     Coordinates are in viewfinder coordinate system.
 *
 * The application can convert the rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didChangeAutoFocusResult:(NSDictionary *)result;	

@end

// EOF
