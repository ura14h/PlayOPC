//
//  CPanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CPanelViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface CPanelViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *showWbCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showCustomWbKelvin1Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColortoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorCreatorColorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorCreatorVividCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showRecentlyArtFilterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showColorPhaseCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showArtFilterAutoBracketCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書

@end

#pragma mark -

@implementation CPanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeWb)) forKey:CameraPropertyWb];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeCustomWbKelvin1)) forKey:CameraPropertyCustomWbKelvin1];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColortone)) forKey:CameraPropertyColortone];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorCreatorColor)) forKey:CameraPropertyColorCreatorColor];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorCreatorVivid)) forKey:CameraPropertyColorCreatorVivid];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeRecentlyArtFilter)) forKey:CameraPropertyRecentlyArtFilter];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeColorPhase)) forKey:CameraPropertyColorPhase];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	
	// 画面表示を初期表示します。
	NSString *wbTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyWb];
	NSString *customWbKelvin1Title = [camera cameraPropertyLocalizedTitle:CameraPropertyCustomWbKelvin1];
	NSString *colortoneTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColortone];
	NSString *colorCreatorColorTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorCreatorColor];
	NSString *colorCreatorVividTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorCreatorVivid];
	NSString *recentlyArtFilterTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyRecentlyArtFilter];
	NSString *colorPhaseTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyColorPhase];
	self.showWbCell.textLabel.text = wbTitle;
	self.showCustomWbKelvin1Cell.textLabel.text = customWbKelvin1Title;
	self.showColortoneCell.textLabel.text = colortoneTitle;
	self.showColorCreatorColorCell.textLabel.text = colorCreatorColorTitle;
	self.showColorCreatorVividCell.textLabel.text = colorCreatorVividTitle;
	self.showRecentlyArtFilterCell.textLabel.text = recentlyArtFilterTitle;
	self.showColorPhaseCell.textLabel.text = colorPhaseTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.showWbCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showCustomWbKelvin1Cell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColortoneCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorCreatorColorCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorCreatorVividCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showRecentlyArtFilterCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showColorPhaseCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showArtFilterAutoBracketCell.detailTextLabel.text = emptyDetailTextLabel;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	[camera removeCameraPropertyDelegate:self];
	_cameraPropertyObserver = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// MARK: セグエで遷移して戻ってくるとたまに自動で行選択が解除されないようです。
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	if (indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];
	
	if (self.isMovingToParentViewController) {
		[self didStartActivity];
	}
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
	
	// 表示を更新します。
	[self updateShowWbCell];
	[self updateShowCustomWbKelvin1Cell];
	[self updateShowColortoneCell];
	[self updateShowColorCreatorColorCell];
	[self updateShowColorCreatorVividCell];
	[self updateShowRecentlyArtFilterCell];
	[self updateShowColorPhaseCell];
	[self updateShowArtFilterAutoBracketCell];
	
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

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowWb"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyWb;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowCustomWbKelvin1"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyCustomWbKelvin1;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColortone"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColortone;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorCreatorColor"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorCreatorColor;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorCreatorVivid"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorCreatorVivid;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowRecentlyArtFilter"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyRecentlyArtFilter;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowColorPhase"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyColorPhase;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowArtFilterAutoBracket"]) {
		// 専用のビューコントローラで処理されるのでここで行う初期化はありません。
	} else {
		// 何もしません。
	}
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	// カメラプロパティに応じた処理を呼び出します。
	NSString *property = ((CameraPropertyValueSelectionViewController *)controller).property;
	if ([property isEqualToString:CameraPropertyWb]) {
		[self didChangeWb];
	} else if ([property isEqualToString:CameraPropertyCustomWbKelvin1]) {
		[self didChangeCustomWbKelvin1];
	} else if ([property isEqualToString:CameraPropertyColortone]) {
		[self didChangeColortone];
	} else if ([property isEqualToString:CameraPropertyColorCreatorColor]) {
		[self didChangeColorCreatorColor];
	} else if ([property isEqualToString:CameraPropertyColorCreatorVivid]) {
		[self didChangeColorCreatorVivid];
	} else if ([property isEqualToString:CameraPropertyRecentlyArtFilter]) {
		[self didChangeRecentlyArtFilter];
	} else if ([property isEqualToString:CameraPropertyColorPhase]) {
		[self didChangeColorPhase];
	} else {
		DEBUG_LOG(@"Unknown property: %@", property);
	}
}

/// カメラプロパティの値に変更があった時に呼び出されます。
- (void)camera:(OLYCamera *)camera didChangeCameraProperty:(NSString *)name {
	DEBUG_LOG(@"name=%@", name);
	
	// すでに活動停止している場合や何かの誤りでセレクタが取得できない場合は何もしません。
	if (!self.startingActivity) {
		return;
	}
	SEL selector = NSSelectorFromString(self.cameraPropertyObserver[name]);
	if (!selector || ![self respondsToSelector:selector]) {
		return;
	}
	
	// メインスレッドでイベントハンドラを呼び出します。
	if ([NSThread isMainThread]) {
		[self performSelector:selector withObject:nil afterDelay:0];
	} else {
		__weak CPanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

#pragma mark -

/// ホワイトバランスの値が変わった時に呼び出されます。
- (void)didChangeWb {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowWbCell];
}

/// カスタムWBの値が変わった時に呼び出されます。
- (void)didChangeCustomWbKelvin1 {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowCustomWbKelvin1Cell];
}

/// 仕上がりピクチャーモードの値が変わった時に呼び出されます。
- (void)didChangeColortone {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColortoneCell];
}

/// カラークリエーター用色相の値が変わった時に呼び出されます。
- (void)didChangeColorCreatorColor {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorCreatorColorCell];
}

/// カラークリエーター用彩度の値が変わった時に呼び出されます。
- (void)didChangeColorCreatorVivid {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorCreatorVividCell];
}

/// アートフィルター種別の値が変わった時に呼び出されます。
- (void)didChangeRecentlyArtFilter {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowRecentlyArtFilterCell];
}

/// パートカラー用色相の値が変わった時に呼び出されます。
- (void)didChangeColorPhase {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowColorPhaseCell];
}

#pragma mark -

/// ホワイトバランスを表示します。
- (void)updateShowWbCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showWbCell name:CameraPropertyWb completion:nil];
}

/// カスタムWBを表示します。
- (void)updateShowCustomWbKelvin1Cell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showCustomWbKelvin1Cell name:CameraPropertyCustomWbKelvin1 completion:nil];
}

/// 仕上がりピクチャーモードを表示します。
- (void)updateShowColortoneCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColortoneCell name:CameraPropertyColortone completion:nil];
}

/// カラークリエーター用色相を表示します。
- (void)updateShowColorCreatorColorCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorCreatorColorCell name:CameraPropertyColorCreatorColor completion:nil];
}

/// カラークリエーター用彩度を表示します。
- (void)updateShowColorCreatorVividCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorCreatorVividCell name:CameraPropertyColorCreatorVivid completion:nil];
}

/// アートフィルター種別を表示します。
- (void)updateShowRecentlyArtFilterCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showRecentlyArtFilterCell name:CameraPropertyRecentlyArtFilter completion:nil];
}

/// パートカラー用色相を表示します。
- (void)updateShowColorPhaseCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showColorPhaseCell name:CameraPropertyColorPhase completion:nil];
}

/// アートフィルター自動ブラケットを表示します。
- (void)updateShowArtFilterAutoBracketCell {
	DEBUG_LOG(@"");
	
	// TAKEMODEプロパティをARTに設定し、RECENTLY_ART_FILTERプロパティがART_BKTに設定されているときに有効です。
	// 設定可不可の条件が複雑なので(処理コストが高いので)、代理としてアートフィルターブラケットのポップアートを参照します。
	AppCamera *camera = GetAppCamera();
	[self tableViewCell:self.showArtFilterAutoBracketCell enabled:[camera canSetCameraProperty:CameraPropertyArtFilterAutoBracket]];
}

/// カメラプロパティ値を表示します。
- (void)updateCameraPropertyCell:(UITableViewCell *)cell name:(NSString *)name completion:(void (^)(NSString *value))completion {
	DEBUG_LOG(@"name=%@", name);
	
	__weak UITableViewCell *weakCell = cell;
	__weak CPanelViewController *weakSelf = self;
	BOOL userInteractionEnabled = weakCell.userInteractionEnabled;
	weakCell.userInteractionEnabled = NO; // 表示内容が確定するまでは操作禁止にします。
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラプロパティを取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSString *propertyValue = [camera cameraPropertyValue:name error:&error];
		if (!propertyValue) {
			// カメラプロパティが取得できませんでした。
			// エラーを無視します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakCell.userInteractionEnabled = userInteractionEnabled;
				weakCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
				[weakSelf tableViewCell:weakCell enabled:[camera canSetCameraProperty:name]];
				if (completion) {
					completion(propertyValue);
				}
			}];
			return;
		}
		DEBUG_LOG(@"propertyValue=%@", propertyValue);
		// 取得した値を表示用の文言に変換します。
		NSString *propertyValueTitle = [camera cameraPropertyValueLocalizedTitle:propertyValue];
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			weakCell.userInteractionEnabled = userInteractionEnabled;
			weakCell.detailTextLabel.text = propertyValueTitle;
			if (weakCell.accessoryType != UITableViewCellAccessoryNone) {
				[weakSelf tableViewCell:weakCell enabled:[camera canSetCameraProperty:name]];
			}
			if (completion) {
				completion(propertyValue);
			}
		}];
	}];
}

@end
