//
//  SystemViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/05.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SystemViewController.h"
#import "AppDelegate.h"
#import "AppCamera.h"
#import "CameraPropertyValueSelectionViewController.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"

@interface SystemViewController () <OLYCameraPropertyDelegate, ItemSelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *batteryLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lensMountStatusCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mediaMountStatusCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cameraModelNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cameraFirmwareVersionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lensModelIdCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lensFirmwareVersionCell;

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (assign, nonatomic) OLYCameraRunMode previousRunMode; ///< この画面に遷移してくる前のカメラ実行モード
@property (strong, nonatomic) NSMutableDictionary *cameraPropertyObserver; ///< 監視するカメラプロパティ名とメソッド名の辞書

@end

#pragma mark -

@implementation SystemViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	self.previousRunMode = OLYCameraRunModeUnknown;

	// 監視するカメラプロパティ名とそれに紐づいた対応処理(メソッド名)を対とする辞書を用意して、
	// Objective-CのKVOチックに、カメラプロパティに変化があったらその個別処理を呼び出せるようにしてみます。
	NSMutableDictionary *cameraPropertyObserver = [[NSMutableDictionary alloc] init];
	[cameraPropertyObserver setObject:NSStringFromSelector(@selector(didChangeBatteryLevel)) forKey:CameraPropertyBatteryLevel];
	self.cameraPropertyObserver = cameraPropertyObserver;
	// カメラプロパティ、カメラのプロパティを監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addCameraPropertyDelegate:self];
	[camera addObserver:self forKeyPath:CameraPropertyLensMountStatus options:0 context:@selector(didChangeLensMountStatus:)];
	
	// 画面表示を初期表示します。
	NSString *batteryLevelTitle = [camera cameraPropertyLocalizedTitle:CameraPropertyBatteryLevel];
	self.batteryLevelCell.textLabel.text = batteryLevelTitle;
	NSString *emptyDetailTextLabel = @" "; // テーブルセルのラベルを空欄にしょうとしてnilとか@""とかを設定するとなぜか不具合が起きます。
	self.batteryLevelCell.detailTextLabel.text = emptyDetailTextLabel;
	self.lensMountStatusCell.detailTextLabel.text = emptyDetailTextLabel;
	self.mediaMountStatusCell.detailTextLabel.text = emptyDetailTextLabel;
	self.cameraModelNameCell.detailTextLabel.text = emptyDetailTextLabel;
	self.cameraFirmwareVersionCell.detailTextLabel.text = emptyDetailTextLabel;
	self.lensModelIdCell.detailTextLabel.text = emptyDetailTextLabel;
	self.lensFirmwareVersionCell.detailTextLabel.text = emptyDetailTextLabel;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	[camera removeObserver:self forKeyPath:CameraPropertyLensMountStatus];
	[camera removeCameraPropertyDelegate:self];
	_cameraPropertyObserver = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];

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
	
	// 画面操作の準備を開始します。
	__weak SystemViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラ実行モードを保守モードにします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		weakSelf.previousRunMode = camera.runMode;
		if (![camera changeRunMode:OLYCameraRunModeMaintenance error:&error]) {
			// モードを移行できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"Could not start System", nil)];
			return;
		}
		
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateBatteryLevelCell];
			[weakSelf updateLensMountStatusCell];
			[weakSelf updateMediaMountStatusCell];
			[weakSelf updateHardwareInformationCells];
		}];
		
		// 画面表示の準備が完了しました。
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
	
	// 画面操作の後始末を開始します。
	// MARK: weakなselfを使うとshowProgress:whileExecutingBlock:のブロックに到達する前に解放されてしまいます。
	__block SystemViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラ実行モードを以前のモードにします。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera changeRunMode:weakSelf.previousRunMode error:&error]) {
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		
		// 画面操作の後始末が完了しました。
		weakSelf = nil;
		DEBUG_LOG(@"");
	}];
	
	// ビューコントローラーが活動を停止しました。
	self.startingActivity = NO;
}

#pragma mark -

/// キー値監視機構によって呼び出されます。
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	DEBUG_DETAIL_LOG(@"keyPath=%@", keyPath);

	// すでに活動停止している場合や何かの誤りでセレクタが取得できない場合は何もしません。
	if (!self.startingActivity) {
		return;
	}
	SEL selector = (SEL)context;
	if (!selector || ![self respondsToSelector:selector]) {
		return;
	}

	// メインスレッドでイベントハンドラを呼び出します。
	if ([NSThread isMainThread]) {
		[self performSelector:selector withObject:change afterDelay:0];
	} else {
		__weak SystemViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:change afterDelay:0];
		}];
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
		__weak SystemViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf performSelector:selector withObject:nil afterDelay:0];
		}];
	}
}

/// バッテリー残量の値が変わった時に呼び出されます。
- (void)didChangeBatteryLevel {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	[self updateBatteryLevelCell];
}

/// レンズ装着の状態が変わった時に呼び出されます。
- (void)didChangeLensMountStatus:(NSDictionary *)change {
	DEBUG_LOG(@"");
	
	// 画面表示を更新します。
	// レンズファームウェアのバージョンも表示更新するべきですが、ここは手を抜いています。
	[self updateLensMountStatusCell];
}

#pragma mark -

/// バッテリーレベルを表示します。
- (void)updateBatteryLevelCell {
	DEBUG_LOG(@"");
	
	__weak SystemViewController *weakSelf = self;
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラプロパティを取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSString *propertyValue = [camera cameraPropertyValue:CameraPropertyBatteryLevel error:&error];
		if (!propertyValue) {
			// カメラプロパティが取得できませんでした。
			// エラーを無視します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.batteryLevelCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
			}];
			return;
		}
		DEBUG_LOG(@"propertyValue=%@", propertyValue);
		// 取得した値を表示用の文言に変換します。
		NSString *batteryLevel = [camera cameraPropertyValueLocalizedTitle:propertyValue];
		// 表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 表示を更新します。
			weakSelf.batteryLevelCell.detailTextLabel.text = batteryLevel;
		}];
	}];
}

/// レンズ装着の状態表示します。
- (void)updateLensMountStatusCell {
	DEBUG_LOG(@"");

	// プロパティの値を表示用の文言に変換します。
	NSDictionary *titles = @{
		@"normal": NSLocalizedString(@"Mounted", nil),
		@"down": NSLocalizedString(@"Mounted (not-ready)", nil),
		@"nolens": NSLocalizedString(@"No Lens", nil),
		@"cantshoot": NSLocalizedString(@"Error", nil),
	};
	AppCamera *camera = GetAppCamera();
	NSString *lensMountStatusRawValue = camera.lensMountStatus;
	NSString *lensMountStatus = titles[lensMountStatusRawValue];
	if (!lensMountStatus) {
		if ([lensMountStatusRawValue hasPrefix:@"normal"]) {
			// MARK: 装着状態が"normal"では詳細情報が付随している場合があります。
			// "normal+electriczoom"なら、電動ズームレンズを装着
			// "normal+macro"なら、マクロレンズを装着
			// "normal+electriczoom+macro"なら、マクロ機能付の電動ズームレンズを装着
			NSMutableArray *lensMountStatusDetailParts = [[NSMutableArray alloc] initWithCapacity:2];
			if ([lensMountStatusRawValue rangeOfString:@"+electriczoom"].location != NSNotFound) {
				[lensMountStatusDetailParts addObject:NSLocalizedString(@"EZ", nil)];
			}
			if ([lensMountStatusRawValue rangeOfString:@"+macro"].location != NSNotFound) {
				[lensMountStatusDetailParts addObject:NSLocalizedString(@"Macro", nil)];
			}
			NSString *lensMountStatusDetailFormattedText = [lensMountStatusDetailParts componentsJoinedByString:@","];
			lensMountStatus = [NSString stringWithFormat:NSLocalizedString(@"Mounted (%@)", nil), lensMountStatusDetailFormattedText];
		} else {
			lensMountStatus = NSLocalizedString(@"Unknown", nil);
		}
	}
	// 表示を更新します。
	self.lensMountStatusCell.detailTextLabel.text = lensMountStatus;
}

/// メディア装着の状態を表示します。
- (void)updateMediaMountStatusCell {
	DEBUG_LOG(@"");
	
	// プロパティの値を表示用の文言に変換します。
	NSDictionary *titles = @{
		@"normal": NSLocalizedString(@"Mounted", nil),
		@"readonly": NSLocalizedString(@"Mounted (read-only)", nil),
		@"cardfull": NSLocalizedString(@"Mounted (full)", nil),
		@"unmount": NSLocalizedString(@"Unmounted", nil),
		@"error": NSLocalizedString(@"Error", nil),
	};
	AppCamera *camera = GetAppCamera();
	NSString *mediaMountStatus = titles[camera.mediaMountStatus];
	if (!mediaMountStatus) {
		mediaMountStatus = NSLocalizedString(@"Unknown", nil);
	}
	// 表示を更新します。
	self.mediaMountStatusCell.detailTextLabel.text = mediaMountStatus;
}

/// ハードウェア情報を表示します。
- (void)updateHardwareInformationCells {
	DEBUG_LOG(@"");
	
	__weak SystemViewController *weakSelf = self;
	[weakSelf executeAsynchronousBlock:^{
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// ハードウェア情報を取得します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		NSDictionary *hardwareInformation = [camera inquireHardwareInformation:&error];
		if (!hardwareInformation) {
			// ハードウェア情報が取得できませんでした。
			// エラーを無視します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
			weakSelf.cameraModelNameCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
			weakSelf.cameraFirmwareVersionCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
			weakSelf.lensModelIdCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
			weakSelf.lensFirmwareVersionCell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
			return;
		}
		DEBUG_LOG(@"hardwareInformation=%@", hardwareInformation);
		// 取得した値を表示用の文言に変換します。
		NSString *cameraModelName = hardwareInformation[OLYCameraHardwareInformationCameraModelNameKey];
		NSString *cameraFirmwareVersion = hardwareInformation[OLYCameraHardwareInformationCameraFirmwareVersionKey];
		if ([cameraFirmwareVersion isEqualToString:@"----"]) {
			cameraFirmwareVersion = NSLocalizedString(@"Unknown", nil);
		} else if (![cameraFirmwareVersion isEqualToString:@"----"] && cameraFirmwareVersion.length == 4) {
			// MARK: カメラファームウェアのバージョンは、OA.Centralが表示している書式ルールに合わせます。
			// "xyzz"を"x.y.zz"に変換します。
			NSString *majorVersion = [cameraFirmwareVersion substringWithRange:NSMakeRange(0, 1)];
			NSString *minorVersion = [cameraFirmwareVersion substringWithRange:NSMakeRange(1, 1)];
			NSString *buildVersion = [cameraFirmwareVersion substringWithRange:NSMakeRange(2, 2)];
			NSInteger majorVersionNumber = [majorVersion integerValue];
			NSInteger minorVersionNumber = [minorVersion integerValue];
			NSInteger buildVersionNumber = [buildVersion integerValue];
			cameraFirmwareVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)majorVersionNumber, (long)minorVersionNumber, (long)buildVersionNumber];
		} else {
			cameraFirmwareVersion = NSLocalizedString(@"Unknown", nil);
		}
		NSString *lensModelId = hardwareInformation[OLYCameraHardwareInformationLensIdKey];
		if ([lensModelId isEqualToString:@"----"]) {
			lensModelId = NSLocalizedString(@"Unknown", nil);
		} else if ([lensModelId integerValue] > 0) {
			// MARK: レンズIDって何だろう。勝手にレンズの製品型式と解釈しました。
			lensModelId = lensModelId;
		} else {
			lensModelId = NSLocalizedString(@"Unknown", nil);
		}
		NSString *lensFirmwareVersion = hardwareInformation[OLYCameraHardwareInformationLensFirmwareVersionKey];
		if ([lensFirmwareVersion isEqualToString:@"----"]) {
			lensFirmwareVersion = NSLocalizedString(@"Unknown", nil);
		} else if (![lensFirmwareVersion isEqualToString:@"----"] && lensFirmwareVersion.length == 4) {
			// MARK: レンズファームウェアのバージョンは、OA.Centralが表示している書式ルールに合わせます。
			// "xyzz"を"x.y.zz"に変換します。
			NSString *majorVersion = [lensFirmwareVersion substringWithRange:NSMakeRange(0, 1)];
			NSString *minorVersion = [lensFirmwareVersion substringWithRange:NSMakeRange(1, 1)];
			NSString *buildVersion = [lensFirmwareVersion substringWithRange:NSMakeRange(2, 2)];
			NSInteger majorVersionNumber = [majorVersion integerValue];
			NSInteger minorVersionNumber = [minorVersion integerValue];
			NSInteger buildVersionNumber = [buildVersion integerValue];
			lensFirmwareVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)majorVersionNumber, (long)minorVersionNumber, (long)buildVersionNumber];
		} else {
			lensFirmwareVersion = NSLocalizedString(@"Unknown", nil);
		}
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			// 表示を更新します。
			weakSelf.cameraModelNameCell.detailTextLabel.text = cameraModelName;
			weakSelf.cameraFirmwareVersionCell.detailTextLabel.text = cameraFirmwareVersion;
			weakSelf.lensModelIdCell.detailTextLabel.text = lensModelId;
			weakSelf.lensFirmwareVersionCell.detailTextLabel.text = lensFirmwareVersion;
		}];
	}];
}

@end
