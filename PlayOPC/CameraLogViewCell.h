//
//  CameraLogViewCell.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/05/17.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// カメラキットのログを表示します。
@interface CameraLogViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel; ///< ログメッセージ

@end
