/**
 * 
 * @file	OLYCamera+PlaybackMaintenance.h
 * @brief	OLYCamera(PlaybackMaintenance) class interface file.
 *
 * 
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 * 
 * Playback auxiliary category of Olympus camera class.
 *
 * This category can erase video and still image and movie saved in the camera.
 *
 * 
 * @category OLYCamera(PlaybackMaintenance)
 */
@interface OLYCamera(PlaybackMaintenance)

// ;-)

// ;-)

/**
 * 
 * Protect media (still image and movie) stored in memory card.
 *
 * When the application tries to delete the protected media, an error occurs.
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::unprotectContent:error:
 * @see OLYCamera::unprotectAllContents:completionHandler:errorHandler:
 *
 * 
 */
- (BOOL)protectContent:(NSString *)path error:(NSError **)error;	

/**
 * 
 * Cancel protection of the media (still image and movie) stored in memory card.
 *
 * When the protection is canceled, the application is allowed to delete the media.
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::protectContent:error:
 *
 * 
 */
- (BOOL)unprotectContent:(NSString *)path error:(NSError **)error;	

/**
 * 
 * Cancel protection of all the media (still image and movie) stored in memory card.
 *
 * @param progressHandler Callback used when cancellation progress changes.
 * @param completionHandler Callback used when cancellation is complete.
 * @param errorHandler Callback used when cancellation is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::protectContent:error:
 *
 * 
 */
- (void)unprotectAllContents:(void (^)(float progress))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Delete media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 * When the application tries to delete the protected media, an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * 
 */
- (BOOL)eraseContent:(NSString *)path error:(NSError **)error;	

// ;-)

// ;-)

@end

// EOF
