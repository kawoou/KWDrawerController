//
//  DrawerGestureSensitivity.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 4..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import Foundation

public enum DrawerGestureSensitivity {
    
    case custom(Float)
    case high
    case normal
    case low
    
    internal func sensitivity() -> Float {
        switch self {
        case .custom(let value): return value
        case .high: return 40.0
        case .normal: return 20.0
        case .low: return 5.0
        }
    }
    
}
