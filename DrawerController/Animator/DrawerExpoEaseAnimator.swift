//
//  DrawerExpoEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerExpoEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                return (value == 0.0) ? value : pow(2, 10 * (value - 1))
            case .easeOut:
                return (value == 1.0) ? value : 1 - pow(2, -10 * value)
            case .easeInOut:
                if value == 0.0 || value == 1.0 { return value }
                
                if value < 0.5 {
                    return 0.5 * pow(2, (20 * value) - 10)
                } else {
                    return -0.5 * pow(2, (-20 * value) + 10) + 1
                }
            }
        }
    }
    
    
    // MARK: - Property
    
    public var easeType: EaseType
    
    
    // MARK: - Public
    
    public override func tick(delta: TimeInterval, duration: TimeInterval, animations: @escaping (Float)->()) {
        
        animations(Float(self.easeType.algorithm(value: delta / duration)))
        
    }
    
    
    // MARK: - Lifecycle
    
    init(easeType: EaseType = .easeInOut) {
        self.easeType = easeType
        
        super.init()
    }
    
}
