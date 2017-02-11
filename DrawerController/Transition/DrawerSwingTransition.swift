//
//  DrawerSwingTransition.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 9..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerSwingTransition: DrawerTransition {
    
    // MARK: - Public
    
    override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
        
        content.isBringToFront = false
    }
    
    override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
        
        var affine = CATransform3DIdentity
        affine.m34 = -1 / 500.0
        
        switch content.drawerSide {
        case .left:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
            content.contentView.layer.sublayerTransform = affine
        case .right:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            content.contentView.layer.sublayerTransform = affine
        default:
            content.viewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            content.contentView.layer.sublayerTransform = CATransform3DIdentity
        }
        
        content.viewController.view.layer.transform = CATransform3DIdentity
    }
    
    override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
        
        content.contentView.layer.sublayerTransform = CATransform3DIdentity
        content.viewController.view.layer.transform = CATransform3DIdentity
        content.viewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        switch content.drawerSide {
        case .left:
            var affine = CATransform3DMakeTranslation(CGFloat(content.drawerWidth / 2), 0, 0)
            affine = CATransform3DRotate(affine, CGFloat(-asin(Double(percentage))), 0, -1, 0)
            content.viewController.view.layer.transform = affine
            
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
        case .right:
            var affine = CATransform3DMakeTranslation(-CGFloat(content.drawerWidth / 2), 0, 0)
            affine = CATransform3DRotate(affine, CGFloat(-asin(Double(percentage))), 0, -1, 0)
            content.viewController.view.layer.transform = affine
            
            content.contentView.transform = CGAffineTransform.identity
            content.contentView.frame = CGRect(
                x: viewRect.width * percentage + content.drawerOffset,
                y: viewRect.minY,
                width: CGFloat(content.drawerWidth),
                height: content.contentView.frame.height
            )
            
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
