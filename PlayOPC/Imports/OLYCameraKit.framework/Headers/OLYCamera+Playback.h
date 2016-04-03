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
     * File size is bigger than that of normal quality video.
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
 * Resize long side of the image to 2048 pixels.
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
 * Download list of files in /DCIM directory of memory card that is inserted in the camera.
 * List contains all still image and movie files in supported format.  
 * Application should distinguish unsupported files using file extension and eliminate them from the list before use.

 * @param handler Callback used when download is complete.
 *
 * Argument of download completion callback.
 *   - list ... List of all supported media stored in memory card in array format.
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * Each element of the list is in dictionary format.
 * Dictionary key is defined to access the element.
 *   - #OLYCameraContentListDirectoryKey ... Directory path.
 *   - #OLYCameraContentListFilenameKey ... File name.
 *   - #OLYCameraContentListFilesizeKey ... File size.
 *   - #OLYCameraContentListFiletypeKey ... File type.
 *     The following are the file types.
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
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadContentList:(void (^)(NSMutableArray *list, NSError *error))handler;	

/**
 * 
 * Download thumbnail of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
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
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadContentThumbnail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data, NSMutableDictionary *metadata))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download reduced image of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the reduced image.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadContentScreennail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download a resized still image.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image.
 * @param resize Size in number of pixels after resizing.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the image.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadImage:(NSString *)path withResize:(OLYCameraImageResize)resize progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Download media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the media.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadContent:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

/**
 * 
 * Split large media (still image or movie) into smaller parts and download each part.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the part is downloaded.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - data ... Received binary data of the part.
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)downloadLargeContent:(NSString *)path progressHandler:(void (^)(NSData *data, float progress, BOOL *stop))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;	

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
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (NSInteger)countNumberOfContents:(NSError **)error;	

/**
 * 
 * Get information of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name 
 * obtained from list of all supported media. Otherwise an error occurs.
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
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (NSDictionary *)inquireContentInformation:(NSString *)path error:(NSError **)error;	

// ;-)

// ;-)

// ;-)

/**
 * 
 * Resize each frame of the video, and save it as a new file in the camera's memory card.
 *
 * String that the application specifies in the file path of the content.  String must
 * combine the directory path and file name obtained from the downloaded contents list.
 * If the application specifies a non-video file, the application will get an error.
 *
 * @param path File path to the video content.
 * @param resize Frame size in number of pixels after resizing. (only 1280 is valid in current version)
 * @param quality Quality of video after resizing.
 * @param progressHandler Callback used when the resizing progress changes.
 * @param completionHandler Callback used when resizing is complete.
 * @param errorHandler Callback used when resizing is abnormally terminated.
 *
 * Argument of progress callback
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If set to true, abnormal termination callback is invoked and resizing is canceled.
 *
 * Argument of abnormal termination callback
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 * @attention
 * This API is only for Wi-Fi.
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
