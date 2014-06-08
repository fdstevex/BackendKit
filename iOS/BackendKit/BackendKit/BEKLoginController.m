//
//  BEKLoginController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKLoginController.h"
#import "BEKAccountTableViewController.h"
#import "BEKExistingAccountTableViewController.h"
#import "BEKWebServiceProtocol.h"
#import "SSKeychain.h"

@interface BEKLoginController()
@end

@implementation BEKLoginController

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UIStoryboard *)storyboard
{
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"BackendKitResources" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BackendKit" bundle:resourceBundle];
    return storyboard;
}

- (void)loginWithNavigationController:(UINavigationController *)navigationController
{
    [self prepareViewController];
    [navigationController pushViewController:self.viewController animated:NO];
}

- (void)prepareViewController
{
    NSString *account = [self loggedInWithEmail];
    if (account == nil) {
        BEKAccountTableViewController *accountTableViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"account"];
        accountTableViewController.loginController = self;
        self.viewController = accountTableViewController;
    } else {
        BEKExistingAccountTableViewController *accountTableViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"existingAccount"];
        accountTableViewController.loginController = self;
        self.viewController = accountTableViewController;
    }
}

- (void)showPrivacyPolicy
{
    if (self.privacyPolicyURL) {
        [[UIApplication sharedApplication] openURL:self.privacyPolicyURL];
    }
}

- (NSString *)loggedInWithEmail
{
    NSArray *accounts = [SSKeychain accountsForService:@"BackendKit"];
    NSDictionary *account = accounts.lastObject;
    return account[kSSKeychainAccountKey];
}

- (NSString *)authToken
{
    return [SSKeychain passwordForService:@"BackendKit"
                                  account:self.loggedInWithEmail];
}

- (void)refresh
{
    // Replace the view controller, since we may have switched from logged in to
    // not logged in (etc).
    UIViewController *current = self.viewController;
    
    [self prepareViewController];
    
    NSMutableArray *viewControllers = [current.navigationController.viewControllers mutableCopy];
    NSUInteger index = [viewControllers indexOfObject:current];
    if (index != NSNotFound) {
        [viewControllers replaceObjectAtIndex:index withObject:self.viewController];
        current.navigationController.viewControllers = viewControllers;
    }
}

- (BOOL)validatePassword:(NSString *)password message:(NSString **)message
{
    if (password.length < 5) {
        *message = NSLocalizedString(@"Password must be at least 5 characters.", nil);
        return NO;
    }
    
    return YES;
}

@end
