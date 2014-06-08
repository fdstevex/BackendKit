//
//  BEKLoginTableViewController.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BEKLoginController;

@interface BEKLoginTableViewController : UITableViewController
@property (strong, nonatomic) BEKLoginController *loginController;
@end
