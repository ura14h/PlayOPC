//
//  AppFavoriteSetting.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/09/26.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppFavoriteSetting.h"

NSString *const AppFavoriteSettingListNameKey = @"AppFavoriteSettingListNameKey";
NSString *const AppFavoriteSettingListPathKey = @"AppFavoriteSettingListPathKey";
NSString *const AppFavoriteSettingListDateKey = @"AppFavoriteSettingListDateKey";
static NSString *const FavoriteSettingNameKey = @"FavoriteSettingName";
static NSString *const FavoriteSettingSnapshotKey = @"FavoriteSettingSnapshot";

@interface AppFavoriteSetting ()

@end

#pragma mark -

@implementation AppFavoriteSetting

#pragma mark -

+ (NSInteger)countOfSettings {
	DEBUG_LOG(@"");

	// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
	NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directoryPath = directoryPaths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (!contents) {
		// ディレクトリリストの取得に失敗しました。
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return 0;
	}
	
	// お気に入り設定のファイル名は"Favorite-YYYYMMDDHHMMSS.plist"です。
	__block NSInteger count = 0;
	[contents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger index, BOOL *stop) {
		NSString *fileName = [[path lastPathComponent] lowercaseString];
		if ([fileName hasPrefix:@"favorite-"] &&
			[fileName hasSuffix:@".plist"]) {
			count++;
		}
	}];
	
	return count;
}

+ (NSArray *)listOfSettings {
	DEBUG_LOG(@"");
	
	// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
	NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directoryPath = directoryPaths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (!contents) {
		// ディレクトリリストの取得に失敗しました。
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return nil;
	}

	// お気に入り設定のファイルを一覧に加えます。
	NSMutableArray *favoriteSettingList = [[NSMutableArray alloc] init];
	[contents enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger index, BOOL *stop) {
		// お気に入り設定のファイル名は"Favorite-YYYYMMDDHHMMSS.plist"です。
		NSString *lowercaseName = [[fileName lastPathComponent] lowercaseString];
		if (![lowercaseName hasPrefix:@"favorite-"] ||
			![lowercaseName hasSuffix:@".plist"]) {
			return;
		}
		
		// 一覧で使用する要素を取得します。
		NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
		NSError *error = nil;
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
		NSDate *fileDate = fileAttributes[NSFileModificationDate];
		NSDictionary *favoriteSetting = [NSDictionary dictionaryWithContentsOfFile:filePath];
		if (!favoriteSetting[FavoriteSettingNameKey] ||
			!favoriteSetting[FavoriteSettingSnapshotKey]) {
			return;
		}
		NSString *favoriteName = favoriteSetting[FavoriteSettingNameKey];
		if (favoriteName.length == 0) {
			return;
		}
		
		// 取得した要素を持つ辞書を一覧に加えます。
		NSDictionary *favoriteListItem = @{
			AppFavoriteSettingListNameKey: favoriteName,
			AppFavoriteSettingListPathKey: fileName,
			AppFavoriteSettingListDateKey: fileDate,
		};
		[favoriteSettingList addObject:favoriteListItem];
	}];

	// 一覧を作成日時の昇順でソートします。
	[favoriteSettingList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSDictionary *item1 = (NSDictionary *)obj1;
		NSDictionary *item2 = (NSDictionary *)obj2;
		NSDate *date1 = item1[AppFavoriteSettingListDateKey];
		NSDate *date2 = item2[AppFavoriteSettingListDateKey];
		return [date1 compare:date2];
	}];
	DEBUG_LOG(@"favoriteSettingList=%@", favoriteSettingList);
	
	return favoriteSettingList;
}

+ (BOOL)removeFile:(NSString *)path {
	DEBUG_LOG(@"path=%@", path);

	// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
	NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directoryPath = directoryPaths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (!contents) {
		// ディレクトリリストの取得に失敗しました。
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return NO;
	}
	
	// お気に入り設定のファイルを削除します。
	NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
	if (![fileManager removeItemAtPath:filePath error:&error]) {
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return NO;
	}

	return YES;
}

+ (AppFavoriteSetting *)favoriteSettingWithContentsOfFile:(NSString *)path {
	DEBUG_LOG(@"path=%@", path);

	// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
	NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directoryPath = directoryPaths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (!contents) {
		// ディレクトリリストの取得に失敗しました。
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return nil;
	}

	// 共有ドキュメントフォルダから設定のスナップショットファイルを読み込みます。
	NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
	NSDictionary *favoriteSetting = [NSDictionary dictionaryWithContentsOfFile:filePath];
	if (!favoriteSetting[FavoriteSettingNameKey] ||
		!favoriteSetting[FavoriteSettingSnapshotKey]) {
		DEBUG_LOG(@"An error occurred: no elements.");
		return nil;
	}
	NSString *name = favoriteSetting[FavoriteSettingNameKey];
	if (name.length == 0) {
		DEBUG_LOG(@"An error occurred: name is empty.");
		return nil;
	}
	NSDictionary *snapshot = favoriteSetting[FavoriteSettingSnapshotKey];
	if (!snapshot) {
		DEBUG_LOG(@"An error occurred: snapshot is empty.");
		return nil;
	}
	
	// お気に入り設定を生成します。
	AppFavoriteSetting *setting = [[AppFavoriteSetting alloc] initWithSnapshot:snapshot name:name];
	setting.path = path;
	
	return setting;
}

#pragma mark -

- (instancetype)initWithSnapshot:(NSDictionary *)snapshot name:(NSString *)name {
	DEBUG_LOG(@"");
	
	self = [super init];
	if (!self) {
		return nil;
	}
	
	_name = name;
	_snapshot = snapshot;
	_path = nil;
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_name = nil;
	_snapshot = nil;
	_path = nil;
}

#pragma mark -

- (BOOL)writeToFile {
	DEBUG_LOG(@"");

	// 共有ドキュメントフォルダにあるファイルの名前を読み取ります。
	NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directoryPath = directoryPaths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
	if (!contents) {
		// ディレクトリリストの取得に失敗しました。
		DEBUG_LOG(@"An error occurred: error=%@", error);
		return NO;
	}

	// 保存するファイル名を作成します。
	NSString *fileName;
	if (self.path) {
		fileName = self.path;
	} else {
		// ファイル名が指定されていない場合は自動生成します。
		// お気に入り設定のファイル名は"Favorite-YYYYMMDDHHMMSS.plist"です。
		NSDate *timestamp = [NSDate date];
		NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
		[timestampFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[timestampFormatter setDateFormat:@"yyyyMMddHHmmss"];
		fileName = [NSString stringWithFormat:@"Favorite-%@.plist", [timestampFormatter stringFromDate:timestamp]];
	}
	NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];

	// お気に入り設定をファイルに保存します。
	NSDictionary *favoriteSetting = @{
		FavoriteSettingNameKey: self.name,
		FavoriteSettingSnapshotKey: self.snapshot,
	};
	if (![favoriteSetting writeToFile:filePath atomically:YES]) {
		return NO;
	}
	
	// 保存したファイル名を覚えておきます。
	self.path = fileName;
	
	return YES;
}

@end
