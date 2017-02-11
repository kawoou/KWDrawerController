KWDrawerController
==================

[![Pod Version](http://img.shields.io/cocoapods/v/KWDrawerController.svg?style=flat)](http://cocoadocs.org/docsets/KWDrawerController/)
[![Pod Platform](http://img.shields.io/cocoapods/p/KWDrawerController.svg?style=flat)](http://cocoadocs.org/docsets/KWDrawerController/)
[![Pod License](http://img.shields.io/cocoapods/l/KWDrawerController.svg?style=flat)](https://github.com/kawoou/KWDrawerController/blob/master/LICENSE)
![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)

Drawer view controller that easy to use!


Screenshot
----------

![KWDrawerController](https://dl.dropboxusercontent.com/u/65611701/KWDrawerViewController.gif)


Installation
------------

### CocoaPods (For iOS 8+ projects)

KWDrawerController is available on [CocoaPods](https://github.com/cocoapods/cocoapods). Add the following to your Podfile:

```ruby
pod 'KWDrawerController', '~> 3.0'
```


### CocoaSeeds (For iOS 7 projects)

I recommend you to try [CocoaSeeds](https://github.com/devxoul/CocoaSeeds), which uses source code instead of dynamic frameworks. Sample Seedfile:

```ruby
github 'kawoou/KWDrawerController', '3.0.0', :files => 'Carte/**.{swift}'
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

Transition은 Drawer를 움직이는 연출을 결정하는 모듈로 `DrawerTransition`를 상속받아 구현된다.

 - DrawerSlideTransition

 <Image>

 - ~DrawerScaleTransition~
 - DrawerParallaxTransition

 <Image>

 - DrawerFloatTransition

 <Image>

 > 해당 트랜지션을 사용하는 경우, Overflow Transition 또한 DrawerFloatTransition을 사용해야한다.

 - DrawerFoldTransition

 <Image>

 - DrawerSwingTransition

 <Image>

 - DrawerZoomTransition

 <Image>


### Overflow Transition

Overflow Transition은 Drawer의 오픈 범위를 넘어서서 Transition을 처리하려고 할 때 사용된다.

 - ~DrawerSlideTransition~
 - DrawerScaleTransition

 <Image>

 > DrawerSlideTransition, DrwaerParallaxTransition, DrawerFoldTransition, DrawerSwingTransition과 함께 사용할 경우 자연스럽다.
 
 - DrawerParallaxTransition

 <Image>

 - DrawerFloatTransition

 <Image>

 > 해당 트랜지션을 사용하는 경우, Transition 또한 DrawerFloatTransition을 사용해야한다.

 - ~DrawerFoldTransition~
 - ~DrawerSwingTransition~

 - DrawerZoomTransition

 <Image>


### Animator

Animator는 Drawer를 움직이는 속도를 제어하는 모듈로 `DrawerAnimator` 또는 `DrawerTickAnimator`를 상속받아 구현된다.

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


⚠️ Requirements
--------------

 - iOS 7.1+
 - Xcode 8.1+
 - Swift 3.0+


🔑 License
----------

KWDrawerController is under MIT license. See the LICENSE file for more info.
