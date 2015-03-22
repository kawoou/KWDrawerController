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

#import "KWDrawerSandbox.h"

@interface KWDrawerSandbox ()
{
    BOOL                    _statusBarHidden;
    BOOL                    _statusBarTranslucent;
    
    CGFloat                 _viewAlpha;
    CGAffineTransform       _viewTransform;
    CGRect                  _viewFrame;
    CATransform3D           _layerTransform;
    CGRect                  _layerFrame;
}

@end

@implementation KWDrawerSandbox

- (id)init
{
    self = [super init];
    if(self)
    {
        _percentage = 0;
        _isCustomAnimation = NO;
    }
    return self;
}

- (void)setDrawerView:(UIView *)drawerView
{
    _drawerView = drawerView;
    [_drawerView setHidden:NO];
    
    _viewAlpha = _drawerView.alpha;
    _layerTransform = _drawerView.layer.transform;
    _layerFrame = _drawerView.layer.frame;
    _viewTransform = _drawerView.transform;
    _viewFrame = _drawerView.frame;
    
    [self setShowShadow:_showShadow];
}

- (void)setShowShadow:(BOOL)showShadow
{
    _showShadow = showShadow;
    
    if(!_drawerView)
        return;
    
    if(_showShadow)
    {
        _drawerView.layer.masksToBounds = NO;
        _drawerView.layer.shadowRadius = kDrawerDefaultShadowRadius;
        _drawerView.layer.shadowOpacity = kDrawerDefaultShadowOpacity;
        _drawerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:_drawerView.bounds] CGPath];
    }
    else
    {
        _drawerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectNull].CGPath;
        _drawerView.layer.masksToBounds = YES;
    }
}

- (void)restoreFirstState
{
    _drawerView.alpha = _viewAlpha;
    _drawerView.layer.transform = _layerTransform;
    _drawerView.layer.frame = _layerFrame;
    _drawerView.transform = _viewTransform;
    _drawerView.frame = _viewFrame;
}

- (void)copyStateInView:(UIView *)view
{
    if(!view)
        return;
    
    view.alpha = _drawerView.alpha;
    view.layer.transform = _drawerView.layer.transform;
    view.layer.frame = _drawerView.layer.frame;
    view.transform = _drawerView.transform;
    view.frame = _drawerView.frame;
}

@end
