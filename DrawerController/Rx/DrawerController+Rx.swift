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

import RxCocoa
import RxSwift

// Taken from RxCococa until marked as public
func castOrThrow(_ resultType: DrawerSide.Type, _ object: Any) throws -> DrawerSide {
    let rawValue = try castOrThrow(Int.self, object)
    guard let returnValue = DrawerSide(rawValue: rawValue) else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

public extension DrawerController {
    public func openSide(_ side: DrawerSide) -> Completable {
        return .create { [weak self] completable -> Disposable in
            guard let ss = self else {
                completable(.error(RxCocoaError.unknown))
                return Disposables.create()
            }
            ss.openSide(side) {
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    public func closeSide() -> Completable {
        return .create { [weak self] completable -> Disposable in
            guard let ss = self else {
                completable(.error(RxCocoaError.unknown))
                return Disposables.create()
            }
            ss.closeSide() {
                completable(.completed)
            }
            return Disposables.create()
        }
    }
}

extension Reactive where Base: DrawerController {
    
    /**
     Reactive wrapper for `delegate`.
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy<DrawerController, DrawerControllerDelegate> {
        return RxDrawerControllerDelegateProxy.proxy(for: base)
    }
    
    public typealias AnimationPercent = (side: DrawerSide, percent: Float)
    public var didAnimation: ControlEvent<AnimationPercent> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidAnimation(drawerController:side:percentage:)))
            .map { a in
                return (
                    side: try castOrThrow(DrawerSide.self, a[1]),
                    percent: try castOrThrow(Float.self, a[2])
                )
            }
        
        return ControlEvent(events: source)
    }
    public var didBeganAnimation: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidBeganAnimation(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var willFinishAnimation: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerWillFinishAnimation(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var willCancelAnimation: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerWillCancelAnimation(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var didFinishAnimation: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidFinishAnimation(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var didCancelAnimation: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidCancelAnimation(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var willOpenSide: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerWillOpenSide(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var willCloseSide: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerWillCloseSide(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var didOpenSide: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidOpenSide(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }
        
        return ControlEvent(events: source)
    }
    public var didCloseSide: ControlEvent<DrawerSide> {
        let source = delegate
            .methodInvoked(#selector(DrawerControllerDelegate.drawerDidCloseSide(drawerController:side:)))
            .map { try castOrThrow(DrawerSide.self, $0[1]) }

        return ControlEvent(events: source)
    }
}
