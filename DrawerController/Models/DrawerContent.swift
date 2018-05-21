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
            guard drawerSide == .none else { return internalDrawerWidth }
            
            if let superview = contentView.superview {
                return Float(superview.frame.width)
            } else {
                return Float(viewController.view.frame.width)
            }
        }
        set {
            internalDrawerWidth = newValue
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
        viewController.drawerController = drawerController
        
        contentView.frame = drawerController.view.bounds
        contentView.autoresizingMask = [.flexibleHeight]
        drawerController.view.addSubview(contentView)

        updateView()
    }
    internal func removeDrawerView() {
        contentView.removeFromSuperview()
        
        viewController.drawerController = nil
    }
    internal func setVisible(_ isVisible: Bool) {
        if isVisible {
            contentView.addSubview(viewController.view)
            viewController.drawerController?.addChildViewController(viewController)
        } else {
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
    }
    
    public func startTransition(side: DrawerSide) {
        transition.initTransition(content: self)
        overflowTransition.initTransition(content: self)
        
        contentView.clipsToBounds = isBringToFront
    }
    public func endTransition(side: DrawerSide) {
        if let transition = useTransition {
            transition.endTransition(content: self, side: side)
        }
        useTransition = nil
    }
    public func transition(side: DrawerSide, percentage: Float, viewRect: CGRect) {
        
        var currentPercent: Float
        var currentTransition = useTransition ?? transition
        
        switch drawerSide {
        case .left:
            currentPercent = 1.0 + percentage
        case .right:
            currentPercent = 1.0 - percentage
        case .none:
            currentPercent = fabs(percentage)
        }
        
        if currentTransition === transition {
            if currentPercent > 1.0 {
                currentTransition = overflowTransition
            }
        } else {
            if currentPercent < 1.0 {
                currentTransition = transition
            }
        }
        
        /// Swap transition
        if useTransition !== currentTransition {
            if let useTransition = useTransition {
                useTransition.transition(
                    content: self,
                    side: side,
                    percentage: CGFloat((percentage >= 0) ? 1.0 : -1.0),
                    viewRect: viewRect
                )
                useTransition.endTransition(content: self, side: side)
            }
            
            useTransition = currentTransition
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
            UIGraphicsBeginImageContext(contentView.frame.size)
        } else {
            UIGraphicsBeginImageContextWithOptions(contentView.frame.size, false, 0.0)
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        contentView.layer.render(in: context)
        
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    
    // MARK: - Private
    
    internal func updateView() {
        let width = CGFloat(drawerWidth)
        contentView.frame.size.width = width
        drawerOffset = 0.0
        
        guard let superview = contentView.superview else { return }
        if drawerSide == .right {
            drawerOffset = superview.frame.width - width
        }
        contentView.frame = CGRect(
            x: CGFloat(-drawerOffset),
            y: 0,
            width: width,
            height: superview.frame.height
        )
        viewController.view.frame = contentView.bounds
    }
    
    
    // MARK: - Initialize
    
    internal init(viewController: UIViewController, drawerSide: DrawerSide) {
        contentView = UIView()
        self.viewController = viewController
        
        self.drawerSide = drawerSide
        internalDrawerWidth = 0.0
        drawerOffset = 0.0
    }
    
}
