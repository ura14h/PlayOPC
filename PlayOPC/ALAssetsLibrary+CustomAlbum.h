//
//  ALAssetsLibrary+CustomAlbum.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/06.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (CustomAlbum)

/// 写真アルバムのカスタムグループに画像データを書き込みます。
- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata groupName:(NSString *)groupName completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock;

@end
