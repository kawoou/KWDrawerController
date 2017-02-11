//
//  DrawerFoldTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerFoldTransition: DrawerTransition {
    
    // MARK: - Internal
    
    private var foldList: [FoldView] = []
    
    
    // MARK: - Private
    
    private func bindView(content: DrawerContent) {
        
        for foldView in self.foldList {
            foldView.isHidden = false
        }
        content.viewController.view.isHidden = true
        
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 500.0
        content.contentView.layer.sublayerTransform = transform
        
    }
    
    private func unbindView(content: DrawerContent) {
        
        for foldView in self.foldList {
            foldView.isHidden = true
        }
        content.contentView.layer.sublayerTransform = CATransform3DIdentity
        content.viewController.view.isHidden = false
        
    }
    
    
    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        unbindView(content: content)
        
        if content.drawerSide != .none {
            /// Initialize
            if self.foldList.count == 0 {
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
                    foldView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
                    
                    if i == 0 {
                        foldView.shadowLayer.colors = [UIColor(white: 0.0, alpha: 0.05).cgColor, UIColor(white: 0.0, alpha: 0.6).cgColor]
                    } else {
                        foldView.shadowLayer.colors = [UIColor(white: 0.0, alpha: 0.9).cgColor, UIColor(white: 0.0, alpha: 0.55).cgColor]
                    }
                    
                    content.contentView.addSubview(foldView)
                    self.foldList.append(foldView)
                }
            }
            
            /// Capture
            if let screenshot = content.screenshot(withOptimization: false) {
                if screenshot.size.width <= CGFloat(content.drawerWidth) {
                    let foldWidth = Float(screenshot.size.width) / 2.0
                    
                    for i in 0..<self.foldList.count {
                        let cropRect = CGRect(
                            x: CGFloat(foldWidth * Float(i) * Float(screenshot.scale)),
                            y: CGFloat(0.0),
                            width: CGFloat(foldWidth * Float(screenshot.scale)),
                            height: CGFloat(Float(screenshot.size.height) * Float(screenshot.scale))
                        )
                        
                        if let imageRef: CGImage = screenshot.cgImage?.cropping(to: cropRect) {
                            self.foldList[i].layer.contents = imageRef
                        }
                    }
                }
            }
            
            bindView(content: content)
        }
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
        
        unbindView(content: content)
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            let sidePercent = 1.0 + percentage
            
            self.foldList[0].layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2 - asin(Double(sidePercent))), 0, 1, 0)
            self.foldList[1].layer.transform = CATransform3DConcat(
                CATransform3DMakeRotation(CGFloat(M_PI_2 - asin(Double(sidePercent))), 0, -1, 0),
                CATransform3DMakeTranslation(self.foldList[0].frame.width * 2, 0, 0)
            )
            
            self.foldList[0].shadowView.alpha = fabs(percentage)
            self.foldList[1].shadowView.alpha = fabs(percentage)
            
            let afterDelta = content.drawerWidth - Float(self.foldList[1].frame.maxX)
            
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset + CGFloat(afterDelta),
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
        case .right:
            let sidePercent = 1.0 - percentage
            
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        
            self.foldList[0].layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2 - asin(Double(sidePercent))), 0, 1, 0)
            self.foldList[1].layer.transform = CATransform3DConcat(
                CATransform3DMakeRotation(CGFloat(M_PI_2 - asin(Double(sidePercent))), 0, -1, 0),
                CATransform3DMakeTranslation(self.foldList[0].frame.width * 2, 0, 0)
            )
            
            self.foldList[0].shadowView.alpha = fabs(percentage)
            self.foldList[1].shadowView.alpha = fabs(percentage)
            
        default:
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        }
        
    }
    
}

private class FoldView: UIView {
    
    // MARK - Property
    
    public var shadowView: UIView {
        get {
            return self.internalShadowView
        }
    }
    public var shadowLayer: CAGradientLayer {
        get {
            return self.internalShadowLayer
        }
    }
    
    
    // MARK - Private
    
    private var internalShadowView: UIView = UIView()
    private var internalShadowLayer: CAGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.internalShadowView.frame = self.bounds
        self.addSubview(self.internalShadowView)
        
        self.internalShadowLayer = CAGradientLayer()
        self.internalShadowLayer.frame = self.shadowView.bounds
        self.internalShadowLayer.startPoint = CGPoint(x: 0, y: 0)
        self.internalShadowLayer.endPoint = CGPoint(x: 1, y: 0)
        self.internalShadowView.layer.addSublayer(self.internalShadowLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

