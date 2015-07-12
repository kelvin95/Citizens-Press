//
//  PhotoFeedAppDelegate.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-11.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "PhotoFeedAppDelegate.h"
#import "PhotoFeedViewController.h"
#import "PhotoFeedNavigationViewController.h"


@implementation PhotoFeedAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    PhotoFeedViewController *pfvc = [[PhotoFeedViewController alloc]init];
    UINavigationController *navController = [[PhotoFeedNavigationViewController alloc]initWithRootViewController:pfvc];
    [navController.navigationBar setBarTintColor:[UIColor colorWithRed:8/255. green:37/255. blue:103/255. alpha:1]];
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    navController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    //[navController.navigationBar setBackgroundColor:[UIColor blueColor]];
    //[navController.navigationBar setBackgroundColor:[UIColor colorWithRed:8/255. green:37/255. blue:103/255. alpha:1]];
    //navController.navigationBar.tintColor = [UIColor blackColor];
    
    
    self.window.rootViewController = navController;
    [self.window addSubview:self.window.rootViewController.view];
    
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
