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

open class DrawerParallaxTransition: DrawerTransition {

    // MARK: - Property
    
    open var parallaxFactor: Float
    
    
    // MARK: - Public
    
    open override func initTransition(content: DrawerContent) {
        super.initTransition(content: content)
        
        content.isBringToFront = false
    }
    
    open override func startTransition(content: DrawerContent, side: DrawerSide) {
        super.startTransition(content: content, side: side)
    }
    
    open override func endTransition(content: DrawerContent, side: DrawerSide) {
        super.endTransition(content: content, side: side)
    }
    
    open override func transition(content: DrawerContent, side: DrawerSide, percentage: CGFloat, viewRect: CGRect) {
        
        let newPercentage = content.drawerSide == .none ? percentage : CGFloat(Float(percentage) / parallaxFactor)
        
        content.contentView.transform = .identity
        content.contentView.frame = CGRect(
            x: viewRect.width * newPercentage + content.drawerOffset,
            y: viewRect.minY,
            width: CGFloat(content.drawerWidth),
            height: content.contentView.frame.height
        )
        
    }
    
    
    // MARK: - Lifecycle
    
    public init(parallaxFactor: Float = 2.0) {
        self.parallaxFactor = parallaxFactor
        
        super.init()
    }
    
}
