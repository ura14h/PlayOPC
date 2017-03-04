/**
 * 
 * @file	OLYCameraLog.h
 * @brief	OLYCameraLog class interface file.
 *
 * 
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

#import <UIKit/UIKit.h>								// UIKit.framework
#import <Foundation/Foundation.h>					// Foundation.framework

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
 * @name Log management class
 *
 * 
 * @{
 */

/**
 * Log output level
 * 
 */
enum OLYCameraLogLevel {
	/**
	 * Error.
	 * 
	 */
	OLYCameraLogLevelError,
	/**
	 * Warning.
	 * 
	 */
	OLYCameraLogLevelWarning,
	/**
	 * Information.
	 * 
	 */
	OLYCameraLogLevelInfo,
	/**
	 * Debug.
	 * 
	 */
	OLYCameraLogLevelDebug,
};
typedef enum OLYCameraLogLevel OLYCameraLogLevel;

/** @} */
/** @} */

@protocol OLYCameraLogDelegate;

/**
 * 
 * Olympus camera SDK log management class.
 *
 * By default, the logger outputs to syslog or console log messages of higher priority than debug level.
 * However, the logger will output log messages of all levels if the SDK is the debug build.
 *
 * 
 */
@interface OLYCameraLog : NSObject

/**
 * Delegate object to receive log messages.
 * 
 */
@property (weak, nonatomic) id<OLYCameraLogDelegate> delegate;

/**
 * 
 * Return the shared instance.
 *
 * 
 */
+ (id)sharedLog;

/**
 * 
 * Set the new delegate.
 *
 * 
 */
+ (void)setDelegate:(id<OLYCameraLogDelegate>)delegate;

/**
 * 
 * Restore delegate to preset.
 *
 * 
 */
+ (void)resetDelegate;

@end

/**
 * 
 * Delegate to receive log messages from Olympus camera SDK.
 *
 * 
 */
@protocol OLYCameraLogDelegate <NSObject>
@optional

/**
 * 
 * Notify that SDK output a log message.
 *
 * @param log Logger that should output a log message.
 * @param message Log message.
 * @param level Log level.
 *
 * 
 */
- (void)log:(OLYCameraLog *)log shouldOutputMessage:(NSString *)message level:(OLYCameraLogLevel)level;

@end

// EOF
