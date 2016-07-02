//
//  BluetoothSettingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/22.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BluetoothSettingViewController.h"
#import <OLYCameraKit/OACentralConfiguration.h>
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"

@interface BluetoothSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *bluetoothLocalNameText;
@property (weak, nonatomic) IBOutlet UITextField *bluetoothPasscodeText;

@end

#pragma mark -

@implementation BluetoothSettingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// 現在のBluetooth接続の設定値を表示します。
	AppSetting *setting = GetAppSetting();
	self.bluetoothLocalNameText.text = setting.bluetoothLocalName;
	self.bluetoothPasscodeText.text = setting.bluetoothPasscode;
	
	// OA.Centralから接続設定を取得したかを監視します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(didGetAppOACentralConfiguration:) name:AppOACentralConfigurationDidGetNotification object:nil];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	// OA.Centralから接続設定を取得したかの監視を終了します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:AppOACentralConfigurationDidGetNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);
	
	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;

	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"LocalName"]) {
		[self didSelectRowAtLocalNameCell];
	} else if ([cellReuseIdentifier isEqualToString:@"Passcode"]) {
		[self didSelectRowAtPasscodeCell];
	} else if ([cellReuseIdentifier isEqualToString:@"GetFromOacentral"]) {
		[self didSelectRowAtFromOacentralCell];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// キーボードでリターンキーをタップした時に呼び出されます。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DEBUG_LOG(@"textField=%@", textField);

	// フィールドの移動は、
	//   ローカルネーム -> パスコード -> キーボードを閉じる
	// です。
	if (textField == self.bluetoothLocalNameText) {
		[self.bluetoothPasscodeText becomeFirstResponder];
	} else if (textField == self.bluetoothPasscodeText) {
		[self.view endEditing:YES];
	}
	return YES;
}

/// OA.CentralからBluetooth接続の設定を取得した時に呼び出されます。
/// この設定情報はAppDelegateによる通知を経由して届きます。
- (void)didGetAppOACentralConfiguration:(NSNotification *)notification {
	DEBUG_LOG(@"notification=%@", notification);

	// OA.Centralから取得した接続設定を現在のBluetooth接続の設定値に入力します。
	OACentralConfiguration *configuration = notification.userInfo[AppOACentralConfigurationDidGetNotificationUserInfo];
	self.bluetoothLocalNameText.text = configuration.bleName;
	self.bluetoothPasscodeText.text = configuration.bleCode;
}

#pragma mark -

/// 完了ボタンがタップされた時に呼び出されます。
- (IBAction)didTapDoneButton:(UIBarButtonItem *)sender {
	DEBUG_LOG(@"bluetoothLocalNameText.text=%@", self.bluetoothLocalNameText.text);
	DEBUG_LOG(@"bluetoothPasscodeText.text=%@", self.bluetoothPasscodeText.text);
	
	// 現在入力されている値をBluetooth接続の設定値として保存します。
	AppSetting *setting = GetAppSetting();
	setting.bluetoothLocalName = self.bluetoothLocalNameText.text;
	setting.bluetoothPasscode = self.bluetoothPasscodeText.text;

	AppCamera *camera = GetAppCamera();
	if (camera.connected && camera.connectionType == OLYCameraConnectionTypeBluetoothLE) {
		// 次回の接続から有効です。
		[self showAlertMessage:NSLocalizedString(@"$desc:DelayNewBluetoothSetting", @"BluetoothSettingViewController.didTapDoneButton") title:NSLocalizedString(@"$title:DelayNewBluetoothSetting", @"BluetoothSettingViewController.didTapDoneButton") handler:^(UIAlertAction *action) {
			// 前の画面に戻ります。
			[self performSegueWithIdentifier:@"DoneBluetoothSetting" sender:self];
		}];
	} else {
		// 前の画面に戻ります。
		[self performSegueWithIdentifier:@"DoneBluetoothSetting" sender:self];
	}
}

/// 'Local Name'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtLocalNameCell {
	DEBUG_LOG(@"");

	// キーボードを開閉します。
	if ([self.bluetoothLocalNameText isFirstResponder]) {
		[self.bluetoothLocalNameText resignFirstResponder];
	} else {
		[self.bluetoothLocalNameText becomeFirstResponder];
	}
}

/// 'Passcode'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtPasscodeCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.bluetoothPasscodeText isFirstResponder]) {
		[self.bluetoothPasscodeText resignFirstResponder];
	} else {
		[self.bluetoothPasscodeText becomeFirstResponder];
	}
}

/// 'Get From OA.Central'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtFromOacentralCell {
	DEBUG_LOG(@"");

	// キーボードを閉じます。
	[self.view endEditing:YES];
	
	// OA.Centralに接続設定の取得を要求します。
	if (![OACentralConfiguration requestConfigurationURL:AppUrlSchemeGetFromOacentral]) {
		// OA.Centralの呼び出しに失敗しました。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotOpenOACentralByNoInstalled", @"BluetoothSettingViewController.didSelectRowAtFromOacentralCell") title:NSLocalizedString(@"$title:CouldNotOpenOACentral", @"BluetoothSettingViewController.didSelectRowAtFromOacentralCell")];
	}
}

@end
