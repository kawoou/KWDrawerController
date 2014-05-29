/*
 The MIT License (MIT)
 
 KWNinePatchView - Copyright (c) 2014, Jeungwon An (kawoou@kawoou.kr)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "UIViewController+KWDrawerViewController.h"

@protocol KWDrawerViewControllerDelegate;
@interface KWDrawerViewController : UIViewController

@property (nonatomic, retain) id<KWDrawerViewControllerDelegate>    delegate;
@property (nonatomic, assign) BOOL                                  slideEnable;
@property (nonatomic, retain) UIViewController                      *mainViewController;
@property (nonatomic, retain) UIViewController                      *leftDrawerViewController;
@property (nonatomic, retain) UIViewController                      *rightDrawerViewController;
@property (readonly)          UIViewController                      *showingViewController;

- (void)showMainViewController;
- (void)showLeftDrawerViewController;
- (void)showRightDrawerViewController;

@end

@protocol KWDrawerViewControllerDelegate

@optional

- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didAnimationMainViewController:(UIViewController *)viewController withPercentage:(CGFloat)percentage;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didBeganAnimationLeftDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didBeganAnimationRightDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationMainDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationLeftDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationRightDrawer:(UIViewController *)viewController;

@end