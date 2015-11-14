//
//  ImmediatelyPanGestureRecognizer.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/11/14.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ImmediatelyPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation ImmediatelyPanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	DEBUG_DETAIL_LOG(@"");

	[super touchesBegan:touches withEvent:event];
	self.state = UIGestureRecognizerStateBegan;
}

@end
