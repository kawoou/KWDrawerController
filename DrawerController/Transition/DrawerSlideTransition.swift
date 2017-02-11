//
//  DrawerSlideTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 4..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerSlideTransition: DrawerTransition {

    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        content.contentView.transform = CGAffineTransform.identity
        content.contentView.frame = CGRect(
            x: viewRect.width * percentage + content.drawerOffset,
            y: viewRect.minY,
            width: CGFloat(content.drawerWidth),
            height: content.contentView.frame.height
        )
        
    }
    
}
