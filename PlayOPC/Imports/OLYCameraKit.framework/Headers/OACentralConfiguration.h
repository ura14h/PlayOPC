/**
 * 
 * @file	OACentralConfiguration.h
 * @brief	OACentralConfiguration class interface file.
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
 * This class provides setting of BLE connection.
 * The setting is provided in cooperation with OA.Central.
 *
 * 
 */
@interface OACentralConfiguration : NSObject	

/**
 * 
 * Indicate the name of the BLE device that is pairing to a camera.
 *
 * If nil, OA.Central is not installed or OA.Central hasn't finished initial setup.
 *
 * 
 */
@property (strong, nonatomic) NSString *bleName;	

/**
 * 
 * Indicate the pass-code of the BLE device that is pairing to a camera.
 *
 * If nil, OA.Central is not installed or OA.Central hasn't finished initial setup.
 *
 * 
 */
@property (strong, nonatomic) NSString *bleCode;	

/**
 * 
 * Requires OA.Central to give your application a setting information of the BLE connection.
 *
 * @param appUrlScheme URL scheme of your application.
 * @return If true, The operation was successful. If false, The operation was abnormal termination.
 *
 * 
 */
+ (BOOL)requestConfigurationURL:(NSString *)appUrlScheme;	

/**
 * 
 * Initialize this instance using setting information of the BLE connection given from OA.Central.
 *
 * @param configurationURL URL including the setting information of the BLE connection given from OA.Central.
 * @return The initialized instance.
 *
 *
 * 
 */
- (id)initWithConfigurationURL:(NSURL *)configurationURL;	

@end

// EOF
