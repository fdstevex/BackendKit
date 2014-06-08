//
//  BEKLoginTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKLoginTableViewController.h"
#import "BEKForgotPasswordTableViewController.h"
#import "BEKLoginUtils.h"
#import "BEKLoginController.h"
#import "BEKLoginService.h"
#import "BEKErrorDefines.h"
#import "SSKeychain.h"

@interface BEKLoginTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showHidePasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation BEKLoginTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showErrorMessage:nil];
    
    self.view.backgroundColor = self.loginController.backgroundColor;
    
    if (self.loginController.privacyPolicyURL == nil) {
        self.privacyPolicyButton.hidden = YES;
    }
}

- (IBAction)didTapCancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showErrorMessage:(NSString *)message
{
    self.errorLabel.text = message;
}

- (BOOL)validate
{
    if (![BEKLoginUtils isValidEmailAddress:self.emailTextField.text]) {
        [self showErrorMessage:NSLocalizedString(@"The email address is not valid.", nil)];
        return NO;
    }

    if (self.passwordTextField.text.length == 0) {
        [self showErrorMessage:NSLocalizedString(@"Please enter your password.", nil)];
        return NO;
    }

    
    [self showErrorMessage:nil];
    return YES;
}

- (void)performLogin
{
    if ([self validate]) {
        [self.loginController.service loginWithEmail:self.emailTextField.text
                                            password:self.passwordTextField.text
                                          completion:^(BOOL success, id result, NSError *error) {
                                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                  if (success) {
                                                      [self receivedAuthToken:result[BEKResponseAuthTokenKey]];
                                                      [self.loginController refresh];
                                                      [self.navigationController dismissViewControllerAnimated:YES
                                                                                                    completion:nil];
                                                  } else {
                                                      if ([error.domain isEqualToString:BEKErrorDomain] && error.code == 403) {
                                                          [self showErrorMessage:NSLocalizedString(@"Email or password is incorrect.", nil)];
                                                      } else {
                                                          [self showErrorMessage:NSLocalizedString(@"Unable to log in.", nil)];
                                                      }
                                                  }
                                              }];
                                          }];
    }
}

- (void)receivedAuthToken:(NSString *)authToken
{
    [SSKeychain setPassword:authToken
                 forService:@"BackendKit"
                    account:self.emailTextField.text];
}

- (IBAction)didTapPrivacyPolicy:(id)sender
{
    [self.loginController showPrivacyPolicy];
}

- (void)updateFromKeychain
{
    NSString *accountName = [self.loginController loggedInWithEmail];
    if (accountName != nil) {
        self.emailTextField.text = accountName;
    }
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
    if ([destination respondsToSelector:@selector(setInitialEmailAddress:)]) {
        [(id)destination setInitialEmailAddress:self.emailTextField.text];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performLogin];
}

@end
