//
//  PlaybackViewCell.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/10.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "PlaybackViewCell.h"

@interface PlaybackViewCell ()

@end

@implementation PlaybackViewCell

- (void)awakeFromNib {
	DEBUG_DETAIL_LOG(@"");
	[super awakeFromNib];
	
	NSString *emptyLabel = @" ";
	self.thumbnailImage.image = nil;
	self.filenameLabel.text = emptyLabel;
	self.datetimeLabel.text = emptyLabel;
	self.filesizeLabel.text = emptyLabel;
	self.attributesLabel.text = emptyLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	DEBUG_DETAIL_LOG(@"selected=%@, animated=%@", (selected ? @"YES" : @"NO"), (animated ? @"YES" : @"NO"));
	[super setSelected:selected animated:animated];
}

@end
