/**
 * @mainpage
 *
 * 
 *
 * @par Summary
 *
 * OLYCameraKit is a software development kit for Olympus wireless cameras.
 *
 * Using the OLYCameraKit, you can easily create applications that control the camera wirelessly.
 *
 * @par Outline
 *
 * - The following classes are available to fetch information and control a connected camera.
 *   - @ref OLYCamera
 * - The following protocols are available to receive or notify change in status of camera or wireless network.
 *   - @ref OLYCameraConnectionDelegate ... Receive state of the communication channel when it changes.
 *   - @ref OLYCameraLiveViewDelegate ... Notify state of live view image when it changes.
 *   - @ref OLYCameraPropertyDelegate ... Receive state of property values or a list of property values when it changes.
 *   - @ref OLYCameraRecordingDelegate ... Notify camera state when it changes. The camera state is regarding capturing operation which affects still image or movie.
 *   - @ref OLYCameraRecordingSupportsDelegate ... Notify camera state when it changes. The camera state is regarding capturing operation which do not affect still image or movie.
 * - The class to output error code and log is available for debugging your application.
 * - The following classes are available to cooperate with Olympus applications.
 *   - @ref OACentralConfiguration ... The setting of BLE connection is provided in cooperation with OA.Central.
 *
 * @par How to use
 *
 * Establish Wi-Fi connection between camera and mobile device in setting screen of the mobile device.
 * Connect to the camera with the SDK after checking settings for communication with the camera.
 * There is no need to change the communication settings usually.
 *
 * The camera has several run modes. Available functions are different in each mode.
 * The camera is set to standalone mode after the connection is established between camera and mobile device.
 * 
 * For recording movie or photograph:
 * Connect to the camera, change to recording mode, set drive and shooting modes,
 * call start capturing and then end capturing.
 *
 * When finished using the camera, the application needs to explicitly disconnect from the camera.
 * If the application supports multitasking, please follow this procedure:
 * Application disconnects from the camera when entering background mode
 * and connects to the camera again when entering foreground mode.
 * This allows other applications to use the camera when the application does not use the camera.
 *
 * 
 */
/**
 * 
 * @file	OLYCamera.h
 * @brief	OLYCamera class interface file.
 *
 * 
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

#import <UIKit/UIKit.h>								// UIKit.framework
#import <Foundation/Foundation.h>					// Foundation.framework
#import <ImageIO/ImageIO.h>							// ImageIO.framework
#import <CFNetwork/CFNetwork.h>						// CFNetwork.framework
#import <CoreBluetooth/CoreBluetooth.h>             // CoreBluetooth.framework
#import <SystemConfiguration/SystemConfiguration.h> // SystemConfiguration.framework

#import "OLYCameraError.h"
#import "OLYCameraLog.h"

/**
 * 
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 * 
 * @{
 */
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
 * 
 * Version of Olympus camera kit.
 *
 * Check this value if the SDK behavior seems incorrect.
 * Problem may have been resolved in the latest version of the SDK.
 *
 * 
 */
extern NSString *const OLYCameraKitVersion;

/**
 * 
 * Build number of Olympus Camera Kit.
 *
 * 
 */
extern NSString *const OLYCameraKitBuildNumber;

/** @} */
/** @} */

/**
 * 
 *
 * Olympus camera class.
 *
 * This class provides the operation and display of live view, including content acquisition in the camera
 * and capturing of still images and recording movies by connecting to the camera.
 * This class has several categories.
 *
 * Please refer to each category for details of the interface.
 * - @ref OLYCamera(CameraConnection)
 *    - This is camera communication category of Olympus camera class.
 *      This category provides the connection and disconnection to the camera.
 * - @ref OLYCamera(CameraSystem)
 *    - This is camera system category of Olympus camera class.
 *      This category enables one to get or set the camera settings (Camera property) and change run mode.
 *    - For example, The application can get or set the following camera properties:
 *      - Basic settings (aperture value, shutter speed, and exposure mode, etc.)
 *      - Color tone and finish setting (white balance, art filter, etc.)
 *      - Focus settings (focus mode, such as focus lock)
 *      - Image quality and saving settings (image size, compression ratio, image quality mode, etc.)
 *      - Camera status (battery level, angle of view, etc.)
 *      - Recording auxiliary (face detection and sound volume level, etc.)
 *    - Please refer to the list of camera properties for more information.
 * - @ref OLYCamera(Maintenance)
 *    - This is maintenance category of Olympus camera class.
 *    - This category provides no function and is reserved for future expansion.
 * - @ref OLYCamera(Playback)
 *    - This is playback category of Olympus camera class.
 *    - This category can download and edit video and still images saved in the camera.
 * - @ref OLYCamera(PlaybackMaintenance)
 *    - This is playback auxiliary category of Olympus camera class.
 * 	  - This category provides no function and is reserved for future expansion.
 * - @ref OLYCamera(Recording)
 *    - This is recording category of Olympus camera class.
 *      This category takes still pictures and records video, exposure control, and focus control.
 * - @ref OLYCamera(RecordingSupports)
 *    - This is recording auxiliary category of Olympus camera class.
 *      This category provides zoom control and live view image display.
 *
 * Several functions are provided for the vendor. These are not available in third party applications.
 *
 * 
 */
@interface OLYCamera : NSObject

// See categories.

@end

#import "OLYCamera+CameraConnection.h"
#import "OLYCamera+CameraSystem.h"
#import "OLYCamera+Playback.h"
#import "OLYCamera+PlaybackMaintenance.h"
#import "OLYCamera+Recording.h"
#import "OLYCamera+RecordingSupports.h"
#import "OLYCamera+Maintenance.h"
#import "OLYCamera+Functions.h"

// EOF
