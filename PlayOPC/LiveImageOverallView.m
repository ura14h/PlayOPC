//
//  LiveImageOverallView.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/10/25.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LiveImageOverallView.h"

@interface LiveImageOverallView ()

@property (assign, nonatomic) CGSize maximumOverallViewSize; ///< このビューの縦横サイズの最大値
@property (strong, nonatomic) CALayer *displayAreaLayer; ///< ライブビュー拡大している表示領域枠の描画レイヤー

@end

#pragma mark -

@implementation LiveImageOverallView

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
	
	_maximumOverallViewSize = CGSizeMake(64.0, 64.0);

	// 枠とドロップシャドウを追加します。
	self.layer.borderWidth = 1.0;
	self.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.layer.masksToBounds = NO;
	self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.layer.shadowRadius = 4.0;

	// 表示領域枠に関する情報を初期化します。
	CALayer *displayAreaLayer = [CALayer layer];
	displayAreaLayer.backgroundColor = [[UIColor whiteColor] CGColor];
	displayAreaLayer.opacity = 1.0;
	displayAreaLayer.frame = CGRectZero;
	[self.layer addSublayer:displayAreaLayer];
	_displayAreaLayer = displayAreaLayer;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_displayAreaLayer = nil;
}

#pragma mark -

- (void)setOverallViewSize:(CGSize)size {
	DEBUG_DETAIL_LOG(@"");

	BOOL needLayout = !CGSizeEqualToSize(_overallViewSize, size);
	_overallViewSize = size;
	
	// 変化がある場合はビューの再配置が必要です。
	if (needLayout) {
		[self invalidateIntrinsicContentSize];
		[self.superview layoutIfNeeded];
		[self updateDisplayAreaLayer];
	}
}

- (void)setDisplayAreaRect:(CGRect)rect {
	DEBUG_DETAIL_LOG(@"");
	
	[self setDisplayAreaRect:rect animated:NO];
}

- (void)setDisplayAreaRect:(CGRect)rect animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"");

	BOOL needLayout = !CGRectEqualToRect(_displayAreaRect, rect);
	_displayAreaRect = rect;

	// 変化がある場合はビューの再表示が必要です。
	if (needLayout) {
		if (!animated) {
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		}
		[self updateDisplayAreaLayer];
		if (!animated) {
			[CATransaction commit];
		}
	}
}

- (void)setOrientation:(UIImageOrientation)orientation {
	DEBUG_DETAIL_LOG(@"");

	BOOL needLayout = (_orientation != orientation);
	_orientation = orientation;
	
	// 変化がある場合はビューの再配置が必要です。
	if (needLayout) {
		[self invalidateIntrinsicContentSize];
		[self.superview layoutIfNeeded];
		[self updateDisplayAreaLayer];
	}
}

#pragma mark -

- (CGSize)intrinsicContentSize {
	DEBUG_DETAIL_LOG(@"");

	CGSize size = [self overallViewSizeInBounds];

	// 回転方向を反映します。
	CGSize viewSize;
	switch (self.orientation) {
		case UIImageOrientationUp:
		case UIImageOrientationDown:
			viewSize = CGSizeMake(size.width, size.height);
			break;
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			viewSize = CGSizeMake(size.height, size.width);
			break;
		default:
			// ありえません。
			viewSize = CGSizeZero;
			break;
	}
	
	return viewSize;
}

#pragma mark -

/// ビューに収まるようにリサイズされた全体サイズを取得します。
- (CGSize)overallViewSizeInBounds {
	DEBUG_DETAIL_LOG(@"");
	
	// サイズがまだ未設定の場合はとりあえず最小のサイズを返します。
	if (CGSizeEqualToSize(self.overallViewSize, CGSizeZero)) {
		return CGSizeZero;
	}
	
	// 最大サイズにフィットするアスペクト比でのビューのサイズを計算します。
	// MARK: カメラファームウェアが1.0だと、アスペクト比を変えてもoverallViewSizeは変わらないようです。
	CGFloat width;
	CGFloat height;
	if (self.overallViewSize.width > self.overallViewSize.height) {
		width = self.maximumOverallViewSize.width;
		height = self.maximumOverallViewSize.height * self.overallViewSize.height / self.overallViewSize.width;
	} else {
		width = self.maximumOverallViewSize.width * self.overallViewSize.width / self.overallViewSize.height;
		height = self.maximumOverallViewSize.height;
	}
	
	return CGSizeMake(width, height);
}

/// ライブビュー拡大している表示領域枠の位置を更新します。
- (void)updateDisplayAreaLayer {
	DEBUG_DETAIL_LOG(@"");

	// 表示領域枠の位置を計算します。
	// MARK: カメラファームウェアが1.0だと、displayAreaRectの値は正しくないようです。
	CGSize overall = [self overallViewSizeInBounds];
	CGFloat w;
	CGFloat h;
	CGFloat x;
	CGFloat y;
	switch (self.orientation) {
		case UIImageOrientationUp:
			w = self.displayAreaRect.size.width * overall.width;
			h = self.displayAreaRect.size.height * overall.height;
			x = self.displayAreaRect.origin.x * overall.width;
			y = self.displayAreaRect.origin.y * overall.height;
			break;
		case UIImageOrientationDown:
			// 上下が逆さになっているので補正します。
			w = self.displayAreaRect.size.width * overall.width;
			h = self.displayAreaRect.size.height * overall.height;
			x = (1.0 - self.displayAreaRect.origin.x) * overall.width - w;
			y = (1.0 - self.displayAreaRect.origin.y) * overall.height - h;
			break;
		case UIImageOrientationLeft:
			// 時計回りに90度回転しているので補正します。
			w = self.displayAreaRect.size.height * overall.height;
			h = self.displayAreaRect.size.width * overall.width;
			x = self.displayAreaRect.origin.y * overall.height;
			y = (1.0 - self.displayAreaRect.origin.x) * overall.width - w;
			break;
		case UIImageOrientationRight:
			// 反時計回りに90度回転しているので補正します。
			w = self.displayAreaRect.size.height * overall.height;
			h = self.displayAreaRect.size.width * overall.width;
			x = (1.0 - self.displayAreaRect.origin.y) * overall.height - h;
			y = self.displayAreaRect.origin.x * overall.width;
			break;
		default:
			// ありえません。
			return;
	}
	CGRect display = CGRectMake(x, y, w, h);
	
	// 表示を更新します。
	self.displayAreaLayer.frame = display;
}

@end
