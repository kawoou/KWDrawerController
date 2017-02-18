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
        set(value) {
            if #available(iOS 7.0, *) {
                var rect = CGRect(x: 0, y: 0, width: value.width, height: value.height)
                
                if self.effectView.frame.width > rect.width {
                    rect.size.width = self.effectView.frame.width
                }
                if self.effectView.frame.height > rect.height {
                    rect.size.height = self.effectView.frame.height
                }
                
                self.effectView.frame = rect
                super.frame = value
                self.translucentView.frame = self.bounds
                
            } else {
                super.frame = value
            }
        }
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set(value) {
            if #available(iOS 7.0, *) {
                var rect = CGRect(x: 0, y: 0, width: value.width, height: value.height)
                
                if self.effectView.bounds.width > rect.width {
                    rect.size.width = self.effectView.bounds.width
                }
                if self.effectView.bounds.height > rect.height {
                    rect.size.height = self.effectView.bounds.height
                }
                
                self.effectView.bounds = rect
                super.bounds = value
                self.translucentView.frame = self.bounds
            } else {
                super.bounds = value
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            if self.isInitialize {
                return self.backgroundView.backgroundColor
            } else {
                return super.backgroundColor
            }
        }
        set(value) {
            if self.isInitialize {
                self.backgroundView.backgroundColor = value
                super.backgroundColor = UIColor.clear
            } else {
                super.backgroundColor = value
            }
        }
    }
    
    override var alpha: CGFloat {
        get {
            if self.isInitialize {
                if #available(iOS 8.0, *) {
                    return super.alpha
                } else {
                    return self.blurView!.alpha
                }
            } else {
                return super.alpha
            }
        }
        set(value) {
            if self.isInitialize {
                if #available(iOS 8.0, *) {
                    super.alpha = value
                } else {
                    self.blurView!.alpha = value
                    super.alpha = 1.0
                }
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
    
    private var blurView: UIView?
    
    
    // MARK: - Private
    
    private func initialize() {
        
        /// Golden-Path
        guard #available(iOS 7.0, *) else { return }
        guard !self.isInitialize else { return }
        
        self.translucentView.frame = self.bounds
        self.translucentView.backgroundColor = UIColor.clear
        self.translucentView.clipsToBounds = true
        self.translucentView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        self.insertSubview(self.translucentView, at: 0)
        
        self.effectView.frame = self.bounds
        self.effectView.backgroundColor = UIColor.clear
        self.effectView.clipsToBounds = true
        self.effectView.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        self.translucentView.addSubview(effectView)
        
        let rect = CGRect(x: 0, y: -1, width: self.bounds.width, height: self.bounds.height + 1)
        if #available(iOS 8.0, *) {
            if let customBlurClass: AnyObject.Type = NSClassFromString("_UICustomBlurEffect") {
                let customBlurObject: NSObject.Type = customBlurClass as! NSObject.Type
                let blurEffect = customBlurObject.init() as! UIBlurEffect
                blurEffect.setValue(1.0, forKeyPath: "scale")
                blurEffect.setValue(CGFloat(25), forKeyPath: "blurRadius")
                
                let visualEffectView = UIVisualEffectView(effect: blurEffect)
                visualEffectView.frame = rect
                visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                visualEffectView.alpha = self.alpha
                self.effectView.addSubview(visualEffectView)
                
                self.blurView = visualEffectView
            } else {
                let toolbar = UIToolbar(frame: rect)
                toolbar.barTintColor = UIColor(white: 0.8, alpha: 1.0)
                toolbar.barStyle = .black
                toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                toolbar.alpha = self.alpha
                self.effectView.addSubview(toolbar)
                
                self.blurView = toolbar
            }
        } else {
            let toolbar = UIToolbar(frame: rect)
            toolbar.barTintColor = UIColor(white: 0.8, alpha: 1.0)
            toolbar.barStyle = .black
            toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toolbar.alpha = self.alpha
            self.effectView.addSubview(toolbar)
            
            self.blurView = toolbar
        }
        super.alpha = 1.0
        
        self.backgroundView.frame = self.bounds
        self.backgroundView.backgroundColor = self.backgroundColor
        self.backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.effectView.addSubview(self.backgroundView)
        
        super.backgroundColor = UIColor.clear
        
        self.isInitialize = true
    }
    
    
    // MARK: - Lifecycle
    
    override var subviews: [UIView] {
        get {
            if self.isInitialize {
                var array = super.subviews
                array.remove(at: array.index(of: self.translucentView)!)
                return array
            } else {
                return super.subviews
            }
        }
    }
    
    override func sendSubview(toBack view: UIView) {
        if self.isInitialize {
            self.insertSubview(view, aboveSubview: self.translucentView)
        } else {
            super.sendSubview(toBack: view)
        }
    }
    
    override func insertSubview(_ view: UIView, at index: Int) {
        if self.isInitialize {
            super.insertSubview(view, at: index + 1)
        } else {
            super.insertSubview(view, at: index)
        }
    }
    
    override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
        if self.isInitialize {
            super.exchangeSubview(at: index1 + 1, withSubviewAt: index2 + 1)
        } else {
            super.exchangeSubview(at: index1, withSubviewAt: index2)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }

}
