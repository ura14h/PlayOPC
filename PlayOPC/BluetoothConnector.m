//
//  BluetoothConnector.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/29.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BluetoothConnector.h"

NSString *const BluetoothConnectionChangedNotification = @"BluetoothConnectionChangedNotification";
NSString *const BluetoothConnectorErrorDomain = @"BluetoothConnectorErrorDomain";

@interface BluetoothConnector () <CBCentralManagerDelegate>

@property (strong, nonatomic) CBPeripheral *peripheral; ///< ペリフェラル
@property (assign, nonatomic) BOOL running; ///< 実行中か否か
@property (strong, nonatomic) dispatch_queue_t queue; ///< Bluetooth処理専用のディスパッチキュー
@property (strong, nonatomic) CBCentralManager *centralManager;	///< Bluetoothセントラルマネージャ
@property (strong, nonatomic) CBPeripheral *cachedPeripheral; ///< キャッシュしたペリフェラル

@end

#pragma mark -

@implementation BluetoothConnector

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");

	self = [super init];
	if (!self) {
		return nil;
	}
	
	_services = nil;
	_localName = nil;
	_timeout = 5.0;
	_peripheral = nil;
	_queue = nil;
	_centralManager = nil;
	_cachedPeripheral = nil;
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	_services = nil;
	_localName = nil;
	_peripheral = nil;
	_queue = nil;
	_centralManager = nil;
	_cachedPeripheral = nil;
}

#pragma mark -

- (BluetoothConnectionStatus)connectionStatus {
	DEBUG_DETAIL_LOG(@"");
	
#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetooth制御は利用できません。
	return BluetoothConnectionStatusNotFound;
#else
	if ([CBCentralManager authorization] == CBManagerAuthorizationDenied ||
		[CBCentralManager authorization] == CBManagerAuthorizationRestricted) {
		return BluetoothConnectionStatusNotNotAuthorized;
	}
	if (self.centralManager) {
		if (self.centralManager.state == CBManagerStatePoweredOn) {
			if (self.peripheral) {
				if (self.peripheral.state == CBPeripheralStateConnected) {
					return BluetoothConnectionStatusConnected;
				} else {
					return BluetoothConnectionStatusNotConnected;
				}
			} else {
				return BluetoothConnectionStatusNotFound;
			}
		}
	} else {
		// セントラルマネージャを初期化していない場合は便宜上未検索とします。
		return BluetoothConnectionStatusNotFound;
	}
	return BluetoothConnectionStatusUnknown;
#endif
}

/// セントラルマネージャを準備します。
- (CBManagerAuthorization)reqeustAuthorization {
	DEBUG_LOG(@"");

#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetooth制御は利用できません。
	return CBManagerAuthorizationDenied;
#else
	// Bluetoothデバイスが利用不可なら即答します。
	if ([CBCentralManager authorization] == CBManagerAuthorizationDenied) {
		self.centralManager = nil;
		self.queue = nil;
		return [CBCentralManager authorization];
	}
	
	// セントラルマネージャを準備します。
	if (!self.centralManager) {
		NSString *dispatchQueueName = [NSString stringWithFormat:@"%@.BluetoothConnector.queue", [[NSBundle mainBundle] bundleIdentifier]];
		_queue = dispatch_queue_create([dispatchQueueName UTF8String], NULL);
		NSDictionary *managerOptions = @{
			CBCentralManagerOptionShowPowerAlertKey: @YES
		};
		self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue options:managerOptions];
	}
	
	// 決まっていないならユーザーが許可もしくは禁止を選択するまで待ちます。
	while ([CBCentralManager authorization] == CBManagerAuthorizationNotDetermined) {
		[NSThread sleepForTimeInterval:0.05];
	}

	// ユーザーの選択した結果を返します。
	DEBUG_LOG(@"authorization=%ld", [CBCentralManager authorization]);
	if ([CBCentralManager authorization] == CBManagerAuthorizationDenied ||
		[CBCentralManager authorization] == CBManagerAuthorizationRestricted) {
		self.centralManager = nil;
		self.queue = nil;
	}
	return [CBCentralManager authorization];
#endif
}

- (void)clearPeripheralCache {
	DEBUG_LOG(@"");

	self.cachedPeripheral = nil;
}

- (BOOL)discoverPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetooth制御は利用できません。
	return NO;
#else
	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:DiscorverPeripheralIsRunnning", @"BluetoothConnector.discoverPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if ([self reqeustAuthorization] == CBManagerAuthorizationDenied) {
		// Bluetoothデバイスは利用できません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNotAvailable description:NSLocalizedString(@"$desc:BluetoothIsNotAvailable", @"BluetoothConnector.discoverPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	// MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
	NSDate *managerStartTime = [NSDate date];
	while (![self managerIsPoweredOn] && [[NSDate date] timeIntervalSinceDate:managerStartTime] < self.timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	if (![self managerIsPoweredOn]) {
		// Bluetoothデバイスは利用できません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNotAvailable description:NSLocalizedString(@"$desc:CBCentralManagerStateNotPoweredOn", @"BluetoothConnector.discoverPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}

	// ペリフェラルに接続している場合はそれを利用します。
	self.running = YES;
	{
		NSArray *peripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:self.services];
		if (peripherals.count > 0) {
			self.peripheral = [peripherals firstObject];
		} else {
			self.peripheral = nil;
		}
	}
	// ペリフェラルをキャッシュしている場合は該当するか確認します。
	if (!self.peripheral && self.cachedPeripheral) {
		DEBUG_LOG(@"Try retrieve peripherals");
		NSArray *peripherals = [self. centralManager retrievePeripheralsWithIdentifiers:@[self.cachedPeripheral.identifier]];
		if (peripherals.count > 0) {
			self.peripheral = [peripherals firstObject];
		}
	}
	// ペリフェラルがキャッシュに該当しない場合はスキャンします。
	if (!self.peripheral) {
		DEBUG_LOG(@"Try scan peripherals");
		NSDictionary *scanOptions = @{
			CBCentralManagerScanOptionAllowDuplicatesKey: @NO
		};
		[self.centralManager scanForPeripheralsWithServices:self.services options:scanOptions];
		NSDate *scanStartTime = [NSDate date];
		while (!self.peripheral && [[NSDate date] timeIntervalSinceDate:scanStartTime] < self.timeout) {
			[NSThread sleepForTimeInterval:0.05];
		}
		[self.centralManager stopScan];
	}
	BOOL discovered = (self.peripheral != nil);
	self.running = NO;
	
	// ペリフェラルが見つかっていたら通知します。
	if (discovered) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
	} else {
		NSError *internalError = [self createError:BluetoothConnectorErrorTimeout description:NSLocalizedString(@"$desc:DiscoveringBluetoothPeripheralTimedOut", @"BluetoothConnector.discoverPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
	}
	return discovered;
#endif
}

- (BOOL)connectPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetooth制御は利用できません。
	return NO;
#else
	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:ConnectPeripheralIsRunnning", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if ([self reqeustAuthorization] == CBManagerAuthorizationDenied) {
		// Bluetoothデバイスは利用できません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNotAvailable description:NSLocalizedString(@"$desc:BluetoothIsNotAvailable", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	// MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
	NSDate *managerStartTime = [NSDate date];
	while (![self managerIsPoweredOn] && [[NSDate date] timeIntervalSinceDate:managerStartTime] < self.timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	if (![self managerIsPoweredOn]) {
		// Bluetoothデバイスは利用できません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNotAvailable description:NSLocalizedString(@"$desc:CBCentralManagerStateNotPoweredOn", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if (!self.peripheral) {
		// ペリフェラルが用意されていません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNoPeripheral description:NSLocalizedString(@"$desc:NoBluetoothPeripherals", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}

	// ペリフェラルに接続します。
	self.running = YES;
	NSDictionary *connectOptions = @{
		CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
		CBConnectPeripheralOptionNotifyOnDisconnectionKey: @NO,
		CBConnectPeripheralOptionNotifyOnNotificationKey: @NO
	};
	[self.centralManager connectPeripheral:self.peripheral options:connectOptions];
	NSDate *scanStartTime = [NSDate date];
	while (self.peripheral.state != CBPeripheralStateConnected && [[NSDate date] timeIntervalSinceDate:scanStartTime] < self.timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	BOOL connected = (self.peripheral.state == CBPeripheralStateConnected);
	self.running = NO;
	
	// ペリフェラルに接続していたら通知します。
	if (connected) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
	} else {
		NSError *internalError = [self createError:BluetoothConnectorErrorTimeout description:NSLocalizedString(@"$desc:ConnectingBluetoothPeripheralTimedOut", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
	}
	return connected;
#endif
}

- (BOOL)disconnectPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

#if (TARGET_OS_SIMULATOR)
	// シミュレータではBluetooth制御は利用できません。
	return NO;
#else
	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:DisconnectPeripheralIsRunnning", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}

	// ペリフェラルの接続を解除します。
	self.running = YES;
	BOOL disconnected = YES;
	if (self.peripheral &&
		self.peripheral.name == self.localName &&
		self.peripheral.state == CBPeripheralStateConnected &&
		[self managerIsPoweredOn]) {
		[self.centralManager cancelPeripheralConnection:self.peripheral];
		NSDate *scanStartTime = [NSDate date];
		while (self.peripheral.state != CBPeripheralStateDisconnected && [[NSDate date] timeIntervalSinceDate:scanStartTime] < self.timeout) {
			[NSThread sleepForTimeInterval:0.05];
		}
		disconnected = self.peripheral.state == CBPeripheralStateDisconnected;
	} else {
		DEBUG_LOG(@"Already disconnected");
	}
	self.peripheral = nil;
	self.running = NO;
	
	// ペリフェラルの接続を解除できていたら通知します。
	if (disconnected) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
	} else {
		NSError *internalError = [self createError:BluetoothConnectorErrorTimeout description:NSLocalizedString(@"$desc:DisconnectingBluetoothPeripheralTimedOut", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
	}
	return disconnected;
#endif
}

#pragma mark -

// セントラルマネージャが電源オンしているか否かを取得します。
- (BOOL)managerIsPoweredOn {
	return (self.centralManager.state == CBManagerStatePoweredOn);
}

/// セントラルマネージャの状態が変わった時に呼び出されます。
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	DEBUG_LOG(@"central.state=%ld", (long)central.state);
	// CBCentralManagerStateUnknown = 0
	// CBCentralManagerStateResetting = 1
	// CBCentralManagerStateUnsupported = 2
	// CBCentralManagerStateUnauthorized = 3
	// CBCentralManagerStatePoweredOff = 4
	// CBCentralManagerStatePoweredOn = 5

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
}

/// セントラルマネージャがペリフェラルを見つけた時に呼び出されます。
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	DEBUG_LOG(@"peripheral=%@, advertisementData=%@, RSSI=%@", peripheral, advertisementData, RSSI);

	if ([advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString:self.localName]) {
		[self.centralManager stopScan];
		self.peripheral = peripheral;
	}
}

/// ペリフェラルに接続した時に呼び出されます。
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	DEBUG_LOG(@"peripheral=%@", peripheral);
	self.peripheral = peripheral;
	self.cachedPeripheral = peripheral;
}

/// ペリフェラルに接続失敗した時に呼び出されます。
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	DEBUG_LOG(@"peripheral=%@", peripheral);
	self.peripheral = nil;
	self.cachedPeripheral = nil;
}

/// ペリフェラルの接続が解除された時に呼び出されます。
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	DEBUG_LOG(@"peripheral=%@", peripheral);

	// 切断処理中以外にBluetoothの切断通知を受けた場合は、ここからさらに通知します。
	if (!self.running) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
	}
}

/// エラー情報を作成します。
- (NSError *)createError:(NSInteger)code description:(NSString *)description {
	DEBUG_LOG(@"code=%ld, description=%@", (long)code, description);
	
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: description
	};
	NSError *error = [[NSError alloc] initWithDomain:BluetoothConnectorErrorDomain code:code userInfo:userInfo];
	return error;
}

@end
