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
#import "UIViewController+Alert.h"

@interface WifiSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *wifiHostText;
@property (weak, nonatomic) IBOutlet UITextField *wifiCommandPortText;
@property (weak, nonatomic) IBOutlet UITextField *wifiEventPortText;
@property (weak, nonatomic) IBOutlet UITextField *wifiLiveViewStreamingPortText;

@end

#pragma mark -

@implementation WifiSettingViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
    [super viewDidLoad];
    
	// 現在のWi-Fi接続の設定値を表示します。
	AppSetting *setting = GetAppSetting();
	self.wifiHostText.text = setting.wifiHost;
	self.wifiCommandPortText.text = [NSString stringWithFormat:@"%ld", (long)setting.wifiCommandPort];
	self.wifiEventPortText.text = [NSString stringWithFormat:@"%ld", (long)setting.wifiEventPort];
	self.wifiLiveViewStreamingPortText.text = [NSString stringWithFormat:@"%ld", (long)setting.wifiLiveViewStreamingPort];
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

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);
	
	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;
	
	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"Host"]) {
		[self didSelectRowAtHostCell];
	} else if ([cellReuseIdentifier isEqualToString:@"CommandPort"]) {
		[self didSelectRowAtCommandPortCell];
	} else if ([cellReuseIdentifier isEqualToString:@"EventPort"]) {
		[self didSelectRowAtEventPortCell];
	} else if ([cellReuseIdentifier isEqualToString:@"LiveViewStreamingPort"]) {
		[self didSelectRowAtLiveViewStreamingPortCell];
	} else if ([cellReuseIdentifier isEqualToString:@"FactoryPreset"]) {
		[self didSelectRowAtFactoryPresetCell];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// キーボードから入力されるたびに呼び出されます。
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	DEBUG_LOG(@"string=%@", string);
	
	BOOL enable = YES;
	if (enable) {
		NSString *host = self.wifiHostText.text;
		NSString *hostValidationPattern = @"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
		NSRegularExpression *hostValidation = [NSRegularExpression regularExpressionWithPattern:hostValidationPattern options:0 error:nil];
		NSUInteger hostValidationResult = [hostValidation numberOfMatchesInString:host options:0 range:NSMakeRange(0, host.length)];
		if (hostValidationResult != 1) {
			enable = FALSE;
		}
	}
	if (enable) {
		NSInteger port = [self.wifiCommandPortText.text integerValue];
		if (port < 1 || port > 65535) {
			enable = FALSE;
		}
	}
	if (enable) {
		NSInteger port = [self.wifiEventPortText.text integerValue];
		if (port < 1 || port > 65535) {
			enable = FALSE;
		}
	}
	if (enable) {
		NSInteger port = [self.wifiLiveViewStreamingPortText.text integerValue];
		if (port < 1 || port > 65535) {
			enable = FALSE;
		}
	}
	if (enable) {
		NSInteger commandPort = [self.wifiCommandPortText.text integerValue];
		NSInteger eventPort = [self.wifiEventPortText.text integerValue];
		NSInteger streamingPort = [self.wifiLiveViewStreamingPortText.text integerValue];
		if (commandPort == eventPort || eventPort == streamingPort || streamingPort == commandPort) {
			enable = FALSE;
		}
	}
	self.doneButton.enabled = enable;
	
	return YES;
}

/// キーボードでリターンキーをタップした時に呼び出されます。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	DEBUG_LOG(@"textField=%@", textField);
	
	// フィールドの移動は、
	//   IPアドレス -> コマンドポート -> イベントポート -> ライブビューストリーミングポート -> キーボードを閉じる
	// です。
	if (textField == self.wifiHostText) {
		[self.wifiCommandPortText becomeFirstResponder];
	} else if (textField == self.wifiCommandPortText) {
		[self.wifiEventPortText becomeFirstResponder];
	} else if (textField == self.wifiEventPortText) {
		[self.wifiLiveViewStreamingPortText becomeFirstResponder];
	} else if (textField == self.wifiLiveViewStreamingPortText) {
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
	AppSetting *setting = GetAppSetting();
	setting.wifiHost = self.wifiHostText.text;
	setting.wifiCommandPort = [self.wifiCommandPortText.text integerValue];
	setting.wifiEventPort = [self.wifiEventPortText.text integerValue];
	setting.wifiLiveViewStreamingPort = [self.wifiLiveViewStreamingPortText.text integerValue];

	// 前の画面に戻ります。
	[self performSegueWithIdentifier:@"DoneWifiSetting" sender:self];
}

/// 'Host'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtHostCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiHostText isFirstResponder]) {
		[self.wifiHostText resignFirstResponder];
	} else {
		[self.wifiHostText becomeFirstResponder];
	}
}

/// 'Command Port'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtCommandPortCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiCommandPortText isFirstResponder]) {
		[self.wifiCommandPortText resignFirstResponder];
	} else {
		[self.wifiCommandPortText becomeFirstResponder];
	}
}

/// 'Event Port'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtEventPortCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiEventPortText isFirstResponder]) {
		[self.wifiEventPortText resignFirstResponder];
	} else {
		[self.wifiEventPortText becomeFirstResponder];
	}
}

/// 'Live View Streaming Port'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtLiveViewStreamingPortCell {
	DEBUG_LOG(@"");
	
	// キーボードを開閉します。
	if ([self.wifiLiveViewStreamingPortText isFirstResponder]) {
		[self.wifiLiveViewStreamingPortText resignFirstResponder];
	} else {
		[self.wifiLiveViewStreamingPortText becomeFirstResponder];
	}
}

/// 'Factory Preset'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtFactoryPresetCell {
	DEBUG_LOG(@"");
	
	// キーボードを閉じます。
	[self.view endEditing:YES];

	// 設定をデフォルト値に戻します。
	AppSetting *setting = GetAppSetting();
	setting.wifiHost = nil;
	setting.wifiCommandPort = 0;
	setting.wifiEventPort = 0;
	setting.wifiLiveViewStreamingPort = 0;
	
	// 前の画面に戻ります。
	[self performSegueWithIdentifier:@"DoneWifiSetting" sender:self];
}

@end
