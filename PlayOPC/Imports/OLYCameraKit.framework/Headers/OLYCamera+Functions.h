/**
 * 
 * @file	OLYCamera+Functions.h
 * @brief	OLYCamera function interface file.
 *
 * 
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 * 
 * @defgroup functions Functions
 *
 * Support functions for Olympus camera class
 *
 * 
 * @{
 */

#pragma mark Image Processing Utilities

/**
 * 
 * @name Image processing utilities
 *
 * 
 * @{
 */

/**
 * 
 * Convert image data to UIImage object.
 *
 * @param data Image data
 * @param metadata Metadata of image data.
 * @return UIImage object generated from image data.
 *
 * 
 */
UIImage *OLYCameraConvertDataToImage(NSData *data, NSDictionary *metadata);	

/** @} */

#pragma mark Coordinate Conversion Utilities

/**
 * 
 * @name Coordinate conversion utilities
 *
 * These utilities convert between
 * coordinates in viewfinder coordinate system and
 * coordinates in live view coordinate system.
 *
 * Live view coordinate system is in units of pixels for live view image.
 * The origin is the upper-left corner.
 * Vertical and horizontal coordinate axes match the image display of the smartphone.
 * If camera is rotated into portrait orientation, the origin is still in the upper-left,
 * but the width and height of the image are changed since image is rotated.
 * Live view coordinates are used to represent a pixel position on the image when user touches the live view.
 *
 * Viewfinder coordinate system is normalized to width = 1.0 and height = 1.0 for live view image.
 * The origin is the upper-left corner.
 * Vertical and horizontal coordinate axes correspond to image sensor in camera.
 * If camera is rotated into portrait or landscape mode, 
 * there is no change to the image width and height or the picture rotation.
 * Viewfinder coordinate system is used to represent the in-focus position and the position of the specified auto focus lock.
 *
 * 
 * @{
 */

/**
 * 
 * Convert coordinates in live view coordinate system
 * into coordinates in viewfinder coordinate system.
 *
 * @param point Coordinates in live view coordinate system.
 * @param liveImage Live view image.
 * @return Coordinates in viewfinder coordinate system.
 *
 * 
 */
CGPoint OLYCameraConvertPointOnLiveImageIntoViewfinder(CGPoint point, UIImage *liveImage);	

/**
 * 
 * Convert coordinates in viewfinder coordinate system
 * into coordinates in live view coordinate system.
 *
 * @param point Coordinates in viewfinder coordinate system.
 * @param liveImage Live view image.
 * @return Coordinates in live view coordinate system.
 *
 * 
 */
CGPoint OLYCameraConvertPointOnViewfinderIntoLiveImage(CGPoint point, UIImage *liveImage);	

/**
 * 
 * Convert rectangular coordinates in live view coordinate system
 * into the rectangular coordinates in viewfinder coordinate system.
 * This method is used to convert coordinates of auto focus frame for example. 
 *
 * @param rect Rectangular coordinates in live view coordinate system.
 * @param liveImage Live view image.
 * @return Rectangular coordinates in viewfinder coordinate system.
 *
 * 
 */
CGRect OLYCameraConvertRectOnLiveImageIntoViewfinder(CGRect rect, UIImage *liveImage);	

/**
 * 
 * Convert rectangular coordinates in viewfinder coordinate system
 * into rectangular coordinates in live view coordinate system.
 * This method is used to convert coordinates of auto focus frame for example. 
 *
 * @param rect Rectangular coordinates in viewfinder coordinate system.
 * @param liveImage Live view image.
 * @return Rectangular coordinates in live view coordinate system.
 *
 * 
 */
CGRect OLYCameraConvertRectOnViewfinderIntoLiveImage(CGRect rect, UIImage *liveImage);	

/** @} */

/** @} */

// EOF
