//
//  LiveImageGridLayer.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/11/14.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LiveImageGridLayer.h"

@implementation LiveImageGridLayer

- (instancetype)initWithCoder:(NSCoder *)decoder {
	DEBUG_LOG(@"");

	self = [super initWithCoder:decoder];
	if (!self) {
		return nil;
	}
	[self initComponent];
	return self;
}

- (instancetype)initWithLayer:(id)layer {
	DEBUG_LOG(@"");
	
	self = [super initWithLayer:layer];
	if (!self) {
		return nil;
	}
	[self initComponent];
	return self;
}

- (void)initComponent {
	DEBUG_LOG(@"");

	_gridBands = 3;
	_gridLineWidth = 1.0;
	_gridLineColor = [UIColor whiteColor];
	
	self.needsDisplayOnBoundsChange = YES;
}

- (void)dealloc {
	DEBUG_LOG(@"");

	_gridLineColor = nil;
}

- (void)setBounds:(CGRect)bounds {
	DEBUG_DETAIL_LOG(@"");
	[super setBounds:bounds];

	self.contentsScale = [[UIScreen mainScreen] scale];
	[self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)context {
	DEBUG_DETAIL_LOG(@"");

	if (self.gridBands == 0 || !self.gridLineColor) {
		return;
	}
	CGSize size = self.bounds.size;
	CGFloat step = 1.0 / (CGFloat)self.gridBands;
	
	for (CGFloat y = 0.0; y < 1.0; y += step) {
		if (y > 0.0 && y < 1.0) {
			CGPoint points[] = {
				CGPointMake(0.0 * size.width, y * size.height),
				CGPointMake(1.0 * size.width, y * size.height),
			};
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddLines(path, nil, points, sizeof(points) / sizeof(CGPoint));
			CGContextAddPath(context, path);
			CGPathRelease(path);
		}
	}
	
	for (CGFloat x = 0.0; x < 1.0; x += step) {
		if (x > 0.0 && x < 1.0) {
			CGPoint points[] = {
				CGPointMake(x * size.width, 0.0 * size.height),
				CGPointMake(x * size.width, 1.0 * size.height),
			};
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddLines(path, nil, points, sizeof(points) / sizeof(CGPoint));
			CGContextAddPath(context, path);
			CGPathRelease(path);
		}
	}
	
	CGContextSetStrokeColorWithColor(context, [self.gridLineColor CGColor]);
	CGContextSetLineWidth(context, self.gridLineWidth);
	CGContextDrawPath(context, kCGPathStroke);
}

- (void)setGridBands:(NSUInteger)lines {
	DEBUG_DETAIL_LOG(@"");

	_gridBands = lines;
	[self setNeedsDisplay];
}

- (void)setGridLineColor:(UIColor *)color {
	DEBUG_DETAIL_LOG(@"");

	_gridLineColor = color;
	[self setNeedsDisplay];
}

@end
