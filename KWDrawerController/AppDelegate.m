//
//  AppDelegate.m
//  KWDrawerController
//
//  Created by Kawoou on 2014. 6. 1..
//  Copyright (c) 2014년 Kawoou. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

#import "KWDrawerFloatingAnimation.h"
#import "KWDrawerFullSizeSlideAnimation.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    KWDrawerController *drawerController = [[KWDrawerController alloc] init];
    UIViewController *leftViewController = [[LeftViewController alloc] init];
    UIViewController *rightViewController = [[RightViewController alloc] init];
    UIViewController *mainViewController = [[MainViewController alloc] init];
    
    [drawerController setDefaultAnimation:[KWDrawerFloatingAnimation sharedInstance] inDrawerSide:KWDrawerSideLeft];
    [drawerController setDefaultAnimation:[KWDrawerFullSizeSlideAnimation sharedInstance] inDrawerSide:KWDrawerSideRight];
    [drawerController setOverflowAnimation:[KWDrawerFullSizeSlideAnimation sharedInstance] inDrawerSide:KWDrawerSideRight];
    
    [drawerController setViewController:mainViewController inDrawerSide:KWDrawerSideNone];
    [drawerController setViewController:leftViewController inDrawerSide:KWDrawerSideLeft];
    [drawerController setViewController:rightViewController inDrawerSide:KWDrawerSideRight];
    [drawerController setMaximumWidth:280.0f inDrawerSide:KWDrawerSideRight animated:NO];
    
    [self.window setBackgroundColor:[UIColor yellowColor]];
    [self.window setRootViewController:drawerController];
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

@end
