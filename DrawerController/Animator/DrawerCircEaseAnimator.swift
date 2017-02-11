//
//  DrawerCircEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerCircEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                return 1 - sqrt(1 - (value * value))
            case .easeOut:
                return sqrt((2 - value) * value)
            case .easeInOut:
                if value < 0.5 {
                    return 0.5 * (1 - sqrt(1 - 4 * (value * value)))
                } else {
                    return 0.5 * (sqrt(-((2 * value) - 3) * ((2 * value) - 1)) + 1)
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
