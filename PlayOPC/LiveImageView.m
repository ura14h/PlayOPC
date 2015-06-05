//
//  LiveImageView.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/13.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
//  このクラスはImageCaptureSampleのCameraLiveImageViewクラスを元にして再構成したものです。

#import "LiveImageView.h"
#import <OLYCameraKit/OLYCamera.h>

@interface LiveImageView ()

// オートフォーカス枠関連
@property (assign, nonatomic) CGFloat focusFrameBorderWidth; ///< オートフォーカス枠の幅
@property (assign, nonatomic) CGFloat focusFrameBorderOpacity; ///< オートフォーカス枠の不透明度
@property (strong, nonatomic) UIColor *focusFrameBorderColorStatusRunning; ///< オートフォーカス枠の色(要求中)
@property (strong, nonatomic) UIColor *focusFrameBorderColorStatusLocked; ///< オートフォーカス枠の色(ロック完了)
@property (strong, nonatomic) UIColor *focusFrameBorderColorStatusFailed; ///< オートフォーカス枠の色(ロック失敗)
@property (assign, nonatomic) BOOL showingFocusFrame; ///< オートフォーカス枠を表示しているか否か
@property (assign, nonatomic) RecordingCameraLiveImageViewStatus focusFrameStatus; /// オートフォーカス枠の表示状態
@property (assign, nonatomic) CGRect focusFrameRect; ///< オートフォーカス枠の位置
@property (strong, nonatomic) CALayer *focusFrameLayer; ///< オートフォーカス枠の描画レイヤー
@property (strong, nonatomic) NSTimer *focusFrameHideTimer; ///< オートフォーカス枠の消去待ちタイマー

// 自動露出枠関連
@property (assign, nonatomic) CGFloat exposureFrameBorderWidth; ///< 自動露出枠の幅
@property (assign, nonatomic) CGFloat exposureFrameBorderOpacity; ///< 自動露出枠の不透明度
@property (strong, nonatomic) UIColor *exposureFrameBorderColorStatusRunning; ///< 自動露出枠の色(要求中)
@property (strong, nonatomic) UIColor *exposureFrameBorderColorStatusLocked; ///< 自動露出枠の色(ロック完了)
@property (strong, nonatomic) UIColor *exposureFrameBorderColorStatusFailed; ///< 自動露出枠の色(ロック失敗)
@property (assign, nonatomic) BOOL showingExposureFrame; ///< 自動露出枠を表示しているか否か
@property (assign, nonatomic) RecordingCameraLiveImageViewStatus exposureFrameStatus; /// 自動露出枠の表示状態
@property (assign, nonatomic) CGRect exposureFrameRect; ///< 自動露出枠の位置
@property (strong, nonatomic) CALayer *exposureFrameLayer; ///< 自動露出枠の描画レイヤー
@property (strong, nonatomic) NSTimer *exposureFrameHideTimer; ///< 自動露出枠の消去待ちタイマー

// 顔認識枠関連
@property (assign, nonatomic) CGFloat faceFrameBorderWidth; ///< 顔認識枠の幅
@property (assign, nonatomic) CGFloat faceFrameBorderOpacity; ///< 顔認識枠の不透明度
@property (strong, nonatomic) UIColor *faceFrameBorderColor; ///< 顔認識枠の色(要求中)
@property (strong, nonatomic) NSMutableArray *showingFaceFrames; ///< 顔認識枠を表示しているか否か
@property (strong, nonatomic) NSMutableArray *faceFrameRects; ///< 顔認識枠の位置
@property (strong, nonatomic) NSMutableArray *faceFrameLayers; ///< 顔認識枠の描画レイヤー

// AF有効枠関連
@property (assign, nonatomic) CGFloat autoFocusEffectiveAreaBorderWidth; ///< AF有効枠の幅
@property (assign, nonatomic) CGFloat autoFocusEffectiveAreaBorderOpacity; ///< AF有効枠の不透明度
@property (strong, nonatomic) UIColor *autoFocusEffectiveAreaBorderColor; ///< AF有効枠の色
@property (assign, nonatomic) BOOL showingAutoFocusEffectiveArea; ///< AF有効枠を表示しているか否か
@property (assign, nonatomic) CGRect autoFocusEffectiveAreaRect; ///< AF有効枠の位置
@property (strong, nonatomic) CALayer *autoFocusEffectiveAreaLayer; ///< AF有効枠の描画レイヤー
@property (strong, nonatomic) NSTimer *autoFocusEffectiveAreaHideTimer; ///< AF有効枠の消去待ちタイマー

// AE有効枠関連
@property (assign, nonatomic) CGFloat autoExposureEffectiveAreaBorderWidth; ///< AE有効枠の幅
@property (assign, nonatomic) CGFloat autoExposureEffectiveAreaBorderOpacity; ///< AE有効枠の不透明度
@property (strong, nonatomic) UIColor *autoExposureEffectiveAreaBorderColor; ///< AE有効枠の色
@property (assign, nonatomic) BOOL showingAutoExposureEffectiveArea; ///< AE有効枠を表示しているか否か
@property (assign, nonatomic) CGRect autoExposureEffectiveAreaRect; ///< AE有効枠の位置
@property (strong, nonatomic) CALayer *autoExposureEffectiveAreaLayer; ///< AE有効枠の描画レイヤー
@property (strong, nonatomic) NSTimer *autoExposureEffectiveAreaHideTimer; ///< AE有効枠の消去待ちタイマー

// フラッシュ表現関連
@property (assign, nonatomic) CGFloat flashingOpacity; ///< フラッシュ表現の不透明度
@property (strong, nonatomic) UIColor *flashingColor; ///< フラッシュ表現の色
@property (assign, nonatomic) BOOL showingFlashing; ///< フラッシュ表現を表示しているか否か
@property (strong, nonatomic) CALayer *flashingLayer; ///< フラッシュ表現の描画レイヤー

@end

#pragma mark -

@implementation LiveImageView

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	DEBUG_LOG(@"frame=%@", NSStringFromCGRect(frame));
	
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
	[self initComponent];
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	DEBUG_LOG(@"decoder=%@", decoder);
	
	self = [super initWithCoder:decoder];
	if (!self) {
		return nil;
	}
	[self initComponent];
	return self;
}

- (void)initComponent {
	DEBUG_LOG(@"");

	_focusFrameBorderWidth = 2.0;
	_focusFrameBorderOpacity = 1.0;
	_focusFrameBorderColorStatusRunning = [UIColor colorWithRed:0.75 green:1.0 blue:0.75 alpha:1.0];
	_focusFrameBorderColorStatusLocked = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
	_focusFrameBorderColorStatusFailed = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	_exposureFrameBorderWidth = 2;
	_exposureFrameBorderOpacity = 1.0;
	_exposureFrameBorderColorStatusRunning = [UIColor colorWithRed:1.0 green:1.0 blue:0.75 alpha:1.0];
	_exposureFrameBorderColorStatusLocked = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
	_exposureFrameBorderColorStatusFailed = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	_faceFrameBorderWidth = 2.0;
	_faceFrameBorderOpacity = 1.0;
	_faceFrameBorderColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
	_autoFocusEffectiveAreaBorderWidth = 2.0;
	_autoFocusEffectiveAreaBorderOpacity = 0.5;
	_autoFocusEffectiveAreaBorderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	_autoExposureEffectiveAreaBorderWidth = 2.0;
	_autoExposureEffectiveAreaBorderOpacity = 0.5;
	_autoExposureEffectiveAreaBorderColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	_flashingOpacity = 1.0;
	_flashingColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	// 後から追加したレイヤーの方が手前に現れます。
	// フラッシュ表現のレイヤーを一番手前に表示したいので一番最後にビューに追加します。
	
	// AF有効枠に関する情報を初期化します。
	_showingAutoFocusEffectiveArea = NO;
	_autoFocusEffectiveAreaRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	CALayer *autoFocusEffectiveAreaLayer = [CALayer layer];
	autoFocusEffectiveAreaLayer.borderWidth = _autoFocusEffectiveAreaBorderWidth;
	autoFocusEffectiveAreaLayer.opacity = 0.0;
	autoFocusEffectiveAreaLayer.frame = CGRectZero;
	[self.layer addSublayer:autoFocusEffectiveAreaLayer];
	_autoFocusEffectiveAreaLayer = autoFocusEffectiveAreaLayer;

	// AE有効枠に関する情報を初期化します。
	_showingAutoExposureEffectiveArea = NO;
	_autoExposureEffectiveAreaRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	CALayer *autoExposureEffectiveAreaLayer = [CALayer layer];
	autoExposureEffectiveAreaLayer.borderWidth = _autoExposureEffectiveAreaBorderWidth;
	autoExposureEffectiveAreaLayer.opacity = 0.0;
	autoExposureEffectiveAreaLayer.frame = CGRectZero;
	[self.layer addSublayer:autoExposureEffectiveAreaLayer];
	_autoExposureEffectiveAreaLayer = autoExposureEffectiveAreaLayer;
	
	// 顔認識枠に関する情報を初期化します。
	const NSInteger faceFrames = 8; // 顔認識の最大検出数はどうやら8個らしいです。
	NSMutableArray *showingFaceFrames = [[NSMutableArray alloc] initWithCapacity:faceFrames];
	NSMutableArray *faceFrameRects = [[NSMutableArray alloc] initWithCapacity:faceFrames];
	NSMutableArray *faceFrameLayers = [[NSMutableArray alloc] initWithCapacity:faceFrames];
	for (NSInteger index = 0; index < faceFrames; index++) {
		[showingFaceFrames addObject:@NO];
		CGRect faceFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0);
		[faceFrameRects addObject:[NSValue valueWithCGRect:faceFrameRect]];
		CALayer *faceFrameLayer = [CALayer layer];
		faceFrameLayer.borderWidth = _faceFrameBorderWidth;
		faceFrameLayer.borderColor = _faceFrameBorderColor.CGColor;
		faceFrameLayer.opacity = 0.0;
		faceFrameLayer.frame = CGRectZero;
		[self.layer addSublayer:faceFrameLayer];
		[faceFrameLayers addObject:faceFrameLayer];
	}
	_showingFaceFrames = showingFaceFrames;
	_faceFrameRects = faceFrameRects;
	_faceFrameLayers = faceFrameLayers;

	// 自動露出枠に関する情報を初期化します。
	_showingExposureFrame = NO;
	_exposureFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0);
	CALayer *exposureFrameLayer = [CALayer layer];
	exposureFrameLayer.borderWidth = _exposureFrameBorderWidth;
	exposureFrameLayer.opacity = 0.0;
	exposureFrameLayer.frame = CGRectZero;
	[self.layer addSublayer:exposureFrameLayer];
	_exposureFrameLayer = exposureFrameLayer;
	
	// オートフォーカス枠に関する情報を初期化します。
	_showingFocusFrame = NO;
	_focusFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0);
	CALayer *focusFrameLayer = [CALayer layer];
	focusFrameLayer.borderWidth = _focusFrameBorderWidth;
	focusFrameLayer.opacity = 0.0;
	focusFrameLayer.frame = CGRectZero;
	[self.layer addSublayer:focusFrameLayer];
	_focusFrameLayer = focusFrameLayer;

	// フラッシュ表現に関する情報を初期化します。
	_showingFlashing = NO;
	CALayer *flashingLayer = [CALayer layer];
	flashingLayer.backgroundColor = _flashingColor.CGColor;
	flashingLayer.opacity = 0.0;
	flashingLayer.frame = self.bounds;
	[self.layer addSublayer:flashingLayer];
	_flashingLayer = flashingLayer;
	
	[CATransaction commit];
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	[_focusFrameHideTimer invalidate];
	_focusFrameHideTimer = nil;
	_focusFrameBorderColorStatusRunning = nil;
	_focusFrameBorderColorStatusLocked = nil;
	_focusFrameBorderColorStatusFailed = nil;
	_focusFrameLayer = nil;
	
	[_exposureFrameHideTimer invalidate];
	_exposureFrameHideTimer = nil;
	_exposureFrameBorderColorStatusRunning = nil;
	_exposureFrameBorderColorStatusLocked = nil;
	_exposureFrameBorderColorStatusFailed = nil;
	_exposureFrameLayer = nil;
	
	_faceFrameBorderColor = nil;
	_showingFaceFrames = nil;
	_faceFrameRects = nil;
	_faceFrameLayers = nil;
	
	_autoFocusEffectiveAreaHideTimer = nil;
	[_autoFocusEffectiveAreaHideTimer invalidate];
	_autoFocusEffectiveAreaBorderColor = nil;
	_autoFocusEffectiveAreaLayer = nil;

	_autoExposureEffectiveAreaHideTimer = nil;
	[_autoExposureEffectiveAreaHideTimer invalidate];
	_autoExposureEffectiveAreaBorderColor = nil;
	_autoExposureEffectiveAreaLayer = nil;
	
	_flashingColor = nil;
	_flashingLayer = nil;
}

- (void)setFrame:(CGRect)rect {
	DEBUG_LOG(@"rect=%@", NSStringFromCGRect(rect));

	// リサイズしたか確認します。
	BOOL resized = NO;
	if (self.image) {
		if (!CGRectEqualToRect(self.bounds, rect)) {
			resized = YES;
		}
	}
	
	[super setFrame:rect];
	
	// リサイズが発生している場合はすべての枠の位置を更新します。
	if (self.image && resized) {
		[self updateAllFramesPosition];
	}
}

- (void)setBounds:(CGRect)rect {
	DEBUG_LOG(@"rect=%@", NSStringFromCGRect(rect));

	// リサイズしたか確認します。
	BOOL resized = NO;
	if (self.image) {
		if (!CGRectEqualToRect(self.bounds, rect)) {
			resized = YES;
		}
	}

	[super setBounds:rect];

	// リサイズが発生している場合はすべての枠の位置を更新します。
	if (self.image && resized) {
		[self updateAllFramesPosition];
	}
}

- (void)setImage:(UIImage *)image {
	DEBUG_DETAIL_LOG(@"image=%@", image);
	
	// リサイズしたか確認します。
	BOOL resized = NO;
	if (image) {
		if (!self.image || // まだ表示していない
			!CGSizeEqualToSize(self.image.size, image.size) || // 表示するサイズが違う
			(self.image.imageOrientation != image.imageOrientation)) { // 表示する向きが違う
			resized = YES;
		}
	}

	// ライブビューが消失する場合は枠を全て非表示します。
	if (!image && self.image) {
		[self hideFocusFrame:NO];
		[self hideExposureFrame:NO];
		[self hideFaceFrames:NO];
	}
	
	// 表示を更新します。
	[super setImage:image];

	// リサイズが発生している場合はすべての枠の位置を更新します。
	if (self.image && resized) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[self updateAllFramesPosition];
		[CATransaction commit];
	}
}

#pragma mark -

- (CGPoint)pointWithGestureRecognizer:(UIGestureRecognizer *)gesture {
	DEBUG_LOG(@"");
	
	if (!gesture || !self.image) {
		return CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	}
	
	CGPoint pointOnView = [gesture locationInView:self];
	CGPoint pointOnImage = [self convertPointFromViewArea:pointOnView];
	CGPoint pointOnViewfinder = OLYCameraConvertPointOnLiveImageIntoViewfinder(pointOnImage, self.image);
	
	return pointOnViewfinder;
}

- (BOOL)containsPoint:(CGPoint)point {
	return CGRectContainsPoint(CGRectMake(0, 0, 1, 1), point);
}

- (void)hideFocusFrame:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	[self.focusFrameHideTimer invalidate];
	self.focusFrameHideTimer = nil;
	
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.focusFrameLayer.opacity = 0.0;
	self.showingFocusFrame = NO;
	if (!animated) {
		[CATransaction commit];
	}
}

- (void)showFocusFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, status=%ld", NSStringFromCGRect(rect), (long)status);
	[self showFocusFrame:rect status:status duration:0.0 animated:animated];
}

- (void)showFocusFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status duration:(NSTimeInterval)duration animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, status=%ld, duration=%f", NSStringFromCGRect(rect), (long)status, duration);

	[self.focusFrameHideTimer invalidate];
	self.focusFrameHideTimer = nil;
	
	if (!self.image) {
		return;
	}
	
	CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
	CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
	CGColorRef frameColorRef;
	switch (status) {
		case RecordingCameraLiveImageViewStatusRunning:
			frameColorRef = self.focusFrameBorderColorStatusRunning.CGColor;
			break;
		case RecordingCameraLiveImageViewStatusLocked:
			frameColorRef = self.focusFrameBorderColorStatusLocked.CGColor;
			break;
		case RecordingCameraLiveImageViewStatusFailed:
			frameColorRef = self.focusFrameBorderColorStatusFailed.CGColor;
			break;
	}
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.focusFrameRect = rect;
	self.focusFrameLayer.borderColor = frameColorRef;
	self.focusFrameLayer.frame = rectOnImageView;
	self.focusFrameLayer.opacity = self.focusFrameBorderOpacity;
	if (!animated) {
		[CATransaction commit];
	}

	self.focusFrameStatus = status;
	self.showingFocusFrame = YES;
	
	if (duration > 0) {
		self.focusFrameHideTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFireFocusFrameHideTimer:) userInfo:nil repeats:NO];
	}
}

- (void)hideExposureFrame:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	[self.exposureFrameHideTimer invalidate];
	self.exposureFrameHideTimer = nil;

	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.exposureFrameLayer.opacity = 0.0;
	if (!animated) {
		[CATransaction commit];
	}

	self.showingExposureFrame = NO;
}

- (void)showExposureFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, status=%ld", NSStringFromCGRect(rect), (long)status);
	[self showExposureFrame:rect status:status duration:0.0 animated:animated];
}

- (void)showExposureFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status duration:(NSTimeInterval)duration animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, status=%ld, duration=%f", NSStringFromCGRect(rect), (long)status, duration);

	[self.exposureFrameHideTimer invalidate];
	self.exposureFrameHideTimer = nil;

	if (!self.image) {
		return;
	}

	CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
	CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
	CGColorRef frameColorRef;
	switch (status) {
		case RecordingCameraLiveImageViewStatusRunning:
			frameColorRef = self.exposureFrameBorderColorStatusRunning.CGColor;
			break;
		case RecordingCameraLiveImageViewStatusLocked:
			frameColorRef = self.exposureFrameBorderColorStatusLocked.CGColor;
			break;
		case RecordingCameraLiveImageViewStatusFailed:
			frameColorRef = self.exposureFrameBorderColorStatusFailed.CGColor;
			break;
	}
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.exposureFrameRect = rect;
	self.exposureFrameLayer.borderColor = frameColorRef;
	self.exposureFrameLayer.frame = rectOnImageView;
	self.exposureFrameLayer.opacity = self.exposureFrameBorderOpacity;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.exposureFrameStatus = status;
	self.showingExposureFrame = YES;
	
	if (duration > 0) {
		self.focusFrameHideTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFireExposureFrameHideTimer:) userInfo:nil repeats:NO];
	}
}

- (void)hideFaceFrames:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	for (CALayer *layer in self.faceFrameLayers) {
		layer.opacity = 0.0;
	}
	if (!animated) {
		[CATransaction commit];
	}

	for (NSInteger index = 0; index < self.showingFaceFrames.count; index++) {
		self.showingFaceFrames[index] = @NO;
	}
}

- (void)showFaceFrames:(NSDictionary *)frames animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"frames=%@", frames);

	if (!self.image) {
		return;
	}
	
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	
	// 顔認識結果の辞書のキーは添え字を示す0から7までの数字らしいです。
	for (NSInteger index = 0; index < self.showingFaceFrames.count; index++) {
		NSString *rectValueKey = [NSString stringWithFormat:@"%ld", (long)index];
		NSValue *rectValue = frames[rectValueKey];
		// あらかじめ用意してある枠の添え字に対する顔認識結果が見つかった場合は、
		// その顔認識情報で枠を表示します。見つからなければ枠を非表示にします。
		if (rectValue) {
			self.faceFrameRects[index] = rectValue;
			CGRect rect = [rectValue CGRectValue];
			CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
			CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
			CALayer *faceFrameLayer = self.faceFrameLayers[index];
			faceFrameLayer.cornerRadius = MIN(rectOnImageView.size.width, rectOnImageView.size.height) / 2.0; // 枠は丸型にします。
			faceFrameLayer.frame = rectOnImageView;
			faceFrameLayer.opacity = self.faceFrameBorderOpacity;
			self.showingFaceFrames[index] = @YES;
		} else {
			CALayer *faceFrameLayer = self.faceFrameLayers[index];
			faceFrameLayer.opacity = 0.0;
			self.showingFaceFrames[index] = @NO;
		}
	}

	if (!animated) {
		[CATransaction commit];
	}
}

- (void)hideAutoFocusEffectiveArea:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");
	
	[self.autoFocusEffectiveAreaHideTimer invalidate];
	self.autoFocusEffectiveAreaHideTimer = nil;
	
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.autoFocusEffectiveAreaLayer.opacity = 0.0;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingAutoFocusEffectiveArea = NO;
}

- (void)showAutoFocusEffectiveArea:(CGRect)rect duration:(NSTimeInterval)duration animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, duration=%f", NSStringFromCGRect(rect), duration);
	
	[self.autoFocusEffectiveAreaHideTimer invalidate];
	self.autoFocusEffectiveAreaHideTimer = nil;
	
	if (!self.image) {
		return;
	}
	
	CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
	CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.autoFocusEffectiveAreaRect = rect;
	self.autoFocusEffectiveAreaLayer.borderColor = [self.autoFocusEffectiveAreaBorderColor CGColor];
	self.autoFocusEffectiveAreaLayer.frame = rectOnImageView;
	self.autoFocusEffectiveAreaLayer.opacity = self.autoFocusEffectiveAreaBorderOpacity;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingAutoFocusEffectiveArea = YES;
	
	if (duration > 0) {
		self.autoFocusEffectiveAreaHideTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFireAutoFocusEffectiveAreaHideTimer:) userInfo:nil repeats:NO];
	}
}

- (void)hideAutoExposureEffectiveArea:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");
	
	[self.autoExposureEffectiveAreaHideTimer invalidate];
	self.autoExposureEffectiveAreaHideTimer = nil;
	
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.autoExposureEffectiveAreaLayer.opacity = 0.0;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingAutoExposureEffectiveArea = NO;
}

- (void)showAutoExposureEffectiveArea:(CGRect)rect duration:(NSTimeInterval)duration animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"rect=%@, duration=%f", NSStringFromCGRect(rect), duration);
	
	[self.autoExposureEffectiveAreaHideTimer invalidate];
	self.autoExposureEffectiveAreaHideTimer = nil;
	
	if (!self.image) {
		return;
	}
	
	CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
	CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.autoExposureEffectiveAreaRect = rect;
	self.autoExposureEffectiveAreaLayer.borderColor = [self.autoExposureEffectiveAreaBorderColor CGColor];
	self.autoExposureEffectiveAreaLayer.frame = rectOnImageView;
	self.autoExposureEffectiveAreaLayer.opacity = self.autoExposureEffectiveAreaBorderOpacity;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingAutoExposureEffectiveArea = YES;
	
	if (duration > 0) {
		self.autoExposureEffectiveAreaHideTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didFireAutoExposureEffectiveAreaHideTimer:) userInfo:nil repeats:NO];
	}
}

/// 撮影中を示すフラッシュの表示を終了します。
- (void)hideFlashing:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.flashingLayer.opacity = 0.0;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingFlashing = NO;
}

/// 撮影中を示すフラッシュの表示を開始します。
- (void)showFlashing:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	if (!self.image) {
		return;
	}
	
	if (!animated) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	self.flashingLayer.opacity = self.flashingOpacity;
	if (!animated) {
		[CATransaction commit];
	}
	
	self.showingFlashing = YES;
}

#pragma mark -

- (void)updateAllFramesPosition {
	DEBUG_DETAIL_LOG(@"");

	if (!self.image) {
		return;
	}

	// オートフォーカス枠の位置を更新します。
	{
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(self.focusFrameRect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		self.focusFrameLayer.frame = rectOnImageView;
	}

	// 自動露出枠の位置を更新します。
	{
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(self.exposureFrameRect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		self.exposureFrameLayer.frame = rectOnImageView;
	}
	
	// 顔認識枠の位置を更新します。
	for (NSInteger index = 0; index < self.showingFaceFrames.count; index++) {
		CGRect rect = [self.faceFrameRects[index] CGRectValue];
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		CALayer *faceFrameLayer = self.faceFrameLayers[index];
		faceFrameLayer.cornerRadius = MIN(rectOnImageView.size.width, rectOnImageView.size.height) / 2.0; // 枠は丸型にします。
		faceFrameLayer.frame = rectOnImageView;
	}
	
	// AF有効枠の位置を更新します。
	{
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(self.autoFocusEffectiveAreaRect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		self.autoFocusEffectiveAreaLayer.frame = rectOnImageView;
	}
	
	// AE有効枠の位置を更新します。
	{
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(self.autoExposureEffectiveAreaRect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		self.autoExposureEffectiveAreaLayer.frame = rectOnImageView;
	}
	
	// フラッシュ表現の位置を更新します。
	{
		CGRect rect = CGRectMake(0, 0, 1, 1);
		CGRect rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image);
		CGRect rectOnImageView = [self convertRectFromImageArea:rectOnImage];
		self.flashingLayer.frame = rectOnImageView;
	}
}

- (void)didFireFocusFrameHideTimer:(NSTimer *)timer {
	DEBUG_DETAIL_LOG(@"");
	[self hideFocusFrame:YES];
}

- (void)didFireExposureFrameHideTimer:(NSTimer *)timer {
	DEBUG_DETAIL_LOG(@"");
	[self hideExposureFrame:YES];
}

- (void)didFireAutoFocusEffectiveAreaHideTimer:(NSTimer *)timer {
	DEBUG_DETAIL_LOG(@"");
	[self hideAutoFocusEffectiveArea:YES];
}

- (void)didFireAutoExposureEffectiveAreaHideTimer:(NSTimer *)timer {
	DEBUG_DETAIL_LOG(@"");
	[self hideAutoExposureEffectiveArea:YES];
}

- (CGPoint)convertPointFromImageArea:(CGPoint)point {
	DEBUG_DETAIL_LOG(@"point=%@", NSStringFromCGPoint(point));

	if (!self.image) {
		return CGPointZero;
	}
	
	CGPoint viewPoint = point;
	CGSize imageSize = self.image.size;
	CGSize viewSize  = self.bounds.size;
	CGFloat ratioX = viewSize.width / imageSize.width;
	CGFloat ratioY = viewSize.height / imageSize.height;
	CGFloat scale = 0.0;
	
	switch (self.contentMode) {
		case UIViewContentModeScaleToFill:	// go to next label.
		case UIViewContentModeRedraw:
			viewPoint.x *= ratioX;
			viewPoint.y *= ratioY;
			break;
		case UIViewContentModeScaleAspectFit:
			scale = MIN(ratioX, ratioY);
			viewPoint.x *= scale;
			viewPoint.y *= scale;
			viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0f;
			viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0f;
			break;
		case UIViewContentModeScaleAspectFill:
			scale = MAX(ratioX, ratioY);
			viewPoint.x *= scale;
			viewPoint.y *= scale;
			viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0f;
			viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0f;
			break;
		case UIViewContentModeCenter:
			viewPoint.x += viewSize.width / 2.0  - imageSize.width  / 2.0f;
			viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
			break;
		case UIViewContentModeTop:
			viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
			break;
		case UIViewContentModeBottom:
			viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
			viewPoint.y += viewSize.height - imageSize.height;
			break;
		case UIViewContentModeLeft:
			viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
			break;
		case UIViewContentModeRight:
			viewPoint.x += viewSize.width - imageSize.width;
			viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;
			break;
		case UIViewContentModeTopRight:
			viewPoint.x += viewSize.width - imageSize.width;
			break;
		case UIViewContentModeBottomLeft:
			viewPoint.y += viewSize.height - imageSize.height;
			break;
		case UIViewContentModeBottomRight:
			viewPoint.x += viewSize.width  - imageSize.width;
			viewPoint.y += viewSize.height - imageSize.height;
			break;
		case UIViewContentModeTopLeft:	// go to next label.
		default:
			break;
	}
	
	return viewPoint;
}

- (CGPoint)convertPointFromViewArea:(CGPoint)point {
	DEBUG_DETAIL_LOG(@"point=%@", NSStringFromCGPoint(point));

	if (!self.image) {
		return CGPointZero;
	}
	
	CGPoint imagePoint = point;
	CGSize imageSize = self.image.size;
	CGSize viewSize  = self.bounds.size;
	CGFloat ratioX = viewSize.width / imageSize.width;
	CGFloat ratioY = viewSize.height / imageSize.height;
	CGFloat scale = 0.0;
	
	switch (self.contentMode) {
		case UIViewContentModeScaleToFill:	// go to next label.
		case UIViewContentModeRedraw:
			imagePoint.x /= ratioX;
			imagePoint.y /= ratioY;
			break;
		case UIViewContentModeScaleAspectFit:
			scale = MIN(ratioX, ratioY);
			imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0f;
			imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0f;
			imagePoint.x /= scale;
			imagePoint.y /= scale;
			break;
		case UIViewContentModeScaleAspectFill:
			scale = MAX(ratioX, ratioY);
			imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0f;
			imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0f;
			imagePoint.x /= scale;
			imagePoint.y /= scale;
			break;
		case UIViewContentModeCenter:
			imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
			imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
			break;
		case UIViewContentModeTop:
			imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
			break;
		case UIViewContentModeBottom:
			imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0f;
			imagePoint.y -= (viewSize.height - imageSize.height);
			break;
		case UIViewContentModeLeft:
			imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
			break;
		case UIViewContentModeRight:
			imagePoint.x -= (viewSize.width - imageSize.width);
			imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;
			break;
		case UIViewContentModeTopRight:
			imagePoint.x -= (viewSize.width - imageSize.width);
			break;
		case UIViewContentModeBottomLeft:
			imagePoint.y -= (viewSize.height - imageSize.height);
			break;
		case UIViewContentModeBottomRight:
			imagePoint.x -= (viewSize.width - imageSize.width);
			imagePoint.y -= (viewSize.height - imageSize.height);
			break;
		case UIViewContentModeTopLeft:		// go to next label.
		default:
			break;
	}
	
	return imagePoint;
}

- (CGRect)convertRectFromImageArea:(CGRect)rect {
	DEBUG_DETAIL_LOG(@"rect=%@", NSStringFromCGRect(rect));

	if (!self.image) {
		return CGRectZero;
	}
	
	CGPoint imageTopLeft = rect.origin;
	CGPoint imageBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	
	CGPoint viewTopLeft = [self convertPointFromImageArea:imageTopLeft];
	CGPoint viewBottomRight = [self convertPointFromImageArea:imageBottomRight];
	
	CGFloat viewWidth = ABS(viewBottomRight.x - viewTopLeft.x);
	CGFloat viewHeight = ABS(viewBottomRight.y - viewTopLeft.y);
	CGRect viewRect = CGRectMake(viewTopLeft.x, viewTopLeft.y, viewWidth, viewHeight);
	
	return viewRect;
}

- (CGRect)convertRectFromViewArea:(CGRect)rect {
	DEBUG_DETAIL_LOG(@"rect=%@", NSStringFromCGRect(rect));

	if (!self.image) {
		return CGRectZero;
	}
	
	CGPoint viewTopLeft = rect.origin;
	CGPoint viewBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	
	CGPoint imageTopLeft = [self convertPointFromViewArea:viewTopLeft];
	CGPoint imageBottomRight = [self convertPointFromViewArea:viewBottomRight];
	
	CGFloat imageWidth = ABS(imageBottomRight.x - imageTopLeft.x);
	CGFloat imageHeight = ABS(imageBottomRight.y - imageTopLeft.y);
	CGRect imageRect = CGRectMake(imageTopLeft.x, imageTopLeft.y, imageWidth, imageHeight);
	
	return imageRect;
}

@end
