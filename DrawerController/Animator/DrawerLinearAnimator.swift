//
//  DrawerLinearAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerLinearAnimator: DrawerAnimator {

    // MARK: - Public
    
    public override func animate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            animations(1.0)
        }, completion: completion)
        
    }
    
}
