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

#import "KWDrawerFoldingAnimation.h"
#import "UIViewController+KWDrawerController.h"

@interface KWDrawerFoldingAnimation ()
{
    UIView              *_foldingView;
    UIImage             *_originalImage;
    
    UIImageView         *_leftImageView;
    UIImageView         *_rightImageView;
    
    UIView              *_leftShadowView;
    UIView              *_rightShadowView;
}

@end

@implementation KWDrawerFoldingAnimation

- (id)init
{
    self = [super init];
    if(self)
    {
        _foldingView = [[UIView alloc] init];
        _originalImage = nil;
        
        [_foldingView addSubview:_leftImageView = [[UIImageView alloc] init]];
        [_foldingView addSubview:_rightImageView = [[UIImageView alloc] init]];
        [_leftImageView addSubview:_leftShadowView = [[UIView alloc] init]];
        [_rightImageView addSubview:_rightShadowView = [[UIView alloc] init]];
        
        [_leftShadowView setBackgroundColor:[UIColor blackColor]];
        [_rightShadowView setBackgroundColor:[UIColor blackColor]];
        [_leftShadowView setAlpha:0.0f];
        [_rightShadowView setAlpha:0.0f];
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/1000.0;
        [_foldingView.layer setSublayerTransform:transform];
    }
    return self;
}

- (void)updateImage:(UIImage *)image viewRect:(CGRect)viewRect
{
    if(_originalImage != image)
    {
        _originalImage = image;
        
        CGRect imageRect1 = (CGRect){0, 0, viewRect.size.width * 0.5f, viewRect.size.height};
        CGRect imageRect2 = (CGRect){imageRect1.size.width, 0, imageRect1.size};
        
        //[_leftImageView setImage:image];
        
        CGImageRef image1 = CGImageCreateWithImageInRect(image.CGImage, CGRectMul(imageRect1, CGRectVal(image.scale)));
        CGImageRef image2 = CGImageCreateWithImageInRect(image.CGImage, CGRectMul(imageRect2, CGRectVal(image.scale)));
        [_leftImageView setImage:[UIImage imageWithCGImage:image1 scale:image.scale orientation:image.imageOrientation]];
        [_rightImageView setImage:[UIImage imageWithCGImage:image2 scale:image.scale orientation:image.imageOrientation]];
        
        CGImageRelease(image1);
        CGImageRelease(image2);
    }
}

- (UIView *)visibleViewForAnimation
{
    //[_leftImageView.layer setTransform:CATransform3DIdentity];
    //[_rightImageView.layer setTransform:CATransform3DIdentity];
    
    return _foldingView;
}

- (void)willAnimationWithMainViewController:(UIViewController *)mainViewController
{
    //[_rightImageView.layer setTransform:CATransform3DIdentity];
}

- (void)animation:(UIViewController *)mainViewController visibleView:(UIView *)visibleView animationSide:(KWDrawerSide)side percentage:(CGFloat)percentage viewRect:(CGRect)viewRect visibleBlock:(KWDrawerVisibleBlock)visibleBlock
{
    KWDrawerController *drawerController = mainViewController.drawerController;
    
    mainViewController.view.transform = CGAffineTransformIdentity;
    mainViewController.view.frame = (CGRect){
        percentage * viewRect.size.width,
        mainViewController.view.frame.origin.y,
        mainViewController.view.frame.size
    };
    
    CGRect imageRect1 = (CGRect){0, 0, viewRect.size.width * 0.5f, viewRect.size.height};
    CGRect imageRect2 = (CGRect){imageRect1.size.width, 0, imageRect1.size};
    
    [self updateImage:[drawerController imageContextInDrawerSide:side] viewRect:viewRect];
    
    [_foldingView setFrame:viewRect];
    [_leftImageView setFrame:imageRect1];
    [_rightImageView setFrame:imageRect1];
    [_leftShadowView setFrame:CGSizeRect(imageRect1.size)];
    [_rightShadowView setFrame:CGSizeRect(imageRect2.size)];
    
    if(side == KWDrawerSideLeft)
    {
        _leftImageView.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        [_leftImageView.layer setTransform:CATransform3DMakeRotation(M_PI_2 - asinf(percentage), 0.0, 1.0, 0.0)];
        
        NSLog(@"%lf %lf", _leftImageView.frame.size.width, _leftImageView.layer.frame.size.width);
        
        CATransform3D affine = CATransform3DIdentity;
        affine = CATransform3DMakeRotation(M_PI_2 - asinf(percentage), 0.0, -1.0, 0.0);
        affine = CATransform3DConcat(affine, CATransform3DMakeTranslation(_leftImageView.layer.frame.size.width - viewRect.size.width * (1.0f - percentage) * 0.5f, 0, 0));
        //affine = CATransform3DConcat(affine, CATransform3DMakeTranslation(_leftImageView.frame.size.width * 2, 0, 0));
        _rightImageView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        [_rightImageView.layer setTransform:affine];
        
        //CGRect oldrt = _rightImageView.frame;
        //CGRect rt = CGRectMul(CGRectSub(_rightImageView.frame, CGPointRect(CGPointMake(imageRect1.size.width, 0))), CGPointRect(CGPointMake(2, 0)));
        //CGRect rt = oldrt;
        //rt.origin.x = _leftImageView.frame.size.width * 2;
        //[_rightImageView setFrame:rt];
        //[_rightImageView setFrame:CGRectMul(CGRectSub(_rightImageView.frame, CGSizeRect(CGSizeMake(imageRect1.size.width, 0))), CGPointRect(CGPointMake(2, 0)))];
        
        [_leftShadowView setAlpha:0.75f - percentage * 0.75f];
        [_rightShadowView setAlpha:1.0f - percentage];
    }
    if(side == KWDrawerSideRight)
    {
        NSLog(@"%lf %lf", viewRect.origin.x, viewRect.size.width);
        CATransform3D affine = CATransform3DIdentity;
        affine = CATransform3DRotate(affine, M_PI_2 + asinf(percentage), 0.0, -1.0, 0.0);
        affine = CATransform3DConcat(affine, CATransform3DMakeTranslation(viewRect.size.width * 0.5f, 0, 0));
        _rightImageView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        _rightImageView.layer.transform = affine;
        
        affine = CATransform3DIdentity;
        affine = CATransform3DRotate(affine, M_PI_2 + asinf(percentage), 0.0, 1.0, 0.0);
        affine = CATransform3DConcat(affine, CATransform3DMakeTranslation(viewRect.size.width * (1.0f + percentage) * 0.5f + viewRect.size.width * 0.5f - _rightImageView.frame.size.width, 0, 0));
        _leftImageView.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        _leftImageView.layer.transform = affine;
        
        [_leftShadowView setAlpha:0.75f + percentage * 0.75f];
        //[_leftImageView setAlpha:0.0f];
        [_rightShadowView setAlpha:1.0f + percentage];
    }
}

@end
