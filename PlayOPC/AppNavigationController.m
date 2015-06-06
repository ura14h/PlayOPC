//
//  AppNavigationController.m
//  PlayOPC
//
//  Created by Hiroki Ishiura on 2015/06/06.
//  Copyright (c) 2015 Hiroki Ishiura. All rights reserved.
//
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppNavigationController.h"

@interface AppNavigationController ()

@property (weak, nonatomic) UITraitCollection *currentTrait;
@property (strong, nonatomic) UITraitCollection *portraitTrait;
@property (strong, nonatomic) UITraitCollection *landscapeTrait;

@end

@implementation AppNavigationController

- (void)viewDidLoad {
	DEBUG_LOG(@"");
    [super viewDidLoad];
	
	// !!!: iPad用に縦置きと横置きでSize Classが変わるようにします。
	// StoryboardでデザインしただけだとiPadで実行した時に横置きにしても縦置きにしてもSize ClassがwAny*hAnyのまま変わらないので、
	// Storyboardで定義してある縦置き用と横置き用の制約が使われるようなTrait CollectionをiPad用に用意します。
	self.currentTrait = nil;
	if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		UITraitCollection *wAnyTrait = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassUnspecified];
		UITraitCollection *hRegularTrait = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
		UITraitCollection *hCompactTrait = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassCompact];
		self.portraitTrait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[wAnyTrait, hRegularTrait]];
		self.landscapeTrait = [UITraitCollection traitCollectionWithTraitsFromCollections:@[wAnyTrait, hCompactTrait]];
	} else {
		self.portraitTrait = nil;
		self.landscapeTrait = nil;
	}
}

- (void)didReceiveMemoryWarning {
	DEBUG_LOG(@"");
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
	DEBUG_LOG(@"animated=%ld", (long)animated);
	[super viewWillAppear:animated];
	
	// 使用するTrait Collectionを縦横のサイズを元に変更します。
	if (self.portraitTrait && self.landscapeTrait) {
		if (self.view.frame.size.width > self.view.frame.size.height) {
			self.currentTrait = self.landscapeTrait;
		} else {
			self.currentTrait = self.portraitTrait;
		}
	}
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	DEBUG_LOG(@"size=%@, coordinator=%@", NSStringFromCGSize(size), coordinator);

	// 使用するTrait Collectionを縦横のサイズを元に変更します。
	if (self.portraitTrait && self.landscapeTrait) {
		if (size.width > size.height) {
			self.currentTrait = self.landscapeTrait;
		} else {
			self.currentTrait = self.portraitTrait;
		}
	}
}

- (UITraitCollection *)overrideTraitCollectionForChildViewController:(UIViewController *)childViewController {
	DEBUG_LOG(@"childViewController=%@", childViewController);

	if (self.portraitTrait && self.landscapeTrait && self.currentTrait) {
		return self.currentTrait;
	}

	// Trait Collectionのカスタマイズがない時は既定のオブジェクトを返します。
	return [super overrideTraitCollectionForChildViewController:childViewController];
}

@end
