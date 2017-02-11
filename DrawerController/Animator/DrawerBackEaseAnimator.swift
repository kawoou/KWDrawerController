//
//  DrawerBackEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerBackEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                return pow(value, 3) - value * sin(value * M_PI)
            case .easeOut:
                let newValue = 1 - value
                return 1 - (pow(newValue, 3) - newValue * sin(newValue * M_PI))
            case .easeInOut:
                if value < 0.5 {
                    let newValue = 2 * value
                    return 0.5 * (pow(newValue, 3) - newValue * sin(newValue * M_PI))
                } else {
                    let newValue = (1 - (2 * value - 1))
                    return 0.5 * (1 - (pow(newValue, 3) - newValue * sin(newValue * M_PI))) + 0.5
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
