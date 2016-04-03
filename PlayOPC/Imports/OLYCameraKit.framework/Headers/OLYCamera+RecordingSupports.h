/**
 * 
 * @file	OLYCamera+RecordingSupports.h
 * @brief	OLYCamera(RecordingSupports) class interface file.
 *
 * 
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
 * @name Olympus camera class: recording auxiliary category
 *
 * 
 * @{
 */

/**
 * 
 * Driving direction of optical zoom.
 *
 * 
 */
enum OLYCameraDrivingZoomLensDirection {	
    /**
     * Towards the wide end (zoom out).
     * 
     */
    OLYCameraDrivingZoomLensWide,	
	
    /**
     * Towards the telephoto end (zoom in).
     * 
     */
    OLYCameraDrivingZoomLensTele,	
};
typedef enum OLYCameraDrivingZoomLensDirection OLYCameraDrivingZoomLensDirection;

/**
 * Driving speed of optical zoom.
 * 
 */
enum OLYCameraDrivingZoomLensSpeed {	
    /**
     * Zoom at low speed.
     * 
     */
    OLYCameraDrivingZoomLensSpeedSlow,	
	
    /**
     * Zoom at high speed.
     * 
     */
    OLYCameraDrivingZoomLensSpeedFast,	
	
    /**
     * Zoom at medium speed.
     * 
     */
    OLYCameraDrivingZoomLensSpeedNormal,	
	
    /**
     * Zoom to wide or telephoto end at once.
     * 
     * 
     */
    OLYCameraDrivingZoomLensSpeedBurst,	
};
typedef enum OLYCameraDrivingZoomLensSpeed OLYCameraDrivingZoomLensSpeed;

/**
 * Magnification of live view.
 * 
 */
enum OLYCameraMagnifyingLiveViewScale {	
    /**
     * 5x magnification.
     * 
     */
    OLYCameraMagnifyingLiveViewScaleX5,	
	
    /**
     * 7x magnification.
     * 
     */
    OLYCameraMagnifyingLiveViewScaleX7,	
	
    /**
     * 10x magnification.
     * 
     */
    OLYCameraMagnifyingLiveViewScaleX10,	
	
    /**
     * 14x magnification.
     * 
     */
    OLYCameraMagnifyingLiveViewScaleX14,	
};
typedef enum OLYCameraMagnifyingLiveViewScale OLYCameraMagnifyingLiveViewScale;

/**
 * Scroll direction in magnified live view.
 * 
 */
enum OLYCameraMagnifyingLiveViewScrollDirection {	
    /**
     * Scroll up.
     * 
     */
    OLYCameraMagnifyingLiveViewScrollDirectionUp,	
	
    /**
     * Scroll left.
     * 
     */
    OLYCameraMagnifyingLiveViewScrollDirectionLeft,	
	
    /**
     * Scroll right.
     * 
     */
    OLYCameraMagnifyingLiveViewScrollDirectionRight,	
	
    /**
     * Scroll down.
     * 
     */
    OLYCameraMagnifyingLiveViewScrollDirectionDown,	
};
typedef enum OLYCameraMagnifyingLiveViewScrollDirection OLYCameraMagnifyingLiveViewScrollDirection;

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
 * @name Olympus camera class: recording auxiliary category
 *
 * 
 * @{
 */

/**
 * Dictionary key for accessing 'Orientation' elements of the level gauge information.
 */
extern NSString *const OLYCameraLevelGaugeOrientationKey;	

/**
 * Dictionary key for accessing 'Roll' elements of the level gauge information.
 * 'Roll' is rotation around the optical axis.
 */
extern NSString *const OLYCameraLevelGaugeRollingKey;	

/**
 * Dictionary key for accessing 'Pitch' elements of the level gauge information.
 * 'Pitch' describes the camera is pointed up or down.
 */
extern NSString *const OLYCameraLevelGaugePitchingKey;	

/**
 * Dictionary key for accessing 'Minimum zoom scale' elements of the level gauge information.
 */
extern NSString *const OLYCameraDigitalZoomScaleRangeMinimumKey;	

/**
 * Dictionary key to access 'Maximum zoom scale' elements of the digital zoom information.
 */
extern NSString *const OLYCameraDigitalZoomScaleRangeMaximumKey;	

/**
 * Dictionary key for accessing 'Overall view' elements of the magnified live view information.
 */
extern NSString *const OLYCameraMagnifyingOverallViewSizeKey;	

/**
 * Dictionary key for accessing 'Display area' elements of the magnified live view information.
 */
extern NSString *const OLYCameraMagnifyingDisplayAreaRectKey;	

/** @} */
/** @} */

@protocol OLYCameraRecordingSupportsDelegate;

#pragma mark -

/**
 * 
 * Recording auxiliary category of Olympus camera class.
 *
 * This category provides zoom control.
 *
 * 
 * @category OLYCamera(RecordingSupports)
 */
@interface OLYCamera(RecordingSupports)

/**
 * 
 * Delegate object to notify camera state when it changes. 
 * The camera state relates to capturing operation which affects still image or movie.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraRecordingSupportsDelegate> recordingSupportsDelegate;	

/**
 * 
 * Indicate optical zoom is changing in the camera.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 * @see OLYCamera::stopDrivingZoomLens:
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL drivingZoomLens;	

/**
 * 
 * Indicate that live view is magnified.
 *
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL magnifyingLiveView;	

/**
 * 
 * Information of level gauge.
 *
 * The following information is included.
 *   - #OLYCameraLevelGaugeOrientationKey ... Inclination and orientation on the camera body.
 *     - "landscape" ... Lens mount tilt is 0 degrees.
 *       Camera body is in horizontal direction.
 *       This is the normal state.
 *     - "portrait_left" ... Lens mount tilt is 90 degrees clockwise.
 *       Camera body is in horizontal direction.
 *     - "landscape_upside_down" ... Lens mount tilt is 180 degrees.
 *       Camera body is in horizontal direction.
 *       This is upside down state.
 *     - "portrait_right" ... Lens mount tilt is 270 degrees clockwise.
 *       Camera body is in horizontal direction.
 *     - "faceup" ...  The camera is pointed up. Horizontal orientation is undefined.
 *     - "facedown" ... The camera is pointed down. Horizontal orientation is undefined.
 *   - #OLYCameraLevelGaugeRollingKey ... Roll angle in degrees of the camera body relative to horizontal.
 *     If the angle cannot be determined, NaN is returned.
 *   - #OLYCameraLevelGaugePitchingKey ... Pitch angle in degrees of the camera body relative to horizontal.
 *     If the angle cannot be determined, NaN is returned.
 *
 * This property is set only if the following conditions are met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (strong, nonatomic, readonly) NSDictionary *levelGauge;	

/**
 * 
 * Face recognition results.
 *
 * Coordinate information of face detected by the camera is stored in dictionary format.
 * The dictionary key is a string that represents the identification number.
 * It is not possible to track the coordinates of a recognized face by relying on a specific identification number.
 *
 * This property is set only if the following conditions are met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (strong, nonatomic, readonly) NSDictionary *detectedHumanFaces;	

/**
 * 
 * Start driving optical zoom with specific speed and direction.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param direction Driving direction.
 * @param speed Driving speed.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 * 
 */
- (BOOL)startDrivingZoomLensForDirection:(OLYCameraDrivingZoomLensDirection)direction speed:(OLYCameraDrivingZoomLensSpeed)speed error:(NSError **)error;	

/**
 * 
 * Start driving optical zoom to the specified focal length.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param focalLength Focal length.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 * 
 */
- (BOOL)startDrivingZoomLensToFocalLength:(float)focalLength error:(NSError **)error;	

/**
 * 
 * Stop driving optical zoom.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 *
 * 
 */
- (BOOL)stopDrivingZoomLens:(NSError **)error;	

/**
 * 
 * Get configurable magnification range of digital zoom.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Configurable range. The acquired information is in dictionary format.
 *
 * The following information is included.
 *  - #OLYCameraDigitalZoomScaleRangeMinimumKey ... Minimum magnification.
 *  - #OLYCameraDigitalZoomScaleRangeMaximumKey ... Maximum magnification.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::changeDigitalZoomScale:error:
 *
 * 
 */
- (NSDictionary *)digitalZoomScaleRange:(NSError **)error;	

/**
 * 
 * Change magnification of digital zoom.
 *
 * If application specifies magnification that is not included in the configurable range,
 * there will be an error.
 * When changing run mode to any mode except recording mode, magnification is changed back to 1x automatically.
 *
 * @param scale Magnification of digital zoom.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::digitalZoomScaleRange:
 *
 * 
 */
- (BOOL)changeDigitalZoomScale:(float)scale error:(NSError **)error;	

/**
 * 
 * Start magnifying live view.
 *
 * If live view is already magnified, an error occurs.
 *
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 * 
 */
- (BOOL)startMagnifyingLiveView:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;	

/**
 * 
 * Start magnifying live view with center coordinate of magnification.
 *
 * If live view is already magnified, an error occurs.
 *
 * @param point Center coordinate of the magnified display in viewfinder coordinate system.
 * The viewfinder coordinate system is explained in coordinate conversion utilities section of functions menu.
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 * 
 */
- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point scale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;	

/**
 * 
 * Stop magnifying live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 *
 * 
 */
- (BOOL)stopMagnifyingLiveView:(NSError **)error;	

/**
 * 
 * Change magnification of live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 * 
 */
- (BOOL)changeMagnifyingLiveViewScale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;	

/**
 * 
 * Move display area in magnified live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param direction Scrolling direction of the display area.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 * @see OLYCamera::magnifyingLiveViewArea:
 *
 * 
 */
- (BOOL)changeMagnifyingLiveViewArea:(OLYCameraMagnifyingLiveViewScrollDirection)direction error:(NSError **)error;	

/**
 * 
 * Get display area information of magnified live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Display area information in the dictionary format.
 *   - #OLYCameraMagnifyingOverallViewSizeKey ... Size of the overall view.
 *   - #OLYCameraMagnifyingDisplayAreaRectKey ... Rectangular coordinates of the display area in viewfinder coordinate system. The viewfinder coordinate system is explained in coordinate conversion utilities section of functions menu.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *
 * @par Availability
 *   - Camera firmware: Version 1.1 or later.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 * @see OLYCamera::changeMagnifyingLiveViewArea:error:
 *
 * 
 */
- (NSDictionary *)magnifyingLiveViewArea:(NSError **)error;	

/**
 * 
 * Download the last captured image.
 *
 * Download the still image in the original size captured that was saved through the last shooting process.
 * This API may not return an expected image if the camera does not finish writing the image to the memory card.
 * Call this API after the camera finishes writing the image to the memory card.
 *
 * Only the last one image is returned even if continuous shooting is enabled.
 *
 * @param progressHandler Callback used when download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progress callback
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of download completion callback
 *   - data ... Binary data of the captured image.
 *   - metadata ... Meta data of the captured image.
 *
 * Argument of abnormal termination callback
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadLastCapturedImage:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to notify camera state when it changes. 
 * The camera state relates to capturing operation which do not affect still image or movie.
 *
 * 
 */
@protocol OLYCameraRecordingSupportsDelegate <NSObject>	
@optional

/**
 * 
 * Notify that SDK will receive preview image.
 *
 * Application is notified when preview image generated and camera property "RECVIEW" is set to "ON".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * The preview image is generated after:
 * 	- Application starts shooting.
 * 	- User presses shutter button.
 *
 * @param camera Instance that receives the image.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)cameraWillReceiveCapturedImagePreview:(OLYCamera *)camera;	

/**
 * 
 * Notify that SDK receives preview image.
 *
 * Application is notified when preview image generated and camera property "RECVIEW" is set to "ON".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * The preview image is generated after: 
 * 	- Application starts shooting.
 * 	- User presses shutter button.
 *
 * @param camera Instance that receives the image.
 * @param data Captured image for preview.
 * @param metadata Metadata of captured image for preview.
 *
 * There are cases where the following information is included in metadata with EXIF information.
 *     - "detectversion" ... Reserved for vendor.
 *     - "detectid" ... Reserved for vendor.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata;	

/**
 * 
 * Notify that SDK fails to receive preview image.
 *
 * @param camera Instance that fails to receive the preview image.
 * @param error Error details.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImagePreviewWithError:(NSError *)error;	

/**
 * 
 * Notify that SDK will receive original size image after shooting.
 *
 * This is notified at the end of the shot if camera property "DESTINATION_FILE" is set to "DESTINATION_FILE_WIFI".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * @param camera Instance that receives the image data.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)cameraWillReceiveCapturedImage:(OLYCamera *)camera;	

/**
 * 
 * Notify that SDK receives original size image after shooting.
 *
 * This is notified at the end of the shot if camera property "DESTINATION_FILE" is set to "DESTINATION_FILE_WIFI".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * @param camera Instance that receives the image data.
 * @param data Captured image for storage.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImage:(NSData *)data;	

/**
 * 
 * Notify that SDK will not receive original size image after shooting.
 *
 * @param camera Instance that fails to receive the image.
 * @param error Error details.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImageWithError:(NSError *)error;	

/**
 * 
 * Notify that the driving of the optical zoom is stopped due to reasons on camera side.
 *
 * This may be caused by the lens reaching the maximum or minimum zoom before calling to stop optical zoom.
 *
 * @param camera Instance that detects the camera stops recording.
 *
 * 
 */
- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera;	

@end

// EOF
