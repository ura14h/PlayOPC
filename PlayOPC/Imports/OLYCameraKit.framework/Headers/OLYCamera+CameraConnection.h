/**
 * @~english
 * @file	OLYCamera+CameraConnection.h
 * @brief	OLYCamera(CameraConnection) class interface file.
 *
 * @~japanese
 * @file	OLYCamera+CameraConnection.h
 * @brief	OLYCamera(CameraConnection) クラスインターフェースファイル
 *
 * @~
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
 * @name Olympus camera class: camera communication category
 *
 * 
 * @{
 */

/**
 * Connection classification for camera.
 * 
 */
enum OLYCameraConnectionType {	
    /**
     * Not connected.
     * 
     */
    OLYCameraConnectionTypeNotConnected,	
	
    /**
     * Wi-Fi.
     * 
     */
    OLYCameraConnectionTypeWiFi,	
	
    /**
     * Bluetooth Smart.
     * 
     */
    OLYCameraConnectionTypeBluetoothLE,	
	
};
typedef enum OLYCameraConnectionType OLYCameraConnectionType;

/** @} */
/** @} */

@protocol OLYCameraConnectionDelegate;

#pragma mark -

/**
 * 
 * This is a camera communication category of Olympus camera class.
 *
 * This category connects and disconnects the camera.
 *
 * 
 * @category OLYCamera(CameraConnection)
 */
@interface OLYCamera(CameraConnection)

// This is reserved for vendors. Please do not use.
@property (strong, nonatomic) NSString *host;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSInteger commandPort;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic) NSInteger liveViewStreamingPort;	

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic) NSInteger eventPort;	

/**
 * 
 * Bluetooth peripheral.
 *
 * The value is used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 * 
 */
@property (strong, nonatomic, readwrite) CBPeripheral *bluetoothPeripheral;	

/**
 * 
 * Password to connect via Bluetooth Smart to the camera.
 *
 * The value may be used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 * 
 */

@property (strong, nonatomic, readwrite) NSString *bluetoothPassword;	// __OLY_API_USER_V1__

/**
 * 
 * If true, the camera starts recording setup after power on via Bluetooth Smart
 *
 * The value may be used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 * 
 */
@property (assign, nonatomic, readwrite) BOOL bluetoothPrepareForRecordingWhenPowerOn;	

/**
 * 
 * Type of connection to the camera.
 *
 * 
 */
@property (assign, nonatomic, readonly) OLYCameraConnectionType connectionType;	

/**
 * 
 * The object that acts as the delegate to receive change to communication state of the camera.
 *
 * 
 */
@property (weak, nonatomic) id<OLYCameraConnectionDelegate> connectionDelegate;	

/**
 * 
 * Indicate whether the camera is currently connected.
 *
 * 
 */
@property (assign, nonatomic, readonly) BOOL connected;	

/**
 * 
 * List of Bluetooth service ID.
 *
 * @return List of Bluetooth service ID.
 *
 * 
 */
+ (NSArray *)bluetoothServices;	

/**
 * 
 * Indicate if camera requires a password for Bluetooth Smart connection.
 *
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, password is required.
 *
 * 
 */
- (BOOL)connectingRequiresBluetoothPassword:(NSError **)error;	

/**
 * 
 * Wake up the camera via Bluetooth Smart.
 *
 * After the camera turns on, the application can connect to the camera.
 * If the application is connected to the camera, the application will get an error.
 *
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 * @see OLYCamera::bluetoothPeripheral
 * @see OLYCamera::bluetoothPassword
 * @see OLYCamera::connectingRequiresBluetoothPassword:
 * @see OLYCamera::bluetoothPrepareForRecordingWhenPowerOn
 *
 * 
 */
- (BOOL)wakeup:(NSError **)error;	

/**
 * 
 * Connect to the camera.
 *
 * Connection to the camera is complete, the application will be able to use features of the SDK.
 *
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 * 
 */
- (BOOL)connect:(NSError **)error;	

/**
 * 
 * Connect to the camera.
 *
 * Connection to the camera is complete, the application will be able to use features of the SDK.
 * If the application wants to change the connection type when it is already connected
 * to the camera, the application must disconnect and connect again.
 *
 * @param connectionType Type of connection. You cannot specify 'not connected'.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 * 
 */
- (BOOL)connect:(OLYCameraConnectionType)connectionType error:(NSError **)error;	

/**
 * 
 * Disconnect from the camera.
 *
 * You can also power off the camera when you disconnect from the camera.
 * If disconnect is successful, the value of the property and state of the camera will be cleared.
 * (Communication settings of the camera connection are not cleared.)
 *
 * @param powerOff If true, the camera will be powered off with disconnection from the camera.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 * 
 */
- (BOOL)disconnectWithPowerOff:(BOOL)powerOff error:(NSError **)error;	

@end

#pragma mark -
#pragma mark Related Delegates

/**
 * 
 * The delegate to receive change to communication state of the camera.
 *
 * 
 */
@protocol OLYCameraConnectionDelegate <NSObject>	
@optional

/**
 * 
 * Notify that connection to the camera was lost by error.
 *
 * @param camera Instance that has lost a communication path with the camera.
 * @param error Error contents.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera disconnectedByError:(NSError *)error;	

@end

// EOF
