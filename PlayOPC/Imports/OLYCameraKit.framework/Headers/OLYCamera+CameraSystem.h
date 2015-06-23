/**
 * 
 * @file	OLYCamera+CameraSystem.h
 * @brief	OLYCamera(CameraSystem) class interface file.
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
 * @name Olympus camera class: camera system category
 *
 * 
 * @{
 */

/**
 * 
 * Run mode of the camera.
 *
 * 
 */
enum OLYCameraRunMode {	
	/**
     * 
	 * Mode where SDK does not work.
	 *
	 * Run mode is sometimes set to this value when the application is not connected or mode change is abnormally terminated.
	 *
     * 
     */
	OLYCameraRunModeUnknown,	
	
	/**
     * 
	 * Standalone mode.
	 *
	 * The run mode is this value immediately after connected to the camera.
	 *
	 * If the application changes to this mode from any other mode,
	 * several camera properties return to their initial states.
	 * For more information please refer to documentation of the camera list of properties.
	 *
     * 
     */
	OLYCameraRunModeStandalone,	
	
	/**
     * 
	 * Playback mode.
	 *
	 * This mode is used to view the captured image in the camera.
	 *
     * 
     */
	OLYCameraRunModePlayback,	
	
	/**
     * 
	 * Play-maintenance mode.
	 *
	 * This mode does not work and is reserved for future expansion.
	 *
     * 
     */
	OLYCameraRunModePlaymaintenance,	
	
	/**
     * 
	 * Recording mode.
	 * 
	 * This mode is used to capture still images and record videos by
	 * the shutter via wireless communication.
	 *
     * 
     */
	OLYCameraRunModeRecording,	
	
	/**
     * 
	 * Maintenance mode.
	 *
	 * This mode does not work and is reserved for future expansion.
	 *
     * 
     */
	OLYCameraRunModeMaintenance,	
	
	// This is reserved for vendor. Please do not use.
	OLYCameraRunModePlaystream,
	
};
typedef enum OLYCameraRunMode OLYCameraRunMode;

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
 * @name Olympus camera class: camera system category
 *
 * 
 * @{
 */

/**
 * Dictionary key for accessing 'Camera Model Name' element of camera hardware information.
 * 
 */
extern NSString *const OLYCameraHardwareInformationCameraModelNameKey;	

/**
 * Dictionary key for accessing 'Camera Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationCameraFirmwareVersionKey;	

/**
 * Dictionary key for accessing 'Lens Type' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensTypeKey;	

/**
 * Dictionary key for accessing 'Lens ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensIdKey;	

/**
 * Dictionary key for accessing 'Lens Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensFirmwareVersionKey;	

/**
 * Dictionary key for accessing 'Flash ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationFlashIdKey;	

/**
 * Dictionary key for accessing 'Flash Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationFlashFirmwareVersionKey;	

/**
 * Dictionary key for accessing 'Accessory ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationAccessoryIdKey;	

/**
 * Dictionary key for accessing 'Accessory Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationAccessoryFirmwareVersionKey;	

/** @} */
/** @} */

@protocol OLYCameraPropertyDelegate;

#pragma mark -

/**
 * 
 * This is a camera system category of Olympus camera class.
 *
 * This category gets or sets the camera settings (camera property) and changes the run mode.
 *
 * For example, the application can get or set the following camera properties:
 *   - Basic settings (F value, shutter speed, exposure mode, etc.)
 *   - Color tone and finish settings (white balance, art filter, etc.)
 *   - Focus settings (focus mode, such as focus lock)
 *   - Image quality and saving settings (image size, compression ratio, image quality mode, etc.)
 *   - Camera status (battery level, angle of view, etc.)
 *   - Recording auxiliary (face detection, sound volume level, etc.)
 *
 * Please refer to the camera list of properties for more information.
 *
 * 
 * @category OLYCamera(CameraSystem)
 */
@interface OLYCamera(CameraSystem)

/**
 * 
 * List of camera property names currently available.
 *
 * The application must check whether the target camera property is contained in the list or not.
 * If not, the target property can not be configured.
 *
 * @see OLYCamera::cameraPropertyValue:error:
 * @see OLYCamera::cameraPropertyValueList:error:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 * 
 */
@property (strong, nonatomic, readonly) NSArray *cameraPropertyNames;	

/**
 * 
 * The object that acts as the delegate to receive changes to camera property.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraPropertyDelegate> cameraPropertyDelegate;	

/**
 * 
 * Current run mode of the camera system.
 *
 * @see OLYCamera::changeRunMode:error:
 *
 * 
 */
@property (assign, nonatomic, readonly) OLYCameraRunMode runMode;	

/**
 * 
 * Indicate if inside of the camera is in high-temperature condition.
 *
 * You can also check using the lighting state of the LED on the camera body.
 * If the inside of the camera has reached a high temperature, please stop using the camera immediately,
 * and wait for the camera to return to normal temperature.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL highTemperatureWarning;	

/**
 * 
 * Indicate status of lens mount.
 *
 * Status of lens mount:
 *   - (nil) ... It is not connected to the camera, or the state is unknown.
 *   - "normal" ... The lens is mounted and available. If the lens has some additional functions,
 *     the following items are added to the end of "normal".
 *     - "+electriczoom" ... The lens is equipped with a motorized zoom.
 *     - "+macro" ... The lens is equipped with a macro mode.
 *   - "down" ... The lens is mounted. However retractable lens is not extended.
 *   - "nolens" ... Disabled because no lens is mounted.
 *   - "cantshoot" ... Disabled because of other reason.
 *
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *lensMountStatus;	

/**
 * 
 * Indicate status of media (memory card) mount.
 *
 * Status of media mount:
 *   - (nil) ... It is not connected to the camera, or the state is unknown.
 *   - "normal" ... Available in the media already mounted.
 *   - "readonly" ... The media is already mounted. But cannot write because the media is read-only.
 *   - "cardfull" ... The media is already mounted. But cannot write because the media is no free space.
 *   - "unmount" ... Disabled because the media is not mounted.
 *   - "error" ... Disabled because of a media mount error.
 *
 * 
 */
@property (strong, nonatomic, readonly) NSString *mediaMountStatus;	

/**
 * 
 * Indicate whether the camera is writing to the media (memory card).
 *
 * You can also check in the lighting state of the LED on the camera body.
 * While the camera is writing to the media, you will see API response is slow.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL mediaBusy;	

/**
 * 
 * Indicate whether the media (memory card) I/O error has occurred.
 *
 * There is a possibility that the media is broken.
 * Please replace with a new media if it occurs frequently.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL mediaError;	

/**
 * 
 * Free space of the media (memory card) attached to the camera. Unit is byte.
 *
 * 
 */
@property (assign, nonatomic, readonly) NSUInteger remainingMediaCapacity;	

/**
 * 
 * The maximum number of images that can be stored in the media (memory card).
 *
 * The exact value depends on the data for the compression ratio of the captured image.
 * Sometimes the value does not change after capturing.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 * 
 */
@property (assign, nonatomic, readonly) NSUInteger remainingImageCapacity;	

/**
 * 
 * The maximum number of seconds a movie that can be stored in the media (memory card).
 *
 * The exact value depends on the data for the compression ratio of the captured video.
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 *
 * 
 */
@property (assign, nonatomic, readonly) NSTimeInterval remainingVideoCapacity;	

/**
 * 
 * Get hardware information of the camera.
 *
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return The hardware information of the camera.
 *
 * Hardware information is in dictionary format.
 * The following keys are defined in order to access each element.
 *   - #OLYCameraHardwareInformationCameraModelNameKey ... Camera model name.
 *   - #OLYCameraHardwareInformationCameraFirmwareVersionKey ... Camera firmware version.
 *   - #OLYCameraHardwareInformationLensTypeKey ... Lens type.
 *   - #OLYCameraHardwareInformationLensIdKey ... Lens ID.
 *   - #OLYCameraHardwareInformationLensFirmwareVersionKey ... Lens firmware version.
 *   - #OLYCameraHardwareInformationFlashIdKey ... Flash ID.
 *   - #OLYCameraHardwareInformationFlashFirmwareVersionKey ... Flash firmware version.
 *   - #OLYCameraHardwareInformationAccessoryIdKey ... Accessory ID.
 *   - #OLYCameraHardwareInformationAccessoryFirmwareVersionKey ... Accessory firmware version.
 *
 * Please refer to the related documentation for more information.
 *
 * 
 */
- (NSDictionary *)inquireHardwareInformation:(NSError **)error;	

/**
 * 
 * Get title of the camera property.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will have an error.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO", "WB")
 * @return Display name for camera property. (e.g. "Aperture", "Shutter Speed", "ISO Sensitivity", "White Balance")
 *
 * @see OLYCamera::cameraPropertyNames
 *
 * 
 */
- (NSString *)cameraPropertyTitle:(NSString *)name;	

/**
 * 
 * Get list of the camera property values that can be set.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will have an error.
 * If the application changes settings such as shooting mode,
 * there are times when the contents of the list changes.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * Each value in the list is a string in the form of "<Property Name/Property Value>."
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO")
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return The list of the camera property values that can be set.
 *
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 *
 * 
 */
- (NSArray *)cameraPropertyValueList:(NSString *)name error:(NSError **)error;	

/**
 * 
 * Get value that is set in the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The return value is a string in the form of "<Property Name/Property Value>."
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO")
 * @param error Error details will be set when operation is abnormally terminated.
 * @return Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>")
 *
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::canSetCameraProperty:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 * 
 */
- (NSString *)cameraPropertyValue:(NSString *)name error:(NSError **)error;	

/**
 * 
 * Get values that are set in the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param names The camera property names. Each element is a string.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return The values set in the camera properties.
 *
 * The retrieved values are in dictionary format.
 * The dictionary key is the camera property name.
 * Setting of the camera property is stored in value corresponding to the key.
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::setCameraPropertyValues:error:
 *
 * 
 */
- (NSDictionary *)cameraPropertyValues:(NSSet *)names error:(NSError **)error;	

/**
 * 
 * Get title of the camera property value.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The argument for parameter "value" is a string in the form of "<Property Name/Property Value>."
 *
 * @param value Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>", "<WB/WB_AUTO>")
 * @return Display name for camera property value. (e.g. "3.5", "250", "Auto", "WB Auto")
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 *
 * 
 */
- (NSString *)cameraPropertyValueTitle:(NSString *)value;	

/**
 * 
 * Check to see if value to the camera properties can be set.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO", "WB")
 * @return If true, the camera property can be set. If false, the camera property cannot be set.
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 * 
 */
- (BOOL)canSetCameraProperty:(NSString *)name;	

/**
 * 
 * Set value to the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode and connection type etc.,
 * there are several properties that are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The argument for parameter "value" is a string in the form of "<Property Name/Property Value>."
 * @param name The camera property name (e.g. "APERTURE", "SHUTTER", "ISO", "WB"). 
 * @param value Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>", "<WB/WB_AUTO>")
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *   - #OLYCameraRunModeMaintenance
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 * @see OLYCamera::canSetCameraProperty:
 *
 * 
 */
- (BOOL)setCameraPropertyValue:(NSString *)name value:(NSString *)value error:(NSError **)error;	

/**
 * 
 * Set values to camera properties.
 *
 * Specifying a value that does not exist in the list of camera properties currently available,
 * will give an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param values The pairs of the camera property value and name.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * Name-value pairs of the camera properties that can be specified in dictionary format.
 * The application must specify the camera property name in the dictionary key
 * and store the value associated with that key in the camera properties.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error. 
 *   - #OLYCameraRunModeRecording
 *   - #OLYCameraRunModeMaintenance
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValues:error:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 * 
 */
- (BOOL)setCameraPropertyValues:(NSDictionary *)values error:(NSError **)error;	

/**
 * 
 * Change run mode of the camera.
 *
 * Available camera features change for different run modes.
 * For example, application should change the mode to #OLYCameraRunModePlayback when shooting photographs,
 * and should change the mode to #OLYCameraRunModeRecording when getting a list of the camera contents.
 * Please refer to the related documentation for more information on relationship between
 * run mode and available camera features.
 *
 * Response of this API may become slow when shooting or writing to memory card.
 *
 * @param mode Run mode of the camera.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::runMode
 *
 * 
 */
- (BOOL)changeRunMode:(OLYCameraRunMode)mode error:(NSError **)error;	

/**
 * 
 * Change date and time of camera.
 *
 * When capturing without specifying date and time in the camera,
 * a wrong value is set to metadata of media (still image and movie) and time stamp of media file.
 *
 * Date and time must be specified in Greenwich Mean Time (GMT), with time zone set in the mobile device.
 * OS standard API returns date and time in GMT format, 
 * and this method can use the returned value without changing the format. 
 * 
 * @param date Date and time.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeStandalone
 *   - #OLYCameraRunModePlayback
 *   - #OLYCameraRunModePlaymaintenance
 *
 * 
 */
- (BOOL)changeTime:(NSDate *)date error:(NSError **)error;	

/**
 * 
 * Register geolocation information to the camera.
 *
 * After the application registers the current geolocation in the camera,
 * the GPS geolocation information will be set in the meta-data of the picture during capture.
 *
 * The geolocation information must be specified by GGA and RMC defined in NMEA-0183.
 *
 * @param location The new geolocation information.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::clearGeolocation:
 *
 * 
 */
- (BOOL)setGeolocation:(NSString *)location error:(NSError **)error;	

/**
 * 
 * Discard registered geolocation information.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::setGeolocation:error:
 *
 * 
 */
- (BOOL)clearGeolocation:(NSError **)error;	

// ;-)

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to receive when the camera property changes.
 *
 * 
 */
@protocol OLYCameraPropertyDelegate <NSObject>	
@optional

/**
 * 
 * Notify that the list of camera property value or camera property value is updated.
 *
 * @param camera Instances indicating change of camera property.
 * @param name Name of the camera property that has changed.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera didChangeCameraProperty:(NSString *)name;	

@end

// EOF
