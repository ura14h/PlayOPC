//
//  ScanStickerViewController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2023/01/29.
//  Copyright (c) 2023 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import "ScanStickerViewController.h"
#import "AppDelegate.h"
#import "AppSetting.h"
#import "AppCamera.h"
#import "AppNavigationController.h"
#import "UIViewController+Alert.h"

@interface ScanStickerViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) BOOL completed;

@end

#pragma mark -

@implementation ScanStickerViewController

#pragma mark -

- (void)viewDidLoad {
	DEBUG_LOG(@"");
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_session = nil;
	_previewLayer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillAppear:animated];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
			   name:AppDidChangeStatusBarOrientationNotification object:nil];
	
	// ツールバーを非表示にします。
	[self.navigationController setToolbarHidden:YES animated:animated];
	
	// スキャンを開始します。
	[self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
	DEBUG_LOG(@"");
	[super viewWillDisappear:animated];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:AppDidChangeStatusBarOrientationNotification object:nil];
	
	// スキャンを終了します。
	[self stopScan];
}

- (void)viewDidLayoutSubviews {
	DEBUG_LOG(@"");
	[super viewDidLayoutSubviews];
	
	// プレビュー表示エリアをリサイズします。
	self.previewLayer.frame = self.view.bounds;
}

- (void)statusBarOrientationDidChange:(NSNotification *)notification {
	DEBUG_LOG(@"");
	
	// プレビュー表示エリアの回転方向を画面に合わせます。
	self.previewLayer.connection.videoOrientation = [self videoOrientation];
}

#pragma mark -

- (AVCaptureVideoOrientation)videoOrientation {
	DEBUG_LOG(@"");
	
	UIInterfaceOrientation uiOrientation = self.view.window.windowScene.interfaceOrientation;
	AVCaptureVideoOrientation avOrientation;
	switch (uiOrientation) {
		case AVCaptureVideoOrientationPortrait:
			avOrientation = AVCaptureVideoOrientationPortrait;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			avOrientation = AVCaptureVideoOrientationLandscapeRight;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			avOrientation = AVCaptureVideoOrientationLandscapeLeft;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			avOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
			break;
		default:
			avOrientation = AVCaptureVideoOrientationPortrait;
	}
	return avOrientation;
}

- (void)startScan {
	DEBUG_LOG(@"");
	
	// ビデオキャプチャセッションを準備します。
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPresetHigh;
	AVCaptureDevice* device =
	[AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
									   mediaType:AVMediaTypeVideo position: AVCaptureDevicePositionBack];
	AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
	[self.session addInput:deviceInput];
	AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
	output.videoSettings = @{
		(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
	};
	dispatch_queue_t queue = dispatch_queue_create("net.homeunix.hio.ipa.PlayOPC.ScanStickerQueue", DISPATCH_QUEUE_SERIAL);
	[output setSampleBufferDelegate:self queue:queue];
	output.alwaysDiscardsLateVideoFrames = YES;
	[self.session addOutput:output];
	
	// プレビュー表示エリアを準備します。
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
	self.previewLayer.frame = self.view.bounds;
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.previewLayer.connection.videoOrientation = [self videoOrientation];
	CALayer *layer = self.view.layer;
	layer.masksToBounds = YES;
	[layer addSublayer:self.previewLayer];
	[self.view layoutIfNeeded];
	
	// ビデオキャプチャセッションを開始します。
	self.completed = NO;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.session startRunning];
	});
}

- (void)stopScan {
	DEBUG_LOG(@"");
	
	// ビデオキャプチャセッションを終了します。
	[self.session stopRunning];
	self.session = nil;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	CVPixelBufferRef cvpixeBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	// スキャンが完了しているときは何もしません。
	if (self.completed) {
		return;
	}
	
	// 画像から文字列を読み取ります。
	__weak ScanStickerViewController *weakSelf = self;
	VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:cvpixeBufferRef options:@{}];
	VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
		if (weakSelf.completed) {
			return;
		}
		if (error) {
			return;
		}
		NSMutableArray<NSString *> *scannedTexts = [NSMutableArray array];
		VNRecognizeTextRequest *textRequest = (VNRecognizeTextRequest *)request;
		for (id rawResult in textRequest.results) {
			if (![rawResult isKindOfClass:[VNRecognizedTextObservation class]]) {
				continue;
			}
			VNRecognizedTextObservation *observation = (VNRecognizedTextObservation *)rawResult;
			NSArray<VNRecognizedText *> *texts = [observation topCandidates:1];
			if (texts.count < 1) {
				continue;
			}
			NSString *text = [texts firstObject].string;
			[scannedTexts addObject:text];
		}
		
		// 読み取った文字列が正しければ、この画面を完了します。
		[weakSelf analyzeScannedTexts:scannedTexts];
	}];
	[handler performRequests:@[request] error:nil];
}

- (void)analyzeScannedTexts:(NSArray *)texts {
	DEBUG_LOG(@"%@", texts.description);
	
	// 読み取った情報を抽出します。
	NSString *snPattern = @"^S/N: ([A-Z0-9]+)$";
	NSRegularExpression *snRegex = [NSRegularExpression regularExpressionWithPattern:snPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSString *snText;
	NSString *ssidPattern = @"^SSID: +(AIR *- *A01 *- *[A-Z0-9]+)$";
	NSRegularExpression *ssidRegex = [NSRegularExpression regularExpressionWithPattern:ssidPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSString *ssidText;
	NSString *passwordPattern = @"^Password: +([0-9]+)$";
	NSRegularExpression *passwordRegex = [NSRegularExpression regularExpressionWithPattern:passwordPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSString *passwordText;
	NSString *bluetoothPattern = @"^Bluetooth: +(AIR *- *A01)$";
	NSRegularExpression *bluetoothRegex = [NSRegularExpression regularExpressionWithPattern:bluetoothPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSString *bluetoothText;
	for (NSString *text in texts) {
		NSRange range = NSMakeRange(0, text.length);
		NSTextCheckingResult *match;
		match = [snRegex firstMatchInString:text options:0 range:range];
		if (match) {
			NSRange matchedRange = [match rangeAtIndex:1];
			snText = [text substringWithRange:matchedRange];
		}
		match = [ssidRegex firstMatchInString:text options:0 range:range];
		if (match) {
			NSRange matchedRange = [match rangeAtIndex:1];
			ssidText = [text substringWithRange:matchedRange];
		}
		match = [passwordRegex firstMatchInString:text options:0 range:range];
		if (match) {
			NSRange matchedRange = [match rangeAtIndex:1];
			passwordText = [text substringWithRange:matchedRange];
		}
		match = [bluetoothRegex firstMatchInString:text options:0 range:range];
		if (match) {
			NSRange matchedRange = [match rangeAtIndex:1];
			bluetoothText = [text substringWithRange:matchedRange];
		}
	}
	if (!snText || !ssidText || !passwordText || !bluetoothText) {
		return;
	}
	snText = [snText stringByReplacingOccurrencesOfString:@" " withString:@""];
	ssidText = [ssidText stringByReplacingOccurrencesOfString:@" " withString:@""];
	passwordText = [passwordText stringByReplacingOccurrencesOfString:@" " withString:@""];
	bluetoothText = [bluetoothText stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	// 読み取った情報が妥当かを確認します。
	NSString *aira01= @"AIR-A01";
	if (snText.length != 9) {
		return;
	}
	if (ssidText.length != (aira01.length + 1 + 9) || ![ssidText hasSuffix:snText]) {
		return;
	}
	if (passwordText.length != 8) {
		return;
	}
	if (bluetoothText.length != aira01.length) {
		return;
	}
	NSString *passcodeText = @"000000";
	self.completed = YES;
	
	// 確認ダイアログを表示します。
	__weak ScanStickerViewController *weakSelf = self;
	NSString *title = NSLocalizedString(@"$title:ScanResult", @"ScanStickerViewController.showAlertMessage");
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"$desc:ScanResult(%@,%@,%@,%@)", @"ScanStickerViewController.showAlertMessage"),
						 snText, ssidText, passwordText, bluetoothText];
	[self showAlertMessage:message title:title okHandler:^(UIAlertAction *action) {
		// 読み取った情報を保存します。
		AppSetting *setting = GetAppSetting();
		setting.wifiSSID = ssidText;
		setting.wifiPassphrase = passwordText;
		setting.bluetoothLocalName = bluetoothText;
		if (!setting.bluetoothPasscode || setting.bluetoothPasscode.length < 1) {
			// パスコードは未構成の場合だけ保存します。
			setting.bluetoothPasscode = passcodeText;
		}
		// 前の画面に戻ります。
		[weakSelf performSegueWithIdentifier:@"DoneScanSticker" sender:self];
	} cancelHandler:^(UIAlertAction *action) {
		// スキャンをやり直します。
		weakSelf.completed = NO;
	}];
}

@end
