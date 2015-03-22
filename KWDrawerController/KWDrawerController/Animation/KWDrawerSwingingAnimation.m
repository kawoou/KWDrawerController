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

#import "KWDrawerSwingingAnimation.h"

@implementation KWDrawerSwingingAnimation

- (UIView *)visibleViewForAnimation
{
    return nil;
}

- (void)animation:(UIViewController *)mainViewController visibleView:(UIView *)visibleView animationSide:(KWDrawerSide)side percentage:(CGFloat)percentage viewRect:(CGRect)viewRect visibleBlock:(KWDrawerVisibleBlock)visibleBlock
{
    CATransform3D affine = CATransform3DIdentity;
    affine.m34 = -1.0/1000.0;
    
    mainViewController.view.transform = CGAffineTransformIdentity;
    mainViewController.view.frame = (CGRect){
        percentage * viewRect.size.width,
        mainViewController.view.frame.origin.y,
        mainViewController.view.frame.size
    };
    
    if(side == KWDrawerSideLeft)
    {
        affine = CATransform3DRotate(affine, -M_PI_2 + percentage * M_PI_2, 0.0, 1.0, 0.0);
        affine = CATransform3DConcat(affine, CATransform3DMakeTranslation(-(1.0f - percentage) * viewRect.size.width, 0, 0));
        
        visibleView.layer.anchorPoint = CGPointMake(1.0, .5);
    }
    if(side == KWDrawerSideRight)
    {
        affine = CATransform3DRotate(affine, M_PI_2 + percentage * M_PI_2, 0.0, 1.0, 0.0);
        affine = CATransform3DConcat(affine, CATransform3DMakeTranslation((1.0f + percentage) * viewRect.size.width, 0, 0));
        
        visibleView.layer.anchorPoint = CGPointMake(0.0, .5);
    }
    visibleView.layer.transform = affine;
    [visibleView setFrame:viewRect];
    
    visibleBlock(YES, NO);
}

@end
