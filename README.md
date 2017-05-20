KWDrawerController
==================

[![Pod Version](http://img.shields.io/cocoapods/v/KWDrawerController.svg?style=flat)](http://cocoadocs.org/docsets/KWDrawerController/3.5)
[![Pod Platform](http://img.shields.io/cocoapods/p/KWDrawerController.svg?style=flat)](http://cocoadocs.org/docsets/KWDrawerController/3.5)
[![Pod License](http://img.shields.io/cocoapods/l/KWDrawerController.svg?style=flat)](https://github.com/kawoou/KWDrawerController/blob/master/LICENSE)
![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)

Drawer view controller that easy to use!


Installation
------------

### CocoaPods (For iOS 8+ projects)

KWDrawerController is available on [CocoaPods](https://github.com/cocoapods/cocoapods). Add the following to your Podfile:

```ruby
pod 'KWDrawerController', '~> 3.5'
```


### Manually

You can either simply drag and drop the `DrawerController` folder into your existing project.


Usage
-----

### Code

```swift
import UIKit

import KWDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let mainViewController   = MainViewController()
        let leftViewController   = LeftViewController()
        let rightViewController  = RightViewController()
        
        let drawerController     = DrawerController()

        drawerController.setViewController(mainViewController, .none)
        drawerController.setViewController(leftViewController, .left)
        drawerController.setViewController(rightViewController, .right)

        /// Customizing

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()

        return true
    }
}
```


### Storyboard

![Storyboard](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/storyboard.jpg)

 1. Set the KWDrawerController to Custom Class of Initial ViewController.

 2. Connects the `DrawerEmbedLeftControllerSegue` or `DrawerEmbedRightControllerSegue` to UIViewController from `KWDrawerController`

 3. Connects the `DrawerEmbedMainControllerSegue` to UIViewController from `KWDrawerController`

 4. Set the SegueIdentifiers to inspector of `KWDrawerController`.


### Open / Close

```swift
/// Open
self.drawerController?.openSide(.left)
self.drawerController?.openSide(.right)

/// Close
self.drawerController?.closeSide()
```


### Delegate

```swift
optional func drawerDidAnimation(
    drawerController: DrawerController,
    side: DrawerSide,
    percentage: Float
)

optional func drawerDidBeganAnimation(
    drawerController: DrawerController,
    side: DrawerSide
)

optional func drawerWillFinishAnimation(
    drawerController: DrawerController,
    side: DrawerSide
)

optional func drawerWillCancelAnimation(
    drawerController: DrawerController,
    side: DrawerSide
)

optional func drawerDidFinishAnimation(
    drawerController: DrawerController,
    side: DrawerSide
)

optional func drawerDidCancelAnimation(
    drawerController: DrawerController,
    side: DrawerSide
)
```


Customizing
-----------

### Transition

`DrawerTransition` is a module that determines the rendering direction to move the Drawer. It is implemented by inheriting `DrawerTransition`.

 - DrawerSlideTransition

![DrawerSlideTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/slide.gif)

 - DrawerScaleTransition
	 - Use is not recommended.
 - DrawerParallaxTransition

![DrawerParallaxTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/parallax.gif)

 - DrawerFloatTransition
    - When using the `Transition`, `Overflow Transition` should also use `DrawerFloatTransition`.

![DrawerFloatTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/float.gif)

 - DrawerFoldTransition

![DrawerFoldTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/fold.gif)

 - DrawerSwingTransition

![DrawerSwingTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/swing.gif)

 - DrawerZoomTransition

![DrawerZoomTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/zoom.gif)


### Overflow Transition

`Overflow Transition` be used when `Transition` beyond the open range of the drawer.

 - DrawerSlideTransition
 - DrawerScaleTransition
    - This is natural when used with `DrawerSlideTransition`, `DrwaerParallaxTransition`, `DrawerFoldTransition`, and `DrawerSwingTransition`.

![DrawerScaleTransition](https://github.com/Kawoou/KWDrawerController/raw/develop/Preview/scale.gif)
    
 - DrawerParallaxTransition
 - DrawerFloatTransition
	 - When using the `Overflow Transition`, `Transition` should also use `DrawerFloatTransition`.
 - DrawerFoldTransition
	 - Use is not recommended.
 - DrawerSwingTransition
	 - Use is not recommended.
 - DrawerZoomTransition


### Animator

Animator is a module that controls the speed of moving a drawer. It is implemented by inheriting `DrawerAnimator` or `DrawerTickAnimator`.

 - DrawerLinearAnimator
 - DrawerCurveEaseAnimator
 - DrawerSpringAnimator
 - DrawerCubicEaseAnimator
 - DrawerQuadEaseAnimator
 - DrawerQuartEaseAnimator
 - DrawerQuintEaseAnimator
 - DrawerCircEaseAnimator
 - DrawerExpoEaseAnimator
 - DrawerSineEaseAnimator
 - DrawerElasticEaseAnimator
 - DrawerBackEaseAnimator
 - DrawerBounceEaseAnimator


### Options

```swift
public var isTapToClose: Bool
public var isGesture: Bool
public var isAnimation: Bool
public var isOverflowAnimation: Bool
public var isShadow: Bool
public var isFadeScreen: Bool
public var isBlur: Bool
public var isEnable: Bool
```


Changelog
---------

+ 1.0 First Release.
+ 1.1 Bug Fix, Add animations.
+ 2.0 Refactoring.
+ 2.1 Bug Fix, Update animation.
+ 2.2 Fix animation, and some bugs.
+ 3.0 Written in Swift 3.0
+ 3.1 Fix Access Control issues on DrawerController.
+ 3.2 Fix Access Control issues on Transition.
+ 3.3 Fix Access Control issues on initializer.
+ 3.4 Remove debug log.
+ 3.5 Fixed bug where touch ignores is not applied for "Absolute Controller".

⚠️ Requirements
--------------

 - iOS 7.1+
 - Xcode 8.1+
 - Swift 3.0+


🔑 License
----------

KWDrawerController is under MIT license. See the LICENSE file for more info.
