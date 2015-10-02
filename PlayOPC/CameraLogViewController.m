//
//  CameraLogViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CameraLogViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "AppCameraLog.h"
#import "CameraLogViewCell.h"
#import "UIViewController+Threading.h"

@interface CameraLogViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *latestButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSArray *messages; ///< ログ履歴

@end

#pragma mark -

@implementation CameraLogViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	
	// アプリケーションの実行状態を監視開始します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

	// 不要な行を表示しないようにします。
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
	// 画面表示を初期表示します。
	self.tableView.estimatedRowHeight = self.tableView.rowHeight;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.shareButton.enabled = NO;
	self.latestButton.enabled = NO;
	self.clearButton.enabled = NO;

}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];

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

/// アプリケーションがアクティブになる時に呼び出されます。
- (void)applicationDidBecomeActive:(NSNotification *)notification {
	DEBUG_LOG(@"");

	// ログを読み込みます。
	[self reloadLog:NO];
}

/// アプリケーションが非アクティブになる時に呼び出されます。
- (void)applicationWillResignActive:(NSNotification *)notification {
	DEBUG_LOG(@"");
	// 今は何もしません。
}

#pragma mark -

// ビューコントローラーが画面を表示して活動を開始する時に呼び出されます。
- (void)didStartActivity {
	DEBUG_LOG(@"");
	
	// すでに活動開始している場合は何もしません。
	if (self.startingActivity) {
		return;
	}

	// ログを読み込みます。
	[self reloadLog:NO];
	
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
	
	return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	CameraLogViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
	cell.messageLabel.text = self.messages[indexPath.row];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_DETAIL_LOG(@"indexPath.row=%ld", (long)indexPath.row);
	
	// MARK: 最終行へのスクロールした時に座標がずれるので、1行の高さを可能な限り正確な見積もります。
	// MARK: Storyboardエディタでセル配置の座標値を見ながらのハードコーディングです。
	NSString *message = self.messages[indexPath.row];
	CGSize messageMaximumSize = CGSizeMake(self.tableView.bounds.size.width - 2, CGFLOAT_MAX);
	UIFont *messageFont = [UIFont systemFontOfSize:11.0];
	NSDictionary *attributes = @{ NSFontAttributeName:messageFont };
	NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
	CGRect messageRect = [message boundingRectWithSize:messageMaximumSize options:options attributes:attributes context:nil];
	CGFloat height = ceil(messageRect.size.height) + 2.0;
	
	return height;
}

/// 再読み込みボタンがタップされた時に呼び出されます。
- (IBAction)didTapRefreshButton:(id)sender {
	DEBUG_LOG(@"");

	// ログを読み込みます。
	[self reloadLog:YES];
}

/// 共有ボタンがタップされた時に呼び出されます。
- (IBAction)didTapShareButton:(id)sender {
	DEBUG_LOG(@"");

	__weak CameraLogViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// テキスト化したログを生成します。
		NSMutableString *logText = [[NSMutableString alloc] init];
		for (NSString *message in self.messages) {
			[logText appendString:message];
			[logText appendString:@"\n"];
		}
		
		// 共有ダイアログを表示します。
		// 一番最初だけ表示されるまでとても時間がかかるようです。
		NSArray *shareItems = @[ logText ];
		UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
		shareController.popoverPresentationController.sourceView = weakSelf.view;
		shareController.popoverPresentationController.barButtonItem = weakSelf.shareButton;
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf presentViewController:shareController animated:YES completion:nil];
		}];
	}];
}

/// 最新ボタンがタップされた時に呼び出されます。
- (IBAction)didTapLatestButton:(id)sender {
	DEBUG_LOG(@"");

	// 最下端にスクロールします。
	if (self.messages.count > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

/// クリアボタンがタップされた時に呼び出されます。
- (IBAction)didTapClearButton:(id)sender {
	DEBUG_LOG(@"");

	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.barButtonItem = self.clearButton;
	
	__weak CameraLogViewController *weakSelf = self;
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteClearLog", @"CameraLogViewController.didTapClearButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			[weakSelf clearLog];
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelClearLog", @"CameraLogViewController.didTapClearButton");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -

/// ログを読み込みます。
- (void)reloadLog:(BOOL)animated {
	DEBUG_LOG(@"");

	__weak CameraLogViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		/// ログを読み込みます。
		AppCameraLog *cameraLog = GetAppCameraLog();
		weakSelf.messages = cameraLog.messages;
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf.tableView reloadData];
			
			// ログメッセージがある場合はボタンを有効にします。
			BOOL hasMessages = weakSelf.messages.count > 0;
			weakSelf.shareButton.enabled = hasMessages;
			weakSelf.latestButton.enabled = hasMessages;
			weakSelf.clearButton.enabled = hasMessages;
			
			// 最下端にスクロールします。
			if (hasMessages) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messages.count - 1 inSection:0];
				[weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
			}
		}];
	}];
}

/// ログをクリアします。
- (void)clearLog {
	DEBUG_LOG(@"");
	
	__weak CameraLogViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// ログをクリアします。
		AppCameraLog *cameraLog = GetAppCameraLog();
		[cameraLog clearMessages];
		weakSelf.messages = cameraLog.messages;
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// ログを読み込みます。
			[weakSelf reloadLog:YES];
		}];
	}];
}

@end
