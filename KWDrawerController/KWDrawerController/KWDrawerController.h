/*
 The MIT License (MIT)
 
 KWDrawerController - Copyright (c) 2014, Jeungwon An (kawoou@kawoou.kr)
 
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

#import "KWDrawerDefinition.h"
#import "KWDrawerAnimation.h"
#import "KWDrawerSandbox.h"

@interface KWDrawerController : UIViewController

@property (nonatomic, retain) id<KWDrawerControllerDelegate>        delegate;
@property (nonatomic, assign) BOOL                                  gestureEnable;
@property (nonatomic, assign) BOOL                                  animationEnable;
@property (nonatomic, assign) BOOL                                  showShadow;
@property (nonatomic, assign) BOOL                                  enable;

@property (readonly)          CGPoint                               touchedPoint;
@property (readonly)          KWDrawerSide                          openedDrawerSide;

- (void)openDrawerSide:(KWDrawerSide)drawerSide animated:(BOOL)animated;

- (UIImage *)imageContextInDrawerSide:(KWDrawerSide)drawerSide;
- (UIViewController *)viewControllerInDrawerSide:(KWDrawerSide)drawerSide;
- (void)setViewController:(UIViewController *)viewController inDrawerSide:(KWDrawerSide)drawerSide;

- (void)setDefaultAnimation:(KWDrawerAnimation *)animation inDrawerSide:(KWDrawerSide)drawerSide;
- (void)setOverflowAnimation:(KWDrawerAnimation *)animation inDrawerSide:(KWDrawerSide)drawerSide;
- (void)setMaximumWidth:(CGFloat)width inDrawerSide:(KWDrawerSide)drawerSide animated:(BOOL)animated;

@end
