//
//  BEKAppDelegate.m
//  LoginSample
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKAppDelegate.h"

@interface BEKAppDelegate()
@property (strong, nonatomic) BEKLoginController *loginController;
@end

@implementation BEKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.loginController = [[BEKLoginController alloc] init];
    self.loginController.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.02 brightness:0.95 alpha:1.0];
    self.loginController.logoImage = [UIImage imageNamed:@"cloud"];
    
    self.loginController.privacyPolicyURL = [NSURL URLWithString:@"http://www.google.com"];
    self.loginController.service = [[BEKWebServiceClient alloc] initWithAPIURL:[NSURL URLWithString:@"http://localhost/~stevex/BackendKit/public/api"]];

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    self.window.rootViewController = navigationController;
    [self.loginController loginWithNavigationController:navigationController];
    
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
