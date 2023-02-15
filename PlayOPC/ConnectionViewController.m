//
//  ConnectionViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <NetworkExtension/NetworkExtension.h>
#import "ConnectionViewController.h"
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "BluetoothConnector.h"
#import "WifiConnector.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"
#import "UIImageView+Animation.h"

@interface ConnectionViewController () <OLYCameraConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *showBluetoothSettingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showWifiSettingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *connectWithUsingBluetoothCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *connectWithUsingWiFiCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *disconnectCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *disconnectAndSleepCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showRecordingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showPlaybackCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showSystemCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showCameraLogCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cameraKitVersionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *keepLastCameraSettingCell;
@property (weak, nonatomic) IBOutlet UISwitch *keepLastCameraSettingSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearRememberedCameraSettingCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *applicationVersionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showAcknowledgementCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showReferenceCell;

@property (strong, nonatomic) BluetoothConnector *bluetoothConnector; ///< Bluetooth接続の監視
@property (strong, nonatomic) WifiConnector *wifiConnector; ///< Wi-Fi接続の監視
@property (strong, nonatomic) NSIndexPath *visibleWhenConnected; ///< アプリ接続が完了した後のスクロール位置
@property (strong, nonatomic) NSIndexPath *visibleWhenDisconnected; ///< アプリ接続の切断が完了した後のスクロール位置
@property (strong, nonatomic) NSIndexPath *visibleWhenSleeped; ///< カメラの電源オフが完了した後のスクロール位置
@property (assign, nonatomic) NSUInteger applicationInactives; ///< アプリが非アクティブになった回数

@end

#pragma mark -

@implementation ConnectionViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// アプリケーションの実行状態を監視開始します。
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	// アプリケーション設定の変更を監視準備します。
	[notificationCenter addObserver:self selector:@selector(didChangedAppSetting:) name:AppSettingChangedNotification object:nil];
	
	// BluetoothとWi-Fiの接続状態を監視準備します。
	self.bluetoothConnector = [[BluetoothConnector alloc] init];
	[notificationCenter addObserver:self selector:@selector(didChangeBluetoothConnection:) name:BluetoothConnectionChangedNotification object:nil];
	self.wifiConnector = [[WifiConnector alloc] init];
	[notificationCenter addObserver:self selector:@selector(didChangeWifiConnection:) name:WifiConnectionChangedNotification object:nil];
	
	// カメラの接続状態を監視開始します。
	AppCamera *camera = GetAppCamera();
	[camera addConnectionDelegate:self];
	
	// 画面表示を初期表示します。
	[self updateShowBluetoothSettingCell];
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
	[self updateKeepLastCameraSettingCell];
	[self updateClearRememberedCameraSettingCell];
	
	// カメラキットのバージョン情報を表示します。
#if 0 // ビルド番号も表示する場合はこのブロックを有効にします。
	NSString *cameraKitVersion = [[NSString alloc] initWithFormat:@"%@ (%@)", OLYCameraKitVersion, OLYCameraKitBuildNumber];
#else
	NSString *cameraKitVersion = OLYCameraKitVersion;
#endif
	self.cameraKitVersionCell.detailTextLabel.text = cameraKitVersion;
	
	// アプリケーションのバージョン情報を表示します。
	//   - CFBundleShortVersionStringをバージョン番号として使用します。
	//   - CFBundleVersionをビルド番号として使用します。
	NSDictionary *bundleInfoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *bundleShortVersion = bundleInfoDictionary[@"CFBundleShortVersionString"];
#if 0 // ビルド番号も表示する場合はこのブロックを有効にします。
	NSString *bundleVersion = bundleInfoDictionary[@"CFBundleVersion"];
	NSString *applicationVersion = [[NSString alloc] initWithFormat:@"%@ (%@)", bundleShortVersion, bundleVersion];
#else
	NSString *applicationVersion = bundleShortVersion;
#endif
	self.applicationVersionCell.detailTextLabel.text = applicationVersion;
	
	// それぞれの処理が完了した後のスクロール位置を設定します。
	self.visibleWhenConnected = [NSIndexPath indexPathForRow:0 inSection:2]; // 撮影モードへ
	self.visibleWhenDisconnected = [NSIndexPath indexPathForRow:1 inSection:1]; // アプリ接続へ
	self.visibleWhenSleeped = [NSIndexPath indexPathForRow:0 inSection:1]; // アプリ接続(カメラ電源投入)へ
	
	// アプリが非アクティブになった回数を初期化します。
	self.applicationInactives = 0;
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	[camera removeConnectionDelegate:self];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:AppSettingChangedNotification object:nil];
	[notificationCenter removeObserver:self name:BluetoothConnectionChangedNotification object:nil];
	[notificationCenter removeObserver:self name:WifiConnectionChangedNotification object:nil];
	_bluetoothConnector = nil;
	_wifiConnector = nil;
	
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	
	_visibleWhenConnected = nil;
	_visibleWhenDisconnected = nil;
	_visibleWhenSleeped = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewDidAppear:animated];
	
	// Wi-Fiの接続状態を監視開始します。
	AppSetting *setting = GetAppSetting();
	self.wifiConnector.SSID = setting.wifiSSID;
	self.wifiConnector.passphrase = setting.wifiPassphrase;
	[self.wifiConnector startMonitoring];
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
}

/// アプリケーションがフォアグラウンドに入る時に呼び出されます。
- (void)applicationWillEnterForeground:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// 監視のハンドラ登録をviewDidLoadでしているのでアプリ起動直後の初回は来ない...
	// 何もしません。
}

/// アプリケーションがアクティブになる時に呼び出されます。
- (void)applicationDidBecomeActive:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// 監視のハンドラ登録をviewDidLoadでしているのでアプリ起動直後の初回は来ない...
	// アプリがユーザ対話を開始する時に呼び出されるほかに、
	// OSの許可ダイアログが表示されて消えるとこれが呼び出されてしまう...
	
	// Wi-Fiの接続状態を監視開始します。
	AppSetting *setting = GetAppSetting();
	self.wifiConnector.SSID = setting.wifiSSID;
	self.wifiConnector.passphrase = setting.wifiPassphrase;
	[self.wifiConnector startMonitoring];
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
}

/// アプリケーションが非アクティブになる時に呼び出されます。
- (void)applicationWillResignActive:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// アプリがユーザ対話を終了する時に呼び出されるほかに、
	// OSの許可ダイアログが表示されるとこれが呼び出されてしまう...
	
	// 非アクティブになった数を更新します。
	self.applicationInactives++;
	DEBUG_LOG(@"applicationInactives=%ld", self.applicationInactives);
}

/// アプリケーションがバックグラウンドに入る時に呼び出されます。
- (void)applicationDidEnterBackground:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// 強制的に、カメラとのアプリ接続を解除します。
	AppCamera *camera = GetAppCamera();
	NSError *error = nil;
	if (![camera disconnectWithPowerOff:NO error:&error]) {
		// カメラとのアプリ接続解除に失敗しました。
		// エラーを無視して続行します。
		DEBUG_LOG(@"An error occurred, but ignores it.");
	}
	
	// 強制的に、カメラとのBluetooth接続を解除します。
	camera.bluetoothPeripheral = nil;
	camera.bluetoothPassword = nil;
	if (![self.bluetoothConnector disconnectPeripheral:&error]) {
		// カメラとのBluetooth接続解除に失敗しました。
		// エラーを無視して続行します。
		DEBUG_LOG(@"An error occurred, but ignores it.");
	}
	
	// Wi-Fiの接続状態を監視停止します。
	[self.wifiConnector stopMonitoring];
	
	// カメラ操作の子画面を表示している場合は、この画面に戻します。
	[self backToConnectionView:NO];
}

#pragma mark -

/// セグエを準備する(画面が遷移する)時に呼び出されます。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"ShowBluetoothSetting"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowWifiSetting"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowRecording"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowPlayback"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowSystem"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowCameaLog"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowReference"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowAcknowledgement"]) {
	} else {
		// 何もしません。
	}
}

/// 一番上のビューコントローラーの画面からこのビューコントローラーの画面に戻る時に呼び出されます。
- (IBAction)exitToConnectionViewController:(UIStoryboardSegue *)segue {
	DEBUG_LOG(@"segue=%@", segue);
	
	// セグエに応じた画面遷移の準備処理を呼び出します。
	NSString *segueIdentifier = segue.identifier;
	if ([segueIdentifier isEqualToString:@"DoneBluetoothSetting"]) {
		[self didChangeBluetoothSetting];
	} else if ([segueIdentifier isEqualToString:@"DoneWifiSetting"]) {
		[self didChangeWifiSetting];
	} else if ([segueIdentifier isEqualToString:@"DoneScanSticker"]) {
		[self didChangeBluetoothSetting];
		[self didChangeWifiSetting];
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
	if ([cellReuseIdentifier isEqualToString:@"ConnectWithUsingBluetooth"]) {
		[self didSelectRowAtConnectWithUsingBluetoothCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ConnectWithUsingWifi"]) {
		[self didSelectRowAtConnectWithUsingWifiCell];
	} else if ([cellReuseIdentifier isEqualToString:@"Disconnect"]) {
		[self didSelectRowAtDisconnectCell];
	} else if ([cellReuseIdentifier isEqualToString:@"DisconnectAndSleep"]) {
		[self didSelectRowAtDisconnectAndSleepCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ShowRecording"]) {
		[self didSelectRowAtRecordingCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ShowPlayback"]) {
		[self didSelectRowAtPlaybackCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ShowSystem"]) {
		[self didSelectRowAtSystemCell];
	} else if ([cellReuseIdentifier isEqualToString:@"ClearRememberedCameraSetting"]) {
		[self didSelectRowAtClearRememberedCameraSettingCell];
	} else if ([cellReuseIdentifier isEqualToString:@"OpenSystemSettings"]) {
		[self didSelectRowAtOpenSystemSettingsCell];
	} else {
		// 何もしません。
	}
	
	// セルの選択を解除します。
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/// カメラとのアプリ接続が解除された時に呼び出されます。
- (void)camera:(OLYCamera *)camera disconnectedByError:(NSError *)error {
	DEBUG_LOG(@"");
	
	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf camera:camera disconnectedByError:error];
		}];
		return;
	}
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
	
	// カメラ操作の子画面を表示している場合は、この画面に戻します。
	[self backToConnectionView:YES];
}

#pragma mark -

/// アプリケーション設定が変化した時に呼び出されます。
- (void)didChangedAppSetting:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf didChangedAppSetting:notification];
		}];
		return;
	}
	
	// 画面表示を更新します。
	[self updateClearRememberedCameraSettingCell];
}

/// Bluetooth接続の状態が変化した時に呼び出されます。
- (void)didChangeBluetoothConnection:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf didChangeBluetoothConnection:notification];
		}];
		return;
	}
	
	// MARK: カメラキットはBluetoothの切断を検知しないのでアプリが自主的にカメラとの接続を解除しなければならない。
	AppCamera *camera = GetAppCamera();
	if (camera.connected && camera.connectionType == OLYCameraConnectionTypeBluetoothLE) {
		BluetoothConnectionStatus bluetoothStatus = self.bluetoothConnector.connectionStatus;
		if (bluetoothStatus != BluetoothConnectionStatusConnected) {
			DEBUG_LOG(@"Clean up camera connection");
			
			// カメラとのアプリ接続を解除します。
			NSError *error = nil;
			if (![camera disconnectWithPowerOff:NO error:&error]) {
				// カメラのアプリ接続を解除できませんでした。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			
			// カメラとのBluetooth接続を解除します。
			camera.bluetoothPeripheral = nil;
			camera.bluetoothPassword = nil;
		}
	}
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
	
	// カメラ操作の子画面を表示している場合は、この画面に戻します。
	[self backToConnectionView:YES];
}

/// Wi-Fi接続の状態が変化した時に呼び出されます。
- (void)didChangeWifiConnection:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf didChangeWifiConnection:notification];
		}];
		return;
	}
	
	// 画面表示を更新します。
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
}

/// Bluetooth接続の設定が変更されたときに呼び出されます。
- (void)didChangeBluetoothSetting {
	DEBUG_LOG(@"");
	
	// Bluetoothのペリフェラルキャッシュをクリアします。
	[self.bluetoothConnector clearPeripheralCache];
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
}

/// Wi-Fi接続の設定が変更されたときに呼び出されます。
- (void)didChangeWifiSetting {
	DEBUG_LOG(@"");
	
	// Wi-Fiの接続状態の監視を再起動します。
	[self.wifiConnector stopMonitoring];
	AppSetting *setting = GetAppSetting();
	self.wifiConnector.SSID = setting.wifiSSID;
	self.wifiConnector.passphrase = setting.wifiPassphrase;
	[self.wifiConnector startMonitoring];
	
	// 画面表示を更新します。
	[self updateShowWifiSettingCell];
}

/// 'Connect with using Bluetooth'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtConnectWithUsingBluetoothCell {
	DEBUG_LOG(@"");
	
	// Bluetoothデバイスの設定を確認します。
	AppSetting *setting = GetAppSetting();
	NSString *bluetoothLocalName = setting.bluetoothLocalName;
#if !(TARGET_OS_SIMULATOR)
	NSString *bluetoothPasscode = setting.bluetoothPasscode;
#endif
	if (!bluetoothLocalName || bluetoothLocalName.length == 0) {
		// Bluetoothデバイスの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectBluetoothByEmptyLocalname", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell") title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
		return;
	}
	DEBUG_LOG(@"Bluetooth setting is ok");
	
	// カメラへの接続を開始します。
	__weak ConnectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

#if (TARGET_OS_SIMULATOR)
		// シミュレータではBluetoothは使用できません。
		[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotUseBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell") title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
#else
		// Bluetoothデバイスの使用許可を確認します。
		if ([self.bluetoothConnector reqeustAuthorization] == CBManagerAuthorizationDenied) {
			// Bluetoothデバイスは使用不可です。
			[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotUseBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell") title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
			return;
		}
		DEBUG_LOG(@"Bluetooth is authorized");
		
		// カメラを探します。
		NSError *error = nil;
		weakSelf.bluetoothConnector.services = [OLYCamera bluetoothServices];
		weakSelf.bluetoothConnector.localName = bluetoothLocalName;
		if (weakSelf.bluetoothConnector.connectionStatus != BluetoothConnectionStatusConnected) {
			BOOL discovered = [weakSelf.bluetoothConnector discoverPeripheral:&error];
			if (!discovered) {
				// カメラが見つかりませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
				return;
			}
		}
		DEBUG_LOG(@"Pheripheral is discoverd");
		
		// カメラにBluetooth接続します。
		if (weakSelf.bluetoothConnector.connectionStatus != BluetoothConnectionStatusConnected) {
			BOOL connected = [weakSelf.bluetoothConnector connectPeripheral:&error];
			if (!connected) {
				// カメラにBluetooth接続できませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
				return;
			}
		}
		DEBUG_LOG(@"Pheripheral is connected");
		
		// カメラにアプリ接続します。
		// この応答が返ってくるまでやや時間がかかるようです。
		AppCamera *camera = GetAppCamera();
		camera.bluetoothPeripheral = weakSelf.bluetoothConnector.peripheral;
		camera.bluetoothPassword = bluetoothPasscode;
		camera.bluetoothPrepareForRecordingWhenPowerOn = YES;
		BOOL connected = [camera connect:OLYCameraConnectionTypeBluetoothLE error:&error];
		if (!connected) {
			// カメラにアプリ接続できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
			camera.bluetoothPeripheral = nil;
			camera.bluetoothPassword = nil;
			// カメラとのBluetooth接続を解除します。
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラとのBluetooth接続解除に失敗しました。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			return;
		}
		DEBUG_LOG(@"Camera is connected");
		
		// スマホの現在時刻をカメラに設定します。
		// MARK: 保守モードでは受け付けないのでこのタイミングしかありません。
		if (![camera changeTime:[NSDate date] error:&error]) {
			// 時刻が設定できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
			return;
		}
		
		// MARK: 実行モードがスタンドアロンモードのまま放置するとカメラの自動スリープが働いてしまってスタンドアロンモード以外へ変更できなくなってしまうようです。
		// カメラの自動スリープを防止するため、あらかじめ実行モードをスタンドアロンモード以外に変更しておきます。(取り敢えず保守モードへ)
		if (![camera changeRunMode:OLYCameraRunModeMaintenance error:&error]) {
			// 実行モードを変更できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
			return;
		}
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowBluetoothSettingCell];
			[weakSelf updateCameraConnectionCells];
			[weakSelf updateCameraOperationCells];
			[weakSelf.tableView scrollToRowAtIndexPath:weakSelf.visibleWhenConnected atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		}];
		
		// アプリ接続が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		
		// バッテリーの残量を確認しておきます。
		[weakSelf checkCameraBatteryLevel];
#endif
	}];
}

/// 'Connect with using Wi-Fi'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtConnectWithUsingWifiCell {
	DEBUG_LOG(@"");
	
	// Wi-Fiアクセスポイントの設定を確認します。
	AppSetting *setting = GetAppSetting();
	NSString *wifiSSID = setting.wifiSSID;
	NSString *wifiPassphrase = setting.wifiPassphrase;
	if (!wifiSSID || wifiSSID.length == 0) {
		// Wi-Fiアクセスポイントの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectWifiByEmptySsid", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
		return;
	}
	if (!wifiPassphrase || wifiPassphrase.length == 0) {
		// Wi-Fiアクセスポイントの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectWifiByEmptyPassphrase", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
		return;
	}
	DEBUG_LOG(@"Wi-Fi setting is ok");
	
	// カメラへの接続するのに電源投入も必要か否かを調べます。
	__block BOOL demandToWakeUpWithUsingBluetooth = NO;
#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetoothは使用できません。
#else
	NSString *bluetoothLocalName = setting.bluetoothLocalName;
	NSString *bluetoothPasscode = setting.bluetoothPasscode;
	if (self.wifiConnector.connectionStatus == WifiConnectionStatusConnected) {
		// Wi-Fi接続先はカメラ
	} else {
		// Wi-Fi接続先はカメラではないが切り替えて接続できる見込みあり
		if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
			if (bluetoothLocalName && bluetoothLocalName.length > 0) {
				// Bluetooth経由の電源投入により自動接続できる見込みあり
				demandToWakeUpWithUsingBluetooth = YES;
			}
		}
	}
#endif
	DEBUG_LOG(@"demandToWakeUpWithUsingBluetooth=%ld", (long)demandToWakeUpWithUsingBluetooth);
	
	// カメラの電源を投入し接続を開始します。
	// 作者の環境ではiPhone 4Sだと電源投入から接続確率まで20秒近くかかっています。
	__weak ConnectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
	
#if (TARGET_OS_SIMULATOR)
		// シミュレータではBluetoothとWiFi接続は使用できません。
#else
		NSError *error = nil;

		// Bluetoothデバイスの使用許可を確認します。
		if (demandToWakeUpWithUsingBluetooth) {
			if ([self.bluetoothConnector reqeustAuthorization] == CBManagerAuthorizationDenied) {
				// Bluetoothデバイスは使用不可です。
				demandToWakeUpWithUsingBluetooth = NO;
			}
		}
		DEBUG_LOG(@"demandToWakeUpWithUsingBluetooth=%ld", (long)demandToWakeUpWithUsingBluetooth);

		// カメラに電源投入を試みます。
		if (demandToWakeUpWithUsingBluetooth) {
			DEBUG_LOG(@"Started power on sequence");

			// カメラを探します。
			weakSelf.bluetoothConnector.services = [OLYCamera bluetoothServices];
			weakSelf.bluetoothConnector.localName = bluetoothLocalName;
			if (weakSelf.bluetoothConnector.connectionStatus != BluetoothConnectionStatusConnected) {
				BOOL discovered = [weakSelf.bluetoothConnector discoverPeripheral:&error];
				if (!discovered) {
					// カメラが見つかりませんでした。
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
					return;
				}
			}
			DEBUG_LOG(@"Pheripheral is discoverd");
			
			// カメラにBluetooth接続します。
			if (weakSelf.bluetoothConnector.connectionStatus != BluetoothConnectionStatusConnected) {
				BOOL connected = [weakSelf.bluetoothConnector connectPeripheral:&error];
				if (!connected) {
					// カメラにBluetooth接続できませんでした。
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
					return;
				}
			}
			DEBUG_LOG(@"Pheripheral is connected");
			
			// カメラの電源を入れます。
			// MARK: カメラ本体のLEDはすぐに電源オン(青)になるが、この応答が返ってくるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
			// MARK: カメラがUSB経由で給電中だと、wekeupメソッドはタイムアウトエラーが時々発生してしまうようです。
			[weakSelf reportBlockWakingUp:progressView];
			AppCamera *camera = GetAppCamera();
			camera.bluetoothPeripheral = weakSelf.bluetoothConnector.peripheral;
			camera.bluetoothPassword = bluetoothPasscode;
			camera.bluetoothPrepareForRecordingWhenPowerOn = YES;
			BOOL wokenUp = [camera wakeup:&error];
			if (!wokenUp) {
				// カメラの電源を入れるのに失敗しました。
				if ([error.domain isEqualToString:OLYCameraErrorDomain] && error.code == OLYCameraErrorOperationAborted) {
					// MARK: カメラをUSB給電中に電源入れるとその後にWi-Fi接続できるようになるのにもかかわらずエラーが返ってくるようです。
					//     Error {
					//         Domain = OLYCameraErrorDomain
					//         Code = 195887114 (OLYCameraErrorOperationAborted)
					//         UserInfo = { NSLocalizedDescription=The camera did not respond in time. }
					//     }
					// エラーにすると使い勝手が悪いので、無視して続行します。
					DEBUG_LOG(@"An error occurred, but ignores it.");
					wokenUp = YES;
				} else {
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				}
			}
			camera.bluetoothPeripheral = nil;
			camera.bluetoothPassword = nil;
			DEBUG_LOG(@"Camera is woke up");
			
			// カメラとのBluetooth接続を解除します。
			// MARK: このタイミングで切断することによって、果たしてWi-FiとBluetoothの電波干渉を避けることができるか?
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラとのBluetooth接続解除に失敗しました。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			DEBUG_LOG(@"Pheripheral is disconnected");
			
			// カメラの電源を入れるのに失敗している場合はここで諦めます。
			if (!wokenUp) {
				return;
			}
			
			DEBUG_LOG(@"Finished power on sequence");
		}
		
		// カメラにWi-Fi接続を試みます。
		{
			DEBUG_LOG(@"Started join sequence");
			
			// Wi-Fi接続を試みます。
			// MARK: カメラ本体のLEDはすぐに接続中(緑)になるが、iOS側のWi-Fi接続が有効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
			[weakSelf reportBlockConnectingWifi:progressView];
			weakSelf.wifiConnector.SSID = wifiSSID;
			weakSelf.wifiConnector.passphrase = wifiPassphrase;
			BOOL joined = [weakSelf.wifiConnector connectHotspot:&error];
			if (!joined) {
				if (error == nil) {
					// WiFi接続の試みをキャンセルしました。
				} else {
					// WiFi接続のパラメータに誤りがあるかもしれません。
					NSString *message = error.localizedDescription;
					if ([error.domain isEqualToString:NEHotspotConfigurationErrorDomain]) {
						// WiFi接続失敗のエラーにはおかしいメッセージ("<unknown>")が入っているので、別途用意したメッセージで差し替えて表示します。
						message = NSLocalizedString(@"$desc:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell");
					}
					[weakSelf showAlertMessage:message title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				}
				// 念のため、カメラとのWiFi接続を解除します。
				[weakSelf.wifiConnector disconnectHotspot:nil];
				return;
			}
			
			// Wi-Fi接続が完了しました。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				progressView.mode = MBProgressHUDModeIndeterminate;
			}];

			DEBUG_LOG(@"Finished join sequence");
		}
#endif
		
		// カメラにアプリ接続します。
		{
			DEBUG_LOG(@"Started connect sequence");
			
			AppCamera *camera = GetAppCamera();
			NSError *error = nil;
			NSTimeInterval reachTimeout = self.wifiConnector.timeout;
			NSDate *reachStartTime = [NSDate date];
			NSUInteger countBefore = self.applicationInactives;
			BOOL reached = [camera canConnect:OLYCameraConnectionTypeWiFi timeout:reachTimeout error:&error];
			NSUInteger countAfter = self.applicationInactives;
			NSDate *reachEndTime = [NSDate date];
			if (!reached) {
				// カメラにアプリ接続できませんでした。
				// 指定したタイムアウト時間よりも早く復帰している場合はローカルネットワークの使用が不許可の可能性があります。
				// アプリが非アクティブになった回数が増えている場合はローカルネットワークの使用許可ダイアログが表示された可能性もあります。
				NSString *message;
				NSTimeInterval timeToReach = [reachEndTime timeIntervalSinceDate:reachStartTime];
				if (error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut &&
					(timeToReach < reachTimeout || countBefore != countAfter)) {
					message = NSLocalizedString(@"$desc:CouldNotConnectCamera", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell");
				} else {
					message = error.localizedDescription;
				}
				[weakSelf showAlertMessage:message title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				// 念のため、カメラとのWiFi接続を解除します。
				[weakSelf.wifiConnector disconnectHotspot:nil];
				return;
			}
			BOOL connected = [camera connect:OLYCameraConnectionTypeWiFi error:&error];
			if (!connected) {
				// カメラにアプリ接続できませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				// 念のため、カメラとのWiFi接続を解除します。
				[weakSelf.wifiConnector disconnectHotspot:nil];
				return;
			}
			DEBUG_LOG(@"Camera is connected");

			// スマホの現在時刻をカメラに設定します。
			// MARK: 保守モードでは受け付けないのでこのタイミングしかありません。
			if (![camera changeTime:[NSDate date] error:&error]) {
				// 時刻が設定できませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				return;
			}
			
			// MARK: 実行モードがスタンドアロンモードのまま放置するとカメラの自動スリープが働いてしまってスタンドアロンモード以外へ変更できなくなってしまうようです。
			// カメラの自動スリープを防止するため、あらかじめ実行モードをスタンドアロンモード以外に変更しておきます。(取り敢えず保守モードへ)
			if (![camera changeRunMode:OLYCameraRunModeMaintenance error:&error]) {
				// 実行モードを変更できませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				return;
			}
			
			// 画面表示を更新します。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				[weakSelf updateShowWifiSettingCell];
				[weakSelf updateCameraConnectionCells];
				[weakSelf updateCameraOperationCells];
				[weakSelf.tableView scrollToRowAtIndexPath:weakSelf.visibleWhenConnected atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			}];

			DEBUG_LOG(@"Finished connect sequence");
		}
		
		// アプリ接続が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		
		// バッテリーの残量を確認しておきます。
		[weakSelf checkCameraBatteryLevel];
	}];
}

/// 'Disconnect'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtDisconnectCell {
	DEBUG_LOG(@"");
	
	// カメラの接続解除を開始します。
	__weak ConnectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf.tableView scrollToRowAtIndexPath:weakSelf.visibleWhenDisconnected atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		}];
		
		// カメラとのアプリ接続を解除します。
		AppCamera *camera = GetAppCamera();
#if !(TARGET_OS_SIMULATOR)
		OLYCameraConnectionType lastConnectionType = camera.connectionType;
#endif
		NSError *error = nil;
		if (![camera disconnectWithPowerOff:NO error:&error]) {
			// カメラのアプリ接続を解除できませんでした。
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		camera.bluetoothPeripheral = nil;
		camera.bluetoothPassword = nil;

#if (TARGET_OS_SIMULATOR)
		// シミュレータではBluetoothとWiFi切断は使用できません。
#else
		// カメラとのBluetooth接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeBluetoothLE) {
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラのBluetooth接続を解除できませんでした。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// カメラとのWiFi接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeWiFi) {
			// カメラとのWiFi接続を解除します。
			[weakSelf reportBlockDisconnectingWifi:progressView];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$desc:DisconnectingWifi", @"ConnectionViewController.didSelectRowAtDisconnectCell");
			}];
			[weakSelf.wifiConnector disconnectHotspot:nil];
		}
#endif
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowBluetoothSettingCell];
			[weakSelf updateShowWifiSettingCell];
			[weakSelf updateCameraConnectionCells];
			[weakSelf updateCameraOperationCells];
		}];
		
		// カメラの接続解除が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
	}];
}

/// 'Disconnect and Sleep'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtDisconnectAndSleepCell {
	DEBUG_LOG(@"");
	
	// カメラの接続解除を開始します。
	__weak ConnectionViewController *weakSelf = self;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf.tableView scrollToRowAtIndexPath:weakSelf.visibleWhenSleeped atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		}];
		
		// カメラとのアプリ接続を解除し電源を切ります。
		AppCamera *camera = GetAppCamera();
#if !(TARGET_OS_SIMULATOR)
		OLYCameraConnectionType lastConnectionType = camera.connectionType;
#endif
		NSError *error = nil;
		if (![camera disconnectWithPowerOff:YES error:&error]) {
			// カメラのアプリ接続を解除できませんでした。
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		camera.bluetoothPeripheral = nil;
		camera.bluetoothPassword = nil;
		
#if (TARGET_OS_SIMULATOR)
		// シミュレータではBluetoothとWiFi切断は使用できません。
#else
		// カメラとのBluetooth接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeBluetoothLE) {
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラのBluetooth接続を解除できませんでした。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
		}
		
		// カメラとのWiFi接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeWiFi) {
			// カメラとのWiFi接続を解除します。
			[weakSelf reportBlockDisconnectingWifi:progressView];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$desc:DisconnectingWifi", @"ConnectionViewController.didSelectRowAtDisconnectAndSleepCell");
			}];
			[weakSelf.wifiConnector disconnectHotspot:nil];
		}
#endif
		
		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowBluetoothSettingCell];
			[weakSelf updateShowWifiSettingCell];
			[weakSelf updateCameraConnectionCells];
			[weakSelf updateCameraOperationCells];
		}];
		
		// カメラの接続解除が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
	}];
}

/// 'Recording'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtRecordingCell {
	DEBUG_LOG(@"");
	
	// 分割されたストーリーボードから読み込んで画面遷移します。
	UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"Recording" bundle:nil];
	UIViewController *viewController = [storybard instantiateInitialViewController];
	[self.navigationController pushViewController:viewController animated:YES];
}

/// 'Playback'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtPlaybackCell {
	DEBUG_LOG(@"");
	
	// 分割されたストーリーボードから読み込んで画面遷移します。
	UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"Playback" bundle:nil];
	UIViewController *viewController = [storybard instantiateInitialViewController];
	[self.navigationController pushViewController:viewController animated:YES];
}

/// 'System'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtSystemCell {
	DEBUG_LOG(@"");
	
	// 分割されたストーリーボードから読み込んで画面遷移します。
	UIStoryboard *storybard = [UIStoryboard storyboardWithName:@"System" bundle:nil];
	UIViewController *viewController = [storybard instantiateInitialViewController];
	[self.navigationController pushViewController:viewController animated:YES];
}

/// 'Keep Last Camera Setting'のセルのスイッチ状態が変化した時に呼び出されます。
- (IBAction)didChangeKeepLastCameraSettingSwitchState:(id)sender {
	DEBUG_LOG(@"on=%@", self.keepLastCameraSettingSwitch.on ? @"YES" : @"NO");
	
	// 現在選択された値を設定値として保存します。
	AppSetting *setting = GetAppSetting();
	setting.keepLastCameraSetting = self.keepLastCameraSettingSwitch.on;
}

/// 'Clear Remembered Camera Setting'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtClearRememberedCameraSettingCell {
	DEBUG_LOG(@"");
	
	UIAlertControllerStyle style = UIAlertControllerStyleActionSheet;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
	alertController.popoverPresentationController.sourceView = self.view;
	alertController.popoverPresentationController.sourceRect = self.clearRememberedCameraSettingCell.frame;
	
	{
		NSString *title = NSLocalizedString(@"$title:ExecuteClearCameraSetting", @"ConnectionViewController.didSelectRowAtClearRememberedCameraSettingCell");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
			// 記憶している前回のカメラ設定をクリアします。
			// MARK: 画面表示の更新はユーザー設定値の監視から呼び出されるのでここでは更新しません。
			AppSetting *setting = GetAppSetting();
			setting.latestSnapshotOfCameraSetting = nil;
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:handler];
		[alertController addAction:action];
	}
	{
		NSString *title = NSLocalizedString(@"$title:CancelClearCameraSetting", @"ConnectionViewController.didSelectRowAtClearRememberedCameraSettingCell");
		void (^handler)(UIAlertAction *action) = ^(UIAlertAction *action) {
		};
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:handler];
		[alertController addAction:action];
	}
	
	[self presentViewController:alertController animated:YES completion:nil];
}

/// 'Open System Settings'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtOpenSystemSettingsCell {
	DEBUG_LOG(@"");

	// 設定アプリを開きます。
	NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
	[GetApp() openURL:url options:@{} completionHandler:nil];
}

#pragma mark -

/// カメラ操作の子画面を表示している場合は、この画面に戻します。
- (void)backToConnectionView:(BOOL)animated {
	DEBUG_LOG(@"animated=%@", (animated ? @"YES" : @"NO"));
	
	// この画面が一番上に表示されている場合は画面遷移は必要ありません。
	if (self.navigationController.topViewController == self) {
		DEBUG_LOG(@"This view controller is already top.");
		return;
	}
	
	// 画面のスタックに対象となるカメラ操作の子画面がいるかどうか検索します。
	BOOL requirePopToConnectionView = NO;
	NSArray *targetRestorationIdentifiers = @[
		@"RecordingViewController",
		@"PlaybackViewController",
		@"SystemViewController",
	];
	for (UIViewController *controller in self.navigationController.viewControllers) {
		NSString *restorationIdentifier = controller.restorationIdentifier;
		if ([targetRestorationIdentifiers containsObject:restorationIdentifier]) {
			requirePopToConnectionView = YES;
			break;
		}
	}
	
	// カメラ操作の子画面を含んでいた場合は、この画面に戻します。
	if (!requirePopToConnectionView) {
		DEBUG_LOG(@"The stack does not include the view controller which can return to the root view controller.");
		return;
	}
	if (animated) {
		// 複数の画面遷移アニメーションが同時開始しないように順番を制御する必要がありそう。
		// 前画面に戻るアニメーションがありの場合は、ここに到達するまでにメインスレッドのディスパッチキューに溜まって
		// しまっていた処理を全て実行してから、この画面に戻すようにします。
		// この対策をしておかないと、前画面に戻るアニメーションとアラートビューの表示アニメーションの開始タイミングが
		// ぶつかったりした時に、なぜかナビゲーションビューの子画面が真っ黒になったりして色々と怪しいです。
		// 原因をきちんと調査しきれなかったので、このバージョンではひとまずここまでです。
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf hideProgress:YES];
			[weakSelf.navigationController popToViewController:weakSelf animated:YES];
		}];
	} else {
		[self hideProgress:NO];
		[self.navigationController popToViewController:self animated:NO];
	}
}

/// カメラのバッテリーを確認します。
- (void)checkCameraBatteryLevel {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	if (!camera.connected) {
		return;
	}
	NSString *propertyValue = [camera cameraPropertyValue:CameraPropertyBatteryLevel error:nil];
	if (!propertyValue) {
		return;
	}
	DEBUG_LOG(@"propertyValue=%@", propertyValue);
	NSArray *okValues = @[
		CameraPropertyValueBatteryLevelUnknown,
		CameraPropertyValueBatteryLevelCharge,
		// CameraPropertyValueBatteryLevelEmpty,
		// CameraPropertyValueBatteryLevelWarning,
		// CameraPropertyValueBatteryLevelLow,
		CameraPropertyValueBatteryLevelFull,
		// CameraPropertyValueBatteryLevelEmptyAc,
		// CameraPropertyValueBatteryLevelSupplyWarning,
		CameraPropertyValueBatteryLevelSupplyLow,
		CameraPropertyValueBatteryLevelSupplyFull,
	];
	if ([okValues containsObject:propertyValue]) {
		return;
	}

	[self showAlertMessage:NSLocalizedString(@"$desc:CameraLowBattery", @"ConnectionViewController.checkCameraBatteryLevel") title:NSLocalizedString(@"$title:CameraLowBattery", @"ConnectionViewController.checkCameraBatteryLevel")];
}

/// Bluetooth接続の状態を表示します。
- (void)updateShowBluetoothSettingCell {
	DEBUG_LOG(@"");
	
	AppSetting *setting = GetAppSetting();
	NSString *bluetoothLocalName = setting.bluetoothLocalName;
	if (bluetoothLocalName && bluetoothLocalName.length > 0) {
#if (TARGET_OS_SIMULATOR)
		// シミュレータでは未接続を表示します。
		self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNotConnected", @"ConnectionViewController.updateShowBluetoothSettingCell");
#else
		BluetoothConnectionStatus status = self.bluetoothConnector.connectionStatus;
		if (status == BluetoothConnectionStatusConnected) {
			// 接続されている場合はローカルネームを表示します。
			CBPeripheral *peripheral = self.bluetoothConnector.peripheral;
			self.showBluetoothSettingCell.detailTextLabel.text = peripheral.name;
		} else if (status == BluetoothConnectionStatusNotNotAuthorized) {
			// Bluetoothは利用不可です。
			self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNotAuthorized", @"ConnectionViewController.updateShowBluetoothSettingCell");
		} else {
			// 接続されていない場合は未接続と表示します。
			self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNotConnected", @"ConnectionViewController.updateShowBluetoothSettingCell");
		}
#endif
		self.showBluetoothSettingCell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
	} else {
		// 設定が未構成です。
		self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNoConfiguration", @"ConnectionViewController.updateShowBluetoothSettingCell");
		self.showBluetoothSettingCell.detailTextLabel.textColor = [UIColor systemRedColor];
	}
}

/// Wi-Fi接続の状態を表示します。
- (void)updateShowWifiSettingCell {
	DEBUG_LOG(@"");
	
	AppSetting *setting = GetAppSetting();
	NSString *wifiSSID = setting.wifiSSID;
	NSString *wifiPassphrase = setting.wifiPassphrase;
	if (wifiSSID && wifiSSID.length > 0 &&
		wifiPassphrase && wifiPassphrase.length > 0) {
#if (TARGET_OS_SIMULATOR)
		// シミュレータでは設定値を表示します。
		AppSetting *setting = GetAppSetting();
		NSString *ssid = setting.wifiSSID;
		self.showWifiSettingCell.detailTextLabel.text = ssid;
#else
		WifiConnectionStatus status = self.wifiConnector.connectionStatus;
		if (status == WifiConnectionStatusConnected) {
			// 接続先がカメラの場合はそのSSIDを表示します。
			self.showWifiSettingCell.detailTextLabel.text = self.wifiConnector.SSID;
		} else if (status == WifiConnectionStatusConnectedOther) {
			// 接続先はカメラ以外の場合はその他と表示します。
			self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiConnectedOther", @"ConnectionViewController.updateShowWifiSettingCell");
		} else if (status == WifiConnectionStatusNotConnected) {
			// 接続されていない場合は未接続と表示します。
			self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiNotConnected", @"ConnectionViewController.updateShowWifiSettingCell");
		} else {
			self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiStatusUnknown", @"ConnectionViewController.updateShowWifiSettingCell");
		}
#endif
		self.showWifiSettingCell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
	} else {
		// 設定が未構成です。
		self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiNoConfiguration", @"ConnectionViewController.updateShowWifiSettingCell");
		self.showWifiSettingCell.detailTextLabel.textColor = [UIColor systemRedColor];
	}
}

/// アプリ接続の状態を画面に表示します。
- (void)updateCameraConnectionCells {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	if (camera.connected && camera.connectionType == OLYCameraConnectionTypeBluetoothLE) {
		// Bluetoothで接続中です。
		[self tableViewCell:self.showBluetoothSettingCell enabled:NO];
		[self tableViewCell:self.showWifiSettingCell enabled:NO];
		[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
		[self tableViewCell:self.disconnectCell enabled:YES];
		[self tableViewCell:self.disconnectAndSleepCell enabled:YES];
		self.connectWithUsingBluetoothCell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.connectWithUsingWiFiCell.accessoryType = UITableViewCellAccessoryNone;
	} else if (camera.connected && camera.connectionType == OLYCameraConnectionTypeWiFi) {
		// Wi-Fiで接続中です。
		[self tableViewCell:self.showBluetoothSettingCell enabled:NO];
		[self tableViewCell:self.showWifiSettingCell enabled:NO];
		[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
		[self tableViewCell:self.disconnectCell enabled:YES];
		[self tableViewCell:self.disconnectAndSleepCell enabled:YES];
		self.connectWithUsingBluetoothCell.accessoryType = UITableViewCellAccessoryNone;
		self.connectWithUsingWiFiCell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		// 未接続です。
		[self tableViewCell:self.showBluetoothSettingCell enabled:YES];
		[self tableViewCell:self.showWifiSettingCell enabled:YES];
		if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
			// Bluetooth使用可
			[self tableViewCell:self.connectWithUsingBluetoothCell enabled:YES];
		} else {
			// Bluetooth使用不可
			[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		}
		if (self.wifiConnector.connectionStatus == WifiConnectionStatusConnected) {
			// Wi-Fi接続先はカメラ
			[self tableViewCell:self.connectWithUsingWiFiCell enabled:YES];
		} else {
			// Wi-Fi接続先はカメラではないが切り替えて接続できる見込みあり
			if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
				// Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり
				[self tableViewCell:self.connectWithUsingWiFiCell enabled:YES];
			} else {
				// Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし
				[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
			}
		}
		[self tableViewCell:self.disconnectCell enabled:NO];
		[self tableViewCell:self.disconnectAndSleepCell enabled:NO];
		self.connectWithUsingBluetoothCell.accessoryType = UITableViewCellAccessoryNone;
		self.connectWithUsingWiFiCell.accessoryType = UITableViewCellAccessoryNone;
	}
}

/// カメラ操作の状態を画面に表示します。
- (void)updateCameraOperationCells {
	DEBUG_LOG(@"");
	
	AppCamera *camera = GetAppCamera();
	if (camera.connected) {
		// 接続中です。
		[self tableViewCell:self.showRecordingCell enabled:YES];
		[self tableViewCell:self.showPlaybackCell enabled:YES];
		[self tableViewCell:self.showSystemCell enabled:YES];
	} else {
		// 未接続です。
		[self tableViewCell:self.showRecordingCell enabled:NO];
		[self tableViewCell:self.showPlaybackCell enabled:NO];
		[self tableViewCell:self.showSystemCell enabled:NO];
	}
}

- (void)updateKeepLastCameraSettingCell {
	DEBUG_LOG(@"");
	
	// 設定値をスイッチの状態に反映します。
	AppSetting *setting = GetAppSetting();
	self.keepLastCameraSettingSwitch.on = setting.keepLastCameraSetting;
}

- (void)updateClearRememberedCameraSettingCell {
	DEBUG_LOG(@"");
	
	AppSetting *setting = GetAppSetting();
	if (setting.latestSnapshotOfCameraSetting) {
		// 記憶している前回のカメラ設定があります。
		[self tableViewCell:self.clearRememberedCameraSettingCell enabled:YES];
	} else {
		// 記憶している前回のカメラ設定はありません。
		[self tableViewCell:self.clearRememberedCameraSettingCell enabled:NO];
	}
}

/// 進捗画面に電源投入中を報告します。
- (void)reportBlockWakingUp:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		NSArray *images = @[
			[UIImage imageNamed:@"Progress-Power-10"],
			[UIImage imageNamed:@"Progress-Power-20"],
			[UIImage imageNamed:@"Progress-Power-30"],
			[UIImage imageNamed:@"Progress-Power-40"],
			[UIImage imageNamed:@"Progress-Power-50"],
			[UIImage imageNamed:@"Progress-Power-60"],
			[UIImage imageNamed:@"Progress-Power-70"],
			[UIImage imageNamed:@"Progress-Power-80"],
			[UIImage imageNamed:@"Progress-Power-90"],
			[UIImage imageNamed:@"Progress-Power-100"],
			[UIImage imageNamed:@"Progress-Power-70"],
			[UIImage imageNamed:@"Progress-Power-40"],
		];
		UIImageView *progressImageView;
		progressImageView = [[UIImageView alloc] initWithImage:images[0]];
		progressImageView.tintColor = [UIColor labelColor];
		[progressImageView setAnimationTemplateImages:images];
		progressImageView.animationDuration = 1.0;
		progressImageView.alpha = 0.75;
		
		progress.customView = progressImageView;
		progress.mode = MBProgressHUDModeCustomView;
		
		[progressImageView startAnimating];
	});
}

/// 進捗画面にWi-Fi接続中を報告します。
- (void)reportBlockConnectingWifi:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		NSArray *images = @[
			[UIImage imageNamed:@"Progress-Wifi-25"],
			[UIImage imageNamed:@"Progress-Wifi-50"],
			[UIImage imageNamed:@"Progress-Wifi-75"],
			[UIImage imageNamed:@"Progress-Wifi-100"],
		];
		UIImageView *progressImageView;
		progressImageView = [[UIImageView alloc] initWithImage:images[0]];
		progressImageView.tintColor = [UIColor labelColor];
		[progressImageView setAnimationTemplateImages:images];
		progressImageView.animationDuration = 1.0;
		progressImageView.alpha = 0.75;
		
		progress.customView = progressImageView;
		progress.mode = MBProgressHUDModeCustomView;
		
		[progressImageView startAnimating];
	});
}

/// 進捗画面にWi-Fi切断中を報告します。
- (void)reportBlockDisconnectingWifi:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		NSArray *images = @[
			[UIImage imageNamed:@"Progress-Wifi-100"],
			[UIImage imageNamed:@"Progress-Wifi-75"],
			[UIImage imageNamed:@"Progress-Wifi-50"],
			[UIImage imageNamed:@"Progress-Wifi-25"],
		];
		UIImageView *progressImageView;
		progressImageView = [[UIImageView alloc] initWithImage:images[0]];
		progressImageView.tintColor = [UIColor labelColor];
		[progressImageView setAnimationTemplateImages:images];
		progressImageView.animationDuration = 1.0;
		progressImageView.alpha = 0.75;
		
		progress.customView = progressImageView;
		progress.mode = MBProgressHUDModeCustomView;
		
		[progressImageView startAnimating];
	});
}

/// 進捗画面に処理完了を報告します。
- (void)reportBlockFinishedToProgress:(MBProgressHUD *)progress {
	DEBUG_LOG(@"");
	
	__block UIImageView *progressImageView;
	dispatch_sync(dispatch_get_main_queue(), ^{
		UIImage *image = [UIImage imageNamed:@"Progress-Checkmark"];
		progressImageView = [[UIImageView alloc] initWithImage:image];
		progressImageView.tintColor = [UIColor labelColor];
		progress.customView = progressImageView;
		progress.mode = MBProgressHUDModeCustomView;
	});
	[NSThread sleepForTimeInterval:0.5];
}

@end
