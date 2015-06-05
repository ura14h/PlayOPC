/**
 * 
 * @file	OLYCameraVideoPlayer.h
 * @brief	OLYCameraVideoPlayer class interface file.
 *
 * 
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

#import <AudioToolbox/AudioToolbox.h>		// AudioToolbox.framework
#import <AVFoundation/AVFoundation.h>		// AVFoundation.framework
#import <UIKit/UIKit.h>						// UIKit.framework

/**
 * 
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 * 
 * @{
 */
// ;-)

// This is reserved for vendors. Please do not use.
enum OLYCameraVideoPlayerError {	
	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerErrorAbortStreaming = 0x0bad1401,	

	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerErrorNoStreamingData = 0x0bad1402,	

	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerErrorDeviceUnavailable = 0x0bad1403,	
	
	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerErrorSynchronizingUnavailable = 0x0bad1404,	
};
typedef enum OLYCameraVideoPlayerError OLYCameraVideoPlayerError;

// This is reserved for vendors. Please do not use.
enum OLYCameraVideoPlayerQuality {	
	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerQualitySpeedUnknown,	

	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerQualitySpeedPriority,	
	
	// This is reserved for vendors. Please do not use.
	OLYCameraVideoPlayerQualityImagePriority,	
};
typedef enum OLYCameraVideoPlayerQuality OLYCameraVideoPlayerQuality;

// ;-)
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
// ;-)

// ;-)

// ;-)
/** @} */

@class OLYCamera;
@protocol OLYCameraVideoPlayerDelegate;

#pragma mark -

// This is reserved for vendors. Please do not use.
@interface OLYCameraVideoPlayer : NSObject	

// This is reserved for vendors. Please do not use.
@property (weak, nonatomic) id<OLYCameraVideoPlayerDelegate> delegate;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic) BOOL showScreennail;	


// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) OLYCameraVideoPlayerQuality quality;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) BOOL opened;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) BOOL playing;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) float currentRate;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSTimeInterval playingDuration;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSTimeInterval minimumBufferingDuration;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSTimeInterval maximumBufferingDuration;	

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

@end

#pragma mark -

// This is reserved for vendors. Please do not use.
@protocol OLYCameraVideoPlayerDelegate <NSObject>	
@optional

// This is reserved for vendors. Please do not use.
- (void)playerDidStartPlayingVideo:(OLYCameraVideoPlayer *)player;	

// This is reserved for vendors. Please do not use.
- (void)playerDidPausePlayingVideo:(OLYCameraVideoPlayer *)player;	

// This is reserved for vendors. Please do not use.
- (void)playerDidResumePlayingVideo:(OLYCameraVideoPlayer *)player;	

// This is reserved for vendors. Please do not use.
- (void)playerDidStopPlayingVideo:(OLYCameraVideoPlayer *)player error:(NSError *)error;	

// This is reserved for vendors. Please do not use.
- (void)playerDidFinishPlayingVideo:(OLYCameraVideoPlayer *)player;	

@end

// EOF
