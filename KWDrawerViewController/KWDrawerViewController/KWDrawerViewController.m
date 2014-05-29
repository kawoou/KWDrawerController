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

#import "KWDrawerViewController.h"

@interface KWDrawerViewController () <UIGestureRecognizerDelegate>
{
    BOOL                    _slideEnable;
    
    CGFloat                 _commitPosition;
    BOOL                    _isMovingLeftDrawer;
    BOOL                    _isMovingRightDrawer;
    BOOL                    _isAnimationPlaying;
    
    CGPoint                 _beginPoint;
    CGPoint                 _movePoint;
    CGPoint                 _endPoint;
    BOOL                    _isTouchMoveLeft;
    
    BOOL                    _leftViewWillAppear;
    BOOL                    _rightViewWillAppear;
    
    BOOL                    _isMainUserInteraction;
    BOOL                    _isLeftUserInteraction;
    BOOL                    _isRightUserInteraction;
    BOOL                    _oldMainUserInteraction;
    BOOL                    _oldLeftUserInteraction;
    BOOL                    _oldRightUserInteraction;
    
    UIPanGestureRecognizer  *_gestureRecognizer;
    UITapGestureRecognizer  *_tapGestureRecognizer;
}

- (void)_showMainViewController;
- (void)_showLeftDrawerViewController;
- (void)_showRightDrawerViewController;

- (void)initialize;
- (void)setUserInteraction:(BOOL)interaction forViewController:(UIViewController *)viewController;

- (void)isMainViewControllerTouched;

- (void)didBeganAnimationLeftDrawer:(UIViewController *)viewController;
- (void)didBeganAnimationRightDrawer:(UIViewController *)viewController;
- (void)mainViewController:(UIViewController *)viewController didAnimationWithPercentage:(CGFloat)percentage;
- (void)willFinishAnimationMainViewController:(UIViewController *)viewController;
- (void)willFinishAnimationLeftDrawer:(UIViewController *)viewController;
- (void)willFinishAnimationRightDrawer:(UIViewController *)viewController;

@end

@implementation KWDrawerViewController

#pragma mark -
#pragma mark Override Methods
- (id)init
{
    if(self = [super init])
        [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
        [self initialize];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
        [self initialize];
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.showingViewController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.showingViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.showingViewController prefersStatusBarHidden];
}

#pragma mark -
#pragma mark Public Methods
- (void)setMainViewController:(UIViewController *)mainViewController
{
    [self addChildViewController:mainViewController];
    
    _mainViewController = mainViewController;
    [self setUserInteraction:NO forViewController:_mainViewController];
    [self setUserInteraction:YES forViewController:_mainViewController];
    
    [self.view addSubview:_mainViewController.view];
    
    CGRect rect = (CGRect){CGPointZero, _mainViewController.view.frame.size};
    _mainViewController.view.frame = rect;
    _mainViewController.drawerController = self;
}

- (void)setLeftDrawerViewController:(UIViewController *)leftDrawerViewController
{
    [self addChildViewController:leftDrawerViewController];
    
    _leftDrawerViewController = leftDrawerViewController;
    [self setUserInteraction:NO forViewController:_leftDrawerViewController];
    [_leftDrawerViewController.view setHidden:YES];
    
    [self.view addSubview:_leftDrawerViewController.view];
    [self.view bringSubviewToFront:_mainViewController.view];
    
    CGRect rect = (CGRect){CGPointZero, _leftDrawerViewController.view.frame.size};
    _leftDrawerViewController.view.frame = rect;
    _leftDrawerViewController.drawerController = self;
}

- (void)setRightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    [self addChildViewController:rightDrawerViewController];
    
    _rightDrawerViewController = rightDrawerViewController;
    [self setUserInteraction:NO forViewController:_rightDrawerViewController];
    [_rightDrawerViewController.view setHidden:YES];
    
    [self.view addSubview:_rightDrawerViewController.view];
    [self.view bringSubviewToFront:_mainViewController.view];
    
    CGRect rect = (CGRect){CGPointZero, _rightDrawerViewController.view.frame.size};
    _rightDrawerViewController.view.frame = rect;
    _rightDrawerViewController.drawerController = self;
}

- (void)showMainViewController
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    [self _showMainViewController];
}

- (void)showLeftDrawerViewController
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    [self _showLeftDrawerViewController];
}

- (void)showRightDrawerViewController
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    [self _showRightDrawerViewController];
}

#pragma mark -
#pragma mark Variables
- (void)setSlideEnable:(BOOL)slideEnable
{
    _slideEnable = slideEnable;
}

- (BOOL)slideEnable
{
    return _slideEnable;
}

- (UIViewController *)showingViewController
{
    if(_commitPosition == 0.0f)
        return _mainViewController;
    else if(_commitPosition == 1.0f)
        return _leftDrawerViewController;
    else if(_commitPosition == -1.0f)
        return _rightDrawerViewController;
    else
        return _mainViewController;
}

#pragma mark -
#pragma mark Gesture Recognizer
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gesture
{
    if(_isMovingLeftDrawer) return;
    if(_isMovingRightDrawer) return;
    if(_isAnimationPlaying) return;
    [self _showMainViewController];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = [gesture state];
    CGPoint location = [gesture locationInView:self.view];
    
    if(_isAnimationPlaying) return;
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        if(!_isMovingLeftDrawer && !_isMovingRightDrawer) return;
        
        CGFloat percentage = _commitPosition + (location.x - _beginPoint.x) / self.view.frame.size.width;
        if(location.x - _movePoint.x > 0)
            _isTouchMoveLeft = NO;
        else if(location.x - _movePoint.x < 0)
            _isTouchMoveLeft = YES;
        
        _movePoint = location;
        
        if(_commitPosition == 0.0f)
        {
            if(percentage < 0 && _rightViewWillAppear == NO)
            {
                _rightViewWillAppear = YES;
                [_rightDrawerViewController viewWillAppear:YES];
            }
            else if(percentage > 0 && _leftViewWillAppear == NO)
            {
                _leftViewWillAppear = YES;
                [_leftDrawerViewController viewWillAppear:YES];
            }
        }
        
        [self mainViewController:_mainViewController didAnimationWithPercentage:percentage];
    }
    else if(state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
        _endPoint = location;
        if(_isMovingLeftDrawer || _isMovingRightDrawer)
        {
            if(_commitPosition == 0.0f)
            {
                if(_isMovingLeftDrawer)
                {
                    [self willFinishAnimationLeftDrawer:_leftDrawerViewController];
                    if(_isTouchMoveLeft == NO)
                        return [self _showLeftDrawerViewController];
                }
                else
                {
                    [self willFinishAnimationRightDrawer:_rightDrawerViewController];
                    if(_isTouchMoveLeft == YES)
                        return [self _showRightDrawerViewController];
                }
            }
            else if(_commitPosition == 1.0f)
            {
                [self willFinishAnimationLeftDrawer:_leftDrawerViewController];
                if(_isTouchMoveLeft == NO)
                    return [self _showLeftDrawerViewController];
            }
            else
            {
                [self willFinishAnimationRightDrawer:_rightDrawerViewController];
                if(_isTouchMoveLeft == YES)
                    return [self _showRightDrawerViewController];
            }
            [self _showMainViewController];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    
    if(!_slideEnable) return NO;
    if(_isAnimationPlaying) return NO;
    if(gestureRecognizer == _gestureRecognizer)
    {
        [self willFinishAnimationLeftDrawer:_leftDrawerViewController];
        [self willFinishAnimationRightDrawer:_rightDrawerViewController];
        
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
        if (fabsf(translation.x) < fabsf(translation.y))
            return NO;
        
        CGRect pointRect;
        CGPoint transition = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:self.view];
        _beginPoint = [gestureRecognizer locationInView:self.view];
        _movePoint = _beginPoint;
        pointRect = CGRectMake(_beginPoint.x-transition.x-20, _beginPoint.y-transition.y-20, 40, 40);
        if(_commitPosition == 0.0f)
        {
            CGRect leftRect = CGRectMake(_mainViewController.view.frame.origin.x-20, 0, 40, self.view.frame.size.height);
            CGRect rightRect = CGRectMake(leftRect.origin.x+self.view.frame.size.width, 0, 40, leftRect.size.height);
            if(_leftDrawerViewController && CGRectIntersectsRect(leftRect, pointRect))
            {
                _isTouchMoveLeft = YES;
                [self didBeganAnimationLeftDrawer:_leftDrawerViewController];
                return YES;
            }
            if(_rightDrawerViewController && CGRectIntersectsRect(rightRect, pointRect))
            {
                _isTouchMoveLeft = NO;
                [self didBeganAnimationRightDrawer:_rightDrawerViewController];
                return YES;
            }
        }
        else if(_commitPosition == 1.0f)
        {
            CGRect mainRect = _mainViewController.view.frame;
            if(CGRectIntersectsRect(mainRect, pointRect))
            {
                _isTouchMoveLeft = YES;
                [self didBeganAnimationLeftDrawer:_leftDrawerViewController];
                return YES;
            }
        }
        else
        {
            CGRect mainRect = _mainViewController.view.frame;
            if(CGRectIntersectsRect(mainRect, pointRect))
            {
                _isTouchMoveLeft = NO;
                [self didBeganAnimationRightDrawer:_rightDrawerViewController];
                return YES;
            }
        }
        return NO;
    }
    else
    {
        if([self isMainViewControllerTouched:[gestureRecognizer locationInView:self.view]])
            return YES;
        
        return NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIGestureRecognizer *gesture = nil;
    if(_gestureRecognizer == gestureRecognizer)
        gesture = _gestureRecognizer;
    else if(_tapGestureRecognizer == gestureRecognizer)
        gesture = _tapGestureRecognizer;
    else
        return NO;
    
    if(gestureRecognizer == otherGestureRecognizer || otherGestureRecognizer == gesture)
        return YES;
    return NO;
}

#pragma mark -
#pragma mark Private Methods
- (void)_showMainViewController
{
    if(_isAnimationPlaying) return;
    
    CGFloat lastCommitPosition = _commitPosition;
    
    _isAnimationPlaying = YES;
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self mainViewController:_mainViewController didAnimationWithPercentage:0.0f];
    } completion:^(BOOL finished){
        _commitPosition = 0.0f;
        [self setUserInteraction:NO forViewController:_leftDrawerViewController];
        [self setUserInteraction:NO forViewController:_rightDrawerViewController];
        [self setUserInteraction:YES forViewController:_mainViewController];
        [self willFinishAnimationMainViewController:_mainViewController];
        
        if(lastCommitPosition == 1.0f)
        {
            [_leftDrawerViewController viewWillDisappear:YES];
            [_leftDrawerViewController viewDidDisappear:YES];
        }
        if(lastCommitPosition == -1.0f)
        {
            [_rightDrawerViewController viewWillDisappear:YES];
            [_rightDrawerViewController viewDidDisappear:YES];
        }
        
        if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        _isAnimationPlaying = NO;
    }];
}

- (void)_showLeftDrawerViewController
{
    if(_isAnimationPlaying) return;
    
    [self didBeganAnimationLeftDrawer:_leftDrawerViewController];
    
    if(_leftViewWillAppear == NO)
        [_leftDrawerViewController viewWillAppear:YES];
    
    _isAnimationPlaying = YES;
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self mainViewController:_mainViewController didAnimationWithPercentage:1.0f];
    } completion:^(BOOL finished){
        _commitPosition = 1.0f;
        [self setUserInteraction:YES forViewController:_leftDrawerViewController];
        [self setUserInteraction:NO forViewController:_mainViewController];
        [self willFinishAnimationLeftDrawer:_leftDrawerViewController];
        
        [_leftDrawerViewController viewDidAppear:YES];
        if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        _isAnimationPlaying = NO;
    }];
}

- (void)_showRightDrawerViewController
{
    if(_isAnimationPlaying) return;
    
    [self didBeganAnimationRightDrawer:_rightDrawerViewController];
    
    if(_rightViewWillAppear == NO)
        [_rightDrawerViewController viewWillAppear:YES];
    
    _isAnimationPlaying = YES;
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self mainViewController:_mainViewController didAnimationWithPercentage:-1.0f];
    } completion:^(BOOL finished){
        _commitPosition = -1.0f;
        [self setUserInteraction:YES forViewController:_rightDrawerViewController];
        [self setUserInteraction:NO forViewController:_mainViewController];
        [self willFinishAnimationRightDrawer:_rightDrawerViewController];
        
        [_rightDrawerViewController viewDidAppear:YES];
        if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        _isAnimationPlaying = NO;
    }];
}

- (void)initialize
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    
    _slideEnable = YES;
    _commitPosition = 0.0f;
    _isMovingLeftDrawer = _isMovingRightDrawer = _isAnimationPlaying = NO;
    _isMainUserInteraction = _isLeftUserInteraction = _isRightUserInteraction = YES;
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [_gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_gestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)setUserInteraction:(BOOL)interaction forViewController:(UIViewController *)viewController
{
    if(interaction == NO)
    {
        if(viewController == _mainViewController)
        {
            if(_isMainUserInteraction == YES)
                _oldMainUserInteraction = _mainViewController.view.userInteractionEnabled;
            _isMainUserInteraction = NO;
        }
        else if(viewController == _leftDrawerViewController)
        {
            if(_isLeftUserInteraction == YES)
                _oldLeftUserInteraction = _leftDrawerViewController.view.userInteractionEnabled;
            _isLeftUserInteraction = NO;
        }
        else
        {
            if(_isRightUserInteraction == YES)
                _oldRightUserInteraction = _rightDrawerViewController.view.userInteractionEnabled;
            _isRightUserInteraction = NO;
        }
    }
    else
    {
        if(viewController == _mainViewController)
        {
            interaction = _oldMainUserInteraction;
            _isMainUserInteraction = YES;
        }
        else if(viewController == _leftDrawerViewController)
        {
            interaction = _oldLeftUserInteraction;
            _isLeftUserInteraction = YES;
        }
        else
        {
            interaction = _oldRightUserInteraction;
            _isRightUserInteraction = YES;
        }
    }
    [viewController.view setUserInteractionEnabled:interaction];
}

- (BOOL)isMainViewControllerTouched:(CGPoint)point
{
    CGRect pointRect = CGRectMake(point.x - 20, point.y - 20, 40, 40);
    
    if(_commitPosition == 0.0f)
        return NO;
    
    for(int i = self.view.subviews.count - 1; i >= 0; i --)
    {
        UIView *view = self.view.subviews[i];
        if(CGRectIntersectsRect(view.frame, pointRect))
        {
            if(_commitPosition > 0.0f &&
               _leftDrawerViewController.view == view)
                return NO;
            
            if(_commitPosition < 0.0f &&
               _rightDrawerViewController.view == view)
                return NO;
            
            if(_mainViewController.view == view)
                return YES;
        }
    }
    
    return NO;
}

- (void)didBeganAnimationLeftDrawer:(UIViewController *)viewController
{
    if(_isAnimationPlaying) return;
    
    _isMovingLeftDrawer = YES;
    _isMovingRightDrawer = NO;
    
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = NO;
    if(_commitPosition == 0.0f)
        _rightDrawerViewController.view.hidden = YES;
    
    [self setUserInteraction:NO forViewController:_leftDrawerViewController];
    if(_commitPosition == -1.0f)
        [self setUserInteraction:NO forViewController:_rightDrawerViewController];
    else
        [self setUserInteraction:NO forViewController:viewController];
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:didBeganAnimationLeftDrawer:)])
        [_delegate drawerViewController:self didBeganAnimationLeftDrawer:viewController];
}

- (void)didBeganAnimationRightDrawer:(UIViewController *)viewController
{
    if(_isAnimationPlaying) return;
    
    _isMovingRightDrawer = YES;
    _isMovingLeftDrawer = NO;
    
    viewController.view.hidden = NO;
    _rightDrawerViewController.view.hidden = NO;
    if(_commitPosition == 0.0f)
        _leftDrawerViewController.view.hidden = YES;
    
    [self setUserInteraction:NO forViewController:_rightDrawerViewController];
    if(_commitPosition == 1.0f)
        [self setUserInteraction:NO forViewController:_leftDrawerViewController];
    else
        [self setUserInteraction:NO forViewController:viewController];
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:didBeganAnimationRightDrawer:)])
        [_delegate drawerViewController:self didBeganAnimationRightDrawer:viewController];
}

- (void)mainViewController:(UIViewController *)viewController didAnimationWithPercentage:(CGFloat)percentage
{
    if(_isMovingLeftDrawer)
    {
        if(percentage < 0.0f) percentage = 0.0f;
        if(percentage > 1.06f) percentage = 1.06f;
    }
    if(_isMovingRightDrawer)
    {
        if(percentage > 0.0f) percentage = 0.0f;
        if(percentage < -1.06f) percentage = -1.06f;
    }
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:didAnimationMainViewController:withPercentage:)])
        [_delegate drawerViewController:self didAnimationMainViewController:_mainViewController withPercentage:percentage];
    else
    {
        viewController.view.frame = CGRectMake(percentage * 280.0f,
                                               viewController.view.frame.origin.y,
                                               viewController.view.frame.size.width,
                                               viewController.view.frame.size.height);
    }
}

- (void)willFinishAnimationMainViewController:(UIViewController *)viewController
{
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = YES;
    _rightDrawerViewController.view.hidden = YES;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationMainDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationMainDrawer:viewController];
}

- (void)willFinishAnimationLeftDrawer:(UIViewController *)viewController
{
    if(!_isMovingLeftDrawer) return;
    
    _isMovingLeftDrawer = NO;
    
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = NO;
    _rightDrawerViewController.view.hidden = YES;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationLeftDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationLeftDrawer:viewController];
}

- (void)willFinishAnimationRightDrawer:(UIViewController *)viewController
{
    if(!_isMovingRightDrawer) return;
    
    _isMovingRightDrawer = NO;
    
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = YES;
    _rightDrawerViewController.view.hidden = NO;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationRightDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationRightDrawer:viewController];
}

@end
