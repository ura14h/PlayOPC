//
//  ContentDetailViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ContentDetailViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"

// メタデータ用の表示文言ローカライズ ... ローカライズされた表示文言はAppExif.stringsに格納されます。
#define AppExifLocalizedString(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"AppExif"]

static const NSInteger ContentDetailSection = 0;
static const NSInteger ContentMetadataSection = 1;
static NSString *const ContentDetailCellIdentifier = @"ContentDetailCell";
static NSString *const ContentDetailTitleKey = @"ContentDetailTitleKey";
static NSString *const ContentDetailValueKey = @"ContentDetailValueKey";
static NSString *const ContentMetadataTitleKey = @"ContentMetadataTitleKey";
static NSString *const ContentMetadataValueKey = @"ContentMetadataValueKey";

@interface ContentDetailViewController ()

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableArray *contentDetails; ///< コンテンツ情報
@property (strong, nonatomic) NSMutableArray *contentMetadata; ///< コンテンツのメタデータ

@end

#pragma mark -

@implementation ContentDetailViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_content = nil;
	_contentData = nil;
	_contentDetails = nil;
	_contentMetadata = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// タイトルを設定します。
	self.title = self.content[OLYCameraContentListFilenameKey];
	
	// ツールバーを表示します。
	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];
	
	if (self.isMovingToParentViewController) {
		[self didStartActivity];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidDisappear:animated];
	
	if (self.isMovingFromParentViewController) {
		[self didFinishActivity];
	}
}

#pragma mark -

/// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

	// コンテンツ情報のリスト表示を開始します。
	__weak ContentDetailViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// コンテンツの絶対パスを作成します。
		NSString *dirname = self.content[OLYCameraContentListDirectoryKey];
		NSString *filename = self.content[OLYCameraContentListFilenameKey];
		NSString *filepath = [dirname stringByAppendingPathComponent:filename];

		// コンテンツの情報を取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSDictionary *information = [camera inquireContentInformation:filepath error:&error];
		if (!information) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotGetContentInformation", @"ContentDetailViewController.didStartActivity")];
			return;
		}
		
		// コンテンツ情報を整形して取り込みます。
		NSMutableArray *contentDetails = [[NSMutableArray alloc] initWithCapacity:information.count];
		for (NSString *key in information.allKeys) {
			id value = information[key];
			// FIXME:どうやって表示文言に変換していいのか不明
			NSString *keyText = key;
			NSString *valueText;
			if ([value isKindOfClass:[NSArray class]]) {
				valueText = [value componentsJoinedByString:@", "];
			} else {
				valueText = [value description];
			}
			NSDictionary *contentDetail = @{
				ContentDetailTitleKey: keyText,
				ContentDetailValueKey: valueText,
			};
			[contentDetails addObject:contentDetail];
		}
		// コンテンツ情報名の昇順でソートします。
		[contentDetails sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSDictionary *item1 = (NSDictionary *)obj1;
			NSDictionary *item2 = (NSDictionary *)obj2;
			NSString *title1 = item1[ContentDetailTitleKey];
			NSString *title2 = item2[ContentDetailTitleKey];
			return [title1 localizedCaseInsensitiveCompare:title2];
		}];
		weakSelf.contentDetails = contentDetails;

		// コンテンツのメタデータを取得します。
		__block NSMutableArray *contentMetadata = [[NSMutableArray alloc] init];
		if (weakSelf.contentData) {
			// バイナリデータからメタデータを抽出します。
			CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(weakSelf.contentData), nil);
			NSDictionary *metadata = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil);
			CFRelease(sourceRef);
			
			// 多階層構造のメタデータを表示用にフラットな構造に変換します。
			[self flattenMetadata:metadata names:nil result:contentMetadata];
			DEBUG_DETAIL_LOG(@"metadata=%@", metadata);
			DEBUG_DETAIL_LOG(@"contentMetadata=%@", contentMetadata);
		}
		// メタデータキー名の昇順でソートします。
		[contentMetadata sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSDictionary *item1 = (NSDictionary *)obj1;
			NSDictionary *item2 = (NSDictionary *)obj2;
			NSString *title1 = item1[ContentMetadataTitleKey];
			NSString *title2 = item2[ContentMetadataTitleKey];
			return [title1 localizedCaseInsensitiveCompare:title2];
		}];
		weakSelf.contentMetadata = contentMetadata;
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 一覧を更新します。
			[weakSelf.tableView reloadData];
		}];
		
		// コンテンツ情報のリスト表示が完了しました。
		DEBUG_LOG(@"");
	}];
	
	// ビューコントローラーが活動を開始しました。
	self.startingActivity = YES;
}

/// ビューコントローラーが画面を破棄して活動を完了する時に呼び出されます。
- (void)didFinishActivity {
	DEBUG_LOG(@"");
	
	// すでに活動停止している場合は何もしません。
	if (!self.startingActivity) {
		return;
	}

	// コンテンツの情報を破棄します。
	self.contentDetails = nil;
	self.contentMetadata = nil;
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_DETAIL_LOG(@"");
	
	if (!self.contentDetails && !self.contentMetadata) {
		return 0;
	}
	if (self.contentMetadata && self.contentMetadata.count > 0) {
		return 2;
	}
	if (self.contentDetails && self.contentDetails.count > 0) {
		return 1;
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);
	
	NSInteger rows = 0;
	switch (section) {
		case ContentDetailSection:
			rows = self.contentDetails.count;
			break;
		case ContentMetadataSection:
			rows = self.contentMetadata.count;
			break;
	}
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);
	
	NSString *title = nil;
	switch (section) {
		case ContentDetailSection:
			if (self.contentDetails && self.contentDetails.count > 0) {
				title = NSLocalizedString(@"$title:ContentDetail", @"ContentDetailViewController.tabeView:titleForHeaderInSection");
			}
			break;
		case ContentMetadataSection:
			if (self.contentMetadata && self.contentMetadata.count > 0) {
				title = NSLocalizedString(@"$title:ContentMetadata", @"ContentDetailViewController.tabeView:titleForHeaderInSection");
			}
			break;
	}
	return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 表示セルを取得します。
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContentDetailCellIdentifier forIndexPath:indexPath];

	// 表示セルをセットアップします。
	if (indexPath.section == ContentDetailSection) {
		// 表示するコンテンツ情報を取得します。
		NSDictionary *detail = self.contentDetails[indexPath.row];
		
		// コンテンツ情報のキー名を表示文言に変換して表示します。
		AppCamera *camera = GetAppCamera();
		NSString *itemName = detail[ContentDetailTitleKey];
		NSString *itemNameTitle = [camera contentInformationLocalizedTitle:itemName];
		cell.textLabel.text = itemNameTitle;
		
		// コンテンツ情報の値を表示文言に変換して表示します。
		// MARK: 補正値や角度などの数値型で値の符号がおかしい場合があります。(2の補数を正しく変換できていないようです)
		// MARK: DigitalTelecon(デジタルテレコン有無)は通信仕様書の記述と異なり"ON"または"OFF"で返されるようです。
		// MARK: Location(本体の位置)の値は通信仕様書の記述と異なり実際には"0x0"から"0x5"までの値で返されるようです。
		// MARK: MonotoneFilter(￼モノクロフィルター効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
		// MARK: MonotoneColor(￼調色効果)は通信仕様書に記述のない"ERROR"という値が返される場合があるようです。
		NSString *itemValue = detail[ContentDetailValueKey];
		NSString *itemValueTitle = [camera contentInformationValueLocalizedTitle:itemName value:itemValue];
		cell.detailTextLabel.text = itemValueTitle;
		
	} else if (indexPath.section == ContentMetadataSection) {
		// 表示するメタデータを取得します。
		NSDictionary *metadata = self.contentMetadata[indexPath.row];
		
		// メタデータのキー名を表示文言に変換して表示します。
		NSString *itemName = metadata[ContentMetadataTitleKey];
		NSString *itemNameTitle = [self metadataNameLocalizedTitle:itemName];
		cell.textLabel.text = itemNameTitle;

		// メタデータの値を表示文言に変換して表示します。
		NSString *itemValue = metadata[ContentMetadataValueKey];
		NSString *itemValueTitle = [self metadataValueLocalizedTitle:itemName value:itemValue];
		cell.detailTextLabel.text = itemValueTitle;
	}
	
	return cell;
}

#pragma mark -

/// 多階層構造のメタデータを表示用にフラットな構造に変換します。
- (void)flattenMetadata:(id)element names:(NSMutableArray *)names result:(NSMutableArray *)result {
	DEBUG_DETAIL_LOG(@"element=%@, names=%@, result=%@", element, names, result);
	
	if ([element isKindOfClass:[NSDictionary class]] || [element isKindOfClass:[NSMutableDictionary class]]) {
		// 要素が辞書の場合は列挙してそれぞれの値を要素として再帰呼び出しします。
		for (NSString *name in [(NSDictionary *)element allKeys]) {
			NSMutableArray *elementName;
			if (names) {
				elementName = [names mutableCopy];
			} else {
				elementName = [[NSMutableArray alloc] init];
			}
			NSString *elementNameLastComponent;
			if ([name isEqualToString:@"{TIFF}"]) {
				elementNameLastComponent = @"Tiff";
			} else if ([name isEqualToString:@"{GPS}"]) {
				elementNameLastComponent = @"Gps";
			} else if ([name isEqualToString:@"{Exif}"]) {
				elementNameLastComponent = @"Exif";
			} else {
				elementNameLastComponent = name;
			}
			[elementName addObject:elementNameLastComponent];
			[self flattenMetadata:element[name] names:elementName result:result];
		}
	} else if ([element isKindOfClass:[NSArray class]] || [element isKindOfClass:[NSMutableArray class]]) {
		// 要素が配列の場合は1つの文字列に結合します。
		NSString *title = [names componentsJoinedByString:@"."];
		__block NSMutableString *value = [[NSMutableString alloc] init];
		[(NSArray *)element enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
			if (value.length > 0) {
				[value appendString:@","];
			}
			NSString *itemText = [[item description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[value appendString:itemText];
		}];
		NSDictionary *item = @{
			ContentMetadataTitleKey: title,
			ContentMetadataValueKey: value,
		};
		[result addObject:item];
	} else {
		// 要素が辞書でも配列でもない場合は文字列として扱います。
		NSString *title = [names componentsJoinedByString:@"."];
		NSString *value = [[element description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSDictionary *item = @{
			ContentMetadataTitleKey: title,
			ContentMetadataValueKey: value,
		};
		[result addObject:item];
	}
}

- (NSString *)metadataNameLocalizedTitle:(NSString *)name {
	DEBUG_DETAIL_LOG(@"name=%@", name);
	
	NSString *key = [NSString stringWithFormat:@"[%@]", name];
	NSString *localizedTitle = AppExifLocalizedString(key);
	if ([localizedTitle isEqualToString:key]) {
		localizedTitle = name;
	}
	return localizedTitle;
}

- (NSString *)metadataValueLocalizedTitle:(NSString *)name value:(NSString *)value {
	DEBUG_DETAIL_LOG(@"name=%@, value=%@", name, value);
	
	NSString *key = [NSString stringWithFormat:@"[%@/%@]", name, value];
	NSString *localizedTitle = AppExifLocalizedString(key);
	if ([localizedTitle isEqualToString:key]) {
		localizedTitle = value;
	}
	return localizedTitle;
}

@end
