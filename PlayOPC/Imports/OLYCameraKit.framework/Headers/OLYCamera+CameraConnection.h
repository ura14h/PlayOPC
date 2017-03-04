/**
 * 
 * @file	OLYCamera+CameraConnection.h
 * @brief	OLYCamera(CameraConnection) class interface file.
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

/**
 * 
 * IP address of the camera.
 *
 * Value is used when you connect to the camera via Wi-Fi.
 * Set value only if specific IP address is needed. Default is 192.168.0.10.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (strong, nonatomic) NSString *host;	

/**
 * 
 * Port number where the camera receives commands.
 *
 * Value is used when you connect to the camera via Wi-Fi.
 * Set value only if specific port number is needed. Default is TCP/80.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (assign, nonatomic) NSInteger commandPort;	

/**
 * 
 * Port number where Camera Kit receives live view images.
 *
 * Value is used when you connect to the camera via Wi-Fi.
 * Set value only if specific port number is needed. Default is UDP/5555.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (assign, nonatomic) NSInteger liveViewStreamingPort;	

/**
 * 
 * Port number where Camera Kit receives events issued by the camera.
 *
 * Value is used when you connect to the camera via Wi-Fi.
 * Set value only if specific port number is needed. Default is TCP/65000.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
@property (assign, nonatomic) NSInteger eventPort;	

/**
 * 
 * Bluetooth peripheral.
 *
 * The value is used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 * @attention
 * This API is only for Bluetooth Smart.
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
 * @attention
 * This API is only for Bluetooth Smart.
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
 * @attention
 * This API is only for Bluetooth Smart.
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
 * @attention
 * This API is only for Bluetooth Smart.
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
 * @attention
 * This API is only for Bluetooth Smart.
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
 * @attention
 * This API is only for Bluetooth Smart.
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
 * Indicate if the application can connect to the camera.
 * If the application is connected to the camera, the application will get an error.
 *
 * @param connectionType Type of connection. You specify 'Wi-Fi'.
 * @param timeout Number of seconds for timeout. If 0 is specified, default value is set.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, the application can connect to the camera.
 *
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (BOOL)canConnect:(OLYCameraConnectionType)connectionType timeout:(NSTimeInterval)timeout error:(NSError **)error;	

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
 * @attention
 * This API is only for Wi-Fi.
 *
 * 
 */
- (void)camera:(OLYCamera *)camera disconnectedByError:(NSError *)error;	

@end

// EOF
