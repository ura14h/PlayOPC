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
	NSString *dispatchQueueName = [NSString stringWithFormat:@"%@.BluetoothConnector.queue", [[NSBundle mainBundle] bundleIdentifier]];
	_queue = dispatch_queue_create([dispatchQueueName UTF8String], NULL);
	NSDictionary *managerOptions = @{
		CBCentralManagerOptionShowPowerAlertKey: @YES
	};
	_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue options:managerOptions];
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
	return BluetoothConnectionStatusConnected;
#else
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
	return BluetoothConnectionStatusUnknown;
#endif
}

- (void)clearPeripheralCache {
	DEBUG_LOG(@"");

	self.cachedPeripheral = nil;
}

- (BOOL)discoverPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:DiscorverPeripheralIsRunnning", @"BluetoothConnector.discoverPeripheral")];
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
	if (self.peripheral && [self.peripheral.name isEqualToString:self.localName]) {
		// すでに検索してあるんじゃないですか。
		NSError *internalError = [self createError:BluetoothConnectorErrorConnected description:NSLocalizedString(@"$desc:BluetoothPeripheralFound", @"BluetoothConnector.discoverPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		// エラーは無視して続行します。
	}

	// ペリフェラルに接続している場合はそれを利用します。
	self.running = YES;
	self.peripheral = nil;
	if (!self.peripheral) {
		DEBUG_LOG(@"");
		NSArray *peripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:self.services];
		if (peripherals.count > 0) {
			self.peripheral = [peripherals firstObject];
		}
	}
	// ペリフェラルをキャッシュしている場合は該当するか確認します。
	if (!self.peripheral && self.cachedPeripheral) {
		DEBUG_LOG(@"");
		NSArray *peripherals = [self. centralManager retrievePeripheralsWithIdentifiers:@[self.cachedPeripheral.identifier]];
		if (peripherals.count > 0) {
			self.peripheral = [peripherals firstObject];
		}
	}
	// ペリフェラルがキャッシュに該当しない場合はスキャンします。
	if (!self.peripheral) {
		DEBUG_LOG(@"");
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
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:DiscoveringBluetoothPeripheralTimedOut", @"BluetoothConnector.discoverPeripheral")
		};
		NSError *theError = [NSError errorWithDomain:BluetoothConnectorErrorDomain code:BluetoothConnectorErrorTimeout userInfo:userInfo];
		DEBUG_LOG(@"error=%@", theError);
		if (error) {
			*error = theError;
		}
	}
	return discovered;
}

- (BOOL)connectPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:ConnectPeripheralIsRunnning", @"BluetoothConnector.connectPeripheral")];
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
	if (self.peripheral && self.peripheral.name == self.localName && self.peripheral.state == CBPeripheralStateConnected) {
		// すでに接続してあるんじゃないですか。
		NSError *internalError = [self createError:BluetoothConnectorErrorConnected description:NSLocalizedString(@"$desc:BluetoothPeripheralConnected", @"BluetoothConnector.connectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		// エラーは無視して続行します。
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
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:ConnectingBluetoothPeripheralTimedOut", @"BluetoothConnector.connectPeripheral")
		};
		NSError *theError = [NSError errorWithDomain:BluetoothConnectorErrorDomain code:BluetoothConnectorErrorTimeout userInfo:userInfo];
		DEBUG_LOG(@"error=%@", theError);
		if (error) {
			*error = theError;
		}
	}
	return connected;
}

- (BOOL)disconnectPeripheral:(NSError **)error {
	DEBUG_LOG(@"");

	if (self.running) {
		// すでに実行中です。
		NSError *internalError = [self createError:BluetoothConnectorErrorBusy description:NSLocalizedString(@"$desc:DisconnectPeripheralIsRunnning", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if (![self managerIsPoweredOn]) {
		// Bluetoothデバイスは利用できません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNotAvailable description:NSLocalizedString(@"$desc:CBCentralManagerStateNotPoweredOn", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if (!self.peripheral) {
		// ペリフェラルが用意されていません。
		NSError *internalError = [self createError:BluetoothConnectorErrorNoPeripheral description:NSLocalizedString(@"$desc:NoBluetoothPeripherals", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		return NO;
	}
	if (self.peripheral && self.peripheral.name == self.localName && self.peripheral.state == CBPeripheralStateDisconnected) {
		// すでに切断してあるんじゃないですか。
		NSError *internalError = [self createError:BluetoothConnectorErrorDisconnected description:NSLocalizedString(@"$desc:BluetoothPeripheralDisconnected", @"BluetoothConnector.disconnectPeripheral")];
		DEBUG_LOG(@"error=%@", internalError);
		if (error) {
			*error = internalError;
		}
		// エラーは無視して続行します。
	}

	// ペリフェラルの接続を解除します。
	self.running = YES;
	[self.centralManager cancelPeripheralConnection:self.peripheral];
	NSDate *scanStartTime = [NSDate date];
	while (self.peripheral.state != CBPeripheralStateDisconnected && [[NSDate date] timeIntervalSinceDate:scanStartTime] < self.timeout) {
		[NSThread sleepForTimeInterval:0.05];
	}
	BOOL disconnected = self.peripheral.state == CBPeripheralStateDisconnected;
	self.running = NO;
	
	// ペリフェラルの接続を解除できていたら通知します。
	if (disconnected) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:BluetoothConnectionChangedNotification object:self];
	} else {
		NSDictionary *userInfo = @{
			NSLocalizedDescriptionKey: NSLocalizedString(@"$desc:DisconnectingBluetoothPeripheralTimedOut", @"BluetoothConnector.disconnectPeripheral")
		};
		NSError *theError = [NSError errorWithDomain:BluetoothConnectorErrorDomain code:BluetoothConnectorErrorTimeout userInfo:userInfo];
		DEBUG_LOG(@"error=%@", theError);
		if (error) {
			*error = theError;
		}
	}
	return disconnected;
}

#pragma mark -

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
	self.cachedPeripheral = peripheral;
}

/// ペリフェラルに接続失敗した時に呼び出されます。
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	DEBUG_LOG(@"peripheral=%@", peripheral);
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

// セントラルマネージャが電源オンしているか否かを取得します。
- (BOOL)managerIsPoweredOn {
	return (self.centralManager.state == CBManagerStatePoweredOn);
}

@end
