//
//  DrawerCubicEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerCubicEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                return pow(value, 3)
            case .easeOut:
                return pow(value - 1, 3) + 1
            case .easeInOut:
                if value < 0.5 {
                    return 4 * pow(value, 3)
                } else {
                    return 0.5 * pow((2 * value) - 2, 3) + 1
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
