//
//  ReferenceViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/26.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ReferenceViewController.h"

@interface ReferenceViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

#pragma mark -

@implementation ReferenceViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// リファレンスマニュアルを表示します。
	NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"Reference" ofType:@"html"];
	NSURL *htmlFileUrl = [NSURL fileURLWithPath:htmlFilePath];
	[self.webView loadRequest:[NSURLRequest requestWithURL:htmlFileUrl]];
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

@end
