//
//  MarginedLabel.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/08/02.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "MarginedLabel.h"

@implementation MarginedLabel

- (id)initWithCoder:(NSCoder *)decoder {
	DEBUG_LOG(@"");
	
	self = [super initWithCoder:decoder];
	if (!self) {
		return nil;
	}
	
	_textMargins = UIEdgeInsetsMake(6.0, 12.0, 6.0, 12.0);
	
	return self;
}

- (void)drawTextInRect:(CGRect)rect {
	DEBUG_LOG(@"");

	[super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textMargins)];
}

- (CGSize)intrinsicContentSize {
	DEBUG_LOG(@"");

	CGSize size = [super intrinsicContentSize];
	size.width += self.textMargins.left;
	size.width += self.textMargins.right;
	size.height += self.textMargins.top;
	size.height += self.textMargins.bottom;
	
	return size;
}

@end
