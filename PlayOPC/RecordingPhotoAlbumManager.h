//
//  RecordingPhotoAlbumManager.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2023/02/04.
//  Copyright (c) 2023 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/// 写真アルバムを管理します。
@interface RecordingPhotoAlbumManager : NSObject

/// 写真アルバムの使用許可を要求します。
- (PHAuthorizationStatus)reqeustAuthorization;

/// 写真アルバムのカスタムグループに画像データを書き込みます。
- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata groupName:(NSString *)groupName completionBlock:(void (^)(BOOL success, NSError *error))completionBlock;

@end
