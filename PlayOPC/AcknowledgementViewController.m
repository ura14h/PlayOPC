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

#import <WebKit/WebKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "AppDelegate.h"
#import "AcknowledgementViewController.h"
#import "UIViewController+Alert.h"

@interface AcknowledgementViewController () <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

#pragma mark -

@implementation AcknowledgementViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
	
	// ビューを初期化します。
	self.webView.navigationDelegate = self;
	
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
	if (![self isReachable:navigationAction.request.URL.scheme]) {
		[self showAlertMessage:NSLocalizedString(@"$desc:CouldNotOpenWebLinkByNoInternet", @"ReferenceViewController.shouldStartLoadWithRequest") title:NSLocalizedString(@"$title:CouldNotOpenWebLink",  @"ReferenceViewController.shouldStartLoadWithRequest")];
		return decisionHandler(WKNavigationActionPolicyCancel);
	}
	
	// このWebViewでは開かずに、代わりにWebブラウザで開きます。
	[GetApp() openURL:navigationAction.request.URL options:@{} completionHandler:nil];
	
	return decisionHandler(WKNavigationActionPolicyCancel);
}

- (BOOL)isReachable:(NSString *)host {
	DEBUG_LOG(@"host=%@", host);
	
	BOOL result = NO;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
	if (reachability == NULL) {
		return result;
	}
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
		result = flags & kSCNetworkReachabilityFlagsReachable;
	}
	CFRelease(reachability);
	return result;
}

@end
