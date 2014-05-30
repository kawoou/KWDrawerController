/*
 The MIT License (MIT)
 
 KWDrawerViewController - Copyright (c) 2014, Jeungwon An (kawoou@kawoou.kr)
 
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

#define CGPointAdd(a,b)     CGPointMake((a).x+(b).x,(a).y+(b).y)
#define CGSizeAdd(a,b)      CGSizeMake((a).width+(b).width,(a).height+(b).height)
#define CGRectAdd(a,b)      (CGRect){CGPointAdd((a).origin,(b).origin),CGSizeAdd((a).size,(b).size)}

#define CGPointRect(a)      ((CGRect){(a),0,0})
#define CGSizeRect(a)       ((CGRect){0,0,(a)})


typedef NS_ENUM(NSInteger, KWDrawerSide)
{
    KWDrawerSideNone = 0,
    KWDrawerSideLeft,
    KWDrawerSideRight,
};

const static CGFloat kDrawerOverflowAnimationPercent            = 1.06f;

const static CGFloat kDrawerDefaultAnimationWidth               = 280.0f;
const static CGFloat kDrawerDefaultAnimationDuration            = 0.35f;

const static CGFloat kDrawerDefaultShadowRadius                 = 10.0f;
const static CGFloat kDrawerDefaultShadowOpacity                = 0.8f;

const static CGFloat kDrawerDefaultFullSizeAnimationFacter      = 0.2875f;
const static CGFloat kDrawerDefaultFullSizeAnimationVisibleSize = 80.0f;


typedef void (^KWDrawerAnimationBlock)(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect);
typedef void (^KWDrawerOverflowAnimationBlock)(UIViewController *mainViewController, KWDrawerSide side, CGFloat percentage, CGRect viewRect);

typedef void (^KWDrawerBlocks)(KWDrawerAnimationBlock animationBlock, KWDrawerOverflowAnimationBlock overflowAnimationBlock);


/* Delegate */
@class KWDrawerViewController;
@protocol KWDrawerViewControllerDelegate
@optional

- (void)drawerViewControllerDidAnimationMainViewController:(UIViewController *)viewController
                                            withPercentage:(CGFloat)percentage
                                          andAnimationSide:(KWDrawerSide)animationSide
                                           andDrawerBlocks:(KWDrawerBlocks)drawerBlocks;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didBeganAnimationLeftDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didBeganAnimationRightDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationMainDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationLeftDrawer:(UIViewController *)viewController;
- (void)drawerViewController:(KWDrawerViewController *)drawerViewController willFinishAnimationRightDrawer:(UIViewController *)viewController;

@end