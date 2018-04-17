/*
The MIT License (MIT)

Copyright (c) 2017 Kawoou (Jungwon An)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

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

import UIKit

open class DrawerSwingTransition: DrawerTransition {
    
    // MARK: - Public
    
    open override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
        
        content.isBringToFront = false
    }
    
    open override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        var affine = CATransform3DIdentity
        affine.m34 = -1 / 500.0
        
        switch content.drawerSide {
        case .left:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            content.contentView.layer.sublayerTransform = affine
        case .right:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            content.contentView.layer.sublayerTransform = affine
        default:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            content.contentView.layer.sublayerTransform = CATransform3DIdentity
        }
        
        content.viewController.view.layer.transform = CATransform3DIdentity
    }
    
    open override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
        
        content.contentView.layer.sublayerTransform = CATransform3DIdentity
        content.viewController.view.layer.transform = CATransform3DIdentity
        content.viewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    open override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            var affine = CATransform3DMakeTranslation(CGFloat(content.drawerWidth / 2), 0, 0)
            affine = CATransform3DRotate(affine, CGFloat(-asin(Double(percentage))), 0, -1, 0)
            content.viewController.view.layer.transform = affine
            
            content.contentView.transform = .identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
        case .right:
            var affine = CATransform3DMakeTranslation(-CGFloat(content.drawerWidth / 2), 0, 0)
            affine = CATransform3DRotate(affine, CGFloat(-asin(Double(percentage))), 0, -1, 0)
            content.viewController.view.layer.transform = affine
            
            content.contentView.transform = .identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
        default:
            content.contentView.transform = .identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        }
        
    }
    
    public override init() {
        super.init()
    }
    
}
