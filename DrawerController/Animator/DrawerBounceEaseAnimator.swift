//
//  DrawerBounceEaseAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerBounceEaseAnimator: DrawerTickAnimator {

    // MARK: - Enum
    
    public enum EaseType {
        case easeIn
        case easeOut
        case easeInOut
        
        internal func algorithm(value: Double) -> Double {
            switch self {
            case .easeIn:
                let outEase: EaseType = .easeOut
                
                return 1 - outEase.algorithm(value: 1 - value)
            case .easeOut:
                if value < 4 / 11.0 {
                    return (121 * value * value) / 16.0
                } else if value < 8 / 11.0 {
                    return (363 / 40.0 * value * value) - (99 / 10.0 * value) + 17 / 5.0
                } else if value < 9 / 10.0 {
                    return (4356 / 361.0 * value * value) - (35442 / 1805.0 * value) + 16061 / 1805.0
                } else {
                    return (54 / 5.0 * value * value) - (513 / 25.0 * value) + 268 / 25.0
                }
            case .easeInOut:
                let inEase: EaseType = .easeIn
                let outEase: EaseType = .easeOut
                
                if value < 0.5 {
                    return 0.5 * inEase.algorithm(value: value * 2)
                } else {
                    return 0.5 * outEase.algorithm(value: value * 2 - 1) + 0.5
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
