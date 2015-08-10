//
//  ItemSelectionViewController.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/16.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

extern NSString *const ItemSelectionViewItemTitleKey; ///< 値の表示用文言への辞書キー
extern NSString *const ItemSelectionViewItemImageKey; ///< 値の画像への辞書キー
extern NSString *const ItemSelectionViewItemValueKey; ///< 値への辞書キー

@protocol ItemSelectionViewControllerDelegate;


/// 値のリストを表示できます。ユーザーがそのリストから値を選択できます。
@interface ItemSelectionViewController : UITableViewController

@property (assign, nonatomic) NSInteger tag; ///< アプリケーション内でこのクラスのコントローラーを識別するに使用できる整数
@property (strong, nonatomic) NSArray *items; ///< 値のリスト(各要素は文字列または辞書であること。辞書の場合は別途定義の辞書キーでアクセスできること。)
@property (assign, nonatomic) NSUInteger selectedItemIndex; ///< ユーザーが最後に選択したもしくは現在選択されている値のリスト上でのインデックス
@property (strong, nonatomic) NSString *itemCellIdentifier; ///< 表示セルの識別子(必ず設定してください)
@property (weak, nonatomic) id<ItemSelectionViewControllerDelegate> itemSelectionDeleage; ///< 値のリストを表示中に起きたイベントを通知する先

@end

/// 値のリストを表示中に起きたイベントを通知します。
@protocol ItemSelectionViewControllerDelegate <NSObject>
@optional

/// ユーザーがリストから値を選択した時に呼び出されます。
- (void)itemSelectionViewController:(ItemSelectionViewController *)controller didSelectedItemIndex:(NSUInteger)index;

@end
