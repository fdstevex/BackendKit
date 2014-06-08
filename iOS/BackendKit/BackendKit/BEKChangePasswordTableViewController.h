//
//  BEKChangePasswordTableViewController.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-06-01.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEKLoginController.h"

@interface BEKChangePasswordTableViewController : UITableViewController
@property (weak, nonatomic) BEKLoginController *loginController;
@end
