//
//  DrawerElasticEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerElasticEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                return sin(13 * M_PI_2 * value) * pow(2, 10 * (value - 1))
            case .easeOut:
                return sin(-13 * M_PI_2 * (value + 1)) * pow(2, -10 * value) + 1
            case .easeInOut:
                if value < 0.5 {
                    return 0.5 * sin(13 * M_PI_2 * (2 * value)) * pow(2, 10 * ((2 * value) - 1))
                } else {
                    return 0.5 * (sin(-13 * M_PI_2 * ((2 * value - 1) + 1)) * pow(2, -10 * (2 * value - 1)) + 2)
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
