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

#import "ConnectionViewController.h"
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "BluetoothConnector.h"
#import "WifiConnector.h"
#import "UIViewController+Alert.h"
#import "UIViewController+Threading.h"
#import "UITableViewController+Cell.h"
#import "UIImageView+Animation.h"

@interface ConnectionViewController () <OLYCameraConnectionDelegate, CLLocationManagerDelegate>

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

@property (assign, nonatomic) BOOL startingActivity; ///< 画面を表示して活動を開始しているか否か
@property (strong, nonatomic) CLLocationManager *locationManager; ///< 位置情報へアクセスする権限があるか調べるための位置情報マネージャ
@property (strong, nonatomic) BluetoothConnector *bluetoothConnector; ///< Bluetooth接続の監視
@property (strong, nonatomic) WifiConnector *wifiConnector; ///< Wi-Fi接続の監視
@property (strong, nonatomic) NSTimer *wifiConnectorTimer; ///< Wi-Fi接続の監視を定期的に更新させるためのタイマー
@property (strong, nonatomic) NSIndexPath *visibleWhenConnected; ///< アプリ接続が完了した後のスクロール位置
@property (strong, nonatomic) NSIndexPath *visibleWhenDisconnected; ///< アプリ接続の切断が完了した後のスクロール位置
@property (strong, nonatomic) NSIndexPath *visibleWhenSleeped; ///< カメラの電源オフが完了した後のスクロール位置

@end

#pragma mark -

@implementation ConnectionViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューコントローラーの活動状態を初期化します。
	self.startingActivity = NO;
	
	// 現在位置利用の権限確認を準備します。
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
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
	[notificationCenter addObserver:self selector:@selector(didChangeWifiStatus:) name:WifiStatusChangedNotification object:nil];

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
	[notificationCenter removeObserver:self name:WifiStatusChangedNotification object:nil];
	_bluetoothConnector = nil;
	_wifiConnector = nil;
	if (_wifiConnectorTimer) {
		[_wifiConnectorTimer invalidate];
	}
	_wifiConnectorTimer = nil;

	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

	_locationManager.delegate = nil;
	_locationManager = nil;
	
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
	
	if (!self.startingActivity) {
		// MARK: iOS9では初回の画面表示の際にapplicationDidBecomeActiveが呼び出されないのでここでフォローします。
		NSOperatingSystemVersion iOS9 = { 9, 0, 0 };
		if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS9]) {
			DEBUG_LOG(@"The application is running on iOS9!");
			[self applicationDidBecomeActive:nil];
		}
		self.startingActivity = YES;
	}
}

/// アプリケーションがアクティブになる時に呼び出されます。
- (void)applicationDidBecomeActive:(NSNotification *)notification {
	DEBUG_LOG(@"");

	// 写真アルバム利用の権限があるか確認します。
	switch ([PHPhotoLibrary authorizationStatus]) {
		case PHAuthorizationStatusNotDetermined:
			DEBUG_LOG(@"Using assets library isn't determind.");
			[self assetsLibraryRequestWhenInUseAuthorization];
			break;
		case PHAuthorizationStatusAuthorized:
			DEBUG_LOG(@"Using assets library is already authorized.");
			break;
		case PHAuthorizationStatusDenied:
		case PHAuthorizationStatusRestricted:
		case PHAuthorizationStatusLimited:
			DEBUG_LOG(@"Using assets library is restricted.");
			break;
	}
	
	// 現在位置利用の権限があるかを確認します。
	switch (self.locationManager.authorizationStatus) {
		case kCLAuthorizationStatusNotDetermined:
			DEBUG_LOG(@"Using location service isn't determind.");
			[self.locationManager requestWhenInUseAuthorization];
			break;
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			DEBUG_LOG(@"Using location service is already authorized.");
			break;
		case kCLAuthorizationStatusDenied:
		case kCLAuthorizationStatusRestricted:
			DEBUG_LOG(@"Using location service is restricted.");
			break;
	}

	// カメラのWi=Fi設定を更新します。
	AppSetting *setting = GetAppSetting();
	AppCamera *camera = GetAppCamera();
	camera.host = setting.wifiHost;
	camera.commandPort = setting.wifiCommandPort;
	camera.eventPort = setting.wifiEventPort;
	camera.liveViewStreamingPort = setting.wifiLiveViewStreamingPort;
	
	// BluetoothとWi-Fiの接続状態を監視開始します。
	self.bluetoothConnector.peripheral = nil;
	[self.wifiConnector startMonitoring];
	
	// Wi-Fiの接続状態を定期的かつ強制的に更新します。
	//   デバイスがカメラのアクセスポイントに直接接続していないような特殊なネットワーク構成の環境では、
	//   iOSのWi-Fiの状態変化をトリガーにしてカメラの存在を確認しに行くことができないので、
	//   (デバイスのWi-Fiはカメラとは別のアクセスポイントに繋がりっ放しなので、Wi-Fiの状態が変化しない)、
	//   これを力技で解決するために、カメラに接続可能か否かを定期的に確認しかつ強制的に更新します。
	NSTimeInterval wifiConnectorTimerInterval = 15.0; // 15秒間隔
	self.wifiConnectorTimer = [NSTimer scheduledTimerWithTimeInterval:wifiConnectorTimerInterval target:self selector:@selector(didFireWifiConnectorTimer:) userInfo:nil repeats:YES];
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
	[self updateShowWifiSettingCell];
	[self updateCameraConnectionCells];
	[self updateCameraOperationCells];
}

/// アプリケーションが非アクティブになる時に呼び出されます。
- (void)applicationWillResignActive:(NSNotification *)notification {
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
	
	// BluetoothとWi-Fiの接続状態を監視停止します。
	self.bluetoothConnector.peripheral = nil;
	[self.wifiConnector stopMonitoring];
	[self.wifiConnectorTimer invalidate];
	self.wifiConnectorTimer = nil;
	
	// カメラ操作の子画面を表示している場合は、この画面に戻します。
	[self backToConnectionView:NO];
}

/// アプリケーションがバックグラウンドに入る時に呼び出されます。
- (void)applicationDidEnterBackground:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// TODO: このタイミングはカメラ接続を一時停止するために研究の余地があります。
}

/// アプリケーションがフォアグラウンドに入る時に呼び出されます。
- (void)applicationWillEnterForeground:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// TODO: このタイミングはカメラ接続を復旧するために研究の余地があります。
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
	} else if ([segueIdentifier isEqualToString:@"ShowAcknowledgement"]) {
	} else if ([segueIdentifier isEqualToString:@"ShowReference"]) {
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
	} else {
		// 何もしません。
	}
}

/// 現在位置利用の権限が変化した時に呼び出されます。
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
	DEBUG_LOG(@"");
	
	switch (self.locationManager.authorizationStatus) {
		case kCLAuthorizationStatusNotDetermined:
			DEBUG_LOG(@"Using location service isn't determind.");
			break;
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			DEBUG_LOG(@"Using location service is already authorized.");
			break;
		case kCLAuthorizationStatusDenied:
		case kCLAuthorizationStatusRestricted:
			DEBUG_LOG(@"Using location service is restricted.");
			break;
	}
}

/// テーブルビューのセルが選択された時に呼び出されます。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DEBUG_LOG(@"indexPath=%@", indexPath);

	// 選択されたセルが何であったか調べます。
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *cellReuseIdentifier = cell.reuseIdentifier;

	// セルに応じたカメラ操作処理を呼び出します。
	if ([cellReuseIdentifier isEqualToString:@"ShowWifiSetting"]) {
		// iOSの設定画面のWi-Fiセクションを開くことができたら素晴らしいのに。
	} else if ([cellReuseIdentifier isEqualToString:@"ConnectWithUsingBluetooth"]) {
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

/// Wi-Fi接続の監視を強制更新するタイマーがタイムアウトした時に呼び出されます。
- (void)didFireWifiConnectorTimer:(NSTimer *)timer {
	DEBUG_LOG(@"");

	/// 接続状態の監視を更新します。
	[self.wifiConnector pokeMonitoring];
}

#pragma mark -

/// アプリケーション設定が変化した時に呼び出されます。
- (void)didChangedAppSetting:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
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
		if (bluetoothStatus == BluetoothConnectionStatusNotFound ||
			bluetoothStatus == BluetoothConnectionStatusNotConnected) {
			DEBUG_LOG(@"");
			
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
- (void)didChangeWifiStatus:(NSNotification *)notification {
	DEBUG_LOG(@"");

	// メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
	if (![NSThread isMainThread]) {
		__weak ConnectionViewController *weakSelf = self;
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			DEBUG_LOG(@"weakSelf=%p", weakSelf);
			[weakSelf didChangeWifiStatus:notification];
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
	
	// 画面表示を更新します。
	[self updateShowBluetoothSettingCell];
}

/// Wi-Fi接続の設定が変更されたときに呼び出されます。
- (void)didChangeWifiSetting {
	DEBUG_LOG(@"");

	// カメラのWi=Fi設定を更新します。
	AppSetting *setting = GetAppSetting();
	AppCamera *camera = GetAppCamera();
	camera.host = setting.wifiHost;
	camera.commandPort = setting.wifiCommandPort;
	camera.eventPort = setting.wifiEventPort;
	camera.liveViewStreamingPort = setting.wifiLiveViewStreamingPort;
	
	// Wi-Fiの接続状態の監視を再起動します。
	[self.wifiConnector stopMonitoring];
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
	NSString *bluetoothPasscode = setting.bluetoothPasscode;
	if (!bluetoothLocalName || bluetoothLocalName.length == 0) {
		// Bluetoothデバイスの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectBluetoothByEmptySetting", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell") title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
		return;
	}
	
	// カメラへの接続を開始します。
	__weak ConnectionViewController *weakSelf = self;
	weakSelf.bluetoothConnector.services = [OLYCamera bluetoothServices];
	weakSelf.bluetoothConnector.localName = bluetoothLocalName;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);
		
		// カメラを探します。
		NSError *error = nil;
		if (weakSelf.bluetoothConnector.connectionStatus == BluetoothConnectionStatusNotFound) {
			if (![weakSelf.bluetoothConnector discoverPeripheral:&error]) {
				// カメラが見つかりませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
				return;
			}
		}
		
		// カメラにBluetooth接続します。
		if (weakSelf.bluetoothConnector.connectionStatus == BluetoothConnectionStatusNotConnected) {
			if (![weakSelf.bluetoothConnector connectPeripheral:&error]) {
				// カメラにBluetooth接続できませんでした。
				[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectBluetooth", @"ConnectionViewController.didSelectRowAtConnectWithUsingBluetoothCell")];
				return;
			}
		}
		
		// カメラにアプリ接続します。
		// この応答が返ってくるまでやや時間がかかるようです。作者の環境ではiPhone 4Sだと10秒程度かかっています。
		AppCamera *camera = GetAppCamera();
		camera.bluetoothPeripheral = weakSelf.bluetoothConnector.peripheral;
		camera.bluetoothPassword = bluetoothPasscode;
		camera.bluetoothPrepareForRecordingWhenPowerOn = YES;
		if (![camera connect:OLYCameraConnectionTypeBluetoothLE error:&error]) {
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
			weakSelf.bluetoothConnector.peripheral = nil;
			return;
		}

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
		DEBUG_LOG(@"");
	}];
}

/// 'Connect with using Wi-Fi'のセルが選択されたときに呼び出されます。
- (void)didSelectRowAtConnectWithUsingWifiCell {
	DEBUG_LOG(@"");

	// カメラへの接続するのに電源投入も必要か否かを調べます。
	BOOL demandToWakeUpWithUsingBluetooth = NO;
	if (self.wifiConnector.connectionStatus == WifiConnectionStatusConnected) {
		if (self.wifiConnector.cameraStatus == WifiCameraStatusReachable) {
			// Wi-Fi接続済みで接続先はカメラ
		} else if (self.wifiConnector.cameraStatus == WifiCameraStatusUnreachable) {
			// Wi-Fi接続済みで接続先はカメラではないが、切り替えて接続できる見込みあり
			demandToWakeUpWithUsingBluetooth = YES;
		} else {
			// Wi-Fi接続済みで接続先は確認中
			// TODO: どうすればよい?
		}
	} else {
		if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
			// Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり
			demandToWakeUpWithUsingBluetooth = YES;
		} else {
			// Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし
			[self showAlertMessage:NSLocalizedString(@"$desc:NoWifiConnections", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
			return;
		}
	}

	// Bluetoothデバイスの設定を確認します。
	AppSetting *setting = GetAppSetting();
	NSString *bluetoothLocalName = setting.bluetoothLocalName;
	NSString *bluetoothPasscode = setting.bluetoothPasscode;
	if (demandToWakeUpWithUsingBluetooth) {
		if (!bluetoothLocalName || bluetoothLocalName.length == 0) {
			// Bluetoothデバイスの設定が不完全です。
			[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectBluetoothByEmptySetting", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
			return;
		}
	}
	
	// Wi-Fiアクセスポイントの設定を確認します。
	NSString *wifiSSID = setting.wifiSSID;
	NSString *wifiPassphrase = setting.wifiPassphrase;
	if (!wifiSSID || wifiSSID.length == 0) {
		// Wi-Fiアクセスポイントの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectWifiSsidByEmptySetting", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
		return;
	}
	if (!wifiPassphrase || wifiPassphrase.length == 0) {
		// Wi-Fiアクセスポイントの設定が不完全です。
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotConnectWifiPassphraseByEmptySetting", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
	}
	
	// カメラの電源を投入し接続を開始します。
	// 作者の環境ではiPhone 4Sだと電源投入から接続確率まで20秒近くかかっています。
	__weak ConnectionViewController *weakSelf = self;
	weakSelf.bluetoothConnector.services = [OLYCamera bluetoothServices];
	weakSelf.bluetoothConnector.localName = bluetoothLocalName;
	[weakSelf showProgress:YES whileExecutingBlock:^(MBProgressHUD *progressView) {
		DEBUG_LOG(@"weakSelf=%p", weakSelf);

		// カメラに電源投入を試みます。
		if (demandToWakeUpWithUsingBluetooth) {
			// カメラを探します。
			NSError *error = nil;
			if (weakSelf.bluetoothConnector.connectionStatus == BluetoothConnectionStatusNotFound) {
				if (![weakSelf.bluetoothConnector discoverPeripheral:&error]) {
					// カメラが見つかりませんでした。
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
					return;
				}
			}
			
			// カメラにBluetooth接続します。
			if (weakSelf.bluetoothConnector.connectionStatus == BluetoothConnectionStatusNotConnected) {
				if (![weakSelf.bluetoothConnector connectPeripheral:&error]) {
					// カメラにBluetooth接続できませんでした。
					[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
					return;
				}
			}
			
			// カメラの電源を入れます。
			// MARK: カメラ本体のLEDはすぐに電源オン(青)になるが、この応答が返ってくるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
			// 作者の環境ではiPhone 4Sだと10秒程度かかっています。
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
			
			// カメラとのBluetooth接続を解除します。
			// MARK: このタイミングで切断することによって、果たしてWi-FiとBluetoothの電波干渉を避けることができるか?
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラとのBluetooth接続解除に失敗しました。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			weakSelf.bluetoothConnector.peripheral = nil;
			
			// カメラの電源を入れるのに失敗している場合はここで諦めます。
			if (!wokenUp) {
				return;
			}

			// Wi-Fi接続を試みます。
			weakSelf.wifiConnector.SSID = wifiSSID;
			weakSelf.wifiConnector.passphrase = wifiPassphrase;
			if (![weakSelf.wifiConnector connect]) {
				// WiFi接続の試みをキャンセルしました。
				return;
			}

			// カメラにアクセスできるWi-Fi接続が有効になるまで待ちます。
			// MARK: カメラ本体のLEDはすぐに接続中(緑)になるが、iOS側のWi-Fi接続が有効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
			// 作者の環境ではiPhone 4S (iOS 10) だと10秒程度かかっています。
			// 作者の環境ではiPhone 6S (iOS 13.3) だと30秒程度かかっています。
			[weakSelf reportBlockConnectingWifi:progressView];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:ConnectingWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell");
			}];
			if (![weakSelf.wifiConnector waitForConnected:40.0]) {
				// Connecting... を元に戻します。
				[weakSelf executeAsynchronousBlockOnMainThread:^{
					[weakSelf updateShowWifiSettingCell];
				}];
				// Wi-Fi接続が有効になりませんでした。
				if (weakSelf.wifiConnector.connectionStatus != WifiConnectionStatusConnected) {
					// カメラにアクセスできるWi-Fi接続は見つかりませんでした。
					[weakSelf showAlertMessage:NSLocalizedString(@"$desc:CouldNotDiscoverWifiConnection", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				} else {
					// カメラにアクセスできるWi-Fi接続ではありませんでした。(すでに別のアクセスポイントに接続している)
					[weakSelf showAlertMessage:NSLocalizedString(@"$desc:WifiConnectionIsNotCamera", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell") title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
				}
				return;
			}

			// 電源投入が完了しました。
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				progressView.mode = MBProgressHUDModeIndeterminate;
			}];
			DEBUG_LOG(@"To wake the camera up is success.");
		}
		
		// カメラにアプリ接続します。
		AppCamera *camera = GetAppCamera();
		NSError *error = nil;
		if (![camera connect:OLYCameraConnectionTypeWiFi error:&error]) {
			// カメラにアプリ接続できませんでした。
			[weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")];
			return;
		}

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
		
		// アプリ接続が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
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
		OLYCameraConnectionType lastConnectionType = camera.connectionType;
		NSError *error = nil;
		if (![camera disconnectWithPowerOff:NO error:&error]) {
			// カメラのアプリ接続を解除できませんでした。
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		camera.bluetoothPeripheral = nil;
		camera.bluetoothPassword = nil;
		
		// カメラとのBluetooth接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeBluetoothLE) {
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラのBluetooth接続を解除できませんでした。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			weakSelf.bluetoothConnector.peripheral = nil;
		}

		// 画面表示を更新します。
		[weakSelf executeAsynchronousBlockOnMainThread:^{
			[weakSelf updateShowBluetoothSettingCell];
			[weakSelf updateShowWifiSettingCell];
			[weakSelf updateCameraConnectionCells];
			[weakSelf updateCameraOperationCells];
		}];
		
		// カメラの接続解除が完了しました。
		[weakSelf reportBlockFinishedToProgress:progressView];
		DEBUG_LOG(@"");
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
		OLYCameraConnectionType lastConnectionType = camera.connectionType;
		NSError *error = nil;
		if (![camera disconnectWithPowerOff:YES error:&error]) {
			// カメラのアプリ接続を解除できませんでした。
			// エラーを無視して続行します。
			DEBUG_LOG(@"An error occurred, but ignores it.");
		}
		camera.bluetoothPeripheral = nil;
		camera.bluetoothPassword = nil;
		
		// カメラとのBluetooth接続を解除します。
		if (lastConnectionType == OLYCameraConnectionTypeBluetoothLE) {
			if (![weakSelf.bluetoothConnector disconnectPeripheral:&error]) {
				// カメラのBluetooth接続を解除できませんでした。
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			// カメラとのBluetooth接続を解除します。
			weakSelf.bluetoothConnector.peripheral = nil;
		}

		// カメラの電源を切った後にWi-Fi接続が無効(もしくは他SSIDへ再接続)になるまで待ちます。
		if (lastConnectionType == OLYCameraConnectionTypeWiFi) {
			// MARK: カメラ本体のLEDはすぐに消灯するが、iOS側のWi-Fi接続が無効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
			// 作者の環境ではiPhone 4Sだと10秒程度かかっています。
			[weakSelf reportBlockDisconnectingWifi:progressView];
			[weakSelf executeAsynchronousBlockOnMainThread:^{
				weakSelf.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$desc:DisconnectingWifi", @"ConnectionViewController.didSelectRowAtDisconnectAndSleepCell");
			}];
			if ([weakSelf.wifiConnector waitForDisconnected:20.0]) {
				// エラーを無視して続行します。
				DEBUG_LOG(@"An error occurred, but ignores it.");
			}
			
			// Wi-Fiの接続情報を削除します。
			[weakSelf.wifiConnector disconnect];
		}

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

#pragma mark -

/// 写真アルバムの利用してよいか問い合わせます。
- (void)assetsLibraryRequestWhenInUseAuthorization {
	DEBUG_LOG(@"");

	PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
	for (PHAssetCollection *collection in collectionResult) {
		DEBUG_LOG(@"group=%@", collection.localizedTitle);
	}
}

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

/// Bluetooth接続の状態を表示します。
- (void)updateShowBluetoothSettingCell {
	DEBUG_LOG(@"");
	
	AppSetting *setting = GetAppSetting();
	NSString *bluetoothLocalName = setting.bluetoothLocalName;
	if (bluetoothLocalName && bluetoothLocalName.length > 0) {
		BluetoothConnectionStatus bluetoothStatus = self.bluetoothConnector.connectionStatus;
		if (bluetoothStatus == BluetoothConnectionStatusConnected) {
			// 接続されている場合はローカルネームを表示します。
			CBPeripheral *peripheral = self.bluetoothConnector.peripheral;
			self.showBluetoothSettingCell.detailTextLabel.text = peripheral.name;
		} else {
			// 接続されていない場合は未接続と表示します。
			self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNotConnected", @"ConnectionViewController.updateShowBluetoothSettingCell");
		}
	} else {
		// 設定が未構成です。
		self.showBluetoothSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:BluetoothNoConfiguration", @"ConnectionViewController.updateShowBluetoothSettingCell");
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
		WifiConnectionStatus wifiStatus = self.wifiConnector.connectionStatus;
		if (wifiStatus == WifiConnectionStatusConnected) {
			// 接続されている場合はそのSSIDを表示します。
			WifiCameraStatus cameraStatus = self.wifiConnector.cameraStatus;
			if (cameraStatus == WifiCameraStatusReachable) {
				// Wi-Fi接続済みで接続先はカメラ
				if (self.wifiConnector.SSID) {
					self.showWifiSettingCell.detailTextLabel.text = self.wifiConnector.SSID;
				} else {
					self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiConnected(null)", @"ConnectionViewController.updateShowWifiSettingCell");
				}
			} else if (cameraStatus == WifiCameraStatusUnreachable) {
				// Wi-Fi接続済みで接続先はカメラではない
				self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiNotConnected(null)", @"ConnectionViewController.updateShowWifiSettingCell");
			} else {
				// Wi-Fi接続済みで接続先は確認中
				self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiStatusUnknown", @"ConnectionViewController.updateShowWifiSettingCell");
			}
		} else if (wifiStatus == WifiConnectionStatusNotConnected) {
			// 接続されていない場合は未接続と表示します。
			self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiNotConnected", @"ConnectionViewController.updateShowWifiSettingCell");
		} else {
			self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiStatusUnknown", @"ConnectionViewController.updateShowWifiSettingCell");
		}
	} else {
		// 設定が未構成です。
		self.showWifiSettingCell.detailTextLabel.text = NSLocalizedString(@"$cell:WifiNoConfiguration", @"ConnectionViewController.updateShowWifiSettingCell");
	}
}

/// アプリ接続の状態を画面に表示します。
- (void)updateCameraConnectionCells {
	DEBUG_LOG(@"");

	AppCamera *camera = GetAppCamera();
	if (camera.connected && camera.connectionType == OLYCameraConnectionTypeBluetoothLE) {
		// Bluetoothで接続中です。
		[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
		[self tableViewCell:self.disconnectCell enabled:YES];
		[self tableViewCell:self.disconnectAndSleepCell enabled:YES];
		self.connectWithUsingBluetoothCell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.connectWithUsingWiFiCell.accessoryType = UITableViewCellAccessoryNone;
	} else if (camera.connected && camera.connectionType == OLYCameraConnectionTypeWiFi) {
		// Wi-Fiで接続中です。
		[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
		[self tableViewCell:self.disconnectCell enabled:YES];
		[self tableViewCell:self.disconnectAndSleepCell enabled:YES];
		self.connectWithUsingBluetoothCell.accessoryType = UITableViewCellAccessoryNone;
		self.connectWithUsingWiFiCell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		// 未接続です。
		if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
			// Bluetooth使用可
			[self tableViewCell:self.connectWithUsingBluetoothCell enabled:YES];
		} else {
			// Bluetooth使用不可
			[self tableViewCell:self.connectWithUsingBluetoothCell enabled:NO];
		}
		if (self.wifiConnector.connectionStatus == WifiConnectionStatusConnected) {
			if (self.wifiConnector.cameraStatus == WifiCameraStatusReachable) {
				// Wi-Fi接続済みで接続先はカメラ
				[self tableViewCell:self.connectWithUsingWiFiCell enabled:YES];
			} else if (self.wifiConnector.cameraStatus == WifiCameraStatusUnreachable) {
				// Wi-Fi接続済みで接続先はカメラではない
				if (self.bluetoothConnector.connectionStatus != BluetoothConnectionStatusUnknown) {
					// Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
					// だが、カメラの電源を入れることぐらいはできるかもしれない
					[self tableViewCell:self.connectWithUsingWiFiCell enabled:YES];
				} else {
					// Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
					[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
				}
			} else {
				// Wi-Fi接続済みで接続先は確認中
				// カメラにアクセスできるか否かが確定するまでの間は操作を許可しない
				[self tableViewCell:self.connectWithUsingWiFiCell enabled:NO];
			}
		} else {
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
