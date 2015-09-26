//
//  AppFavoriteSetting.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/09/26.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

extern NSString *const AppFavoriteSettingListNameKey;
extern NSString *const AppFavoriteSettingListPathKey;
extern NSString *const AppFavoriteSettingListDateKey;

/// お気に入り設定、およびその入出力を行います。
@interface AppFavoriteSetting : NSObject

@property (strong, nonatomic) NSString *name; ///< お気に入り設定の名前
@property (strong, nonatomic) NSDictionary *snapshot; ///< お気に入り保存した時のカメラプロパティの設定値
@property (strong, nonatomic) NSString *path; ///< 保存した先のファイル名

/// 保存されているお気に入り設定のファイル数を取得します。
+ (NSInteger)countOfSettings;

/// 保存されているお気に入り設定のファイル一覧を取得します。
/// 配列要素はファイル情報を持つ辞書形式です。
+ (NSArray *)listOfSettings;

/// お気に入り設定のファイルを削除します。
+ (BOOL)removeFile:(NSString *)path;

/// ファイルからお気に入り設定を読み込みます。
+ (AppFavoriteSetting *)favoriteSettingWithContentsOfFile:(NSString *)path;

/// お気に入り設定をカメラプロパティのスナップショットから生成します。
- (instancetype)initWithSnapshot:(NSDictionary *)snapshot name:(NSString *)name;

/// お気に入り設定をファイルに保存します。
/// 新規の保存の場合は、ファイル名は自動的に生成されます。
- (BOOL)writeToFile;

@end
