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
#import "KWDrawerDefinition.h"

@interface KWDrawerSandbox : NSObject

@property (nonatomic, assign) KWDrawerSide      beginSide;
@property (nonatomic, assign) KWDrawerSide      movingSide;
@property (nonatomic, assign) KWDrawerSide      endedSide;

@property (nonatomic, assign) CGFloat           percentage;
@property (nonatomic, retain) UIView            *drawerView;
@property (nonatomic, assign) BOOL              isCustomAnimation;

@property (nonatomic, assign) BOOL              isOverflow;
@property (nonatomic, assign) BOOL              isOverflowChanged;

@property (nonatomic, assign) BOOL              showShadow;

- (void)restoreFirstState;
- (void)copyStateInView:(UIView *)view;

@end
