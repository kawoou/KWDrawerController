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

open class DrawerCubicEaseAnimator: DrawerTickAnimator {

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
