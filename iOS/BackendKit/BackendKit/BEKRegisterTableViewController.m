//
//  BEKRegisterTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKRegisterTableViewController.h"
#import "BEKBorderedTableViewCell.h"
#import "BEKLoginController.h"
#import "BEKLoginService.h"
#import "BEKLoginUtils.h"
#import "BEKErrorDefines.h"

@interface BEKRegisterTableViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet BEKBorderedTableViewCell *registerCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@end

@implementation BEKRegisterTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = self.loginController.backgroundColor;

    self.errorLabel.text = nil;
    
    if (self.loginController.privacyPolicyURL == nil) {
        self.privacyPolicyButton.hidden = YES;
    }
}

- (IBAction)didTapCancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapPrivacyPolicy:(id)sender
{
    [self.loginController showPrivacyPolicy];
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
    
    NSString *message;
    if (![self.loginController validatePassword:self.passwordTextField.text message:&message]) {
        [self showErrorMessage:message];
        return NO;
    }
    
    if (self.passwordTextField.text.length == 0) {
        [self showErrorMessage:NSLocalizedString(@"Please enter your password.", nil)];
        return NO;
    }
    
    
    [self showErrorMessage:nil];
    return YES;
}

- (void)performRegister
{
    if ([self validate]) {
        [self.loginController.service registerWithEmail:self.emailTextField.text
                                               password:self.passwordTextField.text
                                                  extra:nil
                                             completion:^(BOOL success, id result, NSError *error) {
                                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                     [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                                     
                                                     if (success) {
                                                         // The response at this point may be that we are logged in, that
                                                         // the account could not be created, email verification is required,
                                                         // or perhaps some other error.
                                                         NSString *authToken = result[BEKResponseAuthTokenKey];
                                                         if (authToken.length > 0) {
                                                             [self receivedAuthToken:authToken];
                                                             [self.loginController refresh];
                                                             [self.navigationController dismissViewControllerAnimated:YES
                                                                                                           completion:nil];
                                                         }
                                                     } else {
                                                         if ([error.domain isEqualToString:BEKErrorDomain]) {
                                                             if (error.code == BEKErrorEmailAlreadyRegistered)
                                                                 [self showErrorMessage:NSLocalizedString(@"Email address is already registered", nil)];
                                                         } else {
                                                              [self showErrorMessage:@"Unable to create account."];
                                                         }
                                                    }
                                              }];
                                          }];
    } else {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)receivedAuthToken:(NSString *)authToken
{
    [SSKeychain setPassword:authToken
                 forService:@"BackendKit"
                    account:self.emailTextField.text];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.registerCell) {
        [self performRegister];
    }
}
@end
