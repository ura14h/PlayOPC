//
//  ALAssetsLibrary+CustomAlbum.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/06.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ALAssetsLibrary+CustomAlbum.h"

@implementation ALAssetsLibrary (CustomAlbum)

- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata groupName:(NSString *)groupName completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock {
	DEBUG_LOG(@"imageData.length=%ld, metadata=%@, group=%@", (long)imageData.length, metadata, groupName);
	
	// 写真グループに画像を保存します。
	// !!!: weakなselfを使うとenumerateGroupsWithTypes:usingBlock:failureBlock:より内側の処理に到達する前に解放されてしまいます。
	__block ALAssetsLibrary *weakSelf = self;
	[weakSelf writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error) {
			if (completionBlock) {
				completionBlock(assetURL, error);
			}
			weakSelf = nil;
			return;
		}
		DEBUG_LOG(@"The image is saved into photos alubm.");
		__block BOOL foundGroup = NO;
		[weakSelf enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
			if (group && [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:groupName]) {
				// 写真アルバムにカスタムグループが見つかった場合はそのグループに保存した画像を登録します。
				DEBUG_LOG(@"Update the exsisted album: groupName=%@", groupName);
				foundGroup = YES;
				[weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
					[group addAsset:asset];
					if (completionBlock) {
						completionBlock(assetURL, nil);
					}
					weakSelf = nil;
				} failureBlock:^(NSError *error) {
					if (completionBlock) {
						completionBlock(assetURL, error);
					}
					weakSelf = nil;
				}];
				return;
			}
			if (!group && !foundGroup) {
				// 写真アルバムにカスタムグループが見つからなかった場合はグループを新規作成して画像を登録します。
				DEBUG_LOG(@"Create the new album: groupName=%@", groupName);
				[weakSelf addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
					[weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
						[group addAsset:asset];
						if (completionBlock) {
							completionBlock(assetURL, nil);
						}
						weakSelf = nil;
					} failureBlock:^(NSError *error) {
						if (completionBlock) {
							completionBlock(assetURL, error);
						}
						weakSelf = nil;
					}];
				} failureBlock:^(NSError *error) {
					if (completionBlock) {
						completionBlock(assetURL, error);
					}
					weakSelf = nil;
				}];
				return;
			}
		} failureBlock:^(NSError *error) {
			if (completionBlock) {
				completionBlock(assetURL, error);
			}
			weakSelf = nil;
		}];
	}];
}

@end
