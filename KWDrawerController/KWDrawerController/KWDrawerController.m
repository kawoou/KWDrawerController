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

#import "KWDrawerController.h"

#import "Animation/KWDrawerSlideAnimation.h"
#import "Animation/KWDrawerScaleAnimation.h"

//#define KWDEBUG

@interface KWDrawerController () <UIGestureRecognizerDelegate>
{
    KWDrawerSide            _sideState;
    
    KWDrawerSandbox         *_sandBox;
    
    BOOL                    _statusBarHidden;
    BOOL                    _statusBarTranslucent;
    
    /// Drawer
    BOOL                    _isDrawer             [KWDrawerSideCount];
    BOOL                    _isUserInterection    [KWDrawerSideCount];
    BOOL                    _isOldUserInterection [KWDrawerSideCount];
    UIView                  *_safetyViewBox       [KWDrawerSideCount];
    UIImage                 *_drawerScreenshot    [KWDrawerSideCount];
    KWDrawerAnimation       *_defaultAnimation    [KWDrawerSideCount];
    KWDrawerAnimation       *_overflowAnimation   [KWDrawerSideCount];
    UIView                  *_sandboxView;
    
    CGRect                  _drawerViewRect       [KWDrawerSideCount];
    UIViewController        *_drawerViewController[KWDrawerSideCount];
    
    /// Event
    BOOL                    _viewWillAppear       [KWDrawerSideCount];
    NSInteger               _lastViewWillAppear;
    BOOL                    _isOpenAnimationPlaying;
    
    /// Gesture
    CGPoint                 _beginPoint;
    CGPoint                 _movePoint;
    
    BOOL                    _isTouchMoveLeft;
    UIPanGestureRecognizer  *_panGestureRecognizer;
    UITapGestureRecognizer  *_tapGestureRecognizer;
}

@property (readonly) UIViewController       *openedViewController;

- (void)construct;
- (void)destruct;

- (void)updateViewSize;

- (void)setNeedsStatusBarUpdate;
- (UIStatusBarStyle)preferredStatusBarStyle;
- (UIStatusBarStyle)statusBarStyle;
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;
- (UIStatusBarAnimation)statusBarUpdateAnimation;
- (BOOL)prefersStatusBarHidden;
- (BOOL)statusBarHidden;

@end

@implementation KWDrawerController

@synthesize openedDrawerSide = _sideState;
@synthesize touchedPoint = _movePoint;

- (UINavigationController *)navigationController
{
    if ([super navigationController])
        return [super navigationController];
    else
    {
        if ([[self viewControllerInDrawerSide:KWDrawerSideNone] isKindOfClass:[UINavigationController class]])
            return (UINavigationController *)[self viewControllerInDrawerSide:KWDrawerSideNone];
        else
            return nil;
    }
}

#pragma mark -
#pragma mark Public Methods

- (void)setShowShadow:(BOOL)showShadow
{
    NSInteger i;
    _showShadow = showShadow;
    
    for(i = KWDrawerSideNone; i < KWDrawerSideCount; i ++)
    {
        UIView *view = _drawerViewController[i].view;
        if(_showShadow)
        {
            view.layer.masksToBounds = NO;
            view.layer.shadowRadius = kDrawerDefaultShadowRadius;
            view.layer.shadowOpacity = kDrawerDefaultShadowOpacity;
            view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:view.bounds] CGPath];
        }
        else
        {
            view.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectNull].CGPath;
            view.layer.masksToBounds = YES;
        }
    }
    
    if(_sandBox.movingSide != KWDrawerSideNone)
        [_sandBox setShowShadow:_showShadow];
}

- (void)openDrawerSide:(NSNumber *)drawerSide
{
    [self openDrawerSide:[drawerSide integerValue] animated:_animationEnable];
}

- (void)openDrawerSide:(KWDrawerSide)drawerSide animated:(BOOL)animated
{
    [self openDrawerSide:drawerSide animated:animated completion:nil];
}

- (void)openDrawerSide:(KWDrawerSide)drawerSide animated:(BOOL)animated completion:(void(^)(CGFloat))completion
{
#ifdef KWDEBUG
    NSLog(@"openDrawerSide:animated:");
#endif
    BOOL isOverlap = drawerSide == KWDrawerSideOverlap;
    
    if(!_enable) return;
    if(_isOpenAnimationPlaying) return;
    if(!_isDrawer[drawerSide] && !isOverlap) return;
    
    animated &= _animationEnable;
    
    /// Begin Animation
    KWDrawerSide lastSideState = self.openedDrawerSide;
    if(isOverlap && lastSideState == KWDrawerSideNone)
        return;
    
    if(drawerSide == KWDrawerSideNone)
    {
        if(lastSideState == KWDrawerSideLeft)
            [self didBeganAnimation:KWDrawerSideLeft];
        
        if(lastSideState == KWDrawerSideRight)
            [self didBeganAnimation:KWDrawerSideRight];
    }
    else if(drawerSide == KWDrawerSideOverlap)
    {
        drawerSide = lastSideState;
        [self didBeganAnimation:lastSideState];
    }
    else if(drawerSide == lastSideState)
    {
        [self didBeganAnimation:drawerSide];
    }
    else
    {
        if(lastSideState == KWDrawerSideNone)
            [self didBeganAnimation:drawerSide];
        
        KWDrawerSide invSide = (drawerSide==KWDrawerSideRight)?KWDrawerSideLeft:KWDrawerSideRight;
        if(lastSideState == invSide)
        {
            [self performSelector:@selector(openDrawerSide:) withObject:[NSNumber numberWithInteger:drawerSide] afterDelay:kDrawerDefaultAnimationDuration+kDrawerDefaultAnimationLoopDuration];
            
            drawerSide = KWDrawerSideNone;
            [self didBeganAnimation:invSide];
        }
        [self drawerViewWillAppear:drawerSide];
    }
    
    /// Animation
    CGFloat percentage = 0.0f;
    if(isOverlap)
    {
        percentage = self.view.bounds.size.width / _drawerViewController[drawerSide].view.bounds.size.width;
        
        if(lastSideState == KWDrawerSideRight)
            percentage = -percentage;
    }
    else
    {
        if(drawerSide == KWDrawerSideLeft)
            percentage = 1.0f;
        
        if(drawerSide == KWDrawerSideRight)
            percentage = -1.0f;
    }
    
    _isOpenAnimationPlaying = YES;
    
    CGFloat animateTime = isOverlap ? kDrawerDefaultAnimationDuration * 0.5f : kDrawerDefaultAnimationDuration;
    [self willAnimationWithPercentage:percentage];
    if (_sandBox.isCustomAnimation == YES)
    {
        [self didAnimationWithPercentage:percentage];
        [self performSelector:@selector(openDrawerSideFinishAnimation:) withObject:@[[NSNumber numberWithInteger:drawerSide], [NSNumber numberWithInteger:lastSideState], [NSNumber numberWithBool:animated]] afterDelay:animateTime];
        
        if (isOverlap)
            _sandBox.percentage = percentage;
        
        if(completion)
            completion(animateTime);
    }
    else
    {
        [UIView animateWithDuration:animateTime delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
         {
             [self didAnimationWithPercentage:percentage];
         }
         
         /// Finish Animation
         completion:^(BOOL finished)
         {
             [self openDrawerSideFinishAnimation:@[[NSNumber numberWithInteger:drawerSide], [NSNumber numberWithInteger:lastSideState], [NSNumber numberWithBool:animated]]];
             
             if (isOverlap)
                 _sandBox.percentage = percentage;
             
             if(completion)
                 completion(0.0f);
         }];
    }
}

- (void)openDrawerSideFinishAnimation:(NSArray *)stateArray
{
    KWDrawerSide drawerSide = [stateArray[0] integerValue];
    KWDrawerSide lastSideState = [stateArray[1] integerValue];
    BOOL animated = [stateArray[2] boolValue];
    
    _isOpenAnimationPlaying = NO;
    _sideState = drawerSide;
    
    [self setUserInteraction:(drawerSide == KWDrawerSideLeft)
               forDrawerSide:KWDrawerSideLeft];
    [self setUserInteraction:(drawerSide == KWDrawerSideRight)
               forDrawerSide:KWDrawerSideRight];
    [self setUserInteraction:(drawerSide == KWDrawerSideNone)
               forDrawerSide:KWDrawerSideNone];
    
    [self willFinishAnimation:drawerSide];
    
    if(drawerSide == KWDrawerSideNone)
    {
        if(lastSideState == KWDrawerSideLeft)
        {
            _viewWillAppear[KWDrawerSideLeft] = NO;
            [_drawerViewController[KWDrawerSideLeft] viewWillDisappear:animated];
            [_drawerViewController[KWDrawerSideLeft] viewDidDisappear:animated];
        }
        if(lastSideState == KWDrawerSideRight)
        {
            _viewWillAppear[KWDrawerSideRight] = NO;
            [_drawerViewController[KWDrawerSideRight] viewWillDisappear:animated];
            [_drawerViewController[KWDrawerSideRight] viewDidDisappear:animated];
        }
        if(lastSideState == KWDrawerSideNone)
        {
            if (_lastViewWillAppear != -1)
            {
                _viewWillAppear[_lastViewWillAppear] = NO;
                [_drawerViewController[_lastViewWillAppear] viewWillDisappear:animated];
                [_drawerViewController[_lastViewWillAppear] viewDidDisappear:animated];
            }
        }
        _lastViewWillAppear = -1;
    }
    else
    {
        [_drawerViewController[drawerSide] viewDidAppear:drawerSide];
        [self drawerViewWillAppear:drawerSide];
    }
    
    [self setNeedsStatusBarUpdate];
}

- (UIImage *)imageContextInDrawerSide:(KWDrawerSide)drawerSide
{
    if(!_drawerScreenshot[drawerSide])
        [self drawLayerOnScreenshot:drawerSide];
    
    return _drawerScreenshot[drawerSide];
}

- (UIViewController *)viewControllerInDrawerSide:(KWDrawerSide)drawerSide
{
    return _drawerViewController[drawerSide];
}

- (void)setViewController:(UIViewController *)viewController inDrawerSide:(KWDrawerSide)drawerSide
{
    if (viewController)
    {
        if (_isDrawer[drawerSide] && _animationEnable)
        {
#ifdef KWDEBUG
            NSLog(@"setViewController:inDrawerSide:");
#endif
            if(!_enable) return;
            if(_isOpenAnimationPlaying) return;
            
            /// Begin Animation
            KWDrawerSide lastSideState = self.openedDrawerSide;
            if (lastSideState != KWDrawerSideNone)
            {
                if (drawerSide == lastSideState)
                {
                    [self openDrawerSide:KWDrawerSideNone animated:YES completion:^(CGFloat delay) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                        {
                            [_drawerViewController[drawerSide].view removeFromSuperview];
                            [_drawerViewController[drawerSide] removeFromParentViewController];
                            
                            _drawerViewController[drawerSide] = viewController;
                            [self addChildViewController:viewController];
                            [self setUserInteraction:NO forDrawerSide:drawerSide];
                            [self setUserInteraction:YES forDrawerSide:drawerSide];
                            [_safetyViewBox[drawerSide] addSubview:viewController.view];
                            
                            [self openDrawerSide:drawerSide animated:YES completion:nil];
                        });
                    }];
                }
                else
                {
                    if (drawerSide == KWDrawerSideNone)
                    {
//                        [self openDrawerSide:KWDrawerSideOverlap animated:YES completion:^(CGFloat delay) {
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^
//                            {
                                [_drawerViewController[drawerSide].view removeFromSuperview];
                                [_drawerViewController[drawerSide] removeFromParentViewController];
                        
                                _drawerViewController[drawerSide] = viewController;
                                [self addChildViewController:viewController];
                                [self setUserInteraction:NO forDrawerSide:drawerSide];
                                [self setUserInteraction:YES forDrawerSide:drawerSide];
                                [_safetyViewBox[drawerSide] addSubview:viewController.view];
                                
                                [self openDrawerSide:drawerSide animated:YES completion:nil];
//                            });
//                        }];
                    }
                    else
                    {
                        [_drawerViewController[drawerSide].view removeFromSuperview];
                        [_drawerViewController[drawerSide] removeFromParentViewController];
                        
                        _drawerViewController[drawerSide] = viewController;
                        [self addChildViewController:viewController];
                        [self setUserInteraction:NO forDrawerSide:drawerSide];
                        [self setUserInteraction:YES forDrawerSide:drawerSide];
                        [_safetyViewBox[drawerSide] addSubview:viewController.view];
                    }
                }
            }
            else
            {
                [_drawerViewController[drawerSide].view removeFromSuperview];
                [_drawerViewController[drawerSide] removeFromParentViewController];
                
                _drawerViewController[drawerSide] = viewController;
                [self addChildViewController:viewController];
                [self setUserInteraction:NO forDrawerSide:drawerSide];
                [self setUserInteraction:YES forDrawerSide:drawerSide];
                [_safetyViewBox[drawerSide] addSubview:viewController.view];
            }
        }
        else
        {
            _isDrawer[drawerSide] = YES;
            
            [_drawerViewController[drawerSide].view removeFromSuperview];
            [_drawerViewController[drawerSide] removeFromParentViewController];
            
            _drawerViewController[drawerSide] = viewController;
            
            [self addChildViewController:viewController];
            [self setUserInteraction:NO forDrawerSide:drawerSide];
            [self setUserInteraction:YES forDrawerSide:drawerSide];
            
            [_safetyViewBox[drawerSide] addSubview:viewController.view];
        }
    }
    else
    {
        _isDrawer[drawerSide] = NO;
        
        [_drawerViewController[drawerSide].view removeFromSuperview];
        
        [self setUserInteraction:YES forDrawerSide:drawerSide];
        [_drawerViewController[drawerSide] removeFromParentViewController];
        
        _drawerViewController[drawerSide] = nil;
    }
}

- (void)setDefaultAnimation:(KWDrawerAnimation *)animation inDrawerSide:(KWDrawerSide)drawerSide
{
    _defaultAnimation[drawerSide] = animation;
}

- (void)setOverflowAnimation:(KWDrawerAnimation *)animation inDrawerSide:(KWDrawerSide)drawerSide
{
    _overflowAnimation[drawerSide] = animation;
}

- (void)setMaximumWidth:(CGFloat)width inDrawerSide:(KWDrawerSide)drawerSide animated:(BOOL)animated
{
    if(self.view.bounds.size.width + _drawerViewRect[drawerSide].size.width != width)
    {
        CGRect rect1 = _drawerViewController[drawerSide].view.frame;
        CGRect rect2;
        
        if(_sandBox.movingSide == KWDrawerSideNone)
        {
            rect2 = _sandBox.drawerView.frame;
            rect2.size.width += width - rect1.size.width;
        }
        rect1.size.width = width;
        
        [UIView animateWithDuration:(kDrawerDefaultAnimationDuration * animated) animations:^{
            _drawerViewController[drawerSide].view.frame = rect1;
            
            if(_sandBox.movingSide == KWDrawerSideNone)
                _sandBox.drawerView.frame = rect2;
        }];
        
        [self updateViewSize];
    }
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [gesture setDelegate:self];
    
    return gesture;
}


#pragma mark -
#pragma mark Gesture Recognizer

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gesture
{
    if(!_enable) return;
    if(_isOpenAnimationPlaying) return;
    
    [self openDrawerSide:KWDrawerSideNone animated:_animationEnable];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    if(!_enable) return;
    if(!_gestureEnable) return;
    if(_isOpenAnimationPlaying) return;
    
    UIGestureRecognizerState state = [gesture state];
    CGPoint location = [gesture locationInView:self.view];
    
    if(state == UIGestureRecognizerStateBegan)
    {
        if (_isTouchMoveLeft == YES)
        {
            [self willCancelAnimation];
            [self didBeganAnimation:KWDrawerSideLeft];
        }
        else
        {
            [self willCancelAnimation];
            [self didBeganAnimation:KWDrawerSideRight];
        }
    }
    else if(state == UIGestureRecognizerStateChanged)
    {
        if(_sandBox.movingSide == KWDrawerSideNone) return;
        
        CGSize viewSize = CGSizeAdd(self.view.frame.size, _drawerViewRect[_sandBox.movingSide].size);
        CGFloat percentage = _sandBox.percentage;
        percentage += (location.x - _beginPoint.x) / viewSize.width;
        
        if(location.x - _movePoint.x > 0)
            _isTouchMoveLeft = NO;
        else if(location.x - _movePoint.x < 0)
            _isTouchMoveLeft = YES;
        
        _movePoint = location;
        if(_sandBox.beginSide == KWDrawerSideNone)
        {
            if(percentage < 0)
            {
                [self drawerViewWillAppear:KWDrawerSideRight];
                _lastViewWillAppear = KWDrawerSideRight;
            }
            
            else if(percentage > 0)
            {
                [self drawerViewWillAppear:KWDrawerSideLeft];
                _lastViewWillAppear = KWDrawerSideLeft;
            }
        }
        
        if(percentage > kDrawerOverflowAnimationPercent)
            percentage = kDrawerOverflowAnimationPercent;
        
        if(percentage < -kDrawerOverflowAnimationPercent)
            percentage = -kDrawerOverflowAnimationPercent;
        
        [self willAnimationWithPercentage:percentage];
        [self didAnimationWithPercentage:percentage];
    }
    else
    {
        if(_sandBox.movingSide == KWDrawerSideNone) return;
        
        if(_sandBox.movingSide == KWDrawerSideLeft && (_sandBox.isOverflow || !_isTouchMoveLeft))
            [self openDrawerSide:KWDrawerSideLeft animated:_animationEnable];
            
        else if(_sandBox.movingSide == KWDrawerSideRight && (_sandBox.isOverflow || _isTouchMoveLeft))
            [self openDrawerSide:KWDrawerSideRight animated:_animationEnable];
            
        else
            [self openDrawerSide:KWDrawerSideNone animated:_animationEnable];
        
        _movePoint.x = -1;
        _movePoint.y = -1;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(!_enable) return NO;
    if(_isOpenAnimationPlaying) return NO;
    
    /// Tap Gesture Recognizer
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        if([self isMainViewControllerTouched:[gestureRecognizer locationInView:self.view]])
            return YES;
        return NO;
    }
    
    /// Pan Gesture Recognizer
    else
    {
        if(!_gestureEnable) return NO;
        
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        if(fabs(translation.x) < fabs(translation.y))
            return NO;
        
        _beginPoint = [gestureRecognizer locationInView:self.view];
        _movePoint = _beginPoint;
        
        CGRect pointRect = CGRectAdd(CGPointRect(CGPointSub(_beginPoint, translation)), kDrawerDefaultTouchRect);
        
        if(self.openedDrawerSide == KWDrawerSideNone)
        {
            CGRect leftRect = CGRectAdd(_drawerViewController[KWDrawerSideNone].view.frame, CGRectMake(-40, 0, 0, 0));
            CGRect rightRect = leftRect;
            rightRect.origin.x += leftRect.size.width;
            rightRect.size.width = leftRect.size.width = 80;
            
            if(_isDrawer[KWDrawerSideLeft] &&
               CGRectIntersectsRect(leftRect, pointRect))
            {
                _isTouchMoveLeft = YES;
                return YES;
            }
            
            if(_isDrawer[KWDrawerSideRight] &&
               CGRectIntersectsRect(rightRect, pointRect))
            {
                _isTouchMoveLeft = NO;
                return YES;
            }
        }
        else
        {
            CGRect mainRect = _drawerViewController[KWDrawerSideNone].view.frame;
            if(CGRectIntersectsRect(mainRect, pointRect))
            {
                if(self.openedDrawerSide == KWDrawerSideLeft)
                    _isTouchMoveLeft = YES;
                else
                    _isTouchMoveLeft = NO;
                
                return YES;
            }
        }
    }
    
    return NO;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    UIGestureRecognizer *gesture = nil;
//    if(_panGestureRecognizer == gestureRecognizer)
//        gesture = _panGestureRecognizer;
//    else if(_tapGestureRecognizer == gestureRecognizer)
//        gesture = _tapGestureRecognizer;
//    else
//        return NO;
//
//    if(gestureRecognizer == otherGestureRecognizer || otherGestureRecognizer == gesture)
//        return YES;
//    
//    return NO;
//}

- (BOOL)isMainViewControllerTouched:(CGPoint)point
{
    if(self.openedDrawerSide == KWDrawerSideNone)
        return NO;

    CGRect pointRect = CGRectAdd(CGPointRect(point), kDrawerDefaultTouchRect);
    for(NSInteger i = _sandboxView.subviews.count - 1; i >= 0; i --)
    {
        UIView *view = _sandboxView.subviews[i];
        if(_safetyViewBox[KWDrawerSideLeft] == view)
            view = _drawerViewController[KWDrawerSideLeft].view;
        
        if(_safetyViewBox[KWDrawerSideRight] == view)
            view = _drawerViewController[KWDrawerSideRight].view;
        
        if(_safetyViewBox[KWDrawerSideNone] == view)
            view = _drawerViewController[KWDrawerSideNone].view;
        
        if(CGRectIntersectsRect(view.frame, pointRect))
        {
            if(self.openedDrawerSide == KWDrawerSideLeft &&
               _drawerViewController[KWDrawerSideLeft].view == view)
                return NO;
            
            if(self.openedDrawerSide == KWDrawerSideRight &&
               _drawerViewController[KWDrawerSideRight].view == view)
                return NO;
            
            if(_drawerViewController[KWDrawerSideNone].view == view)
                return YES;
        }
    }
    
    return NO;
}


#pragma mark -
#pragma mark Animation Events

- (void)drawerViewWillAppear:(KWDrawerSide)drawerSide
{
    if(!_viewWillAppear[drawerSide])
    {
        _viewWillAppear[drawerSide] = YES;
        [_drawerViewController[drawerSide] viewWillAppear:YES];
    }
}

- (void)didBeganAnimation:(KWDrawerSide)drawerSide
{
#ifdef KWDEBUG
    NSLog(@"didBeganAnimation:");
#endif
    if(!_enable || _isOpenAnimationPlaying ||
       drawerSide == KWDrawerSideNone)
    {
        [self willCancelAnimation];
        return;
    }
    
    if(_sandBox.drawerView)
        return;
    
    UIView *sandBoxView = [_defaultAnimation[drawerSide] visibleViewForAnimation];
    if(!sandBoxView)
        sandBoxView = _drawerViewController[drawerSide].view;
    
    if([self openSandbox:sandBoxView inDrawerSide:drawerSide])
    {
        //_sandBox.isOverflow = NO;
        _sandBox.isOverflowChanged = NO;
    }
    else
    {
        [self willCancelAnimation];
        return;
    }
    
    if(drawerSide != KWDrawerSideNone)
    {
        [self setUserInteraction:NO forDrawerSide:KWDrawerSideLeft];
        [self setUserInteraction:NO forDrawerSide:KWDrawerSideRight];
    }
    
    //_viewWillAppear[drawerSide] = NO;
    [_sandboxView bringSubviewToFront:_safetyViewBox[KWDrawerSideNone]];
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerController:didBeganAnimationDrawerSide:)])
    {
        [_delegate drawerController:self didBeganAnimationDrawerSide:drawerSide];
    }
    
    [self willAnimationWithPercentage:_sandBox.percentage];
    [self didAnimationWithPercentage:_sandBox.percentage];
}

- (void)willFinishAnimation:(KWDrawerSide)drawerSide
{
#ifdef KWDEBUG
    NSLog(@"willFinishAnimation:");
#endif
    if(!_sandBox.drawerView)
        return;
    
    _sandBox.endedSide = drawerSide;
    [self closeSandbox];
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerController:willFinishAnimationDrawerSide:)])
    {
        [_delegate drawerController:self willFinishAnimationDrawerSide:drawerSide];
    }
}

- (void)willCancelAnimation
{
#ifdef KWDEBUG
    NSLog(@"willCancelAnimation");
#endif
    if(!_sandBox.drawerView)
        return;
    
    [_sandBox restoreFirstState];
    [self closeSandbox];
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerController:willCancelAnimationDrawerSide:)])
    {
        [_delegate drawerController:self willCancelAnimationDrawerSide:_sandBox.movingSide];
    }
}

- (void)willAnimationWithPercentage:(CGFloat)percentage
{
#ifdef KWDEBUG
    NSLog(@"willAnimationWithPercentage:%lf", percentage);
#endif
    if(!_enable)
    {
        [self willCancelAnimation];
        return;
    }
    
    __block KWDrawerAnimation *aniBlock = [KWDrawerSlideAnimation sharedInstance];
    __block KWDrawerAnimation *overflowAniBlock = [KWDrawerScaleAnimation sharedInstance];
    if(_defaultAnimation[_sandBox.movingSide])
        aniBlock = _defaultAnimation[_sandBox.movingSide];
    if(_overflowAnimation[_sandBox.movingSide])
        overflowAniBlock = _overflowAnimation[_sandBox.movingSide];
    
    if((percentage > 0 && _sandBox.movingSide == KWDrawerSideRight) ||
       (percentage < 0 && _sandBox.movingSide == KWDrawerSideLeft))
    {
        KWDrawerSide invSide = (_sandBox.movingSide==KWDrawerSideRight)?KWDrawerSideLeft:KWDrawerSideRight;
        
        if (_isDrawer[invSide])
        {
            UIView *sandBoxView = [_defaultAnimation[invSide] visibleViewForAnimation];
            if(!sandBoxView)
                sandBoxView = _drawerViewController[invSide].view;
            
            _sandBox.endedSide = KWDrawerSideNone;
            _sideState = KWDrawerSideNone;
            [self changeSandbox:sandBoxView inDrawerSide:invSide];
            
            _viewWillAppear[_sandBox.movingSide] = NO;
            [_drawerViewController[_sandBox.movingSide] viewWillDisappear:NO];
            [_drawerViewController[_sandBox.movingSide] viewDidDisappear:NO];
            [self drawerViewWillAppear:invSide];
            
            [self willAnimationWithPercentage:0.0f];
            [self didAnimationWithPercentage:0.0f];
        }
    }
    
    if(fabs(percentage) > 1.0f && !_sandBox.isOverflow)
    {
        UIView *sandBoxView = [_overflowAnimation[_sandBox.movingSide] visibleViewForAnimation];
        if(!sandBoxView)
            sandBoxView = _drawerViewController[_sandBox.movingSide].view;
        
        _sandBox.endedSide = _sandBox.movingSide;
        _sideState = _sandBox.movingSide;
        [self changeSandbox:sandBoxView];
        _sandBox.isOverflow = YES;
        _sandBox.isOverflowChanged = NO;
    }
    if(fabs(percentage) < 1.0f && _sandBox.isOverflow)
    {
        UIView *sandBoxView = [_defaultAnimation[_sandBox.movingSide] visibleViewForAnimation];
        if(!sandBoxView)
            sandBoxView = _drawerViewController[_sandBox.movingSide].view;
        
        _sandBox.endedSide = _sandBox.movingSide;
        _sideState = _sandBox.movingSide;
        [self changeSandbox:sandBoxView];
        _sandBox.isOverflow = NO;
        _sandBox.isOverflowChanged = YES;
    }
    
    if(!_sandBox.isOverflow)
    {
        if (_sandBox.isOverflowChanged)
            [overflowAniBlock willAnimationWithMainViewController:_drawerViewController[KWDrawerSideNone]];
        [aniBlock willAnimationWithMainViewController:_drawerViewController[KWDrawerSideNone]];
    }
    else
    {
        if (_sandBox.isOverflowChanged)
            [aniBlock willAnimationWithMainViewController:_drawerViewController[KWDrawerSideNone]];
        [overflowAniBlock willAnimationWithMainViewController:_drawerViewController[KWDrawerSideNone]];
    }
}

- (void)didAnimationWithPercentage:(CGFloat)percentage
{
#ifdef KWDEBUG
    NSLog(@"didAnimationWithPercentage:%lf", percentage);
#endif
    
    if(!_enable)
    {
        [self willCancelAnimation];
        return;
    }
    
    CGRect viewRect;
    viewRect = CGRectAdd(_drawerViewRect[_sandBox.movingSide], CGSizeRect(self.view.frame.size));
    if(_sandBox.movingSide == KWDrawerSideLeft)
    {
        if(percentage < 0.0f)
            percentage = 0.0f;
    }
    if(_sandBox.movingSide == KWDrawerSideRight)
    {
        if(percentage > 0.0f)
            percentage = 0.0f;
    }
    
    __block KWDrawerAnimation *aniBlock = [KWDrawerSlideAnimation sharedInstance];
    __block KWDrawerAnimation *overflowAniBlock = [KWDrawerScaleAnimation sharedInstance];
    if(_defaultAnimation[_sandBox.movingSide])
        aniBlock = _defaultAnimation[_sandBox.movingSide];
    if(_overflowAnimation[_sandBox.movingSide])
        overflowAniBlock = _overflowAnimation[_sandBox.movingSide];
    
    __block BOOL calledVisibleBox = NO;
    KWDrawerVisibleBlock visibleBox = ^(BOOL isFrontIndex, BOOL isCustomAnimation)
    {
        if (!calledVisibleBox)
        {
            [_sandboxView bringSubviewToFront:_safetyViewBox[KWDrawerSideNone]];
            calledVisibleBox = YES;
        }
        
        if(isFrontIndex)
            [_sandboxView bringSubviewToFront:_safetyViewBox[_sandBox.movingSide]];
        
        _sandBox.isCustomAnimation |= isCustomAnimation;
    };
    KWDrawerVisibleBlock overflowChangedVisibleBox = ^(BOOL isFrontIndex, BOOL isCustomAnimation)
    {
        if (!calledVisibleBox)
        {
            [_sandboxView bringSubviewToFront:_safetyViewBox[KWDrawerSideNone]];
            calledVisibleBox = YES;
        }
        
        if(isFrontIndex)
            [_sandboxView bringSubviewToFront:_safetyViewBox[_sandBox.movingSide]];
    };
    
    if(!_sandBox.isOverflow)
    {
        if(_sandBox.isOverflowChanged)
        {
            [overflowAniBlock animation:_drawerViewController[KWDrawerSideNone] visibleView:_sandBox.drawerView animationSide:_sandBox.movingSide percentage:(_sandBox.movingSide == KWDrawerSideRight ? -1.0 : 1.0) viewRect:viewRect visibleBlock:overflowChangedVisibleBox];
        }
        [aniBlock animation:_drawerViewController[KWDrawerSideNone] visibleView:_sandBox.drawerView animationSide:_sandBox.movingSide percentage:percentage viewRect:viewRect visibleBlock:visibleBox];
    }
    else
    {
        if(_sandBox.isOverflowChanged)
        {
            [aniBlock animation:_drawerViewController[KWDrawerSideNone] visibleView:_sandBox.drawerView animationSide:_sandBox.movingSide percentage:(_sandBox.movingSide == KWDrawerSideRight ? -1.0 : 1.0) viewRect:viewRect visibleBlock:overflowChangedVisibleBox];
        }
        [overflowAniBlock animation:_drawerViewController[KWDrawerSideNone] visibleView:_sandBox.drawerView animationSide:_sandBox.movingSide percentage:percentage viewRect:viewRect visibleBlock:visibleBox];
    }
    _sandBox.isOverflowChanged = NO;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerControllerDidAnimationViewController:withPercentage:andDrawerSide:)])
    {
        [_delegate drawerControllerDidAnimationViewController:_drawerViewController[_sandBox.movingSide] withPercentage:percentage andDrawerSide:_sandBox.movingSide];
    }
}


#pragma mark -
#pragma mark Observer Notifications

- (void)drawLayerOnScreenshot:(KWDrawerSide)drawerSide
{
    //if(drawerSide == KWDrawerSideNone)
    //    return;
    
    UIGraphicsBeginImageContextWithOptions(_drawerViewController[drawerSide].view.frame.size, NO, 0.0);
    if(!UIGraphicsGetCurrentContext())
    {
#ifdef KWDEBUG
        NSLog(@"UIGraphicsGetCurrentContext() is nil. You may have a UIView with CGRectZero");
#endif
    }
    else
    {
        [_drawerViewController[drawerSide].view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        _drawerScreenshot[drawerSide] = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
}

- (void)didBeganDrawViewController:(UIViewController *)viewController
{
    if(_sandBox.movingSide == KWDrawerSideLeft &&
       viewController == _drawerViewController[KWDrawerSideLeft])
        [self drawLayerOnScreenshot:KWDrawerSideLeft];
    
    if(_sandBox.movingSide == KWDrawerSideRight &&
       viewController == _drawerViewController[KWDrawerSideRight])
        [self drawLayerOnScreenshot:KWDrawerSideRight];
}


#pragma mark -
#pragma mark Sandbox Methods

- (BOOL)openSandbox:(UIView *)view inDrawerSide:(KWDrawerSide)drawerSide
{
#ifdef KWDEBUG
    NSLog(@"openSandbox:inDrawerSide:");
#endif
    [self updateViewSize];
    
    if(!view) return NO;
    
    if(_drawerViewController[drawerSide].view != view)
        [self drawLayerOnScreenshot:drawerSide];
    
    if(_drawerViewController[drawerSide].view != view)
    {
        [_safetyViewBox[drawerSide] addSubview:view];
        [_drawerViewController[drawerSide].view setHidden:YES];
    }
    
    _sandBox.beginSide = _sideState;
    _sandBox.movingSide = drawerSide;
    _sandBox.endedSide = KWDrawerSideCount;
    _sandBox.showShadow = _showShadow;
    _sandBox.drawerView = view;
    [_safetyViewBox[drawerSide] bringSubviewToFront:view];
    [_safetyViewBox[drawerSide] setHidden:NO];
    
    return YES;
}

- (void)closeSandbox
{
#ifdef KWDEBUG
    NSLog(@"closeSandbox");
#endif
    NSInteger i;
    
    for(i = KWDrawerSideLeft; i < KWDrawerSideCount; i ++)
    {
        _safetyViewBox[i].hidden = (i != self.openedDrawerSide);
    }
    switch(_sandBox.endedSide)
    {
        case KWDrawerSideLeft:
            _sandBox.percentage = 1.0f;
            break;
            
        case KWDrawerSideRight:
            _sandBox.percentage = -1.0f;
            break;
            
        case KWDrawerSideNone:
            _sandBox.percentage = 0.0f;
            
        default:
            break;
    }
    [self updateViewSize];
    
    UIView *mergeView = _drawerViewController[_sandBox.movingSide].view;
    if(mergeView != _sandBox.drawerView)
    {
        _sandBox.drawerView.hidden = YES;
        //[_sandBox copyStateInView:mergeView];
        
        [_sandBox.drawerView removeFromSuperview];
        _sandBox.drawerView = nil;
    }
    [_safetyViewBox[_sandBox.movingSide] bringSubviewToFront:mergeView];
    [mergeView setHidden:NO];
    
    _sandBox.beginSide = KWDrawerSideNone;
    _sandBox.movingSide = KWDrawerSideNone;
    _sandBox.endedSide = KWDrawerSideCount;
    _sandBox.drawerView = nil;
}

- (void)changeSandbox:(UIView *)view
{
    if(view == _sandBox.drawerView)
        return;
    
    [self changeSandbox:view inDrawerSide:_sandBox.movingSide];
}

- (void)changeSandbox:(UIView *)view inDrawerSide:(KWDrawerSide)drawerSide
{
    if(view == _sandBox.drawerView && drawerSide == _sandBox.movingSide)
        return;
    
    [self closeSandbox];
    
    _beginPoint = _movePoint;
    
    [self openSandbox:view inDrawerSide:drawerSide];
}

- (void)changeSandboxInDrawerSide:(KWDrawerSide)drawerSide
{
    if(drawerSide == _sandBox.movingSide)
        return;
    
    [self changeSandbox:_sandBox.drawerView inDrawerSide:drawerSide];
}

- (void)errorSandbox:(KWDrawerSandbox *)sandBox
{
    
}


#pragma mark -
#pragma mark Override Methods

- (id)init
{
    self = [super init];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self construct];
    }
    return self;
}

- (void)dealloc
{
    [self destruct];
}


#pragma mark -
#pragma mark Private Methods

- (void)construct
{
    NSInteger i;
    
    /// Variable
    _sandBox = [[KWDrawerSandbox alloc] init];
    
    _delegate = nil;
    _gestureEnable = YES;
    _animationEnable = YES;
    _showShadow = NO;
    _enable = YES;
    
    _sideState = KWDrawerSideNone;
    _statusBarHidden = NO;
    _statusBarTranslucent = NO;
    
    /// Parent View
    [self.view setFrame:CGSizeRect(self.view.frame.size)];
    
    /// Sandbox View
    _sandboxView = [[UIView alloc] initWithFrame:self.view.frame];
    [_sandboxView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_sandboxView];
    
    /// Safety View Box
    for(i = KWDrawerSideNone; i < KWDrawerSideCount; i ++)
    {
        _isDrawer[i] = NO;
        _isUserInterection[i] = YES;
        _safetyViewBox[i] = [[UIView alloc] initWithFrame:self.view.frame];
        [_sandboxView addSubview:_safetyViewBox[i]];
    }
    _safetyViewBox[KWDrawerSideLeft].hidden  = YES;
    _safetyViewBox[KWDrawerSideRight].hidden = YES;
    
    /// Gesture Recognizer
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [_panGestureRecognizer setDelegate:self];
    [_tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    
    /// Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBeganDrawViewController:)
                                                 name:kDrawerDrawViewControllerNotification
                                               object:nil];
}

- (void)destruct
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateViewSize
{
    __block NSInteger i;
    static BOOL statusBarHidden = NO;
    
    CGFloat leftSize = _isDrawer[KWDrawerSideLeft] ? self.view.bounds.size.width - _drawerViewController[KWDrawerSideLeft].view.bounds.size.width : 0.0f;
    CGFloat rightSize = _isDrawer[KWDrawerSideRight] ? self.view.bounds.size.width - _drawerViewController[KWDrawerSideRight].view.bounds.size.width : 0.0f;
    
    _drawerViewRect[KWDrawerSideNone]  = CGRectZero;
    _drawerViewRect[KWDrawerSideLeft]  = (CGRect){0, 0, -MAX(0, leftSize), 0};
    _drawerViewRect[KWDrawerSideRight] = (CGRect){MAX(0, rightSize), 0, -MAX(0, rightSize), 0};
    
    /// iOS 3.2 ~ 6.x
    if(![self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        if(_statusBarHidden || _statusBarTranslucent)
        {
            _drawerViewRect[KWDrawerSideNone]  = (CGRect){0, -20, 0, 20};
            for(i = KWDrawerSideLeft; i < KWDrawerSideCount; i ++)
                _drawerViewRect[i] = CGRectAdd(_drawerViewRect[i], _drawerViewRect[KWDrawerSideNone]);
        }
        
        if(statusBarHidden != (_statusBarHidden | _statusBarTranslucent))
        {
            [UIView animateWithDuration:kDrawerDefaultAnimationDuration animations:^
             {
                 for(i = KWDrawerSideNone; i < KWDrawerSideCount; i ++)
                 {
                     _drawerViewController[i].view.frame = CGRectAdd(_drawerViewController[i].view.frame, _drawerViewRect[KWDrawerSideNone]);
                 }
             }];
        }
        
        statusBarHidden = _statusBarHidden | _statusBarTranslucent;
    }
}

- (UIViewController *)openedViewController
{
    switch (self.openedDrawerSide)
    {
        case KWDrawerSideLeft:
        case KWDrawerSideRight:
            return _drawerViewController[self.openedDrawerSide];
            
        default:
            return _drawerViewController[KWDrawerSideNone];
    }
}

- (void)setUserInteraction:(BOOL)interaction forDrawerSide:(KWDrawerSide)drawerSide
{
    if (!_isDrawer[drawerSide])
        return;
    
    if(!interaction)
    {
        if(_isUserInterection[drawerSide])
            _isOldUserInterection[drawerSide] = _drawerViewController[drawerSide].view.userInteractionEnabled;
    }
    else
    {
        interaction = _isOldUserInterection[drawerSide];
    }
    _isUserInterection[drawerSide] = interaction;
    
    [_drawerViewController[drawerSide].view setUserInteractionEnabled:interaction];
    [_safetyViewBox[drawerSide] setUserInteractionEnabled:interaction];
}


#pragma mark -
#pragma mark StatusBar Methods
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self statusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self statusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden
{
    return [self statusBarHidden];
}

- (UIStatusBarStyle)statusBarStyle
{
    UIStatusBarStyle style;
    
    if([self.openedViewController respondsToSelector:@selector(statusBarStyle)])
    {
        UIViewController *viewController = self.openedViewController;
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            style = (UIStatusBarStyle)[navigationController.visibleViewController performSelector:@selector(statusBarStyle)];
        }
        else
            style = (UIStatusBarStyle)[viewController performSelector:@selector(statusBarStyle)];
    }
    else
    {
        style = [self preferredStatusBarStyle];
    }
    
    if(style == UIStatusBarStyleLightContent)
        _statusBarTranslucent = YES;
    else
        _statusBarTranslucent = NO;
    
    return style;
}

- (UIStatusBarAnimation)statusBarUpdateAnimation
{
    UIStatusBarAnimation animation;
    
    if([self.openedViewController respondsToSelector:@selector(statusBarUpdateAnimation)])
    {
        animation = (UIStatusBarAnimation)[self.openedViewController performSelector:@selector(statusBarUpdateAnimation)];
    }
    else
    {
        animation = [self preferredStatusBarUpdateAnimation];
    }
    
    return animation;
}

- (BOOL)statusBarHidden
{
    BOOL hidden;
    
    if([self.openedViewController respondsToSelector:@selector(statusBarHidden)])
    {
        hidden = (BOOL)[self.openedViewController performSelector:@selector(statusBarHidden)];
    }
    else
    {
        hidden = [self prefersStatusBarHidden];
    }
    
    return _statusBarHidden = hidden;
}

- (void)setNeedsStatusBarUpdate
{
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7.x
        [UIView animateWithDuration:kDrawerDefaultAnimationDuration animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
    //else
    {
        UIStatusBarAnimation animation = [self statusBarUpdateAnimation];
        UIApplication *application = [UIApplication sharedApplication];
        
        // iOS 3.2 ~ 6.x
        [application setStatusBarStyle:[self statusBarStyle]
                              animated:(animation != UIStatusBarAnimationNone)];
        
        [application setStatusBarHidden:[self statusBarHidden]
                          withAnimation:animation];
    }
}

@end
