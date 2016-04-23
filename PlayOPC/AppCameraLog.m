//
//  AppCameraLog.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/04.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppCameraLog.h"
#import <OLYCameraKit/OLYCameraLog.h>

@interface AppCameraLog () <OLYCameraLogDelegate>

@property (strong, nonatomic) NSMutableArray *mutableMessages;

@end

#pragma mark -

@implementation AppCameraLog

#pragma mark -

- (instancetype)init {
	DEBUG_LOG(@"");
	
	self = [super init];
	if (!self) {
		return nil;
	}

	_mutableMessages = [[NSMutableArray alloc] init];
	[OLYCameraLog setDelegate:self];
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	[OLYCameraLog resetDelegate];
	_mutableMessages = nil;
}

#pragma mark -

- (NSArray *)messages {
	DEBUG_LOG(@"");
	
	return [NSArray arrayWithArray:self.mutableMessages];
}

- (BOOL)clearMessages {
	DEBUG_LOG(@"");
	
	[self.mutableMessages removeAllObjects];
	
	return YES;
}

#pragma mark -

/// カメラキットがログに出力しようとしたときに呼び出されます。
- (void)log:(OLYCameraLog *)log shouldOutputMessage:(NSString *)message level:(OLYCameraLogLevel)level {
	NSLog(@"%@", message);
	
	// ログファイル用のメッセージを作成します。
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone localTimeZone]];
	[formatter setDateFormat:@"HH:mm:ss.SSS"];
	NSString *loggingTimestamp = [formatter stringFromDate:currentTime];
	NSString *loggingMessage = [NSString stringWithFormat:@"%@ %@", loggingTimestamp, message];
	
	// ログ履歴に記録します。
	[self.mutableMessages addObject:loggingMessage];
}

@end
