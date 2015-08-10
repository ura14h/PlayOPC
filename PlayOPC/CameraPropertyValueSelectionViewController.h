//
//  CameraPropertyValueSelectionViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/11.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "ItemSelectionViewController.h"

/// カメラプロパティの値リストを表示できます。ユーザーがカメラプロパティのリストから値を選択できます。
@interface CameraPropertyValueSelectionViewController : ItemSelectionViewController

@property (strong, nonatomic) NSString *property; ///< 値をリスト表示するカメラプロパティ

@end
