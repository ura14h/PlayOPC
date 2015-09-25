//
//  AppCameraTests.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AppCamera.h"

@interface AppCameraTests : XCTestCase

@end

@implementation AppCameraTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

/// プロパティ一括設定のテスト
/// Wi-Fi接続済みにしてから実行します。
- (void)testSetCameraPropertyValues {
	// 渡す値か渡すタイミングか分からないが一括設定後の値が期待した結果にならないので調査してみました。
	
	// 分割せずに渡す
	{
		NSError *error = nil;
		AppCamera *camera = [[AppCamera alloc] init];
		XCTAssertTrue([camera connect:OLYCameraConnectionTypeBluetoothLE error:&error], @"%@", error);
		XCTAssertTrue([camera changeRunMode:OLYCameraRunModeRecording error:&error], @"%@", error);
		NSDictionary *properties = @{
			@"TAKEMODE": @"<TAKEMODE/A>",
			@"RECENTLY_ART_FILTER": @"<RECENTLY_ART_FILTER/VINTAGE>",
			@"COLORTONE": @"<COLORTONE/VINTAGE>",
		};
		XCTAssertTrue([camera setCameraPropertyValues:properties error:&error], @"%@", error);
		NSString *takemode = [camera cameraPropertyValue:@"TAKEMODE" error:&error];
		XCTAssertNotNil(takemode, @"%@", error);
		XCTAssertEqualObjects(takemode, @"<TAKEMODE/A>", @"%@", takemode);
		XCTAssertTrue([camera disconnectWithPowerOff:FALSE error:&error], @"%@", error);
	}
	// 分割して渡す(RECENTLY_ART_FILTERを触る)
	{
		NSError *error = nil;
		AppCamera *camera = [[AppCamera alloc] init];
		XCTAssertTrue([camera connect:OLYCameraConnectionTypeBluetoothLE error:&error], @"%@", error);
		XCTAssertTrue([camera changeRunMode:OLYCameraRunModeRecording error:&error], @"%@", error);
		NSDictionary *properties1 = @{ @"TAKEMODE": @"<TAKEMODE/A>" };
		NSDictionary *properties2 = @{ @"RECENTLY_ART_FILTER": @"<RECENTLY_ART_FILTER/VINTAGE>" };
		XCTAssertTrue([camera setCameraPropertyValues:properties1 error:&error], @"%@", error);
		XCTAssertTrue([camera setCameraPropertyValues:properties2 error:&error], @"%@", error);
		NSString *takemode = [camera cameraPropertyValue:@"TAKEMODE" error:&error];
		XCTAssertNotNil(takemode, @"%@", error);
		XCTAssertEqualObjects(takemode, @"<TAKEMODE/A>", @"%@", takemode); // FIXME: 失敗する (@"<TAKEMODE/ART>"になってしまう)
		XCTAssertTrue([camera disconnectWithPowerOff:FALSE error:&error], @"%@", error);
	}
	// 分割して渡す(COLORTONEを触る)
	{
		NSError *error = nil;
		AppCamera *camera = [[AppCamera alloc] init];
		XCTAssertTrue([camera connect:OLYCameraConnectionTypeBluetoothLE error:&error], @"%@", error);
		XCTAssertTrue([camera changeRunMode:OLYCameraRunModeRecording error:&error], @"%@", error);
		NSDictionary *properties1 = @{ @"TAKEMODE": @"<TAKEMODE/A>" };
		NSDictionary *properties2 = @{ @"COLORTONE": @"<COLORTONE/VINTAGE>" };
		XCTAssertTrue([camera setCameraPropertyValues:properties1 error:&error], @"%@", error);
		XCTAssertTrue([camera setCameraPropertyValues:properties2 error:&error], @"%@", error);
		NSString *takemode = [camera cameraPropertyValue:@"TAKEMODE" error:&error];
		XCTAssertNotNil(takemode, @"%@", error);
		XCTAssertEqualObjects(takemode, @"<TAKEMODE/A>", @"%@", takemode);
		XCTAssertTrue([camera disconnectWithPowerOff:FALSE error:&error], @"%@", error);
	}
	// 分割して渡す(RECENTLY_ART_FILTERとCOLORTONEを触る)
	{
		NSError *error = nil;
		AppCamera *camera = [[AppCamera alloc] init];
		XCTAssertTrue([camera connect:OLYCameraConnectionTypeBluetoothLE error:&error], @"%@", error);
		XCTAssertTrue([camera changeRunMode:OLYCameraRunModeRecording error:&error], @"%@", error);
		NSDictionary *properties1 = @{ @"TAKEMODE": @"<TAKEMODE/A>" };
		NSDictionary *properties2 = @{ @"COLORTONE": @"<COLORTONE/VINTAGE>" };
		NSDictionary *properties3 = @{ @"RECENTLY_ART_FILTER": @"<RECENTLY_ART_FILTER/VINTAGE>" };
		XCTAssertTrue([camera setCameraPropertyValues:properties1 error:&error], @"%@", error);
		XCTAssertTrue([camera setCameraPropertyValues:properties2 error:&error], @"%@", error);
		XCTAssertTrue([camera setCameraPropertyValues:properties3 error:&error], @"%@", error);
		NSString *takemode = [camera cameraPropertyValue:@"TAKEMODE" error:&error];
		XCTAssertNotNil(takemode, @"%@", error);
		XCTAssertEqualObjects(takemode, @"<TAKEMODE/A>", @"%@", takemode); // FIXME: 失敗する (@"<TAKEMODE/ART>"になってしまう)
		XCTAssertTrue([camera disconnectWithPowerOff:FALSE error:&error], @"%@", error);
	}

	/// 今のところ、TAKEMODEとRECENTLY_ART_FILTERを設定したい場合は、それらを一緒にしてAPIに渡さないと
	/// 正しい結果にならないようです。
}

@end
