//
//  AcknowledgementViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/03/21.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AcknowledgementViewController.h"

@interface AcknowledgementViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

#pragma mark -

@implementation AcknowledgementViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// 謝辞を表示します。
	NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"Acknowledgement" ofType:@"html"];
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
