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
    @objc optional func drawerDidAnimation(drawerController: DrawerController, side: DrawerSide, percentage: Float)
    @objc optional func drawerDidBeganAnimation(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerWillFinishAnimation(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerWillCancelAnimation(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerDidFinishAnimation(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerDidCancelAnimation(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerWillOpenSide(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerWillCloseSide(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerDidOpenSide(drawerController: DrawerController, side: DrawerSide)
    @objc optional func drawerDidCloseSide(drawerController: DrawerController, side: DrawerSide)
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
            return internalDrawerWidth
        }
        set {
            let updateList = contentMap
                .filter { $0.value.drawerWidth != newValue }
                .map { $0.key }
            
            for side in updateList {
                setDrawerWidth(newValue, for: side)
            }
            internalDrawerWidth = newValue
        }
    }
    
    public var gestureSenstivity: DrawerGestureSensitivity = .normal
    
    public var options: DrawerOption = DrawerOption()
    
    @IBInspectable
    public var shadowRadius: CGFloat = 10.0 {
        didSet { shadowView.layer.shadowRadius = shadowRadius }
    }
    
    @IBInspectable
    public var shadowOpacity: Float = 0.8 {
        didSet { shadowView.layer.shadowOpacity = shadowOpacity }
    }
    
    @IBInspectable
    public var fadeColor: UIColor = UIColor(white: 0, alpha: 0.8) {
        didSet { fadeView.backgroundColor = fadeColor }
    }
    
    @IBInspectable
    public var isEnableAutoSwitchDirection: Bool = false
    
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
    

    // MARK: - Public
    
    /// Options
    public func getSideOption(for side: DrawerSide) -> DrawerOption? {
        guard let content = contentMap[side] else { return nil }
        return content.option
    }
    
    /// Absolute
    public func getAbsolute(for side: DrawerSide) -> Bool {
        guard let content = contentMap[side] else { return false }
        return content.isAbsolute
    }
    public func setAbsolute(_ isAbsolute: Bool, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        
        if content.isAbsolute != isAbsolute && drawerSide == side && side != .none {
            closeSide() {
                content.isAbsolute = isAbsolute
            }
        } else {
            content.isAbsolute = isAbsolute
        }
    }
    
    /// Bring to Front
    public func getBringToFront(for side: DrawerSide) -> Bool {
        guard let content = contentMap[side] else { return false }
        return content.isBringToFront
    }
    public func setBringToFront(_ isBringToFront: Bool, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        content.isBringToFront = isBringToFront
    }
    
    /// Transition
    public func getTransition(for side: DrawerSide) -> DrawerTransition? {
        guard let content = contentMap[side] else { return nil }
        return content.transition
    }
    public func setTransition(_ transition: DrawerTransition, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        content.transition = transition
        
        guard !isAnimating else { return }
        let percent: Float = drawerSide == .none ? 0.0 : 1.0
        
        willBeginAnimate(side: drawerSide)
        didBeginAnimate(side: drawerSide)
        willAnimate(side: drawerSide, percent: percent)
        didAnimate(side: drawerSide, percent: percent)
        
        content.startTransition(side: drawerSide)
        content.transition(
            side: drawerSide,
            percentage: calcPercentage(side: side, moveSide: drawerSide, percent),
            viewRect: calcViewRect(content: content)
        )
        content.endTransition(side: drawerSide)
        
        willFinishAnimate(side: drawerSide, percent: percent)
        didFinishAnimate(side: drawerSide, percent: percent)
    }
    public func getOverflowTransition(for side: DrawerSide) -> DrawerTransition? {
        guard let content = contentMap[side] else { return nil }
        return content.overflowTransition
    }
    public func setOverflowTransition(_ transition: DrawerTransition, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        content.overflowTransition = transition
    }
    
    
    /// Animator
    public func getAnimator(for side: DrawerSide) -> DrawerAnimator? {
        guard let content = contentMap[side] else { return nil }
        return content.animator
    }
    public func setAnimator(_ animator: DrawerAnimator, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        content.animator = animator
    }
    
    /// Drawer Width
    public func getDrawerWidth(for side: DrawerSide) -> Float? {
        guard let content = contentMap[side] else { return nil }
        return content.drawerWidth
    }
    public func setDrawerWidth(_ drawerWidth: Float, for side: DrawerSide) {
        guard let content = contentMap[side] else { return }
        
        guard drawerSide == side else {
            content.drawerWidth = drawerWidth
            return
        }
    
        let oldDrawerWidth = content.drawerWidth
        let variationWidth = drawerWidth - oldDrawerWidth
        content.animator.doAnimate(
            duration: animationDuration,
            animations: { percentage in
                content.drawerWidth = oldDrawerWidth + variationWidth * percentage
            },
            completion: { _ in }
        )
    }
    
    /// View controller
    public func getViewController(for side: DrawerSide) -> UIViewController? {
        return contentMap[side]?.viewController
    }
    public func setViewController(_ viewController: UIViewController?, for side: DrawerSide) {
        guard isEnable() else { return }
        guard let controller = viewController else {
            removeSide(side)
            return
        }
        addSide(side, viewController: controller)
    }
    
    /// Actions
    @IBAction func openLeftSide(_ sender: Any) {
        openSide(.left)
    }
    
    @IBAction func openRightSide(_ sender: Any) {
        openSide(.right)
    }
    
    public func openSide(_ side: DrawerSide, completion: (()->())? = nil) {
        /// Golden-Path
        guard isEnable(), !isAnimating else { return }
        delegate?.drawerWillOpenSide?(drawerController: self, side: side)
        
        if drawerSide != .none && side != drawerSide {
            closeSide { [weak self] in
                self?.openSide(side, completion: completion)
            }
            return
        }
        
        isAnimating = true
        
        willBeginAnimate(side: side)
        didBeginAnimate(side: side)
        
        willAnimate(side: side, percent: 0.0)
        
        /// Check available of animation.
        guard isAnimation() else {
            didAnimate(side: side, percent: 1.0)
            
            willFinishAnimate(side: side, percent: 1.0)
            didFinishAnimate(side: side, percent: 1.0)
            
            isAnimating = false
            delegate?.drawerDidOpenSide?(drawerController: self, side: side)
            completion?()
            return
        }
        
        if gestureLastPercentage >= 0.0 {
            didAnimate(side: side, percent: gestureLastPercentage)
        } else {
            didAnimate(side: side, percent: 0.0)
        }
        if let content = contentMap[side] {
            content.animator.doAnimate(
                duration: animationDuration,
                animations: { [weak self] percent in
                    guard let ss = self else { return }
                    if ss.gestureLastPercentage >= 0.0 {
                        let invertLastPercent = 1.0 - ss.gestureLastPercentage
                        ss.didAnimate(side: side, percent: invertLastPercent * percent + ss.gestureLastPercentage)
                    } else {
                        ss.didAnimate(side: side, percent: percent)
                    }
                },
                completion: { [weak self] isComplete in
                    guard let ss = self else { return }
                    ss.willFinishAnimate(side: side, percent: 1.0)
                    ss.didFinishAnimate(side: side, percent: 1.0)
                    
                    ss.isAnimating = false
                    ss.delegate?.drawerDidOpenSide?(drawerController: ss, side: side)
                    completion?()
                }
            )
        } else {
            UIView.animate(
                withDuration: animationDuration,
                animations: { [weak self] in
                    guard let ss = self else { return }
                    ss.didAnimate(side: side, percent: 1.0)
                },
                completion: { [weak self] isComplete in
                    guard let ss = self else { return }
                    ss.willFinishAnimate(side: side, percent: 1.0)
                    ss.didFinishAnimate(side: side, percent: 1.0)
                    
                    ss.isAnimating = false
                    ss.delegate?.drawerDidOpenSide?(drawerController: ss, side: side)
                    completion?()
                }
            )
        }
    }
    
    public func closeSide(completion: (()->())? = nil) {
        /// Golden-Path
        guard isEnable(), !isAnimating else { return }

        delegate?.drawerWillCloseSide?(drawerController: self, side: drawerSide)
        
        let oldSide = drawerSide
        isAnimating = true
        
        willBeginAnimate(side: .none)
        didBeginAnimate(side: .none)
        
        willAnimate(side: .none, percent: 1.0)
        
        /// Check if the animation is available.
        guard isAnimation() else {
            didAnimate(side: .none, percent: 0.0)
            
            willFinishAnimate(side: .none, percent: 0.0)
            didFinishAnimate(side: .none, percent: 0.0)
            
            isAnimating = false
            delegate?.drawerDidCloseSide?(drawerController: self, side: oldSide)
            completion?()
            return
        }
        
        if gestureLastPercentage >= 0.0 {
            didAnimate(side: .none, percent: gestureLastPercentage)
        } else {
            didAnimate(side: .none, percent: 0.9999)
        }
        if let content = contentMap[drawerSide] {
            content.animator.doAnimate(
                duration: animationDuration,
                animations: { [weak self] percent in
                    guard let ss = self else { return }
                    if ss.gestureLastPercentage >= 0.0 {
                        ss.didAnimate(side: .none, percent: ss.gestureLastPercentage - percent * ss.gestureLastPercentage)
                    } else {
                        ss.didAnimate(side: .none, percent: 1.0 - percent)
                    }
                }, completion: { [weak self] isComplete in
                    guard let ss = self else { return }
                    ss.willFinishAnimate(side: .none, percent: 0.0)
                    ss.didFinishAnimate(side: .none, percent: 0.0)
                    
                    ss.isAnimating = false
                    ss.delegate?.drawerDidCloseSide?(drawerController: ss, side: oldSide)
                    completion?()
                }
            )
        } else {
            UIView.animate(
                withDuration: animationDuration,
                animations: { [weak self] in
                    guard let ss = self else { return }
                    ss.didAnimate(side: .none, percent: 0.0)
                }, completion: { [weak self] isComplete in
                    guard let ss = self else { return }
                    ss.willFinishAnimate(side: .none, percent: 0.0)
                    ss.didFinishAnimate(side: .none, percent: 0.0)
                    
                    ss.isAnimating = false
                    ss.delegate?.drawerDidCloseSide?(drawerController: ss, side: oldSide)
                    completion?()
                }
            )
        }
    }
    
    
    // MARK: - Private
    
    private var contentMap: [DrawerSide: DrawerContent] = [:]
    
    private var internalDrawerWidth: Float = 280.0
    private var internalFromSide: DrawerSide = .none
    
    private var shadowView: UIView = UIView()
    private var fadeView: UIView = UIView()
    private var translucentView: TranslucentView = TranslucentView()
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private var currentOrientation: UIDeviceOrientation = .unknown
    
    #if swift(>=3.2)
    private var observeContext: NSKeyValueObservation?
    #else
    private var isObserveKVO: Bool = false
    private static var observeContext: Int = 0
    #endif

    /// Gesture
    private var gestureBeginPoint: CGPoint = CGPoint.zero
    private var gestureMovePoint: CGPoint = CGPoint.zero
    private var gestureLastPercentage: Float = -1.0
    private var isGestureMoveLeft: Bool = false
    
    private func isEnable() -> Bool {
        return options.isEnable
    }
    private func isEnable(content: DrawerContent) -> Bool {
        return options.isEnable && content.option.isEnable
    }
    private func isAnimation() -> Bool {
        return options.isAnimation
    }
    private func isAnimation(content: DrawerContent) -> Bool {
        return options.isAnimation && content.option.isAnimation
    }
    private func isOverflowAnimation() -> Bool {
        return options.isOverflowAnimation
    }
    private func isOverflowAnimation(content: DrawerContent) -> Bool {
        return options.isOverflowAnimation && content.option.isOverflowAnimation
    }
    private func isGesture() -> Bool {
        return options.isGesture
    }
    private func isGesture(content: DrawerContent) -> Bool {
        return options.isGesture && content.option.isGesture
    }
    private func isShadow(content: DrawerContent) -> Bool {
        return options.isShadow && content.option.isShadow
    }
    private func isFadeScreen(content: DrawerContent) -> Bool {
        return options.isFadeScreen && content.option.isFadeScreen
    }
    private func isBlur(content: DrawerContent) -> Bool {
        return options.isBlur && content.option.isBlur
    }
    private func isTapToClose() -> Bool {
        return options.isTapToClose
    }
    private func isTapToClose(content: DrawerContent) -> Bool {
        return options.isTapToClose && content.option.isTapToClose
    }
    
    private func addSide(_ side: DrawerSide, viewController: UIViewController) {
        /// Golden-Path
        guard !isAnimating else { return }
        
        /// Closure
        let setNewContent: ((DrawerContent?) -> Void) = { [weak self] content in
            guard let ss = self else { return }
            
            if let oldContent = content {
                oldContent.removeDrawerView()
            }
            let newContent = DrawerContent(
                viewController: viewController,
                drawerSide: side
            )
            newContent.addDrawerView(drawerController: ss)
            newContent.drawerWidth = ss.drawerWidth
            ss.contentMap[side] = newContent
            if side == .none {
                newContent.setVisible(true)
            }
            
            newContent.startTransition(side: .none)
            newContent.transition(
                side: .none,
                percentage: ss.calcPercentage(side: side, moveSide: .none, 0.0),
                viewRect: ss.calcViewRect(content: newContent)
            )
            newContent.endTransition(side: .none)
        }
        
        guard let content = contentMap[side] else {
            setNewContent(nil)
            return
        }
        
        /// Check exposed in screen.
        if drawerSide == side {
            closeSide {
                setNewContent(content)
            }
        } else {
            setNewContent(content)
        }
    }
    private func removeSide(_ side: DrawerSide) {
        /// Golden-Path
        guard !isAnimating, let content = contentMap[side] else { return }
        
        /// Closure
        let unsetContent: ((DrawerContent) -> Void) = { [weak self] content in
            content.removeDrawerView()
            self?.contentMap.removeValue(forKey: side)
        }
        
        if drawerSide == side {
            closeSide {
                unsetContent(content)
            }
        } else {
            unsetContent(content)
        }
    }
    
    
    // MARK: - Animation
    
    private func calcPercentage(side: DrawerSide, moveSide: DrawerSide, _ percentage: Float) -> Float {
        switch (side, moveSide) {
        case (.left, _):
            return -1.0 + percentage
            
        case (.right, _):
            return 1.0 - percentage
            
        case (.none, .right):
            return -percentage
            
        case (.none, _):
            return percentage
        }
    }
    private func calcViewRect(content: DrawerContent?) -> CGRect {
        if let selectedContent = content {
            return CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat(selectedContent.drawerWidth), height: view.frame.height)
            )
        } else {
            return CGRect(
                origin: .zero,
                size: CGSize(width: CGFloat(drawerWidth), height: view.frame.height)
            )
        }
    }
    
    private func willBeginAnimate(side: DrawerSide) {
        for (drawerSide, content) in contentMap {
            if drawerSide == side || drawerSide == .none || drawerSide == internalFromSide {
                content.contentView.isHidden = false
            } else {
                content.contentView.isHidden = true
            }
        }
        
        internalFromSide = side
        
        /// View Controller Events
        if side != .none, let sideContent = contentMap[side] {
            sideContent.setVisible(true)
        }
        
        /// User Interaction
        view.isUserInteractionEnabled = false
    }
    private func didBeginAnimate(side: DrawerSide) {
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? drawerSide : side
        
        mainContent.startTransition(side: side)
        
        /// Delegate
        defer {
            delegate?.drawerDidBeganAnimation?(drawerController: self, side: side)
        }
        
        guard let sideContent = contentMap[moveSide] else { return }
        sideContent.startTransition(side: side)
        
        /// Fade Screen
        fadeView.isHidden = !isFadeScreen(content: sideContent)
        if isFadeScreen(content: sideContent) {
            if sideContent.isBringToFront {
                view.insertSubview(fadeView, aboveSubview: mainContent.contentView)
            } else {
                view.insertSubview(fadeView, aboveSubview: sideContent.contentView)
            }
        }
        
        /// Blur
        translucentView.isHidden = !isBlur(content: sideContent)
        if isBlur(content: sideContent) {
            if sideContent.isBringToFront {
                view.insertSubview(translucentView, aboveSubview: mainContent.contentView)
            } else {
                view.insertSubview(translucentView, aboveSubview: sideContent.contentView)
            }
        }
        
        /// Shadow
        shadowView.isHidden = !isShadow(content: sideContent)
        if isShadow(content: sideContent) {
            shadowView.frame = sideContent.contentView.frame
            shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
            view.insertSubview(shadowView, belowSubview: sideContent.contentView)
        }
        
        if sideContent.isBringToFront {
            view.bringSubview(toFront: sideContent.contentView)
        } else {
            view.bringSubview(toFront: mainContent.contentView)
        }
    }
    private func willAnimate(side: DrawerSide, percent: Float) {}
    private func didAnimate(side: DrawerSide, percent: Float) {
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? drawerSide : side
        
        guard let sideContent = contentMap[moveSide] else {
            mainContent.transition(
                side: side,
                percentage: calcPercentage(side: .none, moveSide: moveSide, percent),
                viewRect: calcViewRect(content: nil)
            )
            fadeView.layer.opacity = percent
            translucentView.alpha = CGFloat(percent)
            return
        }
        
        if !sideContent.isAbsolute {
            mainContent.transition = sideContent.transition
            mainContent.overflowTransition = sideContent.overflowTransition
            mainContent.transition(
                side: side,
                percentage: calcPercentage(side: .none, moveSide: moveSide, percent),
                viewRect: calcViewRect(content: sideContent)
            )
        }
        
        sideContent.transition(
            side: side,
            percentage: calcPercentage(side: moveSide, moveSide: moveSide, percent),
            viewRect: calcViewRect(content: sideContent)
        )
        
        if isShadow(content: sideContent) {
            shadowView.frame = sideContent.contentView.frame
            shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
            shadowView.alpha = CGFloat(percent)
        }
        
        if sideContent.isBringToFront {
            fadeView.layer.opacity = percent
            translucentView.alpha = CGFloat(percent)
        } else {
            fadeView.layer.opacity = 1.0 - percent
            translucentView.alpha = CGFloat(1.0 - percent)
        }
        
        /// Delegate
        delegate?.drawerDidAnimation?(drawerController: self, side: side, percentage: percent)
    }
    private func willFinishAnimate(side: DrawerSide, percent: Float) {
        /// Delegate
        delegate?.drawerWillFinishAnimation?(drawerController: self, side: side)
    }
    private func didFinishAnimate(side: DrawerSide, percent: Float) {
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? drawerSide : side
        
        let sideContent = contentMap[moveSide]
        if let content = sideContent {
            if content.isBringToFront {
                fadeView.layer.opacity = percent
                translucentView.alpha = CGFloat(percent)
            } else {
                fadeView.layer.opacity = 1.0 - percent
                translucentView.alpha = CGFloat(1.0 - percent)
            }
            
            content.endTransition(side: side)
            if moveSide != .none, side == .none {
                content.setVisible(false)
            }
        } else {
            fadeView.layer.opacity = percent
            translucentView.alpha = CGFloat(percent)
        }
        
        mainContent.endTransition(side: side)
        
        /// Set User Interaction
        for (drawerSide, content) in contentMap {
            if drawerSide == side {
                content.contentView.isUserInteractionEnabled = true
            } else {
                content.contentView.isUserInteractionEnabled = false
            }
        }
        
        drawerSide = side
        
        /// User Interaction
        if let content = sideContent {
            if !isTapToClose(content: content) {
                mainContent.contentView.isUserInteractionEnabled = true
            }
        }
        view.isUserInteractionEnabled = true
        
        /// Delegate
        delegate?.drawerDidFinishAnimation?(drawerController: self, side: side)
    }
    private func willCancelAnimate(side: DrawerSide, percent: Float) {
        /// Delegate
        delegate?.drawerWillCancelAnimation?(drawerController: self, side: side)
    }
    private func didCancelAnimate(side: DrawerSide, percent: Float) {
        /// Golden-Path
        guard let mainContent = contentMap[.none] else { return }
        
        let moveSide = side == .none ? drawerSide : side
        
        let sideContent = contentMap[moveSide]
        if let content = sideContent {
            if content.isBringToFront {
                fadeView.layer.opacity = percent
                translucentView.alpha = CGFloat(percent)
            } else {
                fadeView.layer.opacity = 1.0 - percent
                translucentView.alpha = CGFloat(1.0 - percent)
            }
        } else {
            fadeView.layer.opacity = percent
            translucentView.alpha = CGFloat(percent)
        }
        
        /// Set User Interaction
        for (drawerSide, content) in contentMap {
            if drawerSide == side {
                content.contentView.isUserInteractionEnabled = true
            } else {
                content.contentView.isUserInteractionEnabled = false
            }
        }
        
        drawerSide = side
        
        /// User Interaction
        if let content = sideContent {
            if !isTapToClose(content: content) {
                mainContent.contentView.isUserInteractionEnabled = true
            }
        }
        view.isUserInteractionEnabled = true
        
        /// Delegate
        delegate?.drawerDidCancelAnimation?(drawerController: self, side: side)
    }
    
    private func updateLayout() {
        for content in contentMap.values {
            content.updateView()
        }
        
        guard !isAnimating else { return }
        for (side, content) in contentMap {
            if side == .none { continue }
            
            let percent: Float = drawerSide == .none ? 0.0 : 1.0
            
            willBeginAnimate(side: drawerSide)
            didBeginAnimate(side: drawerSide)
            willAnimate(side: drawerSide, percent: percent)
            didAnimate(side: drawerSide, percent: percent)
            
            content.startTransition(side: drawerSide)
            content.transition(
                side: drawerSide,
                percentage: calcPercentage(side: side, moveSide: drawerSide, percent),
                viewRect: calcViewRect(content: content)
            )
            content.endTransition(side: drawerSide)
            
            willFinishAnimate(side: drawerSide, percent: percent)
            didFinishAnimate(side: drawerSide, percent: percent)
        }
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    private func isContentTouched(point: CGPoint, side: DrawerSide) -> Bool {
        guard drawerSide != .none else { return false }
        
        let gestureSensitivity = CGFloat(gestureSenstivity.sensitivity())
        let pointRect = CGRect(
            origin: CGPoint(
                x: point.x - gestureSensitivity,
                y: point.y - gestureSensitivity
            ),
            size: CGSize(
                width: gestureSensitivity * 2.0,
                height: gestureSensitivity * 2.0
            )
        )
        
        for (drawerSide, content) in contentMap where content.isAbsolute && drawerSide != side {
            if content.contentView.frame.intersects(pointRect) {
                return false
            }
        }
        
        for (drawerSide, content) in contentMap {
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
        guard isEnable(), isGesture(), !isAnimating else { return }
        
        closeSide { [weak self] in
            self?.gestureLastPercentage = -1.0
        }
    }
    
    @objc
    private func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
        /// Golden-Path
        guard isEnable(), isGesture(), !isAnimating else { return }
        
        let location = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            if isGestureMoveLeft == true {
                willBeginAnimate(side: .left)
                didBeginAnimate(side: .left)
            } else {
                willBeginAnimate(side: .right)
                didBeginAnimate(side: .right)
            }
            
            switch drawerSide {
            case .left:
                gestureLastPercentage = 1.0
            case .right:
                gestureLastPercentage = -1.0
            case .none:
                gestureLastPercentage = 0.0
            }
            
            willAnimate(side: internalFromSide, percent: fabs(gestureLastPercentage))
            didAnimate(side: internalFromSide, percent: fabs(gestureLastPercentage))
            
        case .changed:
            guard internalFromSide != .none else { return }
            
            let viewRect = calcViewRect(content: contentMap[internalFromSide])
            let moveVariationX = Float(location.x - gestureMovePoint.x)
            var percentage = gestureLastPercentage + moveVariationX / Float(viewRect.width)
            
            if moveVariationX > 0 {
                isGestureMoveLeft = false
            } else if moveVariationX < 0 {
                isGestureMoveLeft = true
            }
            
            let checkAndSwitchDirection = { [weak self] (from: DrawerSide, to: DrawerSide, percentage: Float) -> Float in
                guard let ss = self else { return percentage }
                
                guard ss.internalFromSide == from else { return percentage }
                switch from {
                case .left:
                    guard percentage < 0.0 else { return percentage }
                case .right:
                    guard percentage > 0.0 else { return percentage }
                default:
                    return percentage
                }
                
                guard ss.isEnableAutoSwitchDirection else {
                    switch from {
                    case .left:
                        guard percentage > 0.0 else { return 0.0 }
                    case .right:
                        guard percentage < 0.0 else { return 0.0 }
                    default:
                        return percentage
                    }
                    return percentage
                }
                guard ss.contentMap[to] != nil else {
                    return 0.0
                }
                
                ss.willAnimate(side: from, percent: 0.0)
                ss.didAnimate(side: from, percent: 0.0)
                
                ss.willFinishAnimate(side: from, percent: 0)
                ss.didFinishAnimate(side: from, percent: 0)
                
                ss.drawerSide = .none
                
                ss.willBeginAnimate(side: to)
                ss.didBeginAnimate(side: to)
                return percentage
            }
            percentage = checkAndSwitchDirection(.right, .left, percentage)
            percentage = checkAndSwitchDirection(.left, .right, percentage)
            
            gestureMovePoint = location
            if isOverflowAnimation(content: contentMap[internalFromSide]!) {
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
            
            willAnimate(side: internalFromSide, percent: fabs(percentage))
            didAnimate(side: internalFromSide, percent: fabs(percentage))
            
            gestureLastPercentage = percentage
            
        default:
            guard internalFromSide != .none else { return }
            
            willCancelAnimate(side: internalFromSide, percent: fabs(gestureLastPercentage))
            didCancelAnimate(side: internalFromSide, percent: fabs(gestureLastPercentage))
            
            gestureLastPercentage = fabs(gestureLastPercentage)
            
            if internalFromSide == .left && !isGestureMoveLeft {
                openSide(.left) { [weak self] in
                    self?.gestureLastPercentage = -1.0
                }
            } else if internalFromSide == .right && isGestureMoveLeft {
                openSide(.right) { [weak self] in
                    self?.gestureLastPercentage = -1.0
                }
            } else {
                if fabs(gestureLastPercentage) > 1.0 {
                    if internalFromSide == .left {
                        openSide(.left) { [weak self] in
                            self?.gestureLastPercentage = -1.0
                        }
                    } else if internalFromSide == .right {
                        openSide(.right) { [weak self] in
                            self?.gestureLastPercentage = -1.0
                        }
                    }
                } else {
                    closeSide { [weak self] in
                        self?.gestureLastPercentage = -1.0
                    }
                }
            }
            
            gestureMovePoint.x = -1
            gestureMovePoint.y = -1
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        /// Golden-Path
        guard isEnable() else { return false }
        guard !isAnimating else { return false }
        
        let location = gestureRecognizer.location(in: view)
        
        /// Check tap gesture recognizer
        if gestureRecognizer is UITapGestureRecognizer {
            guard isTapToClose() else { return false }
            guard let sideContent = contentMap[drawerSide] else { return false }
            
            if isContentTouched(point: location, side: .none) {
                guard isTapToClose(content: sideContent) else { return false }
                return true
            }
            return false
        }
        
        /// Check pan gesture recognizer
        guard isGesture() else { return false }
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        let translation = panGesture.translation(in: view)
        guard fabs(translation.x) >= fabs(translation.y) else { return false }
        
        /// Set default values
        gestureBeginPoint = location
        gestureMovePoint = gestureBeginPoint
        
        let gestureSensitivity = CGFloat(gestureSenstivity.sensitivity())
        let pointRect = CGRect(
            origin: CGPoint(
                x: (gestureBeginPoint.x - translation.x) - gestureSensitivity,
                y: (gestureBeginPoint.y - translation.y) - gestureSensitivity
            ),
            size: CGSize(
                width: gestureSensitivity * 2.0,
                height: gestureSensitivity * 2.0
            )
        )
        
        /// Gesture Area
        if drawerSide == .none {
            let leftRect = CGRect(
                x: CGFloat(Float(view.frame.minX) - DrawerController.GestureArea),
                y: view.frame.minY,
                width: CGFloat(DrawerController.GestureArea * 2.0),
                height: view.frame.height
            )
            let rightRect = CGRect(
                x: CGFloat(Float(view.frame.maxX) - DrawerController.GestureArea),
                y: view.frame.origin.y,
                width: CGFloat(DrawerController.GestureArea * 2.0),
                height: view.frame.height
            )
            
            if let content = contentMap[.left] {
                if isGesture(content: content) && leftRect.intersects(pointRect) {
                    isGestureMoveLeft = true
                    return true
                }
            }
            if let content = contentMap[.right] {
                if isGesture(content: content) && rightRect.intersects(pointRect) {
                    isGestureMoveLeft = false
                    return true
                }
            }
        } else {
            guard let content = contentMap[.none] else { return false }
            guard let sideContent = contentMap[drawerSide] else { return false }
            
            guard isGesture(content: sideContent) else { return false }
            
            if content.contentView.frame.intersects(pointRect) {
                if drawerSide == .left {
                    isGestureMoveLeft = true
                } else {
                    isGestureMoveLeft = false
                }
                return true
            }
        }
        
        return false
    }
    
    
    // MARK: - Lifecycle
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        options.isTapToClose = true
        options.isGesture = true
        options.isAnimation = true
        options.isOverflowAnimation = true
        options.isShadow = true
        options.isFadeScreen = true
        options.isBlur = true
        options.isEnable = true
        
        /// Default View
        shadowView.layer.shadowOpacity = shadowOpacity
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.layer.masksToBounds = false
        shadowView.layer.opacity = 0.0
        shadowView.isHidden = true
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(shadowView)
        
        fadeView.frame = view.bounds
        fadeView.backgroundColor = fadeColor
        fadeView.alpha = 0.0
        fadeView.isHidden = true
        fadeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(fadeView)
        
        translucentView.frame = view.bounds
        translucentView.layer.opacity = 0.0
        translucentView.isHidden = true
        translucentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(translucentView)
        
        /// Gesture Recognizer
        panGestureRecognizer = { [unowned self] in
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
            return gesture
        }()
        tapGestureRecognizer = { [unowned self] in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
            return gesture
        }()
        
        view.clipsToBounds = true
        
        /// Storyboard
        if let mainSegueID = mainSegueIdentifier {
            performSegue(withIdentifier: mainSegueID, sender: self)
        }
        if let leftSegueID = leftSegueIdentifier {
            performSegue(withIdentifier: leftSegueID, sender: self)
        }
        if let rightSegueID = rightSegueIdentifier {
            performSegue(withIdentifier: rightSegueID, sender: self)
        }
        
        /// Events
        #if swift(>=3.2)
            observeContext = view.observe(\.frame) { [weak self] (view, event) in
                self?.updateLayout()
            }
        #else
            view.addObserver(self, forKeyPath: "frame", options: .new, context: &DrawerController.observeContext)
            isObserveKVO = true
        #endif
    }
    
    deinit {
        #if swift(>=3.2)
            observeContext?.invalidate()
            observeContext = nil
        #else
            if isObserveKVO {
                view.removeObserver(self, forKeyPath:"frame")
            }
        #endif
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for (_, content) in contentMap {
            content.contentView.setNeedsUpdateConstraints()
            content.contentView.setNeedsLayout()
            content.contentView.layoutIfNeeded()
        }
        
        let newOrientation = UIDevice.current.orientation
        guard newOrientation != .unknown, newOrientation != currentOrientation else { return }
        currentOrientation = newOrientation
        
        updateLayout()
    }
    
    #if !swift(>=3.2)
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &DrawerController.observeContext else {
            observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard isObserveKVO else { return }

        if keyPath == "frame" {
            updateLayout()
        }
    }
    #endif

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}
