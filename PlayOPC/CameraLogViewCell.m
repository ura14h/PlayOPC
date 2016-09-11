//
//  CameraLogViewCell.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "CameraLogViewCell.h"

@interface CameraLogViewCell ()

@end

@implementation CameraLogViewCell

- (void)awakeFromNib {
	DEBUG_DETAIL_LOG(@"");
	[super awakeFromNib];

	NSString *emptyLabel = @" ";
	self.messageLabel.text = emptyLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"selected=%@, animated=%@", (selected ? @"YES" : @"NO"), (animated ? @"YES" : @"NO"));
	[super setSelected:selected animated:animated];
}

@end
