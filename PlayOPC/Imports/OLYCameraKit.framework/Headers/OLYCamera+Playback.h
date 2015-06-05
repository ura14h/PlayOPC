/**
 * 
 * @file	OLYCamera+Playback.h
 * @brief	OLYCamera(Playback) class interface file.
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
 * @name Olympus camera class: playback category
 *
 * 
 * @{
 */

/**
 * 
 * Supported video quality when resized.
 *
 * 
 */
enum OLYCameraResizeVideoQuality {	
    /**
     * 
	 * High quality video.
	 *
     * 
     */
    OLYCameraResizeVideoQualityFine,	
	
    /**
     * 
	 * Normal quality video.
	 *
     * 
     */
    OLYCameraResizeVideoQualityNormal,	
};
typedef enum OLYCameraResizeVideoQuality OLYCameraResizeVideoQuality;

/**
 * 
 * Supported sizes for images.
 *
 * 
 */
typedef CGFloat OLYCameraImageResize;	

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
 * @name Olympus camera class: playback category
 *
 * 
 * @{
 */

/**
 * Resize long side of the image to 1024 pixels.
 * 
 */
extern const OLYCameraImageResize OLYCameraImageResize1024;	

/**
 * Resize long side of the image to 1600 pixels.
 * 
 */
extern const OLYCameraImageResize OLYCameraImageResize1600;	

/**
 * Resize long side of the image to 1920 pixels.
 * 
 */
extern const OLYCameraImageResize OLYCameraImageResize1920;	

/**
 * Resize long side of image to 2048 pixels.
 * 
 */
extern const OLYCameraImageResize OLYCameraImageResize2048;	

/**
 * Use the original size of the image.
 * 
 */
extern const OLYCameraImageResize OLYCameraImageResizeNone;	

/**
 * Dictionary key for accessing 'Directory path' elements of the content information.
 * 
 */
extern NSString *const OLYCameraContentListDirectoryKey;	

/**
 * Dictionary key for accessing 'File name' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListFilenameKey;	

/**
 * Dictionary key for accessing 'File size' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListFilesizeKey;	

/**
 * Dictionary key for accessing 'File type' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListFiletypeKey;	

/**
 * Dictionary key for accessing 'File attribute list' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListAttributesKey;	

/**
 * Dictionary key for accessing 'File modified date' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListDatetimeKey;	

/**
 * Dictionary key for accessing 'Extension' elements of content information.
 * 
 */
extern NSString *const OLYCameraContentListExtensionKey;	

/** @} */
/** @} */

@protocol OLYCameraPlaybackDelegate;

#pragma mark -

/**
 * 
 * Playback category of Olympus camera class.
 *
 * This category downloads and edits still image and movie saved in the camera.
 *
 * 
 * @category OLYCamera(Playback)
 */
@interface OLYCamera(Playback)

/**
 * 
 * Delegate object to receive changes to playback operations.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraPlaybackDelegate> playbackDelegate;	

/**
 * 
 * Download list of all supported media (still image and video) in the camera.
 *
 * Download list of files in memory card that is mounted in the camera in /DCIM directory.
 * List contains all still image and movie files in supported format.  
 * Application should distinguish unsupported files using file extension and eliminate them from the list before use.

 * @param handler Callback used when download is complete.
 *
 * Argument of download completion callback.
 *   - list ... List of all supported media stored in memory card in array format.
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * Each element of the list is dictionary format.
 * Dictionary key is defined to access the element.
 *   - #OLYCameraContentListDirectoryKey ... Directory path.
 *   - #OLYCameraContentListFilenameKey ... File name.
 *   - #OLYCameraContentListFilesizeKey ... File size.
 *   - #OLYCameraContentListFiletypeKey ... File type.
 *     The following are the file type.
 *     - "directory" ... Directory.
 *     - "file" ... File.
 *   - #OLYCameraContentListAttributesKey ... Array of file attributes. Array is normally set to empty.
 *     The following are the file attributes.
 *      - "protected" ... Protected file and cannot be deleted.
 *      - "hidden" ... Hidden file.
 *   - #OLYCameraContentListDatetimeKey ... Date object that represents date and time the file was changed.
 *   - #OLYCameraContentListExtensionKey ... Array of extended information.
 *
 * Please refer to the related documentation for more information on extended information.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (void)downloadContentList:(void (^)(NSMutableArray *list, NSError *error))handler;	

/**
 * 
 * Download thumbnail of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media and otherwise causes an error.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled and errorHandler is invoked.
 * 
 * Argument of completionHandler
 *   - image ... Binary data of thumbnail.
 *   - metadata ... Metadata of the thumbnail.
 *     There are cases where the following information is included in addition to the EXIF information.
 *     - "gpstag" ... 1 if the content has positioning information, 0 if it does not.
 *     - "moviesec" ...  Movie length in seconds if the movie file has length information.
 *     - "detectversion" ... Reserved for vendor.
 *     - "detectid" ... Reserved for vendor.
 *     - "groupid" ... Reserved for vendor.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 * 
 */
- (void)downloadContentThumbnail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data, NSMutableDictionary *metadata))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download reduced image of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media and otherwise causes an error.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is cancelled and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the thumbnail.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (void)downloadContentScreennail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download a resized still image.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media and otherwise causes an error.
 *
 * @param path File path to the still image.
 * @param resize Size in number of pixels after resizing.
 * @param progressHandler Callback used when the progress of the download changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when the download was aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the thumbnail.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (void)downloadImage:(NSString *)path withResize:(OLYCameraImageResize)resize progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media and otherwise causes an error.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the progress of the download changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when the download was aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the thumbnail.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (void)downloadContent:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Count the number of media (still image and movie) in the camera.
 *
 * @param error Error details are set when the operation is abnormally terminated.
 * @return Number of media.
 *
 * If the number of the acquired media is zero, an error may occur.
 * If the application wants to know the exact number of media, 
 * the application should check that error details are not set.
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (NSInteger)countNumberOfContents:(NSError **)error;	

/**
 * 
 * Get information of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media and otherwise causes an error.
 *
 * @param path File path to the still image or movie.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return Information of the media.
 *
 * Information on still image
 *   - Please refer to the related documentation for detailed information.
 *   - The application can also see EXIF information that is included in metadata of the media.
 * 
 * Information on movie (string format)
 *   - "playtime" ... Movie length in seconds.
 * 	 - "moviesize" ... Pixel size of the movie frame. The format is "[height]x[width]". For example "1920x1080"
 * 	 - "shootingdatetime" ... Date and time taken. Format is "[YYYYMMDD]T[hhmm]". For example "20141124T1234"
 *
 * @par Supported run modes
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (NSDictionary *)inquireContentInformation:(NSString *)path error:(NSError **)error;	

// ;-)

// ;-)

// ;-)

/**
 * 
 * Resizes each frame of the video content, and save it as a new content into the camera.
 *
 * The application can also add the image effect to the scene when editing and merging videos.
 * Video content that the application specifies must be a short movie format.
 * If the application specifies a non-video content, the application will get an error.
 *
 * @param path File path of the video content.
 * @param resize Pixel size of each frame after resizing process.
 * @param quality Quality of video after resizing process.
 * @param progressHandler Callback that will be called every time the progress of the resizing process changes.
 * @param completionHandler Callback that is called when the resize processing is complete.
 * @param errorHandler Callback that is called when the resize processing is abnormally terminated.
 *
 * Argument of progress callback
 *   - progress ... Progress rate is set. 0.0 immediately after the start, 1.0 is complete.
 *   - stop ... If set to true, abnormal termination callback is invoked resize processing is canceled.
 *
 * Argument of abnormal termination callback
 *   - error ... Error details will be set when the operation is abnormally terminated.
 *
 * @par Supported run modes
 * This method call is allowed only in run mode the following.
 * The application will get an error when called in run mode other than these.
 *   - #OLYCameraRunModePlayback
 *
 * 
 */
- (void)resizeVideoFrame:(NSString *)path size:(CGFloat)resize quality:(OLYCameraResizeVideoQuality)quality progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * Delegate to receive camera state regarding playback operation when it changes.
 * 
 * 
 */
@protocol OLYCameraPlaybackDelegate <NSObject>	
@optional

// something functions will come...

@end

// EOF
