//
//  UIImageView+Animation.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/07/03.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "UIImageView+Animation.h"

@implementation UIImageView (Animation)

- (void)setAnimationTemplateImages:(NSArray *)images {
	DEBUG_DETAIL_LOG(@"images=%@", images);

	NSMutableArray *templateImages = [[NSMutableArray alloc] initWithCapacity:images.count];
	for (UIImage *image in images) {
		// 指定されたイメージから、描画モードがテンプレート画像になるようなイメージを作成します。
		UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0, image.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		CGContextClipToMask(context, rect, image.CGImage);
		[self.tintColor setFill];
		CGContextFillRect(context, rect);
		UIImage *templateImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[templateImages addObject:templateImage];
	}
	self.animationImages = templateImages;
}

@end
