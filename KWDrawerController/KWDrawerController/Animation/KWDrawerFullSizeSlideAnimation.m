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

#import "KWDrawerFullSizeSlideAnimation.h"
#import "UIViewController+KWDrawerController.h"

@implementation KWDrawerFullSizeSlideAnimation

- (id)init
{
    self = [super init];
    if(self)
    {
        _fullSizeFactor = kDrawerDefaultFullSizeAnimationFacter;
        _visibleSize = kDrawerDefaultFullSizeAnimationVisibleSize;
    }
    return self;
}

- (UIView *)visibleViewForAnimation
{
    return nil;
}

- (void)animation:(UIViewController *)mainViewController visibleView:(UIView *)visibleView animationSide:(KWDrawerSide)side percentage:(CGFloat)percentage viewRect:(CGRect)viewRect visibleBlock:(KWDrawerVisibleBlock)visibleBlock
{
    UIView *drawerView = mainViewController.drawerController.view;
    CGAffineTransform affine = CGAffineTransformMakeScale(drawerView.frame.size.width / viewRect.size.width, drawerView.frame.size.height / viewRect.size.height);
    CGFloat newPercentage = 1.0f - fabsf(percentage) * _fullSizeFactor;
    
    mainViewController.view.transform = CGAffineTransformMakeScale(newPercentage, newPercentage);
    if(side == KWDrawerSideLeft)
    {
        mainViewController.view.frame = (CGRect){
            newPercentage * percentage * (viewRect.size.width * 2 - _visibleSize),
            mainViewController.view.frame.origin.y,
            mainViewController.view.frame.size
        };
        
        affine = CGAffineTransformScale(affine, 1.5 - 0.5 * percentage, 1.5 - 0.5 * percentage);
    }
    if(side == KWDrawerSideRight)
    {
        mainViewController.view.frame = (CGRect){
            newPercentage * percentage * (viewRect.size.width - _visibleSize),
            mainViewController.view.frame.origin.y,
            mainViewController.view.frame.size
        };
        
        affine = CGAffineTransformScale(affine, 1.5 + 0.5 * percentage, 1.5 + 0.5 * percentage);
    }
    
    [visibleView setAlpha:fabsf(percentage)];
    [visibleView setCenter:drawerView.center];
    [visibleView setTransform:affine];
}

@end
