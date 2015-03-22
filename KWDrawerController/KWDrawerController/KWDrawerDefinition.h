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

#import <UIKit/UIKit.h>

@class KWDrawerAnimation;

typedef NS_ENUM(NSInteger, KWDrawerSide)
{
    KWDrawerSideOverlap = -1,
    KWDrawerSideNone = 0,
    KWDrawerSideLeft,
    KWDrawerSideRight,
    
    KWDrawerSideCount
};


/* Static variable */
const static CGFloat kDrawerOverflowAnimationPercent            = 1.06f;

const static CGRect  kDrawerDefaultTouchRect                    = ((CGRect){-20,20,40,40});
const static CGFloat kDrawerDefaultAnimationWidth               = 280.0f;
const static CGFloat kDrawerDefaultAnimationDuration            = 0.35f;
const static CGFloat kDrawerDefaultAnimationLoopDuration        = 0.1f;

const static CGFloat kDrawerDefaultShadowRadius                 = 10.0f;
const static CGFloat kDrawerDefaultShadowOpacity                = 0.8f;

const static CGFloat kDrawerDefaultFullSizeAnimationFacter      = 0.2875f;
const static CGFloat kDrawerDefaultFullSizeAnimationVisibleSize = 80.0f;

#define kDrawerDrawViewControllerNotification                   @"KWDrawerViewControllerDidBeganDrawViewController"
#define kDrawerSizingViewControllerNotification                   @"KWDrawerViewControllerDidBeganSizingViewController"

/* Block types */
typedef void (^KWDrawerVisibleBlock)(BOOL isFrontIndex, BOOL isCustomAnimation);
//typedef void (^KWDrawerAnimationBlock)(UIView *view, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect, KWDrawerVisibleBlock visibleBlock);
//typedef void (^KWDrawerOverflowAnimationBlock)(UIView *view, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect, KWDrawerVisibleBlock visibleBlock);

typedef void (^KWDrawerBlocks)(KWDrawerAnimation *animationBlock, KWDrawerAnimation *overflowAnimationBlock);


/* Inline functions */
#undef CGPointAdd
#undef CGPointSub
#undef CGPointMul
#undef CGSizeAdd
#undef CGSizeSub
#undef CGSizeMul
#undef CGRectAdd
#undef CGRectSub
#undef CGRectMul
#undef CGPointOne
#undef CGSizeOne
#undef CGRectOne
#undef CGPointVal
#undef CGSizeVal
#undef CGRectVal
#undef CGPointRect
#undef CGSizeRect

#define CGPointAdd(a,b)     CGPointMake((a).x+(b).x,(a).y+(b).y)
#define CGPointSub(a,b)     CGPointMake((a).x-(b).x,(a).y-(b).y)
#define CGPointMul(a,b)     CGPointMake((a).x*(b).x,(a).y*(b).y)
#define CGSizeAdd(a,b)      CGSizeMake((a).width+(b).width,(a).height+(b).height)
#define CGSizeSub(a,b)      CGSizeMake((a).width-(b).width,(a).height-(b).height)
#define CGSizeMul(a,b)      CGSizeMake((a).width*(b).width,(a).height*(b).height)
#define CGRectAdd(a,b)      ((CGRect){CGPointAdd((a).origin,(b).origin),CGSizeAdd((a).size,(b).size)})
#define CGRectSub(a,b)      ((CGRect){CGPointSub((a).origin,(b).origin),CGSizeSub((a).size,(b).size)})
#define CGRectMul(a,b)      ((CGRect){CGPointMul((a).origin,(b).origin),CGSizeMul((a).size,(b).size)})
#define CGPointOne          ((CGPoint){1,1})
#define CGSizeOne           ((CGSize){1,1})
#define CGRectOne           ((CGRect){1,1,1,1})
#define CGPointVal(a)       ((CGPoint){a,a})
#define CGSizeVal(a)        ((CGSize){a,a})
#define CGRectVal(a)        ((CGRect){a,a,a,a})
#define CGPointRect(a)      ((CGRect){(a),0,0})
#define CGSizeRect(a)       ((CGRect){0,0,(a)})


/* Delegate */
@class KWDrawerController;
@protocol KWDrawerControllerDelegate
@optional

- (void)drawerControllerDidAnimationViewController:(UIViewController *)viewController
                                    withPercentage:(CGFloat)percentage
                                     andDrawerSide:(KWDrawerSide)drawerSide;
- (void)drawerController:(KWDrawerController *)drawerController didBeganAnimationDrawerSide:(KWDrawerSide)drawerSide;
- (void)drawerController:(KWDrawerController *)drawerController willFinishAnimationDrawerSide:(KWDrawerSide)drawerSide;
- (void)drawerController:(KWDrawerController *)drawerController willCancelAnimationDrawerSide:(KWDrawerSide)drawerSide;

//- (void)drawerController:(KWDrawerController *)drawerViewController didBeganAnimationLeftDrawer:(UIViewController *)viewController;
//- (void)drawerController:(KWDrawerController *)drawerViewController didBeganAnimationRightDrawer:(UIViewController *)viewController;
//- (void)drawerController:(KWDrawerController *)drawerViewController willFinishAnimationMainDrawer:(UIViewController *)viewController;
//- (void)drawerController:(KWDrawerController *)drawerViewController willFinishAnimationLeftDrawer:(UIViewController *)viewController;
//- (void)drawerController:(KWDrawerController *)drawerViewController willFinishAnimationRightDrawer:(UIViewController *)viewController;

@end