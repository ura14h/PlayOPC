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
#import "Reachability.h"
#import "UIViewController+Alert.h"

@interface ReferenceViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

#pragma mark -

@implementation ReferenceViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューを初期化します。
	self.webView.delegate = self;
	
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
	
	self.webView.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	DEBUG_LOG(@"request=%@", request);

	// 内蔵ドキュメントなら常に許可します。
	if ([request.URL.scheme isEqualToString:@"file"]) {
		return YES;
	}
	
	// 外部コンテンツならインターネットに接続されているかを確認します。
	Reachability *reachability = [Reachability reachabilityWithHostName:@"itunes.apple.com"];
	NetworkStatus status = [reachability currentReachabilityStatus];
	if (status == NotReachable) {
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotOpenWebLinkByNoInternet", @"ReferenceViewController.shouldStartLoadWithRequest") title:NSLocalizedString(@"$title:CouldNotOpenWebLink",  @"ReferenceViewController.shouldStartLoadWithRequest")];
		return NO;
	}
	
	// このWebViewでは開かずに、代わりにWebブラウザで開きます。
	[[UIApplication sharedApplication] openURL:request.URL];
	return NO;
}

@end
