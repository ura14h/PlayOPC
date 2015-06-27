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
#import "Reachability.h"
#import "UIViewController+Alert.h"

@interface AcknowledgementViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

#pragma mark -

@implementation AcknowledgementViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];

	// ビューを初期化します。
	self.webView.delegate = self;
	
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
		[self showAlertMessage:NSLocalizedString(@"The device does not connect with the Internet. If you want to open the site via Wi-Fi it is necessary to disconnect camera connection first.", nil) title:NSLocalizedString(@"Could not open link", nil)];
		return NO;
	}
	
	// このWebViewでは開かずに、代わりにWebブラウザで開きます。
	[[UIApplication sharedApplication] openURL:request.URL];
	return NO;
}

@end
