//
//  BEKForgotPasswordTableViewController.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-30.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BEKLoginController;

@interface BEKForgotPasswordTableViewController : UITableViewController
@property (weak, nonatomic) BEKLoginController *loginController;
@property (strong, nonatomic) NSString *initialEmailAddress;
@end
