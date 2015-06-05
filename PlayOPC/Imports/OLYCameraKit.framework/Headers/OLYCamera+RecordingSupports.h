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

// This is reserved for vendors. Please do not use.
enum OLYCameraMagnifyingLiveViewScale {	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScaleX5,	
	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScaleX7,	
	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScaleX10,	
	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScaleX14,	
};
typedef enum OLYCameraMagnifyingLiveViewScale OLYCameraMagnifyingLiveViewScale;

// This is reserved for vendors. Please do not use.
enum OLYCameraMagnifyingLiveViewScrollDirection {	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScrollDirectionUp,	
	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScrollDirectionLeft,	
	
    // This is reserved for vendors. Please do not use.
    OLYCameraMagnifyingLiveViewScrollDirectionRight,	
	
    // This is reserved for vendors. Please do not use.
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

// ;-)

// ;-)

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
 * The camera state is regarding capturing operation which affects still image or movie.
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

// This is reserved for vendors. Please do not use.
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
 * This property is not set if the following conditions are not met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 * 
 */
@property (strong, nonatomic, readonly) NSDictionary *levelGauge;	

/**
 * 
 * Face recognition results.
 *
 * Coordinate information of face detected by the camera is stored in a dictionary format.
 * The dictionary key is a string that represents the identification number.
 * It is not possible to track the coordinates of a recognized face by relying on a specific identification number.
 *
 * This property is not set if the following conditions are not met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
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
 * @par This method call is allowed only in following run modes and otherwise causes an error.
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
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
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
 * If the optical zoom already being driven, application will get an error.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error. 
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
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
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
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::digitalZoomScaleRange:
 *
 * 
 */
- (BOOL)changeDigitalZoomScale:(float)scale error:(NSError **)error;	

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to notify camera state when it changes. 
 * The camera state is regarding capturing operation which do not affect still image or movie.
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
 * 
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata;	

/**
 * 
 * Notify that SDK failes to receive preview image.
 *
 * @param camera Instance that failes to receive the image.
 * @param error Error details.
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
 * @param camera Instance that receives image data.
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
 * @param camera Instance that receives image data.
 * @param data Captured image for storage.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImage:(NSData *)data;	

/**
 * 
 * Notify that SDK failes to receive original size image after shooting.
 *
 * @param camera Instance that failes to receive the image.
 * @param error Error details.
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
