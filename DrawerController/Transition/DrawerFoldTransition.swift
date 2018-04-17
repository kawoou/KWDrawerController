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

open class DrawerFoldTransition: DrawerTransition {
    
    // MARK: - Internal
    
    private var foldList: [FoldView] = []
    
    
    // MARK: - Private
    
    private func bindView(content: DrawerContent) {
        
        for foldView in foldList {
            foldView.isHidden = false
        }
        content.viewController.view.isHidden = true
        
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 500.0
        content.contentView.layer.sublayerTransform = transform
        
    }
    
    private func unbindView(content: DrawerContent) {
        
        for foldView in foldList {
            foldView.isHidden = true
        }
        content.contentView.layer.sublayerTransform = CATransform3DIdentity
        content.viewController.view.isHidden = false
        
    }
    
    
    // MARK: - Public
    
    open override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
    }
    
    open override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        unbindView(content: content)
        
        if content.drawerSide != .none {
            /// Initialize
            if foldList.count == 0 {
                let foldWidth = content.drawerWidth / 2
                
                for i in 0..<2 {
                    let foldView = FoldView(
                        frame: CGRect(
                            x: CGFloat(-foldWidth / 2),
                            y: CGFloat(0),
                            width: CGFloat(foldWidth),
                            height: content.contentView.frame.height
                        )
                    )
                    foldView.layer.anchorPoint = CGPoint(x: Double(i % 2), y: 0.5)
                    foldView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0, 1, 0)
                    
                    if i == 0 {
                        foldView.shadowLayer.colors = [UIColor(white: 0.0, alpha: 0.05).cgColor, UIColor(white: 0.0, alpha: 0.6).cgColor]
                    } else {
                        foldView.shadowLayer.colors = [UIColor(white: 0.0, alpha: 0.9).cgColor, UIColor(white: 0.0, alpha: 0.55).cgColor]
                    }
                    
                    content.contentView.addSubview(foldView)
                    foldList.append(foldView)
                }
            }
            
            /// Capture
            if let screenshot = content.screenshot(withOptimization: false) {
                if screenshot.size.width <= CGFloat(content.drawerWidth) {
                    let foldWidth = Float(screenshot.size.width) / 2.0
                    
                    for i in 0..<foldList.count {
                        let cropRect = CGRect(
                            x: CGFloat(foldWidth * Float(i) * Float(screenshot.scale)),
                            y: CGFloat(0.0),
                            width: CGFloat(foldWidth * Float(screenshot.scale)),
                            height: CGFloat(Float(screenshot.size.height) * Float(screenshot.scale))
                        )
                        
                        if let imageRef: CGImage = screenshot.cgImage?.cropping(to: cropRect) {
                            foldList[i].layer.contents = imageRef
                        }
                    }
                }
            }
            
            bindView(content: content)
        }
    }
    
    open override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
        
        unbindView(content: content)
    }
    
    open override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            let sidePercent = 1.0 + percentage
            
            foldList[0].layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2 - asin(Double(sidePercent))), 0, 1, 0)
            foldList[1].layer.transform = CATransform3DConcat(
                CATransform3DMakeRotation(CGFloat(Double.pi / 2 - asin(Double(sidePercent))), 0, -1, 0),
                CATransform3DMakeTranslation(foldList[0].frame.width * 2, 0, 0)
            )
            
            foldList[0].shadowView.alpha = fabs(percentage)
            foldList[1].shadowView.alpha = fabs(percentage)
            
            let afterDelta = content.drawerWidth - Float(foldList[1].frame.maxX)
            
            content.contentView.transform = .identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset + CGFloat(afterDelta),
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
        case .right:
            let sidePercent = 1.0 - percentage
            
            content.contentView.transform = .identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        
            foldList[0].layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2 - asin(Double(sidePercent))), 0, 1, 0)
            foldList[1].layer.transform = CATransform3DConcat(
                CATransform3DMakeRotation(CGFloat(Double.pi / 2 - asin(Double(sidePercent))), 0, -1, 0),
                CATransform3DMakeTranslation(foldList[0].frame.width * 2, 0, 0)
            )
            
            foldList[0].shadowView.alpha = fabs(percentage)
            foldList[1].shadowView.alpha = fabs(percentage)
            
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

private class FoldView: UIView {
    
    // MARK - Property
    
    public var shadowView: UIView {
        get {
            return internalShadowView
        }
    }
    public var shadowLayer: CAGradientLayer {
        get {
            return internalShadowLayer
        }
    }
    
    
    // MARK - Private
    
    private var internalShadowView: UIView = UIView()
    private var internalShadowLayer: CAGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        internalShadowView.frame = bounds
        addSubview(internalShadowView)
        
        internalShadowLayer = CAGradientLayer()
        internalShadowLayer.frame = shadowView.bounds
        internalShadowLayer.startPoint = CGPoint(x: 0, y: 0)
        internalShadowLayer.endPoint = CGPoint(x: 1, y: 0)
        internalShadowView.layer.addSublayer(internalShadowLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

