//
//  DrawerParallaxTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 9..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerParallaxTransition: DrawerTransition {

    // MARK: - Property
    
    public var parallaxFactor: Float
    
    
    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
        
        content.isBringToFront = false
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        let newPercentage = content.drawerSide == .none ? percentage : CGFloat(Float(percentage) / self.parallaxFactor)
        
        content.contentView.transform = CGAffineTransform.identity
        content.contentView.frame = CGRect(
            x: viewRect.width * newPercentage + content.drawerOffset,
            y: viewRect.minY,
            width: CGFloat(content.drawerWidth),
            height: content.contentView.frame.height
        )
        
    }
    
    
    // MARK: - Lifecycle
    
    init(parallaxFactor: Float = 2.0) {
        self.parallaxFactor = parallaxFactor
        
        super.init()
    }
    
}
