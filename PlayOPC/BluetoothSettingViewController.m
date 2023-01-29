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
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowScanStickerByBluetoothSetting"]) {
		// TODO:
	} else {
		// 何もしません。
	}
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

@end
