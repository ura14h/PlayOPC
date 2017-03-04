//
//  PHPhotoLibrary+CustomAlbum.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2017/03/04.
//  Copyright (c) 2017 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Photos/Photos.h>

typedef void (^PHPhotoLibraryWriteImageCompletionBlock)(BOOL success, NSError *error);

@interface PHPhotoLibrary (CustomAlbum)

/// 写真アルバムのカスタムグループに画像データを書き込みます。
- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata groupName:(NSString *)groupName completionBlock:(PHPhotoLibraryWriteImageCompletionBlock)completionBlock;

@end
