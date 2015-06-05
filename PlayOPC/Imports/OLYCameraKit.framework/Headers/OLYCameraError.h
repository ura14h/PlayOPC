/**
 * 
 * @file	OLYCameraError.h
 * @brief	OLYCameraError definition file.
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
 * @name Error related
 *
 * 
 * @{
 */

/**
 * NSError codes in the OLYCameraErrorDomain.
 * 
 */
enum OLYCameraError {
	/**
     * Unknown error occurred.
     * 
     */
	OLYCameraErrorUnknown = 0x0bad0001,
	
	/**
     * 
	 * Invalid parameters.
	 *
	 * There is an error in the value specified in the property or method argument.
	 * Please check the value you specified and the specifications of the camera.
	 *
     * 
     */
	OLYCameraErrorInvalidParameters = 0x0bad0002,
	
	/**
     * 
	 * Invalid operation.
	 *
	 * Application may have tried to call an operation not allowed in current mode.
	 * Please change the application so those operations are not called.
	 *
     * 
     */
	OLYCameraErrorInvalidOperations = 0x0bad0003,
	
	/**
     * Operation is not supported.
     * 
     */
	OLYCameraErrorUnsupportedOperations = 0x0bad0004,
	
	/**
     * 
	 * Connecting to camera failed.
	 *
	 * The camera and mobile device may not be connected with Bluetooth or Wi-Fi.
	 * Please check whether the mobile device is connected to the camera before trying to control the camera.
	 *
     * 
     */
	OLYCameraErrorConnectionFailed = 0x0bad0005,
	
	/**
     * 
	 * Not connected to the camera.
	 *
	 * To operate the camera, the program must first be connected to the camera using the SDK.
	 * Please make sure the program is calling the connection method for the first time.
	 *
     * 
     */
	OLYCameraErrorNotConnected = 0x0bad0006,
	
	/**
     * 
	 * Sending a command to the camera failed.
	 *
	 * There is a possibility that the camera firmware specification and SDK specification
	 * do not match, or the network is unstable.
	 *
     * 
     */
	OLYCameraErrorCommandFailed = 0x0bad0007,
	
	/**
     * 
	 * The data returned from the camera is broken or in an unexpected format.
	 *
	 * There is a possibility that the camera firmware specification and SDK specification
	 * do not match, or the network is unstable.
	 *
     * 
     */
	OLYCameraErrorBadResponse = 0x0bad0008,
	
	/**
     * 
	 * The command was rejected because the camera is busy processing other tasks.
	 *
	 * The command may be successful if sent again later.
	 *
     * 
	 *
	 */
	OLYCameraErrorCameraBusy = 0x0bad0009,
	
	/**
     * 
	 * Operation is aborted.
	 *
	 * Operation may have been aborted during processing, such as by user.
	 *
     * 
     */
	OLYCameraErrorOperationAborted = 0x0bad000a,
	
	/**
     * 
	 * Focusing by the camera failed.
	 *
	 * User may have tried to focus on an object that cannot be recognized by the camera's autofocus.
	 * The operation may be successful if run again after changing position of the subject or framing in the viewfinder.
	 *
     * 
     */
	OLYCameraErrorFocusFailed = 0x0bad000b,
	
};
typedef enum OLYCameraError OLYCameraError;

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
 * @name Errors related
 *
 * 
 * @{
 */

/**
 * OLYCameraKit errors.
 * 
 */
extern NSString *const OLYCameraErrorDomain;

/**
 * Dictionary key for accessing error detail elements in user's information of NSError instance.
 * 
 */
extern NSString *const OLYCameraErrorDetailKey;

/** @} */
/** @} */

// EOF
