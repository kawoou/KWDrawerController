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

internal class TranslucentView: UIView {
    
    // MARK: - Property
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var rect = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height)
            
            if effectView.frame.width > rect.width {
                rect.size.width = effectView.frame.width
            }
            if effectView.frame.height > rect.height {
                rect.size.height = effectView.frame.height
            }
            
            effectView.frame = rect
            super.frame = newValue
            translucentView.frame = bounds
        }
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            var rect = CGRect(x: 0, y: 0, width: newValue.width, height: newValue.height)
            
            if effectView.bounds.width > rect.width {
                rect.size.width = effectView.bounds.width
            }
            if effectView.bounds.height > rect.height {
                rect.size.height = effectView.bounds.height
            }
            
            effectView.bounds = rect
            super.bounds = newValue
            translucentView.frame = bounds
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            if isInitialize {
                return backgroundView.backgroundColor
            } else {
                return super.backgroundColor
            }
        }
        set(value) {
            if isInitialize {
                backgroundView.backgroundColor = value
                super.backgroundColor = UIColor.clear
            } else {
                super.backgroundColor = value
            }
        }
    }
    
    override var alpha: CGFloat {
        get {
            if isInitialize {
                return blurView.alpha
            } else {
                return super.alpha
            }
        }
        set(value) {
            if isInitialize {
                blurView.alpha = value
                super.alpha = 1.0
            } else {
                super.alpha = value
            }
        }
    }
    
    
    // MARK: - Internal
    
    private var isInitialize: Bool = false
    
    private var translucentView: UIView = UIView()
    private var effectView: UIView = UIView()
    private var backgroundView: UIView = UIView()
    
    private var blurView: UIView!
    
    
    // MARK: - Private
    
    private func initialize() {
        /// Golden-Path
        guard !isInitialize else { return }
        
        translucentView.frame = bounds
        translucentView.backgroundColor = .clear
        translucentView.clipsToBounds = true
        translucentView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        insertSubview(translucentView, at: 0)
        
        effectView.frame = bounds
        effectView.backgroundColor = .clear
        effectView.clipsToBounds = true
        effectView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        translucentView.addSubview(effectView)
        
        let rect = CGRect(x: 0, y: -1, width: bounds.width, height: bounds.height + 1)
        if let customBlurClass: AnyObject.Type = NSClassFromString("_UICustomBlurEffect") {
            let customBlurObject: NSObject.Type = customBlurClass as! NSObject.Type
            let blurEffect = customBlurObject.init() as! UIBlurEffect
            blurEffect.setValue(1.0, forKeyPath: "scale")
            blurEffect.setValue(CGFloat(25), forKeyPath: "blurRadius")
            
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.frame = rect
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            visualEffectView.alpha = alpha
            effectView.addSubview(visualEffectView)
            
            blurView = visualEffectView
        } else {
            let toolBar = UIToolbar(frame: rect)
            toolBar.barTintColor = UIColor(white: 0.8, alpha: 1.0)
            toolBar.barStyle = .black
            toolBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toolBar.alpha = alpha
            effectView.addSubview(toolBar)
            
            blurView = toolBar
        }
        super.alpha = 1.0
        
        backgroundView.frame = bounds
        backgroundView.backgroundColor = backgroundColor
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.addSubview(backgroundView)
        
        super.backgroundColor = UIColor.clear
        
        isInitialize = true
    }
    
    
    // MARK: - Lifecycle
    
    override var subviews: [UIView] {
        get {
            if isInitialize {
                var array = super.subviews
                array.remove(at: array.index(of: translucentView)!)
                return array
            } else {
                return super.subviews
            }
        }
    }
    
    override func sendSubview(toBack view: UIView) {
        if isInitialize {
            insertSubview(view, aboveSubview: translucentView)
        } else {
            super.sendSubview(toBack: view)
        }
    }
    
    override func insertSubview(_ view: UIView, at index: Int) {
        if isInitialize {
            super.insertSubview(view, at: index + 1)
        } else {
            super.insertSubview(view, at: index)
        }
    }
    
    override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
        if isInitialize {
            super.exchangeSubview(at: index1 + 1, withSubviewAt: index2 + 1)
        } else {
            super.exchangeSubview(at: index1, withSubviewAt: index2)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

}
