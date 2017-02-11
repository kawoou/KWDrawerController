//
//  DrawerCurveEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerCurveEaseAnimator: DrawerAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
        
        internal func option() -> UIViewAnimationOptions {
            switch self {
            case .linear: return .curveLinear
            case .easeIn: return .curveEaseIn
            case .easeOut: return .curveEaseOut
            case .easeInOut: return .curveEaseInOut
            }
        }
    }
    
    
    // MARK: - Property
    
    public var easeType: EaseType
    
    
    // MARK: - Public
    
    public override func animate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: self.easeType.option(), animations: {
            animations(1.0)
        }, completion: completion)
        
    }
    
    
    // MARK: - Lifecycle
    
    init(easeType: EaseType = .easeInOut) {
        self.easeType = easeType
        
        super.init()
    }
    
}
