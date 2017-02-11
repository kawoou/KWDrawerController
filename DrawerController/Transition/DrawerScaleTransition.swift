//
//  DrawerScaleTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 4..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerScaleTransition: DrawerTransition {

    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        content.contentView.transform = CGAffineTransform.identity
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
        
        content.contentView.transform = CGAffineTransform.identity
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            if 1.0 == -percentage {
                content.contentView.transform = CGAffineTransform.identity
            } else {
                content.contentView.transform = CGAffineTransform(scaleX: 1.0 + percentage, y: 1.0)
            }
            content.contentView.frame = CGRect(
                x: 0,
                y: viewRect.minY,
                width: content.contentView.frame.width,
                height: content.contentView.frame.height
            )
        case .right:
            if 1.0 == percentage {
                content.contentView.transform = CGAffineTransform.identity
            } else {
                content.contentView.transform = CGAffineTransform(scaleX: 1.0 - percentage, y: 1.0)
            }
            content.contentView.frame = CGRect(
                x: viewRect.width + content.drawerOffset - content.contentView.frame.width,
                y: viewRect.minY,
                width: content.contentView.frame.width,
                height: content.contentView.frame.height
            )
        case .none:
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.size.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: content.contentView.frame.width,
                height: content.contentView.frame.height
            )
        }
        
    }
    
}
