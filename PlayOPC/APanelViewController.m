//
//  APanelViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "APanelViewController.h"
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface APanelViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate>

@property (weak ,nonatomic) IBOutlet UISegmentedControl *liveViewTappingActionSegment;
@property (weak, nonatomic) IBOutlet UITableViewCell *afLockStateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *unlockAfCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aeLockStateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *unlockAeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showFullTimeAfCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showFocusStillCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showFocusMovieCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAntiShakeMovieCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAntiShakeFocalLengthCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書

@end

#pragma mark -

@implementation APanelViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;

	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAfLockState)) forKey:CameraPropertyAfLockState];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAeLockState)) forKey:CameraPropertyAeLockState];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeFullTimeAf)) forKey:CameraPropertyFullTimeAf];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeFocusStill)) forKey:CameraPropertyFocusStill];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeFocusMovie)) forKey:CameraPropertyFocusMovie];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAe)) forKey:CameraPropertyAe];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAntiShakeMovie)) forKey:CameraPropertyAntiShakeMovie];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeAntiShakeFocalLength)) forKey:CameraPropertyAntiShakeFocalLength];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	
	// 画面表示を初期表示します。
	self.liveViewTappingActionSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
	NSString *afLockStateTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAfLockState];
	NSString *aeLockStateTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAeLockState];
	NSString *fullTimeAf = [camera cameraPropertyLocalizedTitle:CameraPropertyFullTimeAf];
	NSString *focusStillTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyFocusStill];
	NSString *focusMovieTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyFocusMovie];
	NSString *aeTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAe];
	NSString *antiShakeMovieTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAntiShakeMovie];
	NSString *antiShakeFocalLengthTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyAntiShakeFocalLength];
	self.afLockStateCell.textLabel.text = afLockStateTitle;
	self.aeLockStateCell.textLabel.text = aeLockStateTitle;
	self.showFullTimeAfCell.textLabel.text = fullTimeAf;
	self.showFocusStillCell.textLabel.text = focusStillTitle;
	self.showFocusMovieCell.textLabel.text = focusMovieTitle;
	self.showAeCell.textLabel.text = aeTitle;
	self.showAntiShakeMovieCell.textLabel.text = antiShakeMovieTitle;
	self.showAntiShakeFocalLengthCell.textLabel.text = antiShakeFocalLengthTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.afLockStateCell.detailTextLabel.text = emptyDetailTextLabel;
	self.aeLockStateCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showFullTimeAfCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showFocusStillCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showFocusMovieCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showAeCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showAntiShakeMovieCell.detailTextLabel.text = emptyDetailTextLabel;
	self.showAntiShakeFocalLengthCell.detailTextLabel.text = emptyDetailTextLabel;
	self.liveViewTappingActionSegment.enabled = NO;
	[self tableViewCell:self.afLockStateCell enabled:NO];
	[self tableViewCell:self.aeLockStateCell enabled:NO];
	[self tableViewCell:self.showFullTimeAfCell enabled:NO];
	[self tableViewCell:self.showFocusStillCell enabled:NO];
	[self tableViewCell:self.showFocusMovieCell enabled:NO];
	[self tableViewCell:self.showAeCell enabled:NO];
	[self tableViewCell:self.showAntiShakeMovieCell enabled:NO];
	[self tableViewCell:self.showAntiShakeFocalLengthCell enabled:NO];
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
	
	// didStartActivityメソッドは、パネルを表示する直前にRecordingViewControllerによって呼び出されます。
	// RecordingViewController, PlaybackViewController, SystemViewControllerの手順とは異なります。
}

- (void)viewDidDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidDisappear:animated];
	
	// didFinishActivityメソッドは、パネルを消去する直前にRecordingViewControllerによって呼び出されます。
	// RecordingViewController, PlaybackViewController, SystemViewControllerの手順とは異なります。
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
	[self updateAfLockStateCell];
	[self updateAeLockStateCell];
	[self updateShowFullTimeAfCell];
	[self updateShowFocusStillCell];
	[self updateShowFocusMovieCell];
	[self updateShowAeCell];
	[self updateShowAntiShakeMovieCell];
	[self updateShowAntiShakeFocalLengthCell];

	// ライブビューパネルタップ時動作の現在設定を表示します。
	AppSetting *setting = GetAppSetting();
	AppSettingLiveViewTappingAction action = setting.liveViewTappingAction;
	switch (action) {
		case AppSettingLiveViewTappingActionAF:
			self.liveViewTappingActionSegment.selectedSegmentIndex = 0;
			break;
		case AppSettingLiveViewTappingActionAE:
			self.liveViewTappingActionSegment.selectedSegmentIndex = 1;
			break;
		default:
			self.liveViewTappingActionSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
			break;
	}
	self.liveViewTappingActionSegment.enabled = YES;
	
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

	// 表示を更新します。
	self.liveViewTappingActionSegment.enabled = NO;
	[self tableViewCell:self.afLockStateCell enabled:NO];
	[self tableViewCell:self.aeLockStateCell enabled:NO];
	[self tableViewCell:self.showFullTimeAfCell enabled:NO];
	[self tableViewCell:self.showFocusStillCell enabled:NO];
	[self tableViewCell:self.showFocusMovieCell enabled:NO];
	[self tableViewCell:self.showAeCell enabled:NO];
	[self tableViewCell:self.showAntiShakeMovieCell enabled:NO];
	[self tableViewCell:self.showAntiShakeFocalLengthCell enabled:NO];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowFullTimeAf"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyFullTimeAf;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowFocusStill"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyFocusStill;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowFocusMovie"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyFocusMovie;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowAe"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyAe;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowAntiShakeMovie"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyAntiShakeMovie;
		viewController.itemSelectionDeleage = self;
	} else if ([segueIdentifier isEqualToString:@"ShowAntiShakeFocalLength"]) {
		CameraPropertyValueSelectionViewController *viewController = segue.destinationViewController;
		viewController.property = CameraPropertyAntiShakeFocalLength;
		viewController.itemSelectionDeleage = self;
	} else {
		// 何もしません。
	}
}

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);
	
	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;
	
	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"UnlockAf"]) {
		[self didSelectRowAtUnlockAfCell];
	} else if ([cellReuseIdentifier isEqualToString:@"UnlockAe"]) {
		[self didSelectRowAtUnlockAeCell];
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// カメラプロパティ値選択ビューコントローラで値が選択されると呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index {
	DEBUG_LOG(@"index=%ld", (long)index);
	
	// カメラプロパティに応じた処理を呼び出します。
	NSString *property = ((CameraPropertyValueSelectionViewController *)controller).property;
	if ([property isEqualToString:CameraPropertyFullTimeAf]) {
		[self didChangeFullTimeAf];
	} else if ([property isEqualToString:CameraPropertyFocusStill]) {
		[self didChangeFocusStill];
	} else if ([property isEqualToString:CameraPropertyFocusMovie]) {
		[self didChangeFocusMovie];
	} else if ([property isEqualToString:CameraPropertyAe]) {
		[self didChangeAe];
	} else if ([property isEqualToString:CameraPropertyAntiShakeMovie]) {
		[self didChangeAntiShakeMovie];
	} else if ([property isEqualToString:CameraPropertyAntiShakeFocalLength]) {
		[self didChangeAntiShakeFocalLength];
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
		__weak APanelViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

#pragma mark -

/// ライブビューパネルタップ時動作の選択値が変わった時に呼び出されます。
- (IBAction)didChangeLiveViewTappingActionSegmentValue:(id)sender {
	DEBUG_LOG(@"");
	
	// ライブビューパネルタップ時動作の現在設定を変更します。
	AppSetting *setting = GetAppSetting();
	AppSettingLiveViewTappingAction action = AppSettingLiveViewTappingActionUnknown;
	switch (self.liveViewTappingActionSegment.selectedSegmentIndex) {
		case 0:
			action = AppSettingLiveViewTappingActionAF;
			break;
		case 1:
			action = AppSettingLiveViewTappingActionAE;
			break;
		default:
			break;
	}
	setting.liveViewTappingAction = action;
}

/// フォーカス固定(AFロック)の値が変わった時に呼び出されます。
- (void)didChangeAfLockState {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateAfLockStateCell];
}

/// 露出固定(AEロック)の値が変わった時に呼び出されます。
- (void)didChangeAeLockState {
	DEBUG_LOG(@"");

	// 画面表示を更新します。
	[self updateAeLockStateCell];
}

/// フルタイムAFの値が変わった時に呼び出されます。
- (void)didChangeFullTimeAf {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowFullTimeAfCell];
}

/// フォーカスモード(静止画用)の値が変わった時に呼び出されます。
- (void)didChangeFocusStill {
	DEBUG_LOG(@"");

	// 画面表示を更新します。
	[self updateShowFocusStillCell];
}

/// フォーカスモード(動画用)の値が変わった時に呼び出されます。
- (void)didChangeFocusMovie {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowFocusMovieCell];
}

/// 測光方式の値が変わった時に呼び出されます。
- (void)didChangeAe {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowAeCell];
}

/// 動画手ぶれ補正の値が変わった時に呼び出されます。
- (void)didChangeAntiShakeMovie {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowAntiShakeMovieCell];
}

/// IS焦点距離の値が変わった時に呼び出されます。
- (void)didChangeAntiShakeFocalLength {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateShowAntiShakeFocalLengthCell];
}

/// 'Unlock AF'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtUnlockAfCell {
	DEBUG_LOG(@"");

	// AFロックの解除を開始します。
	__weak APanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// AFロック座標をクリアします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera clearAutoFocusPoint:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not unlock AF", nil)];
			return;
		}
		// AFロックを解除します。
		if (![camera unlockAutoFocus:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not unlock AF", nil)];
			return;
		}

		// 画面表示を更新しなくても、
		// MARK: AFロックを解除するとフォーカス固定(AFロック)のプロパティ値変更の通知が発生するようです。
		
		// AFロックの解除が完了しました。
		DEBUG_LOG(@"");
	}];
}

/// 'Unlock AE'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtUnlockAeCell {
	DEBUG_LOG(@"");

	// AEロックの解除を開始します。
	__weak APanelViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// AEロック座標をクリアします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera clearAutoExposurePoint:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not unlock AE", nil)];
			return;
		}
		// AEロックを解除します。
		if (![camera unlockAutoExposure:&error]) {
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not unlock AE", nil)];
			return;
		}

		// 画面表示を更新しなくても、
		// MARK: AEロックを解除すると露出固定(AEロック)のプロパティ値変更の通知が発生するようです。
		
		// AEロックの解除が完了しました。
		DEBUG_LOG(@"");
	}];
}

#pragma mark -

/// フォーカス固定(AFロック)を表示します。
- (void)updateAfLockStateCell {
	DEBUG_LOG(@"");

	__weak APanelViewController *weakSelf = self;
	[self updateCameraPropertyCell:self.afLockStateCell name:CameraPropertyAfLockState completion:^(NSString *value) {
		// 表示したフォーカス固定(AFロック)の値に応じて、'Unlock AF'セルの有効無効も設定します。
		BOOL unlockAfEnabled = [value isEqualToString:CameraPropertyAfLockStateLock];
		[weakSelf tableViewCell:weakSelf.unlockAfCell enabled:unlockAfEnabled];
	}];
}

/// 露出固定(AEロック)を表示します。
- (void)updateAeLockStateCell {
	DEBUG_LOG(@"");
	
	__weak APanelViewController *weakSelf = self;
	[self updateCameraPropertyCell:self.aeLockStateCell name:CameraPropertyAeLockState completion:^(NSString *value) {
		// 表示した露出固定(AEロック)の値に応じて、'Unlock AE'セルの有効無効も設定します。
		BOOL unlockAeEnabled = [value isEqualToString:CameraPropertyAeLockStateLock];
		[weakSelf tableViewCell:weakSelf.unlockAeCell enabled:unlockAeEnabled];
	}];
}

/// フルタイムAFを表示します。
- (void)updateShowFullTimeAfCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showFullTimeAfCell name:CameraPropertyFullTimeAf completion:nil];
}

/// フォーカスモード(静止画用)を表示します。
- (void)updateShowFocusStillCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showFocusStillCell name:CameraPropertyFocusStill completion:nil];
}

/// フォーカスモード(動画用)を表示します。
- (void)updateShowFocusMovieCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showFocusMovieCell name:CameraPropertyFocusMovie completion:nil];
}

/// 測光方式を表示します。
- (void)updateShowAeCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showAeCell name:CameraPropertyAe completion:nil];
}

/// 動画手ぶれ補正を表示します。
- (void)updateShowAntiShakeMovieCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showAntiShakeMovieCell name:CameraPropertyAntiShakeMovie completion:nil];
}

/// IS焦点距離を表示します。
- (void)updateShowAntiShakeFocalLengthCell {
	DEBUG_LOG(@"");
	
	[self updateCameraPropertyCell:self.showAntiShakeFocalLengthCell name:CameraPropertyAntiShakeFocalLength completion:nil];
}

/// カメラプロパティ値を表示します。
- (void)updateCameraPropertyCell:(UITableViewCell *)cell name:(NSString *)name completion:(void (^)(NSString *value))completion {
	DEBUG_LOG(@"name=%@", name);

	__weak UITableViewCell *weakCell = cell;
	__weak APanelViewController *weakSelf = self;
	BOOL userInteractionEnabled = weakCell.userInteractionEnabled;
	weakCell.userInteractionEnabled = NO; // 表示内容が確定するまでは操作禁止にします。
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakCell=%p", weakCell);
		if (!weakCell) {
			return;
		}
		
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
