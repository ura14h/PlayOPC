//
//  LiveImageView.h
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/04/13.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

/// 枠表示状態
typedef enum : NSInteger {
	RecordingCameraLiveImageViewStatusRunning, ///< 要求中
	RecordingCameraLiveImageViewStatusLocked, ///< ロック完了
	RecordingCameraLiveImageViewStatusFailed, ///< ロック失敗
} RecordingCameraLiveImageViewStatus;

/// カメラのライブビューを表示します。
@interface LiveImageView : UIImageView

/// ジェスチャーが認識したビューファインダー系の座標を取得します。
- (CGPoint)pointWithGestureRecognizer:(UIGestureRecognizer *)gesture;

/// 指定されたビューファインダー系の座標がライブビューの表示エリアに含まれているか否かを示します。
- (BOOL)containsPoint:(CGPoint)point;

/// フォーカス枠を非表示にします。
- (void)hideFocusFrame:(BOOL)animated;

/// フォーカス枠を表示します。
- (void)showFocusFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status animated:(BOOL)animated;

/// フォーカス枠を表示し、指定時間後に非表示にします。
/// 指定時間が0秒の場合は表示し続けます。
- (void)showFocusFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status duration:(NSTimeInterval)duration animated:(BOOL)animated;

/// フォーカス枠の枠表示状態を変更します。
- (void)changeFocusFrameStatus:(RecordingCameraLiveImageViewStatus)status animated:(BOOL)animated;

/// 自動露出枠を非表示にします。
- (void)hideExposureFrame:(BOOL)animated;

/// 自動露出枠を表示します。
- (void)showExposureFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status animated:(BOOL)animated;

/// 自動露出枠を表示し、指定時間後に非表示にします。
/// 指定時間が0秒の場合は表示し続けます。
- (void)showExposureFrame:(CGRect)rect status:(RecordingCameraLiveImageViewStatus)status duration:(NSTimeInterval)duration animated:(BOOL)animated;

/// 顔認識枠を非表示にします。
- (void)hideFaceFrames:(BOOL)animated;

/// 顔認識枠を表示します。
- (void)showFaceFrames:(NSDictionary *)frames animated:(BOOL)animated;

/// オートフォーカスを使って合焦させる座標として有効な範囲枠を非表示にします。
- (void)hideAutoFocusEffectiveArea:(BOOL)animated;

/// オートフォーカスを使って合焦させる座標として有効な範囲を枠で表示し、指定時間後に非表示にします。
/// 指定時間が0秒の場合は表示し続けます。
- (void)showAutoFocusEffectiveArea:(CGRect)rect duration:(NSTimeInterval)duration animated:(BOOL)animated;

/// 自動露光制御のターゲット座標として有効な範囲枠を非表示にします。
- (void)hideAutoExposureEffectiveArea:(BOOL)animated;

/// 自動露光制御のターゲット座標として有効な範囲を枠で表示し、指定時間後に非表示にします。
/// 指定時間が0秒の場合は表示し続けます。
- (void)showAutoExposureEffectiveArea:(CGRect)rect duration:(NSTimeInterval)duration animated:(BOOL)animated;

/// 撮影中を示すフラッシュの表示を終了します。
- (void)hideFlashing:(BOOL)animated;

/// 撮影中を示すフラッシュの表示を開始します。
- (void)showFlashing:(BOOL)animated;

/// グリッド線の表示を終了します。
- (void)hideGrid:(BOOL)animated;

/// グリッド線の表示を開始します。
- (void)showGrid:(BOOL)animated;

@end
