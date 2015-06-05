//
//  main.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/20.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
	DEBUG_LOG(@"");
	
	@autoreleasepool {
		int exit_code = 0;
		@try {
			exit_code = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
		}
		@catch (NSException *exception) {
			// キャッチできない致命的な例外は情報をデバッグコンソールに出力します。
			DEBUG_LOG(@"exception=%@", [exception description]);
			DEBUG_LOG(@"stack trace={\n%@\n}", [exception callStackSymbols]);
		}
		return exit_code;
	}
}
