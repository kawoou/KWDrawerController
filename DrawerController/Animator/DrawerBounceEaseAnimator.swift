/*
The MIT License (MIT)

Copyright (c) 2017 Kawoou (Jungwon An)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

open class DrawerBounceEaseAnimator: DrawerTickAnimator {

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
    
    open var easeType: EaseType
    
    
    // MARK: - Public
    
    open override func tick(delta: TimeInterval, duration: TimeInterval, animations: @escaping (Float)->()) {
        animations(Float(easeType.algorithm(value: delta / duration)))
    }
    
    
    // MARK: - Lifecycle
    
    public init(easeType: EaseType = .easeInOut) {
        self.easeType = easeType
        
        super.init()
    }
    
}
