//
//  DrawerAnimator.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 8..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

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
    
}
