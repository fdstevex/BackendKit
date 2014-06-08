//
//  BEKAccountTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKAccountTableViewController.h"

@interface BEKAccountTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@end

@implementation BEKAccountTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = self.loginController.backgroundColor;
    self.logoImage.image = self.loginController.logoImage;

    if (self.loginController.privacyPolicyURL == nil) {
        self.privacyPolicyButton.hidden = YES;
    }
}

- (IBAction)didTapPrivacyPolicy:(id)sender
{
    [self.loginController showPrivacyPolicy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destination = segue.destinationViewController;
    if ([destination isKindOfClass:[UINavigationController class]]) {
        destination = ((UINavigationController *)destination).viewControllers.firstObject;
    }
    if ([destination respondsToSelector:@selector(setLoginController:)]) {
        [(id)destination setLoginController:self.loginController];
    }
}

@end
