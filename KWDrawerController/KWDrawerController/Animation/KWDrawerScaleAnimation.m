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

#import "KWDrawerScaleAnimation.h"

@implementation KWDrawerScaleAnimation

- (UIView *)visibleViewForAnimation
{
    return nil;
}

- (void)animation:(UIViewController *)mainViewController visibleView:(UIView *)visibleView animationSide:(KWDrawerSide)side percentage:(CGFloat)percentage viewRect:(CGRect)viewRect visibleBlock:(KWDrawerVisibleBlock)visibleBlock
{
    CGAffineTransform affine = CGAffineTransformMakeScale(fabs(percentage), 1.0f);
    
    if(mainViewController.view.frame.origin.x != 0)
    {
        mainViewController.view.frame = (CGRect){
            percentage * viewRect.size.width,
            mainViewController.view.frame.origin.y,
            mainViewController.view.frame.size
        };
    }
    
    [visibleView setTransform:affine];
    
    if(side == KWDrawerSideLeft)
    {
        [visibleView setFrame:CGRectAdd(CGSizeRect(visibleView.frame.size), CGPointRect(viewRect.origin))];
    }
    if(side == KWDrawerSideRight)
    {
        [visibleView setFrame:CGRectAdd(((CGRect){(percentage + 1.0f) * viewRect.size.width, 0,
            visibleView.frame.size}), CGPointRect(viewRect.origin))];
    }
    
    visibleBlock(YES, NO);
}

@end
