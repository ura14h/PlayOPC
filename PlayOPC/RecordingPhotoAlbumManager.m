//
//  RecordingPhotoAlbumManager.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2023/02/04.
//  Copyright (c) 2023 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RecordingPhotoAlbumManager.h"

@interface RecordingPhotoAlbumManager ()

@property (strong, nonatomic) PHPhotoLibrary *library;

@end

#pragma mark -

@implementation RecordingPhotoAlbumManager

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");
	
	self = [super init];
	if (!self) {
		return nil;
	}
	
	_library = [PHPhotoLibrary sharedPhotoLibrary];
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_library = nil;
}

#pragma mark -

- (PHAuthorizationStatus)reqeustAuthorization {
	DEBUG_LOG(@"");
	
	// 写真アルバムが利用可または不可なら即答します。
	if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusNotDetermined) {
		return [PHPhotoLibrary authorizationStatus];
	}
	
	// 決まっていないならユーザーが許可もしくは禁止を選択するまで待ちます。
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
		DEBUG_LOG(@"");
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	// ユーザーの選択した結果を返します。
	DEBUG_LOG(@"authorization=%ld", (long)[PHPhotoLibrary authorizationStatus]);
	return [PHPhotoLibrary authorizationStatus];
}

- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata groupName:(NSString *)groupName completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
	DEBUG_LOG(@"imageData.length=%ld, metadata=%@, group=%@", (long)imageData.length, metadata, groupName);

	// いったん、画像をディスク上に保存します。
	NSString *fileBody = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *fileName = [fileBody stringByAppendingPathExtension:@"jpg"];
	NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
	NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
	if (metadata) {
		// FIXME: 画像データとメタデータが別々に渡される場合は現在未サポートです。
		DEBUG_LOG(@"An error occurred: should be set metadata to nil.");
		completionBlock(NO, nil);
	} else {
		[imageData writeToURL:imageUrl atomically:YES];
	}

	// 写真アルバムのカスタムグループに画像を登録します。
	[self writeImageUrlToSavedPhotosAlbum:imageUrl groupName:groupName completionBlock:completionBlock];
}

- (void)writeImageUrlToSavedPhotosAlbum:(NSURL *)imageUrl groupName:(NSString *)groupName completionBlock:(void (^)(BOOL success, NSError *error))completionBlock {

	// 写真アルバムからカスタムコレクションを検索します。
	__block PHAssetCollection *group = nil;
	PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
	for (PHAssetCollection *collection in collectionResult) {
		if ([collection.localizedTitle isEqualToString:groupName]) {
			group = collection;
			break;
		}
	}
	if (group) {
		// 写真アルバムにカスタムグループが見つかった場合はそのグループに保存した画像を登録します。
		[self.library performChanges:^{
			PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:group];
			PHAssetChangeRequest *imageRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageUrl];
			PHObjectPlaceholder *imagePlaceholder = [imageRequest placeholderForCreatedAsset];
			[request addAssets:@[imagePlaceholder]];
		} completionHandler:^(BOOL success, NSError *error) {
			DEBUG_LOG(@"Thread: %@", [NSThread isMainThread] ? @"main thread" : @"background thread");
			completionBlock(success, error);
		}];
	} else {
		// 写真アルバムにカスタムグループが見つからなかった場合はグループを新規作成して画像を登録します。
		[self.library performChanges:^{
			[PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:groupName];
		} completionHandler:^(BOOL success, NSError *error) {
			if (success) {
				[self writeImageUrlToSavedPhotosAlbum:imageUrl groupName:groupName completionBlock:completionBlock];
			} else {
				DEBUG_LOG(@"Thread: %@", [NSThread isMainThread] ? @"main thread" : @"background thread");
				completionBlock(success, error);
			}
		}];
	}
}

@end
