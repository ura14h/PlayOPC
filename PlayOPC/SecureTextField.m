//
//  SecureTextField.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2023/02/08.
//  Copyright (c) 2023 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SecureTextField.h"

@interface SecureTextField ()

@property (strong, nonatomic) UIButton *button;

@end

#pragma mark -

@implementation SecureTextField

#pragma mark -

- (id)initWithCoder:(NSCoder *)decoder {
	DEBUG_LOG(@"");
	
	self = [super initWithCoder:decoder];
	if (!self) {
		return nil;
	}
	
	_button = [[UIButton alloc] init];
	CGFloat size = self.bounds.size.height;
	[_button setFrame:CGRectMake(0, 0, size, size)];
	[_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
	[self setRightView:_button];
	[self setRightViewMode:UITextFieldViewModeAlways];
	[self setSecureStateImage];
	
	return self;
}

- (void)dealloc {
	DEBUG_LOG(@"");
	
	_button = nil;
}

- (void)setSecureStateImage {
	DEBUG_LOG(@"");
	
	UIImage *image = nil;
	if (self.isSecureTextEntry) {
		image = [UIImage systemImageNamed:@"eye"];
	} else {
		image = [UIImage systemImageNamed:@"eye.slash"];
	}
	[self.button setImage:image forState:UIControlStateNormal];
}

- (IBAction)didTapButton:(UIButton *)sender {
	DEBUG_LOG(@"");
	
	self.secureTextEntry = !self.secureTextEntry;
	[self setSecureStateImage];
}

@end
