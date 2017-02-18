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

public class DrawerContent {
    
    // MARK: - Property
    
    public var isAbsolute: Bool = false
    
    public var option: DrawerOption = DrawerOption()
    
    public var transition: DrawerTransition = DrawerSlideTransition()
    public var overflowTransition: DrawerTransition = DrawerScaleTransition()
    public var animator: DrawerAnimator = DrawerCurveEaseAnimator()
    
    public private(set) var contentView: UIView
    public private(set) var viewController: UIViewController
    
    public internal(set) var drawerSide: DrawerSide {
        didSet {
            updateView()
        }
    }
    public internal(set) var drawerWidth: Float {
        get {
            if self.drawerSide != .none {
                return self.internalDrawerWidth
            } else {
                if let superview = contentView.superview {
                    return Float(superview.frame.width)
                } else {
                    return Float(self.viewController.view.frame.width)
                }
            }
        }
        set(value) {
            self.internalDrawerWidth = value
            
            updateView()
        }
    }
    public private(set) var drawerOffset: CGFloat
    
    
    // MARK: - Internal
    
    internal var isBringToFront: Bool = true
    
    private var internalDrawerWidth: Float
    
    private var lastSide: DrawerSide = .none
    private var lastPercentage: Float = 0.0
    private var useTransition: DrawerTransition? = nil
    
    
    // MARK: - Public
    
    internal func addDrawerView(drawerController: DrawerController) {
        
        self.viewController.drawerController = drawerController
        
        self.contentView.frame = drawerController.view.bounds
        self.contentView.addSubview(self.viewController.view)
        drawerController.view.addSubview(self.contentView)
        
        drawerController.addChildViewController(self.viewController)
        
        updateView()
    }
    internal func removeDrawerView() {
        
        self.viewController.removeFromParentViewController()
        
        self.viewController.view.removeFromSuperview()
        self.contentView.removeFromSuperview()
        
        self.viewController.drawerController = nil
    }
    
    public func startTransition(side: DrawerSide) {
        self.transition.initTransition(content: self)
        self.overflowTransition.initTransition(content: self)
        
        self.contentView.clipsToBounds = self.isBringToFront
    }
    public func endTransition(side: DrawerSide) {
        if let transition = self.useTransition {
            transition.endTransition(content: self, side: side)
        }
        self.useTransition = nil
    }
    public func transition(side: DrawerSide, percentage: Float, viewRect: CGRect) {
        
        var currentPercent: Float
        var currentTransition = self.useTransition ?? self.transition
        
        switch self.drawerSide {
        case .left:
            currentPercent = 1.0 + percentage
        case .right:
            currentPercent = 1.0 - percentage
        case .none:
            currentPercent = fabs(percentage)
        }
        
        if currentTransition === self.transition {
            if currentPercent > 1.0 {
                currentTransition = self.overflowTransition
            }
        } else {
            if currentPercent < 1.0 {
                currentTransition = self.transition
            }
        }
        
        /// Swap transition
        if self.useTransition !== currentTransition {
            
            if self.useTransition != nil {
                self.useTransition!.transition(
                    content: self,
                    side: side,
                    percentage: CGFloat((percentage >= 0) ? 1.0 : -1.0),
                    viewRect: viewRect
                )
                self.useTransition!.endTransition(content: self, side: side)
            }
            
            self.useTransition = currentTransition
            currentTransition.startTransition(content: self, side: side)
        }
        
        currentTransition.transition(
            content: self,
            side: side,
            percentage: CGFloat(percentage),
            viewRect: viewRect
        )
    }
    
    public func screenshot(withOptimization optimized: Bool) -> UIImage? {
        if (optimized) {
            UIGraphicsBeginImageContext(self.contentView.frame.size)
        } else {
            UIGraphicsBeginImageContextWithOptions(self.contentView.frame.size, false, 0.0)
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            self.contentView.layer.render(in: context)
            
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return screenshot
        } else {
            return nil
        }
    }
    
    
    // MARK: - Private
    
    internal func updateView() {
        let width = CGFloat(self.drawerWidth)
        
        self.contentView.frame.size.width = width
        
        self.drawerOffset = 0.0
        
        if let superView = self.contentView.superview {
            if self.drawerSide == .right {
                self.drawerOffset = superView.frame.width - width
            }
            self.viewController.view.frame = CGRect(
                x: CGFloat(-self.drawerOffset),
                y: 0,
                width: superView.frame.width,
                height: superView.frame.height
            )
        }
    }
    
    
    // MARK: - Initialize
    
    internal init(viewController: UIViewController, drawerSide: DrawerSide) {
        
        self.contentView = UIView()
        self.viewController = viewController
        
        self.drawerSide = drawerSide
        self.internalDrawerWidth = 0.0
        self.drawerOffset = 0.0
    }
    
}
