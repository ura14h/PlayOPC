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

NSString *const ContentDetailCellIdentifier = @"ContentDetailCell";
NSString *const ContentDetailTitleKey = @"ContentDetailTitleKey";
NSString *const ContentDetailValueKey = @"ContentDetailValueKey";

@interface ContentDetailViewController ()

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableArray *contentDetails; ///< コンテンツ情報

@end

#pragma mark -

@implementation ContentDetailViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	
	// コンテンツ情報をクリアします。
	self.contentDetails = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_content = nil;
	_contentDetails = nil;
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
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not get information", nil)];
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
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	DEBUG_DETAIL_LOG(@"");
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DEBUG_DETAIL_LOG(@"section=%ld", (long)section);
	
	return self.contentDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// 表示セルを取得します。
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContentDetailCellIdentifier forIndexPath:indexPath];
	NSDictionary *contentDetail = self.contentDetails[indexPath.row];

	// コンテンツ情報のキー名を表示文言に変換して表示します。
	AppCamera *camera = GetAppCamera();
	NSString *itemName = contentDetail[ContentDetailTitleKey];
	NSString *itemNameTitle = [camera contentInformationLocalizedTitle:itemName];
	cell.textLabel.text = itemNameTitle;
	
	// コンテンツ情報の値を表示文言に変換して表示します。
	NSString *itemValue = contentDetail[ContentDetailValueKey];
	NSString *itemValueTitle = [camera contentInformationValueLocalizedTitle:itemName value:itemValue];
	cell.detailTextLabel.text = itemValueTitle;
	
	return cell;
}

@end
