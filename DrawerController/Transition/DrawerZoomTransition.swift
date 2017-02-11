//
//  DrawerZoomTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 12..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerZoomTransition: DrawerTransition {

    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
        
        content.isBringToFront = false
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        content.contentView.transform = CGAffineTransform.identity
        content.contentView.frame = CGRect(
            x: content.drawerOffset,
            y: 0,
            width: CGFloat(content.drawerWidth),
            height: content.contentView.frame.height
        )
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            let sidePercent = CGFloat(1.3 - (1.0 + percentage) * 0.3)
            content.contentView.transform = CGAffineTransform(scaleX: sidePercent, y: sidePercent)
            
        case .right:
            let sidePercent = CGFloat(1.3 - (1.0 - percentage) * 0.3)
            content.contentView.transform = CGAffineTransform(scaleX: sidePercent, y: sidePercent)
            
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
