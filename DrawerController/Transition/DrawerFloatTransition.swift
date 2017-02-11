//
//  DrawerFloatTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerFloatTransition: DrawerTransition {

    // MARK: - Property
    
    public var floatFactor: Float
    
    
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
        
        switch content.drawerSide {
        case .left:
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        case .right:
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
        case .none:
            content.contentView.transform = CGAffineTransform(
                scaleX: CGFloat(1.0 - Float(fabs(percentage)) * self.floatFactor),
                y: CGFloat(1.0 - Float(fabs(percentage)) * self.floatFactor)
            ).translatedBy(
                x: viewRect.size.width * percentage,
                y: 0
            )
        }
        
    }
    
    
    // MARK: - Lifecycle
    
    init(floatFactor: Float = 0.2875) {
        self.floatFactor = floatFactor
        
        super.init()
    }
    
}
