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

#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "ReferenceViewController.h"
#import "Reachability.h"
#import "UIViewController+Alert.h"

@interface ReferenceViewController () <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

#pragma mark -

@implementation ReferenceViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューを初期化します。
	self.webView.navigationDelegate = self;
	
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
	
	self.webView.navigationDelegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark -

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	DEBUG_LOG(@"request=%@", navigationAction.request);

	// 内蔵ドキュメントなら常に許可します。
	if ([navigationAction.request.URL.scheme isEqualToString:@"file"]) {
		return decisionHandler(WKNavigationActionPolicyAllow);
	}
	
	// 外部コンテンツならインターネットに接続されているかを確認します。
	Reachability *reachability = [Reachability reachabilityWithHostName:@"itunes.apple.com"];
	NetworkStatus status = [reachability currentReachabilityStatus];
	if (status == NotReachable) {
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotOpenWebLinkByNoInternet", @"ReferenceViewController.shouldStartLoadWithRequest") title:NSLocalizedString(@"$title:CouldNotOpenWebLink",  @"ReferenceViewController.shouldStartLoadWithRequest")];
		return decisionHandler(WKNavigationActionPolicyCancel);
	}
	
	// このWebViewでは開かずに、代わりにWebブラウザで開きます。
	[GetApp() openURL:navigationAction.request.URL options:@{} completionHandler:nil];

	return decisionHandler(WKNavigationActionPolicyCancel);
}

@end
