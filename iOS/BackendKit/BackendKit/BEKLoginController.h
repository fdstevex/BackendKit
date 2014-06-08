//
//  BEKLoginController.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import "BEKWebServiceProtocol.h"

@interface BEKLoginController : NSObject

@property (strong, nonatomic) NSURL *privacyPolicyURL;
@property (strong, nonatomic) id<BEKWebServiceProtocol> service;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIImage *logoImage;

// This will be either an BEKAccountTableViewController if the user is not logged in,
// or an BEKExistingAccountTableViewController if the user is logged in.
@property (strong, nonatomic) UIViewController *viewController;

@property (readonly) NSString *authToken;

- (void)loginWithNavigationController:(UINavigationController *)navigationController;

- (void)showPrivacyPolicy;

- (NSString *)loggedInWithEmail;

- (void)refresh;

- (BOOL)validatePassword:(NSString *)passsword message:(NSString **)message;

@end
