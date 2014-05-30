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

@implementation KWDrawerAnimation

+ (KWDrawerAnimationBlock)slideAnimationBlock
{
    return ^(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect)
    {
        KWDrawerViewController *drawerViewController = mainViewController.drawerController;
        CGAffineTransform affine = CGAffineTransformIdentity;
        
        mainViewController.view.transform = affine;
        mainViewController.view.frame = (CGRect){
            percentage * viewRect.size.width,
            mainViewController.view.frame.origin.y,
            mainViewController.view.frame.size
        };
        
        if(animationSide == KWDrawerSideLeft)
        {
            [drawerViewController.leftDrawerViewController.view setTransform:affine];
            [drawerViewController.leftDrawerViewController.view setFrame:viewRect];
        }
        if(animationSide == KWDrawerSideRight)
        {
            [drawerViewController.rightDrawerViewController.view setTransform:affine];
            [drawerViewController.rightDrawerViewController.view setFrame:viewRect];
        }
    };
}

+ (KWDrawerAnimationBlock)floatingSlideAnimationBlock
{
    return ^(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect)
    {
        KWDrawerViewController *drawerViewController = mainViewController.drawerController;
        CGAffineTransform affine = CGAffineTransformIdentity;
        
        mainViewController.view.transform = affine;
        mainViewController.view.frame = (CGRect){
            0,
            mainViewController.view.frame.origin.y,
            mainViewController.view.frame.size
        };
        
        if(animationSide == KWDrawerSideLeft)
        {
            [drawerViewController.leftDrawerViewController.view setTransform:affine];
            [drawerViewController.leftDrawerViewController.view setFrame:CGRectAdd(CGRectMake(viewRect.size.width * (-1.0f + percentage), 0, 0, 0),viewRect)];
            
            [drawerViewController.view bringSubviewToFront:drawerViewController.leftDrawerViewController.view];
        }
        if(animationSide == KWDrawerSideRight)
        {
            [drawerViewController.rightDrawerViewController.view setTransform:affine];
            [drawerViewController.rightDrawerViewController.view setFrame:CGRectAdd(CGRectMake(viewRect.size.width * (1.0f + percentage), 0, 0, 0),viewRect)];
            
            [drawerViewController.view bringSubviewToFront:drawerViewController.rightDrawerViewController.view];
        }
    };
}

+ (KWDrawerAnimationBlock)fullSizeSlideAnimationBlock
{
    return [self fullSizeSlideAnimationBlock:kDrawerDefaultFullSizeAnimationFacter
                             mainVisibleSize:kDrawerDefaultFullSizeAnimationVisibleSize];
}

+ (KWDrawerAnimationBlock)fullSizeSlideAnimationBlock:(CGFloat)fullSizeFactor
{
    return [self fullSizeSlideAnimationBlock:fullSizeFactor
                             mainVisibleSize:kDrawerDefaultFullSizeAnimationVisibleSize];
}

+ (KWDrawerAnimationBlock)fullSizeSlideAnimationBlock:(CGFloat)fullSizeFactor mainVisibleSize:(CGFloat)visibleSize
{
    return ^(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect)
    {
        KWDrawerViewController *drawerViewController = mainViewController.drawerController;
        CGAffineTransform affine = CGAffineTransformMakeScale(drawerViewController.view.frame.size.width / viewRect.size.width,
                                                              drawerViewController.view.frame.size.height / viewRect.size.height);
        CGFloat newPercentage = 1.0f - fabs(percentage) * fullSizeFactor;
        
        if(animationSide == KWDrawerSideLeft)
        {
            mainViewController.view.transform = CGAffineTransformMakeScale(newPercentage, newPercentage);
            mainViewController.view.frame = (CGRect){
                newPercentage * percentage * (viewRect.size.width * 2 - visibleSize),
                mainViewController.view.frame.origin.y,
                mainViewController.view.frame.size
            };
            
            affine = CGAffineTransformScale(affine, 1.5 - 0.5 * percentage, 1.5 - 0.5 * percentage);
            [drawerViewController.leftDrawerViewController.view setAlpha:percentage];
            [drawerViewController.leftDrawerViewController.view setCenter:drawerViewController.view.center];
            [drawerViewController.leftDrawerViewController.view setTransform:affine];
        }
        if(animationSide == KWDrawerSideRight)
        {
            mainViewController.view.transform = CGAffineTransformMakeScale(newPercentage, newPercentage);
            mainViewController.view.frame = (CGRect){
                newPercentage * percentage * (viewRect.size.width - visibleSize),
                mainViewController.view.frame.origin.y,
                mainViewController.view.frame.size
            };
            
            affine = CGAffineTransformScale(affine, 1.5 + 0.5 * percentage, 1.5 + 0.5 * percentage);
            [drawerViewController.rightDrawerViewController.view setAlpha:-percentage];
            [drawerViewController.rightDrawerViewController.view setCenter:drawerViewController.view.center];
            [drawerViewController.rightDrawerViewController.view setTransform:affine];
        }
        
        [drawerViewController.view bringSubviewToFront:mainViewController.view];
    };
}

+ (KWDrawerOverflowAnimationBlock)noneOverflowAnimationBlock
{
    return ^(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect){};
}

+ (KWDrawerOverflowAnimationBlock)scalingOverflowAnimationBlock
{
    return ^(UIViewController *mainViewController, KWDrawerSide animationSide, CGFloat percentage, CGRect viewRect)
    {
        KWDrawerViewController *drawerViewController = mainViewController.drawerController;
        CGAffineTransform affine = CGAffineTransformMakeScale(fabs(percentage), 1.0f);
        
        if(mainViewController.view.frame.origin.x != 0)
        {
            mainViewController.view.frame = (CGRect){
                percentage * viewRect.size.width,
                mainViewController.view.frame.origin.y,
                mainViewController.view.frame.size
            };
        }
        
        if(animationSide == KWDrawerSideLeft)
        {
            [drawerViewController.leftDrawerViewController.view setTransform:affine];
            [drawerViewController.leftDrawerViewController.view setFrame:CGRectAdd(CGSizeRect(drawerViewController.leftDrawerViewController.view.frame.size), CGPointRect(viewRect.origin))];
        }
        if(animationSide == KWDrawerSideRight)
        {
            [drawerViewController.rightDrawerViewController.view setTransform:affine];
            [drawerViewController.rightDrawerViewController.view setFrame:CGRectAdd(((CGRect){(percentage + 1.0f) * viewRect.size.width, 0,
                drawerViewController.rightDrawerViewController.view.frame.size}), CGPointRect(viewRect.origin))];
        }
    };
}

@end
