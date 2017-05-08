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
    
    static let FrameRate: Double = 1.0 / 60.0
    
    
    // MARK: - Property
    
    public var isTicked: Bool { return false }
    
    
    // MARK: - Internal
    
    private var startTime: TimeInterval = 0.0
    private var durationTime: TimeInterval = 0.0
    private var animationClosure: ((Float)->())?
    private var completionClosure: ((Bool)->())?
    
    private var displayLink: CADisplayLink?
    
    
    // MARK: - Public
    
    public func animate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {
        
    }
    
    public func tick(delta: TimeInterval, duration: TimeInterval, animations: @escaping (Float)->()) {
        
    }
    
    
    // MARK: - Private
    
    internal func doAnimate(duration: TimeInterval, animations: @escaping (Float)->(), completion: @escaping ((Bool)->())) {
        if !self.isTicked {
            
            self.animate(duration: duration, animations: animations, completion: completion)
            
        } else {
            
            if let display = self.displayLink {
                display.invalidate()
                self.displayLink = nil
            }
            
            self.startTime = CACurrentMediaTime()
            self.durationTime = duration
            self.animationClosure = animations
            self.completionClosure = completion
            
            self.displayLink = CADisplayLink(target: self, selector: #selector(render))
            self.displayLink!.add(to: .current, forMode: .defaultRunLoopMode)
        }
    }
    
    @objc
    private func render() {
        
        guard let display = self.displayLink else { return }
        
        let delta = CACurrentMediaTime() - self.startTime
        
        if delta > self.durationTime {
            self.tick(delta: self.durationTime, duration: self.durationTime, animations: self.animationClosure!)
            self.completionClosure!(true)
            
            display.invalidate()
            self.displayLink = nil
        } else {
            self.tick(delta: delta, duration: self.durationTime, animations: self.animationClosure!)
        }
    }
    
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
}