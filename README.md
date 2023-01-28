# PLAY OPC

This application can operate Open Platform Camera (OLYMPUS AIR A01) of Olympus.
You can try most functions of SDK 1.1 provided by Olympus with using this application.

OLYMPUS AIR A01 is necessary to use this application.
(It is OLYMPUS AIR A01 if this description says a camera.)

## Features

* Switching on the camera via Bluetooth
* Displaying real-time preview image by the camera
* Taking a picture with using the camera
* Recording a video with using the camera
* Displaying various states of the camera
* Exchanging a camera setting with the pasteboard
* Preserving a favorite camera setting to the device
* Sharing favorite camera settings
* Changing a shooting mode
* Coordinating some exposure parameters
* Shooting supports auto bracketing mode
* Shooting supports interval timer mode
* Changing the color taste of the image
* Adding special effects to an image
* Locking auto focus and auto exposure
* Changing an angle of view using optical zoom and digital zoom (The optical zooming requires a motor zoom lens)
* Magnifying real-time preview image by the camera
* Changing a quality of picture to store at the camera
* Changing sound volume
* Registering the current geolocation as the photography place
* Viewing and sharing a picture or a video which stored in the camera
* Browsing a photo's information
* Converting a photo's information to parameters of camera setting
* Protecting or unprotecting pictures and videos which stored in the camera
* Deleting pictures and videos which stored in the camera
* Setting the current time at the camera automatically
* Changing Wi-Fi channel of the camera
* Switching off the camera

## Known Issue

* If the device cannot connect the camera via Wi-Fi automatically, it is necessary to connect the camera by manual operation.
* The operation of the camera is not stable and may not work at the place where Wi-Fi is crowded.
* The app cannot initialize media cards in the camera. ~~Please use [OA.Central](app.olympus-imaging.com/oacentral/) provided by OLYMPUS.~~

## Runs Immediately

You may find the binary version of application in [iTunes App Store](https://itunes.apple.com/app/play-opc/id999316498). Please download it if you want to see immediately this application works. 

## Requirements

Building this application requires:

* iOS 15.0 and later
* macOS 13.1 and later
* Xcode 14.2 and later

When the project that you downloaded does not seem to be able to build, please read the trouble-shooting section of [Wiki](https://github.com/ura14h/PlayOPC/wiki).

## Authors

* Hiroki Ishiura (except file in /PlayOPC/Imports directory)

## License

Original souce code of PLAY OPC is released under the terms of MIT license. You may find the content of the license [http://opensource.org/licenses/mit-license.php]().

OLYCameraKit.framework is released under the terms of OLYMPUS license. This license is not equal to MIT license.

## Other Information

* If you are interested in handling the OLYMPUS AIR A01, please check the published instruction manual. (http://sapp.olympus-imaging.com/manual/man_a01_us_enu.pdf]())  
* If you have an interest in camera functions and camera parameters, please read SDK document. You may download it from: [https://dl-support.olympus-imaging.com/opc/en/]()
