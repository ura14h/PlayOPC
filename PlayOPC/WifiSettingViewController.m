//
//  WifiSettingViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2016/07/02.
//  Copyright (c) 2016 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "WifiSettingViewController.h"
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "UIViewController+Alert.h"

@interface WifiSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *wifiSsidText;
@property (weak, nonatomic) IBOutlet UITextField *wifiPassphraseText;

@end

#pragma mark -

@implementation WifiSettingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// 現在のWi-Fi接続の設定値を表示します。
	AppSetting *setting = GetAppSetting();
	self.wifiSsidText.text = setting.wifiSSID;
	self.wifiPassphraseText.text = setting.wifiPassphrase;
	self.doneButton.enabled = NO;
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
	if ([segueIdentifier isEqualToString:@"ShowScanStickerByWifiSetting"]) {
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
	if ([cellReuseIdentifier isEqualToString:@"SSID"]) {
		[self didSelectRowAtSsidCell];
	} else if ([cellReuseIdentifier isEqualToString:@"Passphrase"]) {
		[self didSelectRowAtPassphraseCell];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// キーボードから入力されるたびに呼び出されます。
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	DEBUG_LOG(@"string=%@", string);

	// テキストフィールドを更新します。
	textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];

	// 入力されている値をチェックします。
	BOOL enable = YES;
	if (enable) {
		NSString *ssid = self.wifiSsidText.text;
		NSString* trimed = [ssid stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
		if (trimed.length < 1) {
			enable = FALSE;
		}
	}
	if (enable) {
		NSString *passphrase = self.wifiPassphraseText.text;
		NSString* trimed = [passphrase stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
		if (trimed.length < 1) {
			enable = FALSE;
		}
	}
	self.doneButton.enabled = enable;
	
	return NO; // この処理でテキストフィールドを更新したので、OSの既定処理は実行させません。
}

/// キーボードでリターンキーをタップした時に呼び出されます。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DEBUG_LOG(@"textField=%@", textField);
	
	// フィールドの移動は、
	//   SSID名 -> パスフレーズ -> IPアドレス -> コマンドポート -> イベントポート -> ライブビューストリーミングポート -> キーボードを閉じる
	// です。
	if (textField == self.wifiSsidText) {
		[self.wifiPassphraseText becomeFirstResponder];
	} else if (textField == self.wifiPassphraseText) {
		[self.view endEditing:YES];
	}
	return YES;
}

#pragma mark -

/// 完了ボタンがタップされた時に呼び出されます。
- (IBAction)didTapDoneButton:(UIBarButtonItem *)sender {
	DEBUG_LOG(@"");

	// キーボードを閉じます。
	[self.view endEditing:YES];

	// 現在入力されている値をWi-Fi接続の設定値として保存します。
	NSString *ssid = self.wifiSsidText.text;
	NSString* trimedSsid = [ssid stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	NSString *passphrase = self.wifiPassphraseText.text;
	NSString* trimedPassphrase = [passphrase stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	AppSetting *setting = GetAppSetting();
	setting.wifiSSID = trimedSsid;
	setting.wifiPassphrase = trimedPassphrase;

	AppCamera *camera = GetAppCamera();
	if (camera.connected && camera.connectionType == OLYCameraConnectionTypeWiFi) {
		// 次回の接続から有効です。
		[self showAlertMessage:NSLocalizedString(@"$desc:DelayNewWifiHostSetting", @"WifiSettingViewController.didTapDoneButton") title:NSLocalizedString(@"$title:DelayNewWifiHostSetting", @"WifiSettingViewController.didTapDoneButton") handler:^(UIAlertAction *action) {
			// 前の画面に戻ります。
			[self performSegueWithIdentifier:@"DoneWifiSetting" sender:self];
		}];
	} else {
		// 前の画面に戻ります。
		[self performSegueWithIdentifier:@"DoneWifiSetting" sender:self];
	}
}

/// 'SSID Name'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtSsidCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiSsidText isFirstResponder]) {
		[self.wifiSsidText resignFirstResponder];
	} else {
		[self.wifiSsidText becomeFirstResponder];
	}
}

/// 'Passphrase'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtPassphraseCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiPassphraseText isFirstResponder]) {
		[self.wifiPassphraseText resignFirstResponder];
	} else {
		[self.wifiPassphraseText becomeFirstResponder];
	}
}

@end
