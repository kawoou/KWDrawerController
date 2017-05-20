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

@objc
public protocol DrawerControllerDelegate {
    
    @objc
    optional func drawerDidAnimation(
        drawerController: DrawerController,
        side: DrawerSide,
        percentage: Float
    )
    
    @objc
    optional func drawerDidBeganAnimation(
        drawerController: DrawerController,
        side: DrawerSide
    )
    
    @objc
    optional func drawerWillFinishAnimation(
        drawerController: DrawerController,
        side: DrawerSide
    )
    
    @objc
    optional func drawerWillCancelAnimation(
        drawerController: DrawerController,
        side: DrawerSide
    )
    
    @objc
    optional func drawerDidFinishAnimation(
        drawerController: DrawerController,
        side: DrawerSide
    )
    
    @objc
    optional func drawerDidCancelAnimation(
        drawerController: DrawerController,
        side: DrawerSide
    )
    
}

open class DrawerController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Define
    
    static let OverflowPercentage: Float = 1.06
    static let GestureArea: Float = 40.0
    
    
    // MARK: - Property
    
    @IBOutlet
    public weak var delegate: DrawerControllerDelegate?
    
    @IBInspectable
    public var drawerWidth: Float {
        get {
            return self.internalDrawerWidth
        }
        set(value) {
            for (side, content) in self.contentMap {
                if content.drawerWidth != value {
                    self.setDrawerWidth(drawerWidth: value, side: side)
                }
            }
            self.internalDrawerWidth = value
        }
    }
    
    @IBInspectable
    public var gestureSenstivity: DrawerGestureSensitivity = .normal
    
    @IBInspectable
    public var options: DrawerOption = DrawerOption()
    
    @IBInspectable
    public var shadowRadius: CGFloat = 10.0
    
    @IBInspectable
    public var shadowOpacity: Float = 0.8
    
    @IBInspectable
    public var animationDuration: TimeInterval = 0.35

    @IBInspectable
    public var mainSegueIdentifier: String?
    
    @IBInspectable
    public var leftSegueIdentifier: String?
    
    @IBInspectable
    public var rightSegueIdentifier: String?
    
    public private(set) var drawerSide: DrawerSide = .none
    public private(set) var isAnimating: Bool = false
    
    public private(set) var panGestureRecognizer: UIPanGestureRecognizer?
    
    
    // MARK: - Internal
    
    private var contentMap: [DrawerSide: DrawerContent] = [:]
    
    private var internalDrawerWidth: Float = 280.0
    private var internalFromSide: DrawerSide = .none
    
    private var shadowView: UIView = UIView()
    private var fadeView: UIView = UIView()
    private var translucentView: TranslucentView = TranslucentView()
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    /// Gesture
    private var gestureBeginPoint: CGPoint = CGPoint.zero
    private var gestureMovePoint: CGPoint = CGPoint.zero
    private var gestureLastPercentage: Float = -1.0
    private var isGestureMoveLeft: Bool = false
    

    // MARK: - Public
    
    /// Options
    public func getSideOption(side: DrawerSide) -> DrawerOption? {
        guard let content = self.contentMap[side] else { return nil }
        return content.option
    }
    
    /// Absolute
    public func getAbsolute(side: DrawerSide) -> Bool {
        guard let content = self.contentMap[side] else { return false }
        return content.isAbsolute
    }
    public func setAbsolute(isAbsolute: Bool, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        
        if content.isAbsolute != isAbsolute && self.drawerSide == side && side != .none {
            closeSide() {
                content.isAbsolute = isAbsolute
            }
        } else {
            content.isAbsolute = isAbsolute
        }
    }
    
    /// Bring to Front
    public func getBringToFront(side: DrawerSide) -> Bool {
        guard let content = self.contentMap[side] else { return false }
        return content.isBringToFront
    }
    public func setBringToFront(isBringToFront: Bool, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        content.isBringToFront = isBringToFront
    }
    
    /// Transition
    public func getTransition(side: DrawerSide) -> DrawerTransition? {
        guard let content = self.contentMap[side] else { return nil }
        return content.transition
    }
    public func setTransition(transition: DrawerTransition, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        content.transition = transition
        
        if !self.isAnimating {
            let percent: Float = self.drawerSide == .none ? 0.0 : 1.0
            
            self.willBeginAnimate(side: self.drawerSide)
            self.didBeginAnimate(side: self.drawerSide)
            self.willAnimate(side: self.drawerSide, percent: percent)
            self.didAnimate(side: self.drawerSide, percent: percent)
            
            content.startTransition(side: self.drawerSide)
            content.transition(
                side: self.drawerSide,
                percentage: self.calcPercentage(side: side, moveSide: self.drawerSide, percent),
                viewRect: self.calcViewRect(content: content)
            )
            content.endTransition(side: self.drawerSide)
            
            self.willFinishAnimate(side: self.drawerSide, percent: percent)
            self.didFinishAnimate(side: self.drawerSide, percent: percent)
        }
    }
    public func getOverflowTransition(side: DrawerSide) -> DrawerTransition? {
        guard let content = self.contentMap[side] else { return nil }
        return content.overflowTransition
    }
    public func setOverflowTransition(transition: DrawerTransition, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        content.overflowTransition = transition
    }
    
    
    /// Animator
    public func getAnimator(side: DrawerSide) -> DrawerAnimator? {
        guard let content = self.contentMap[side] else { return nil }
        return content.animator
    }
    public func setAnimator(animator: DrawerAnimator, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        content.animator = animator
    }
    
    /// Drawer Width
    public func getDrawerWidth(side: DrawerSide) -> Float? {
        guard let content = self.contentMap[side] else { return nil }
        return content.drawerWidth
    }
    public func setDrawerWidth(drawerWidth: Float, side: DrawerSide) {
        guard let content = self.contentMap[side] else { return }
        
        if self.drawerSide == side {
            let oldDrawerWidth = content.drawerWidth
            content.animator.doAnimate(duration: self.animationDuration, animations: { percentage in
                content.drawerWidth = oldDrawerWidth + (drawerWidth - oldDrawerWidth) * percentage
            }, completion: { _ in })
        } else {
            content.drawerWidth = drawerWidth
        }
    }
    
    /// View controller
    public func setViewController(_ viewController: UIViewController?, side: DrawerSide) {
        guard isEnable() else { return }
        
        if let controller = viewController {
            self.addSide(side, viewController: controller)
        } else {
            self.removeSide(side)
        }
        
    }
    
    /// Actions
    public func openSide(_ side: DrawerSide, completion: (()->())? = nil) {
        
        /// Golden-Path
        guard isEnable() else { return }
        guard !self.isAnimating else { return }
        
        if self.drawerSide != .none && side != self.drawerSide {
            self.closeSide {
                self.openSide(side, completion: completion)
            }
        } else {
        
            self.isAnimating = true
            
            self.willBeginAnimate(side: side)
            self.didBeginAnimate(side: side)
            
            self.willAnimate(side: side, percent: 0.0)
            
            /// Check available of animation.
            if (self.isAnimation()) {
                
                if let content = self.contentMap[side] {
                    if self.gestureLastPercentage >= 0.0 {
                        self.didAnimate(side: side, percent: self.gestureLastPercentage)
                    } else {
                        self.didAnimate(side: side, percent: 0.0)
                    }
                    
                    content.animator.doAnimate(duration: self.animationDuration, animations: { percent in
                        if self.gestureLastPercentage >= 0.0 {
                            self.didAnimate(side: side, percent: (1.0 - self.gestureLastPercentage) * percent + self.gestureLastPercentage)
                        } else {
                            self.didAnimate(side: side, percent: percent)
                        }
                    }, completion: { isComplete in
                        self.willFinishAnimate(side: side, percent: 1.0)
                        self.didFinishAnimate(side: side, percent: 1.0)
                        
                        self.isAnimating = false
                        
                        completion?()
                    })
                } else {
                    if self.gestureLastPercentage >= 0.0 {
                        self.didAnimate(side: side, percent: self.gestureLastPercentage)
                    } else {
                        self.didAnimate(side: side, percent: 0.0)
                    }
                    
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        self.didAnimate(side: side, percent: 1.0)
                    }, completion: { isComplete in
                        self.willFinishAnimate(side: side, percent: 1.0)
                        self.didFinishAnimate(side: side, percent: 1.0)
                        
                        self.isAnimating = false
                        
                        completion?()
                    })
                }
                
            } else {
                self.didAnimate(side: side, percent: 1.0)
                
                self.willFinishAnimate(side: side, percent: 1.0)
                self.didFinishAnimate(side: side, percent: 1.0)
                
                self.isAnimating = false
                
                completion?()
            }
        }
        
    }
    
    public func closeSide(completion: (()->())? = nil) {
        
        /// Golden-Path
        guard isEnable() else { return }
        guard !self.isAnimating else { return }
        
        self.isAnimating = true
        
        self.willBeginAnimate(side: .none)
        self.didBeginAnimate(side: .none)
        
        self.willAnimate(side: .none, percent: 1.0)
        
        /// Check if the animation is available.
        if (self.isAnimation()) {
            
            if let content = self.contentMap[self.drawerSide] {
                if self.gestureLastPercentage >= 0.0 {
                    self.didAnimate(side: .none, percent: self.gestureLastPercentage)
                } else {
                    self.didAnimate(side: .none, percent: 0.9999)
                }
                
                content.animator.doAnimate(duration: self.animationDuration, animations: { percent in
                    if self.gestureLastPercentage >= 0.0 {
                        self.didAnimate(side: .none, percent: self.gestureLastPercentage - percent * self.gestureLastPercentage)
                    } else {
                        self.didAnimate(side: .none, percent: 1.0 - percent)
                    }
                }, completion: { isComplete in
                    self.willFinishAnimate(side: .none, percent: 0.0)
                    self.didFinishAnimate(side: .none, percent: 0.0)
                    
                    self.isAnimating = false
                    
                    completion?()
                })
            } else {
                if self.gestureLastPercentage >= 0.0 {
                    self.didAnimate(side: .none, percent: self.gestureLastPercentage)
                } else {
                    self.didAnimate(side: .none, percent: 0.9999)
                }
                
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.didAnimate(side: .none, percent: 0.0)
                }, completion: { isComplete in
                    self.willFinishAnimate(side: .none, percent: 0.0)
                    self.didFinishAnimate(side: .none, percent: 0.0)
                    
                    self.isAnimating = false
                    
                    completion?()
                })
            }
            
        } else {
            self.didAnimate(side: .none, percent: 0.0)
            
            self.willFinishAnimate(side: .none, percent: 0.0)
            self.didFinishAnimate(side: .none, percent: 0.0)
            
            self.isAnimating = false
            
            completion?()
        }
    }
    
    
    // MARK: - Private
    
    private func isEnable() -> Bool {
        return self.options.isEnable
    }
    private func isEnable(content: DrawerContent) -> Bool {
        return self.options.isEnable && content.option.isEnable
    }
    private func isAnimation() -> Bool {
        return self.options.isAnimation
    }
    private func isAnimation(content: DrawerContent) -> Bool {
        return self.options.isAnimation && content.option.isAnimation
    }
    private func isOverflowAnimation() -> Bool {
        return self.options.isOverflowAnimation
    }
    private func isOverflowAnimation(content: DrawerContent) -> Bool {
        return self.options.isOverflowAnimation && content.option.isOverflowAnimation
    }
    private func isGesture() -> Bool {
        return self.options.isGesture
    }
    private func isGesture(content: DrawerContent) -> Bool {
        return self.options.isGesture && content.option.isGesture
    }
    private func isShadow(content: DrawerContent) -> Bool {
        return self.options.isShadow && content.option.isShadow
    }
    private func isFadeScreen(content: DrawerContent) -> Bool {
        return self.options.isFadeScreen && content.option.isFadeScreen
    }
    private func isBlur(content: DrawerContent) -> Bool {
        return self.options.isBlur && content.option.isBlur
    }
    private func isTapToClose() -> Bool {
        return self.options.isTapToClose
    }
    private func isTapToClose(content: DrawerContent) -> Bool {
        return self.options.isTapToClose && content.option.isTapToClose
    }
    
    private func addSide(_ side: DrawerSide, viewController: UIViewController) {
        
        /// Golden-Path
        if self.isAnimating { return }
        
        /// Closure
        let setNewContent: ((DrawerContent?)->()) = { content in
            if let oldContent = content {
                oldContent.removeDrawerView()
            }
            let newContent = DrawerContent(
                viewController: viewController,
                drawerSide: side
            )
            newContent.addDrawerView(drawerController: self)
            newContent.drawerWidth = self.drawerWidth
            self.contentMap[side] = newContent
            
            newContent.startTransition(side: .none)
            newContent.transition(
                side: .none,
                percentage: self.calcPercentage(side: side, moveSide: .none, 0.0),
                viewRect: self.calcViewRect(content: newContent)
            )
            newContent.endTransition(side: .none)
        }
        
        if let content = contentMap[side] {
            
            /// Check exposed in screen.
            if self.drawerSide == side {
                self.closeSide {
                    setNewContent(content)
                }
            } else {
                setNewContent(content)
            }
            
        } else {
            setNewContent(nil)
        }
    }
    private func removeSide(_ side: DrawerSide) {
        
        /// Golden-Path
        if self.isAnimating { return }
        guard let content = contentMap[side] else { return }
        
        /// Closure
        let unsetContent: ((DrawerContent)->()) = { content in
            content.removeDrawerView()
            self.contentMap.removeValue(forKey: side)
        }
        
        if self.drawerSide == side {
            self.closeSide {
                unsetContent(content)
            }
        } else {
            unsetContent(content)
        }
    }
    
    
    // MARK: - Animation
    
    private func calcPercentage(side: DrawerSide, moveSide: DrawerSide, _ percentage: Float) -> Float {
        switch side {
        case .left: return -(1.0 - percentage)
        case .right: return (1.0 - percentage)
        case .none:
            switch moveSide {
            case .right: return -percentage
            default: return percentage
            }
        }
    }
    private func calcViewRect(content: DrawerContent?) -> CGRect {
        if let selectedContent = content {
            return CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: CGFloat(selectedContent.drawerWidth), height: self.view.frame.height)
            )
        } else {
            return CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: CGFloat(self.drawerWidth), height: self.view.frame.height)
            )
        }
    }
    
    private func willBeginAnimate(side: DrawerSide) {
        #if DEBUG
        print("willBeginAnimate(side: \(side.rawValue))")
        #endif
        
        for (drawerSide, content) in self.contentMap {
            if drawerSide == side || drawerSide == .none || drawerSide == self.internalFromSide {
                content.contentView.isHidden = false
            } else {
                content.contentView.isHidden = true
            }
        }
        
        self.internalFromSide = side
        
        /// View Controller Events
        if side == .none {
            if let sideContent = contentMap[self.drawerSide] {
                sideContent.viewController.viewWillDisappear(isAnimation(content: sideContent))
            }
        } else {
            if let sideContent = contentMap[side] {
                sideContent.viewController.viewWillAppear(isAnimation(content: sideContent))
            }
        }
        
        /// User Interaction
        self.view.isUserInteractionEnabled = false
    }
    private func didBeginAnimate(side: DrawerSide) {
        #if DEBUG
        print("didBeginAnimate(side: \(side.rawValue))")
        #endif
        
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? self.drawerSide : side
        
        mainContent.startTransition(side: side)
        
        if let sideContent = contentMap[moveSide] {
            sideContent.startTransition(side: side)
            
            /// Fade Screen
            self.fadeView.isHidden = !self.isFadeScreen(content: sideContent)
            if self.isFadeScreen(content: sideContent) {
                if sideContent.isBringToFront {
                    self.view.insertSubview(self.fadeView, aboveSubview: mainContent.contentView)
                } else {
                    self.view.insertSubview(self.fadeView, aboveSubview: sideContent.contentView)
                }
            }
            
            /// Blur
            self.translucentView.isHidden = !self.isBlur(content: sideContent)
            if self.isBlur(content: sideContent) {
                if sideContent.isBringToFront {
                    self.view.insertSubview(self.translucentView, aboveSubview: mainContent.contentView)
                } else {
                    self.view.insertSubview(self.translucentView, aboveSubview: sideContent.contentView)
                }
            }
            
            /// Shadow
            self.shadowView.isHidden = !self.isShadow(content: sideContent)
            if self.isShadow(content: sideContent) {
                self.shadowView.frame = sideContent.contentView.frame
                self.shadowView.layer.shadowPath = UIBezierPath(rect: self.shadowView.bounds).cgPath
                self.view.insertSubview(self.shadowView, belowSubview: sideContent.contentView)
            }
            
            if sideContent.isBringToFront {
                self.view.bringSubview(toFront: sideContent.contentView)
            } else {
                self.view.bringSubview(toFront: mainContent.contentView)
            }
            
            /// View Controller Events
            if side != .none {
                sideContent.viewController.viewDidAppear(isAnimation(content: sideContent))
            }
        }
        
        /// Delegate
        self.delegate?.drawerDidBeganAnimation?(drawerController: self, side: side)
    }
    private func willAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("willAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
    }
    private func didAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("didAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
        
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? self.drawerSide : side
        
        if let sideContent = contentMap[moveSide] {
            if !sideContent.isAbsolute {
                mainContent.transition = sideContent.transition
                mainContent.overflowTransition = sideContent.overflowTransition
                mainContent.transition(
                    side: side,
                    percentage: self.calcPercentage(side: .none, moveSide: moveSide, percent),
                    viewRect: self.calcViewRect(content: sideContent)
                )
            }
            
            sideContent.transition(
                side: side,
                percentage: self.calcPercentage(side: moveSide, moveSide: moveSide, percent),
                viewRect: self.calcViewRect(content: sideContent)
            )
            
            if self.isShadow(content: sideContent) {
                self.shadowView.frame = sideContent.contentView.frame
                self.shadowView.layer.shadowPath = UIBezierPath(rect: self.shadowView.bounds).cgPath
                self.shadowView.alpha = CGFloat(percent)
            }
            
            if sideContent.isBringToFront {
                self.fadeView.layer.opacity = percent
                self.translucentView.alpha = CGFloat(percent)
            } else {
                self.fadeView.layer.opacity = 1.0 - percent
                self.translucentView.alpha = CGFloat(1.0 - percent)
            }
        } else {
            mainContent.transition(
                side: side,
                percentage: self.calcPercentage(side: .none, moveSide: moveSide, percent),
                viewRect: self.calcViewRect(content: nil)
            )
            self.fadeView.layer.opacity = percent
            self.translucentView.alpha = CGFloat(percent)
        }
        
        /// Delegate
        self.delegate?.drawerDidAnimation?(drawerController: self, side: side, percentage: percent)
    }
    private func willFinishAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("willFinishAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
        
        /// Delegate
        self.delegate?.drawerWillFinishAnimation?(drawerController: self, side: side)
    }
    private func didFinishAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("didFinishAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
        
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? self.drawerSide : side
        
        let sideContent = contentMap[moveSide]
        if let content = sideContent {
            if content.isBringToFront {
                self.fadeView.layer.opacity = percent
                self.translucentView.alpha = CGFloat(percent)
            } else {
                self.fadeView.layer.opacity = 1.0 - percent
                self.translucentView.alpha = CGFloat(1.0 - percent)
            }
            
            content.endTransition(side: side)
            
            /// View Controller Events
            if side == .none {
                content.viewController.viewDidDisappear(isAnimation(content: content))
            }
        } else {
            self.fadeView.layer.opacity = percent
            self.translucentView.alpha = CGFloat(percent)
        }
        
        mainContent.endTransition(side: side)
        
        /// Set User Interaction
        for (drawerSide, content) in self.contentMap {
            if drawerSide == side {
                content.contentView.isUserInteractionEnabled = true
            } else {
                content.contentView.isUserInteractionEnabled = false
            }
        }
        
        self.drawerSide = side
        
        /// User Interaction
        if let content = sideContent {
            if !self.isTapToClose(content: content) {
                mainContent.contentView.isUserInteractionEnabled = true
            }
        }
        self.view.isUserInteractionEnabled = true
        
        /// Delegate
        self.delegate?.drawerDidFinishAnimation?(drawerController: self, side: side)
    }
    private func willCancelAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("willCancelAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
        
        /// Delegate
        self.delegate?.drawerWillCancelAnimation?(drawerController: self, side: side)
    }
    private func didCancelAnimate(side: DrawerSide, percent: Float) {
        #if DEBUG
        print("didCancelAnimate(side: \(side.rawValue), percent: \(percent))")
        #endif
        
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? self.drawerSide : side
        
        let sideContent = contentMap[moveSide]
        if let content = sideContent {
            if content.isBringToFront {
                self.fadeView.layer.opacity = percent
                self.translucentView.alpha = CGFloat(percent)
            } else {
                self.fadeView.layer.opacity = 1.0 - percent
                self.translucentView.alpha = CGFloat(1.0 - percent)
            }
        } else {
            self.fadeView.layer.opacity = percent
            self.translucentView.alpha = CGFloat(percent)
        }
        
        /// Set User Interaction
        for (drawerSide, content) in self.contentMap {
            if drawerSide == side {
                content.contentView.isUserInteractionEnabled = true
            } else {
                content.contentView.isUserInteractionEnabled = false
            }
        }
        
        self.drawerSide = side
        
        /// User Interaction
        if let content = sideContent {
            if !self.isTapToClose(content: content) {
                mainContent.contentView.isUserInteractionEnabled = true
            }
        }
        self.view.isUserInteractionEnabled = true
        
        /// Delegate
        self.delegate?.drawerDidCancelAnimation?(drawerController: self, side: side)
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    private func isContentTouched(point: CGPoint, side: DrawerSide) -> Bool {
        guard self.drawerSide != .none else { return false }
        
        let pointRect = CGRect(
            origin: CGPoint(
                x: CGFloat(Float(point.x) - gestureSenstivity.sensitivity()),
                y: CGFloat(Float(point.y) - gestureSenstivity.sensitivity())
            ),
            size: CGSize(
                width: CGFloat(gestureSenstivity.sensitivity() * 2.0),
                height: CGFloat(gestureSenstivity.sensitivity() * 2.0)
            )
        )
        
        for (drawerSide, content) in self.contentMap {
            if content.isAbsolute {
                if content.contentView.frame.intersects(pointRect) {
                    if drawerSide != side {
                        return false
                    }
                }
            }
        }
        
        for (drawerSide, content) in self.contentMap {
            if content.contentView.frame.intersects(pointRect) {
                if drawerSide == side {
                    return true
                } else {
                    return false
                }
            }
        }
        
        return false
    }
    
    @objc
    private func handleTapGestureRecognizer(gesture: UITapGestureRecognizer) {
        
        /// Golden-Path
        guard isEnable() else { return }
        guard isGesture() else { return }
        guard !self.isAnimating else { return }
        
        self.closeSide {
            self.gestureLastPercentage = -1.0
        }
    }
    
    @objc
    private func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
        
        /// Golden-Path
        guard isEnable() else { return }
        guard isGesture() else { return }
        guard !self.isAnimating else { return }
        
        let location = gesture.location(in: self.view)
        
        switch gesture.state {
        case .began:
            if isGestureMoveLeft == true {
                self.willBeginAnimate(side: .left)
                self.didBeginAnimate(side: .left)
            } else {
                self.willBeginAnimate(side: .right)
                self.didBeginAnimate(side: .right)
            }
            
            switch self.drawerSide {
            case .left: self.gestureLastPercentage = 1.0
            case .right: self.gestureLastPercentage = -1.0
            case .none: self.gestureLastPercentage = 0.0
            }
            
            self.willAnimate(side: self.internalFromSide, percent: fabs(self.gestureLastPercentage))
            self.didAnimate(side: self.internalFromSide, percent: fabs(self.gestureLastPercentage))
            
        case .changed:
            guard self.internalFromSide != .none else { return }
            
            let viewRect = self.calcViewRect(content: self.contentMap[self.internalFromSide])
            var percentage = self.gestureLastPercentage + (Float(location.x) - Float(self.gestureMovePoint.x)) / Float(viewRect.width)
            
            if location.x - self.gestureMovePoint.x > 0 {
                self.isGestureMoveLeft = false
            } else if location.x - self.gestureMovePoint.x < 0 {
                self.isGestureMoveLeft = true
            }
            
            if self.internalFromSide == .right && percentage > 0.0 {
                if let _ = self.contentMap[.left] {
                    self.willAnimate(side: self.internalFromSide, percent: 0.0)
                    self.didAnimate(side: self.internalFromSide, percent: 0.0)
                    
                    self.willFinishAnimate(side: self.internalFromSide, percent: 0)
                    self.didFinishAnimate(side: self.internalFromSide, percent: 0)
                    
                    self.drawerSide = .none
                    
                    self.willBeginAnimate(side: .left)
                    self.didBeginAnimate(side: .left)
                } else {
                    percentage = 0.0
                }
            }
            if self.internalFromSide == .left && percentage < 0.0 {
                if let _ = self.contentMap[.right] {
                    self.willAnimate(side: self.internalFromSide, percent: 0.0)
                    self.didAnimate(side: self.internalFromSide, percent: 0.0)
                    
                    self.willFinishAnimate(side: self.internalFromSide, percent: 0)
                    self.didFinishAnimate(side: self.internalFromSide, percent: 0)
                    
                    self.drawerSide = .none
                    
                    self.willBeginAnimate(side: .right)
                    self.didBeginAnimate(side: .right)
                } else {
                    percentage = 0.0
                }
            }
            
            self.gestureMovePoint = location
            if self.isOverflowAnimation(content: self.contentMap[self.internalFromSide]!) {
                if percentage > DrawerController.OverflowPercentage {
                    percentage = DrawerController.OverflowPercentage
                }
                if percentage < -DrawerController.OverflowPercentage {
                    percentage = -DrawerController.OverflowPercentage
                }
            } else {
                if percentage > 1.0 {
                    percentage = 1.0
                }
                if percentage < -1.0 {
                    percentage = -1.0
                }
            }
            
            self.willAnimate(side: self.internalFromSide, percent: fabs(percentage))
            self.didAnimate(side: self.internalFromSide, percent: fabs(percentage))
            
            self.gestureLastPercentage = percentage
            
        default:
            guard self.internalFromSide != .none else { return }
            
            self.willCancelAnimate(side: self.internalFromSide, percent: fabs(self.gestureLastPercentage))
            self.didCancelAnimate(side: self.internalFromSide, percent: fabs(self.gestureLastPercentage))
            
            self.gestureLastPercentage = fabs(self.gestureLastPercentage)
            
            if self.internalFromSide == .left && !self.isGestureMoveLeft {
                self.openSide(.left) {
                    self.gestureLastPercentage = -1.0
                }
            } else if self.internalFromSide == .right && self.isGestureMoveLeft {
                self.openSide(.right) {
                    self.gestureLastPercentage = -1.0
                }
            } else {
                if fabs(self.gestureLastPercentage) > 1.0 {
                    
                    if self.internalFromSide == .left {
                        self.openSide(.left) {
                            self.gestureLastPercentage = -1.0
                        }
                    } else if self.internalFromSide == .right {
                        self.openSide(.right) {
                            self.gestureLastPercentage = -1.0
                        }
                    }
                    
                } else {
                    self.closeSide {
                        self.gestureLastPercentage = -1.0
                    }
                }
            }
            
            self.gestureMovePoint.x = -1
            self.gestureMovePoint.y = -1
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        /// Golden-Path
        guard isEnable() else { return false }
        guard !self.isAnimating else { return false }
        
        let location = gestureRecognizer.location(in: self.view)
        
        /// Check Tap / Pan gesture recognizer
        if gestureRecognizer is UITapGestureRecognizer {
            guard isTapToClose() else { return false }
            guard let sideContent = self.contentMap[self.drawerSide] else { return false }
            
            if self.isContentTouched(point: location, side: .none) {
                guard isTapToClose(content: sideContent) else { return false }
                
                return true
            }
        } else {
            guard isGesture() else { return false }
            
            let panGesture: UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation = panGesture.translation(in: self.view)
            
            if fabs(translation.x) < fabs(translation.y) {
                return false
            }
            
            /// Set default values
            self.gestureBeginPoint = location
            self.gestureMovePoint = self.gestureBeginPoint
            
            let pointRect = CGRect(
                origin: CGPoint(
                    x: CGFloat(Float(self.gestureBeginPoint.x - translation.x) - gestureSenstivity.sensitivity()),
                    y: CGFloat(Float(self.gestureBeginPoint.y - translation.y) - gestureSenstivity.sensitivity())
                ),
                size: CGSize(
                    width: CGFloat(gestureSenstivity.sensitivity() * 2.0),
                    height: CGFloat(gestureSenstivity.sensitivity() * 2.0)
                )
            )
            
            /// Gesture Area
            if self.drawerSide == .none {
                
                let leftRect = CGRect(
                    x: CGFloat(Float(self.view.frame.minX) - DrawerController.GestureArea),
                    y: self.view.frame.minY,
                    width: CGFloat(DrawerController.GestureArea * 2.0),
                    height: self.view.frame.height
                )
                let rightRect = CGRect(
                    x: CGFloat(Float(self.view.frame.maxX) - DrawerController.GestureArea),
                    y: self.view.frame.origin.y,
                    width: CGFloat(DrawerController.GestureArea * 2.0),
                    height: self.view.frame.height
                )
                
                if let content = self.contentMap[.left] {
                    if self.isGesture(content: content) && leftRect.intersects(pointRect) {
                        self.isGestureMoveLeft = true
                        return true
                    }
                }
                if let content = self.contentMap[.right] {
                    if  self.isGesture(content: content) && rightRect.intersects(pointRect) {
                        self.isGestureMoveLeft = false
                        return true
                    }
                }
            } else {
                guard let content = self.contentMap[.none] else { return false }
                guard let sideContent = self.contentMap[self.drawerSide] else { return false }
                
                guard isGesture(content: sideContent) else { return false }
                
                if content.contentView.frame.intersects(pointRect) {
                    if self.drawerSide == .left {
                        self.isGestureMoveLeft = true
                    } else {
                        self.isGestureMoveLeft = false
                    }
                    return true
                }
            }
        }
        
        return false
    }
    
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.options.isTapToClose = true
        self.options.isGesture = true
        self.options.isAnimation = true
        self.options.isOverflowAnimation = true
        self.options.isShadow = true
        self.options.isFadeScreen = true
        self.options.isBlur = true
        self.options.isEnable = true
        
        /// Default View
        self.shadowView.layer.shadowOpacity = self.shadowOpacity
        self.shadowView.layer.shadowRadius = self.shadowRadius
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.opacity = 0.0
        self.shadowView.isHidden = true
        self.shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.shadowView)
        
        self.fadeView.frame = self.view.bounds
        self.fadeView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        self.fadeView.alpha = 0.0
        self.fadeView.isHidden = true
        self.fadeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.fadeView)
        
        self.translucentView.frame = self.view.bounds
        self.translucentView.layer.opacity = 0.0
        self.translucentView.isHidden = true
        self.translucentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.translucentView)
        
        /// Gesture Recognizer
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        
        self.panGestureRecognizer!.delegate = self
        self.tapGestureRecognizer!.delegate = self
        
        self.view.addGestureRecognizer(self.panGestureRecognizer!)
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
        
        self.view.clipsToBounds = true
        
        /// Storyboard
        if let mainSegueID = self.mainSegueIdentifier {
            self.performSegue(withIdentifier: mainSegueID, sender: self)
        }
        if let leftSegueID = self.leftSegueIdentifier {
            self.performSegue(withIdentifier: leftSegueID, sender: self)
        }
        if let rightSegueID = self.rightSegueIdentifier {
            self.performSegue(withIdentifier: rightSegueID, sender: self)
        }
        
        /// Event Handler
        self.view.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        self.view.removeObserver(self, forKeyPath:"center")
    }
    
    @objc
    private func deviceRotated() {
        
        for (_, content) in self.contentMap {
            content.updateView()
        }
        
        if !self.isAnimating {
            for (side, content) in self.contentMap {
                let percent: Float = self.drawerSide == .none ? 0.0 : 1.0
                
                self.willBeginAnimate(side: self.drawerSide)
                self.didBeginAnimate(side: self.drawerSide)
                self.willAnimate(side: self.drawerSide, percent: percent)
                self.didAnimate(side: self.drawerSide, percent: percent)
                
                content.startTransition(side: self.drawerSide)
                content.transition(
                    side: self.drawerSide,
                    percentage: self.calcPercentage(side: side, moveSide: self.drawerSide, percent),
                    viewRect: self.calcViewRect(content: content)
                )
                content.endTransition(side: self.drawerSide)
                
                self.willFinishAnimate(side: self.drawerSide, percent: percent)
                self.didFinishAnimate(side: self.drawerSide, percent: percent)
                
            }
        }
        
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        if keyPath == "center" {
            deviceRotated()
        }
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}
