//
//  RecImageButton.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/07.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RecImageButton.h"

@interface RecImageButton ()

@property (assign, nonatomic) CGSize thumbnailImageSize; ///< レックビューサムネイル画像のサイズ

@end

#pragma mark -

@implementation RecImageButton

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
	
	_thumbnailImageSize = CGSizeMake(64.0, 64.0);
}

- (void)dealloc {
	DEBUG_LOG(@"");
}

- (CGSize)intrinsicContentSize {
	DEBUG_DETAIL_LOG(@"");
	
	return self.imageView.intrinsicContentSize;
}

#pragma mark -

- (void)setImage:(UIImage *)image {
	DEBUG_LOG(@"image=%@", image);
	
	// フェードアニメーションを設定します。
	// FIXME: 一度削除してから再び設定しているがこの方法で良いのかよく分からない。
	[self.layer removeAllAnimations];
	CATransition *transision = [CATransition animation];
	transision.duration = 0.25;
	transision.type = kCATransitionFade;
	[self.layer addAnimation:transision forKey:nil];
	
	if (!image) {
		// 設定する画像がない場合は非表示にします。
		[super setImage:image forState:UIControlStateNormal];
		return;
	}
	
	// リサイズする大きさを求めます。
	CGFloat widthRatio  = self.thumbnailImageSize.width  / image.size.width;
	CGFloat heightRatio = self.thumbnailImageSize.height / image.size.height;
	CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
	CGSize thumbnailSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
	
	// リサイズした画像を作成します。
	// 縁線も描画します。縁線の外側は黒色で内側は白色です。
	CGRect rect = CGRectMake(0.0, 0.0, thumbnailSize.width, thumbnailSize.height);
	UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	[image drawInRect:rect];
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextStrokeRectWithWidth(context, rect, 2.0);
	CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextStrokeRectWithWidth(context, rect, 1.0);
	UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// 表示を更新します。
	[super setImage:thumbnailImage forState:UIControlStateNormal];
}

@end
