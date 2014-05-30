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

#import "KWDrawerController.h"

@interface KWDrawerViewController () <UIGestureRecognizerDelegate>
{
    BOOL                    _slideEnable;
    
    CGFloat                 _commitPosition;
    
    CGPoint                 _beginPoint;
    CGPoint                 _movePoint;
    CGPoint                 _endPoint;
    BOOL                    _isTouchMoveLeft;
    
    BOOL                    _leftViewWillAppear;
    BOOL                    _rightViewWillAppear;
    BOOL                    _statusBarHidden;
    BOOL                    _statusBarTranslucent;
    
    BOOL                    _isMainUserInteraction;
    BOOL                    _isLeftUserInteraction;
    BOOL                    _isRightUserInteraction;
    BOOL                    _oldMainUserInteraction;
    BOOL                    _oldLeftUserInteraction;
    BOOL                    _oldRightUserInteraction;
    
    CGRect                  _mainViewRect;
    CGRect                  _leftViewRect;
    CGRect                  _rightViewRect;
    
    UIPanGestureRecognizer  *_gestureRecognizer;
    UITapGestureRecognizer  *_tapGestureRecognizer;
}

@property (nonatomic, assign) BOOL      isMovingLeftDrawer;
@property (nonatomic, assign) BOOL      isMovingRightDrawer;
@property (nonatomic, assign) BOOL      isAnimationPlaying;

- (void)_showMainViewController;
- (void)_showLeftDrawerViewController;
- (void)_showRightDrawerViewController;

- (void)initialize;
- (void)repositioning;
- (void)setUserInteraction:(BOOL)interaction forViewController:(UIViewController *)viewController;

- (BOOL)isMainViewControllerTouched:(CGPoint)point;

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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UIStatusBarStyle style = (UIStatusBarStyle)[self.showingViewController performSelector:@selector(statusBarStyle)];
    
    if(style == UIStatusBarStyleLightContent)
        _statusBarTranslucent = YES;
    else
        _statusBarTranslucent = NO;
    
    return style;
#pragma clang diagnostic pop
}

- (UIStatusBarAnimation)statusBarUpdateAnimation
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return (UIStatusBarAnimation)[self.showingViewController performSelector:@selector(statusBarUpdateAnimation)];
#pragma clang diagnostic pop
}

- (BOOL)statusBarHidden
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return _statusBarHidden = (BOOL)[self.showingViewController performSelector:@selector(statusBarHidden)];
#pragma clang diagnostic pop
}

- (void)setNeedsStatusBarUpdate
{
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [UIView animateWithDuration:0.35f animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:[self statusBarStyle] animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:[self statusBarHidden] withAnimation:[self statusBarUpdateAnimation]];
        
        [self repositioning];
    }
}

#pragma mark -
#pragma mark Public Methods
- (void)setMainViewController:(UIViewController *)mainViewController
{
    [self addChildViewController:mainViewController];
    
    _mainViewController = mainViewController;
    [self addChildViewController:_mainViewController];
    
    [self setUserInteraction:NO forViewController:_mainViewController];
    [self setUserInteraction:YES forViewController:_mainViewController];
    
    [self.view addSubview:_mainViewController.view];
    
    [self repositioning];
}

- (void)setLeftDrawerViewController:(UIViewController *)leftDrawerViewController
{
    [self addChildViewController:leftDrawerViewController];
    
    _leftDrawerViewController = leftDrawerViewController;
    [self addChildViewController:_leftDrawerViewController];
    
    [self setUserInteraction:NO forViewController:_leftDrawerViewController];
    [_leftDrawerViewController.view setHidden:YES];
    
    [self.view addSubview:_leftDrawerViewController.view];
    [self.view bringSubviewToFront:_mainViewController.view];
    
    [self repositioning];
}

- (void)setRightDrawerViewController:(UIViewController *)rightDrawerViewController
{
    [self addChildViewController:rightDrawerViewController];
    
    _rightDrawerViewController = rightDrawerViewController;
    [self addChildViewController:_rightDrawerViewController];
    
    [self setUserInteraction:NO forViewController:_rightDrawerViewController];
    [_rightDrawerViewController.view setHidden:YES];
    
    [self.view addSubview:_rightDrawerViewController.view];
    [self.view bringSubviewToFront:_mainViewController.view];
    
    [self repositioning];
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

- (void)setMaximumLeftDrawerWidth:(CGFloat)width animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    if(self.view.bounds.size.width + _rightViewRect.size.width != width)
    {
        CGRect rect = _leftDrawerViewController.view.frame;
        rect.size.width = width;
        
        [UIView animateWithDuration:(kDrawerDefaultAnimationDuration * animated) animations:^{
            _leftDrawerViewController.view.frame = rect;
        } completion:completion];
        
        [self repositioning];
    }
}

- (void)setMaximumRightDrawerWidth:(CGFloat)width animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    if(self.view.bounds.size.width + _rightViewRect.size.width != width)
    {
        CGRect rect = _rightDrawerViewController.view.frame;
        rect.size.width = width;
        
        [UIView animateWithDuration:(kDrawerDefaultAnimationDuration * animated) animations:^{
            _rightDrawerViewController.view.frame = rect;
        } completion:completion];
        
        [self repositioning];
    }
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

- (void)setShowShadow:(BOOL)showShadow
{
    _showShadow = showShadow;
    
    UIView *mainView = self.mainViewController.view;
    UIView *leftView = self.leftDrawerViewController.view;
    UIView *rightView = self.rightDrawerViewController.view;
    if(_showShadow)
    {
        mainView.layer.masksToBounds = NO;
        mainView.layer.shadowRadius = kDrawerDefaultShadowRadius;
        mainView.layer.shadowOpacity = kDrawerDefaultShadowOpacity;
        mainView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:mainView.bounds] CGPath];
        
        leftView.layer.masksToBounds = NO;
        leftView.layer.shadowRadius = kDrawerDefaultShadowRadius;
        leftView.layer.shadowOpacity = kDrawerDefaultShadowOpacity;
        leftView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:leftView.bounds] CGPath];
        
        rightView.layer.masksToBounds = NO;
        rightView.layer.shadowRadius = kDrawerDefaultShadowRadius;
        rightView.layer.shadowOpacity = kDrawerDefaultShadowOpacity;
        rightView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:rightView.bounds] CGPath];
    }
    else
    {
        mainView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectNull].CGPath;
        mainView.layer.masksToBounds = YES;
        
        leftView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectNull].CGPath;
        leftView.layer.masksToBounds = YES;
        
        rightView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectNull].CGPath;
        rightView.layer.masksToBounds = YES;
    }
}

- (void)setDelegate:(id<KWDrawerViewControllerDelegate>)delegate
{
    _delegate = delegate;

    [self repositioning];
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
    if(self.isAnimationPlaying) return;
    [self _showMainViewController];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = [gesture state];
    CGPoint location = [gesture locationInView:self.view];
    
    if(self.isAnimationPlaying) return;
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGSize viewSize;
        if(self.isMovingLeftDrawer)
            viewSize = CGSizeAdd(self.view.frame.size, _leftViewRect.size);
        else if(self.isMovingRightDrawer)
            viewSize = CGSizeAdd(self.view.frame.size, _rightViewRect.size);
        else
            return;
        
        CGFloat percentage = _commitPosition + (location.x - _beginPoint.x) / viewSize.width;
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
        if(self.isMovingLeftDrawer || self.isMovingRightDrawer)
        {
            if(_commitPosition == 0.0f)
            {
                if(self.isMovingLeftDrawer)
                {
                    if(_isTouchMoveLeft == NO)
                        return [self _showLeftDrawerViewController];
                }
                else
                {
                    if(_isTouchMoveLeft == YES)
                        return [self _showRightDrawerViewController];
                }
            }
            else if(_commitPosition == 1.0f)
            {
                if(_isTouchMoveLeft == NO)
                    return [self _showLeftDrawerViewController];
            }
            else
            {
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
    
    if(!_slideEnable)
        return NO;
    if(self.isAnimationPlaying)
        return NO;
    if(gestureRecognizer == _gestureRecognizer)
    {
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
    if(self.isAnimationPlaying) return;
    
    CGFloat lastCommitPosition = _commitPosition;
    if(!self.isMovingLeftDrawer && !self.isMovingRightDrawer)
    {
        if(lastCommitPosition > 0.0f)
        {
            self.isMovingLeftDrawer = YES;
            self.isMovingRightDrawer = NO;
        }
        if(lastCommitPosition < 0.0f)
        {
            self.isMovingLeftDrawer = NO;
            self.isMovingRightDrawer = YES;
        }
    }
    
    self.isAnimationPlaying = YES;
    [UIView animateWithDuration:kDrawerDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
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
        self.isAnimationPlaying = NO;
        
        [self setNeedsStatusBarUpdate];
    }];
}

- (void)_showLeftDrawerViewController
{
    if(self.isAnimationPlaying) return;
    
    [self didBeganAnimationLeftDrawer:_leftDrawerViewController];
    
    if(_leftViewWillAppear == NO)
        [_leftDrawerViewController viewWillAppear:YES];
    
    self.isAnimationPlaying = YES;
    [UIView animateWithDuration:kDrawerDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self mainViewController:_mainViewController didAnimationWithPercentage:1.0f];
    } completion:^(BOOL finished){
        _commitPosition = 1.0f;
        [self setUserInteraction:YES forViewController:_leftDrawerViewController];
        [self setUserInteraction:NO forViewController:_mainViewController];
        [self willFinishAnimationLeftDrawer:_leftDrawerViewController];
        
        [_leftDrawerViewController viewDidAppear:YES];
        self.isAnimationPlaying = NO;
        
        [self setNeedsStatusBarUpdate];
    }];
}

- (void)_showRightDrawerViewController
{
    if(self.isAnimationPlaying) return;
    
    [self didBeganAnimationRightDrawer:_rightDrawerViewController];
    
    if(_rightViewWillAppear == NO)
        [_rightDrawerViewController viewWillAppear:YES];
    
    self.isAnimationPlaying = YES;
    [UIView animateWithDuration:kDrawerDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self mainViewController:_mainViewController didAnimationWithPercentage:-1.0f];
    } completion:^(BOOL finished){
        _commitPosition = -1.0f;
        [self setUserInteraction:YES forViewController:_rightDrawerViewController];
        [self setUserInteraction:NO forViewController:_mainViewController];
        [self willFinishAnimationRightDrawer:_rightDrawerViewController];
        
        [_rightDrawerViewController viewDidAppear:YES];
        self.isAnimationPlaying = NO;
        
        [self setNeedsStatusBarUpdate];
    }];
}

- (void)initialize
{
    _leftViewWillAppear = _rightViewWillAppear = NO;
    
    _slideEnable = YES;
    _commitPosition = 0.0f;
    self.isMovingLeftDrawer = self.isMovingRightDrawer = self.isAnimationPlaying = NO;
    _isMainUserInteraction = _isLeftUserInteraction = _isRightUserInteraction = YES;
    _statusBarHidden = NO;
    _statusBarTranslucent = NO;
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [_gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_gestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)repositioning
{
    static BOOL statusBarHidden = NO;
    CGFloat leftSize = self.view.bounds.size.width - _leftDrawerViewController.view.bounds.size.width;
    CGFloat rightSize = self.view.bounds.size.width - _rightDrawerViewController.view.bounds.size.width;
    
    _mainViewRect = CGRectZero;
    _leftViewRect = CGRectMake(0, 0, -MAX(0, leftSize), 0);
    _rightViewRect = CGRectMake(MAX(0, rightSize), 0, -MAX(0, rightSize), 0);
    
    if(!_isAnimationPlaying)
    {
        /* 7.0f > OS Version */
        if(![self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {
            if(_statusBarHidden || _statusBarTranslucent)
            {
                _mainViewRect = CGRectMake(0, -20, 0, 20);
                _leftViewRect = CGRectAdd(_leftViewRect, _mainViewRect);
                _rightViewRect = CGRectAdd(_rightViewRect, _mainViewRect);
            }
        }
        if(statusBarHidden != _statusBarHidden || _statusBarTranslucent != _statusBarHidden)
        {
            [UIView animateWithDuration:0.35f animations:^{
                CGRect viewRect = (CGRect){self.view.frame.origin.x, 0, self.view.frame.size};
                
                _mainViewController.view.frame = CGRectAdd(viewRect, _mainViewRect);
                _leftDrawerViewController.view.frame = CGRectAdd(viewRect, _leftViewRect);
                _rightDrawerViewController.view.frame = CGRectAdd(viewRect, _rightViewRect);
            }];
        }
        else
        {
            CGRect viewRect = (CGRect){self.view.frame.origin.x, 0, self.view.frame.size};
            
            _mainViewController.view.frame = CGRectAdd(viewRect, _mainViewRect);
            _leftDrawerViewController.view.frame = CGRectAdd(viewRect, _leftViewRect);
            _rightDrawerViewController.view.frame = CGRectAdd(viewRect, _rightViewRect);
        }
        if(![self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            statusBarHidden = _statusBarHidden || _statusBarTranslucent;
    }
}

- (void)setIsMovingLeftDrawer:(BOOL)isMovingLeftDrawer
{
    _isMovingLeftDrawer = isMovingLeftDrawer;
}

- (void)setIsMovingRightDrawer:(BOOL)isMovingRightDrawer
{
    _isMovingRightDrawer = isMovingRightDrawer;
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
    
    for(NSInteger i = self.view.subviews.count - 1; i >= 0; i --)
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
    if(self.isAnimationPlaying) return;
    
    self.isMovingLeftDrawer = YES;
    self.isMovingRightDrawer = NO;
    
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
    if(self.isAnimationPlaying) return;
    
    self.isMovingRightDrawer = YES;
    self.isMovingLeftDrawer = NO;
    
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
    KWDrawerSide sideState = self.isMovingLeftDrawer?KWDrawerSideLeft:(self.isMovingRightDrawer?KWDrawerSideRight:KWDrawerSideNone);
    
    CGRect viewRect = (CGRect){CGPointZero, self.view.frame.size};
    if(sideState == KWDrawerSideLeft)
    {
        viewRect = CGRectAdd(_leftViewRect, CGSizeRect(self.view.frame.size));
        
        if(percentage < 0.0f)
            percentage = 0.0f;
        
        if(percentage > kDrawerOverflowAnimationPercent)
            percentage = kDrawerOverflowAnimationPercent;
    }
    if(sideState == KWDrawerSideRight)
    {
        viewRect = CGRectAdd(_rightViewRect, CGSizeRect(self.view.frame.size));
        
        if(percentage > 0.0f)
            percentage = 0.0f;
        
        if(percentage < -kDrawerOverflowAnimationPercent)
            percentage = -kDrawerOverflowAnimationPercent;
    }
    
    __block KWDrawerAnimationBlock aniBlock = [KWDrawerAnimation slideAnimationBlock];
    __block KWDrawerOverflowAnimationBlock overflowAniBlock = [KWDrawerAnimation scalingOverflowAnimationBlock];
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewControllerDidAnimationMainViewController:withPercentage:andAnimationSide:andDrawerBlocks:)])
    {
        [_delegate drawerViewControllerDidAnimationMainViewController:_mainViewController withPercentage:percentage andAnimationSide:sideState andDrawerBlocks:^(KWDrawerAnimationBlock animationBlock, KWDrawerOverflowAnimationBlock overflowAnimationBlock)
        {
            if(animationBlock)
                aniBlock = animationBlock;
            
            if(overflowAnimationBlock)
                overflowAniBlock = overflowAnimationBlock;
        }];
    }
    
    if(fabs(percentage) > 1.0f)
        overflowAniBlock(viewController, sideState, percentage, viewRect);
    else
        aniBlock(viewController, sideState, percentage, viewRect);
}

- (void)willFinishAnimationMainViewController:(UIViewController *)viewController
{
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = YES;
    _rightDrawerViewController.view.hidden = YES;
    
    self.isMovingLeftDrawer = NO;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationMainDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationMainDrawer:viewController];
}

- (void)willFinishAnimationLeftDrawer:(UIViewController *)viewController
{
    if(!self.isMovingLeftDrawer) return;
    
    self.isMovingLeftDrawer = NO;
    self.isMovingRightDrawer = NO;
    
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = NO;
    _rightDrawerViewController.view.hidden = YES;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationLeftDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationLeftDrawer:viewController];
}

- (void)willFinishAnimationRightDrawer:(UIViewController *)viewController
{
    if(!self.isMovingRightDrawer) return;
    
    self.isMovingRightDrawer = NO;
    
    viewController.view.hidden = NO;
    _leftDrawerViewController.view.hidden = YES;
    _rightDrawerViewController.view.hidden = NO;
    
    if(_delegate && [((id)_delegate) respondsToSelector:@selector(drawerViewController:willFinishAnimationRightDrawer:)])
        [_delegate drawerViewController:self willFinishAnimationRightDrawer:viewController];
}

@end

