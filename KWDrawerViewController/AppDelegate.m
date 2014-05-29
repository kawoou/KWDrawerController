//
//  AppDelegate.m
//  KWDrawerViewController
//
//  Created by Kawoou on 2014. 5. 29..
//  Copyright (c) 2014년 Kawoou. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    KWDrawerViewController *drawerViewController = [[KWDrawerViewController alloc] init];
    UIViewController *leftViewController = [[LeftViewController alloc] init];
    UIViewController *rightViewController = [[RightViewController alloc] init];
    UIViewController *mainViewController = [[MainViewController alloc] init];
    
    [drawerViewController setMainViewController:mainViewController];
    [drawerViewController setLeftDrawerViewController:leftViewController];
    [drawerViewController setRightDrawerViewController:rightViewController];
    [drawerViewController setDelegate:self];
    
    [self.window setRootViewController:drawerViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark KWDrawerViewControllerDelegate

- (void)drawerViewController:(KWDrawerViewController *)drawerViewController didAnimationMainViewController:(UIViewController *)viewController withPercentage:(CGFloat)percentage
{
    if(percentage >= 0.0f)
    {
        viewController.view.transform = CGAffineTransformIdentity;
        viewController.view.frame = CGRectMake(0,
                                               0,
                                               viewController.view.superview.frame.size.width,
                                               viewController.view.superview.frame.size.height);
        
        CGAffineTransform affine;
        affine = CGAffineTransformMakeTranslation((-viewController.view.superview.frame.size.width + 120) * (1.0f - percentage) * (percentage > 1.0f ? 0.5f : 1.0f), 0);
        affine = CGAffineTransformScale(affine, percentage > 1.0f ? percentage : 1.0f, 1.0f);
        drawerViewController.leftDrawerViewController.view.transform = affine;
        
        [drawerViewController.view bringSubviewToFront:drawerViewController.leftDrawerViewController.view];
    }
    
    if(percentage <= 0.0f)
    {
        CGFloat newPercentage = 1.0f + percentage * 0.2875f;
        viewController.view.transform = CGAffineTransformMakeScale(newPercentage, newPercentage);
        viewController.view.frame = CGRectMake(newPercentage * percentage * 236.0f,
                                               viewController.view.frame.origin.y,
                                               viewController.view.frame.size.width,
                                               viewController.view.frame.size.height);
        
        drawerViewController.rightDrawerViewController.view.transform = CGAffineTransformMakeScale(1.5 + 0.5 * percentage, 1.5 + 0.5 * percentage);
        drawerViewController.rightDrawerViewController.view.alpha = -percentage;
    }
}

@end
