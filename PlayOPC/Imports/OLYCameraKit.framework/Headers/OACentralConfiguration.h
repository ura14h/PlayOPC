/**
 * @~english
 * @file	OACentralConfiguration.h
 * @brief	OACentralConfiguration class interface file.
 *
 * @~japanese
 * @file	OACentralConfiguration.h
 * @brief	OACentralConfiguration クラスインターフェースファイル
 *
 * @~
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

#import <UIKit/UIKit.h>								// UIKit.framework
#import <Foundation/Foundation.h>					// Foundation.framework

/**
 * 
 * This class receives setting information 
 * from Olympus official app, OA.Central, to support Bluetooth Smart Connection.

 * 
 */
@interface OACentralConfiguration : NSObject	

/**
 * 
 * Indicate the name of the Bluetooth Smart device paired to the camera.
 *
 * If nil, OA.Central is not installed or OA.Central did not finish initial setup.
 *
 * 
 */
@property (strong, nonatomic) NSString *bleName;	

/**
 * 
 * Indicate the passcode of the Bluetooth Smart device paired to the camera.
 *
 * If nil, OA.Central is not installed or OA.Central did not finish initial setup.
 *
 * 
 */
@property (strong, nonatomic) NSString *bleCode;	

/**
 * 
 * Request setting information of the Bluetooth Smart connection to OA.Central.
 *
 * @param appUrlScheme URL scheme of your application.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * 
 */
+ (BOOL)requestConfigurationURL:(NSString *)appUrlScheme;	

/**
 * 
 * Initialize instance using setting information of Bluetooth Smart connection received from OA.Central.
 *
 * @param configurationURL URL including the setting information.
 * @return The initialized instance.
 *
 *
 * 
 */
- (id)initWithConfigurationURL:(NSURL *)configurationURL;	

@end

// EOF
