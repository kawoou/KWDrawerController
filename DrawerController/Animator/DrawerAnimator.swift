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

open class DrawerAnimator {
    
    // MARK: - Define
    
    internal static let FrameRate: Double = 1.0 / 60.0
    
    
    // MARK: - Property
    
    open var isTicked: Bool { return false }
    
    
    // MARK: - Internal
    
    private var startTime: TimeInterval = 0.0
    private var durationTime: TimeInterval = 0.0
    private var animationClosure: ((Float)->())?
    private var completionClosure: ((Bool)->())?
    
    private var displayLink: CADisplayLink?
    
    
    // MARK: - Public
    
    open func animate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {}
    
    open func tick(delta: TimeInterval, duration: TimeInterval, animations: @escaping (Float)->()) {}
    
    
    // MARK: - Private
    
    internal func doAnimate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {
        guard isTicked else {
            animate(duration: duration, animations: animations, completion: completion)
            return
        }
        
        if let display = displayLink {
            display.invalidate()
            displayLink = nil
        }
        
        startTime = CACurrentMediaTime()
        durationTime = duration
        animationClosure = animations
        completionClosure = completion
        
        displayLink = { [unowned self] in
            let displayLink = CADisplayLink(target: self, selector: #selector(render))
            displayLink.add(to: .current, forMode: .defaultRunLoopMode)
            return displayLink
        }()
    }
    
    @objc
    private func render() {
        guard let display = displayLink, let animationClosure = animationClosure else { return }
        
        let delta = CACurrentMediaTime() - startTime
        
        if delta > durationTime {
            tick(delta: durationTime, duration: durationTime, animations: animationClosure)
            completionClosure!(true)
            
            display.invalidate()
            displayLink = nil
        } else {
            tick(delta: delta, duration: durationTime, animations: animationClosure)
        }
    }
    
    
    // MARK: - Lifecycle
    
    public init() {}
    
}
