//
//  UIViewController+DrawerController.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 4..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIViewController {
    
    private struct AssociatedKeys {
        static var drawerController = "drawerController"
    }
    
    var drawerController: DrawerController? {
        get {
            guard let controller = objc_getAssociatedObject(self, &AssociatedKeys.drawerController) as? DrawerController else {
                return parent?.drawerController
            }
            return controller
        }
        
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.drawerController, value, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    open override class func initialize() {
        guard self === UIViewController.self else { return }
        
        let originalSelector = #selector(viewDidLayoutSubviews)
        let swizzledSelector = #selector(xxx_viewDidLayoutSubviews)
        swizzling(self, originalSelector, swizzledSelector)
    }
    
    
    // MARK: - Method Swizzling
    
    func xxx_viewDidLayoutSubviews(animated: Bool) {
        self.xxx_viewDidLayoutSubviews(animated: animated)
    }
    
}
