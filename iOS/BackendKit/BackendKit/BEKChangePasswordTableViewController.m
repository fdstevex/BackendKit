//
//  BEKChangePasswordTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-06-01.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKChangePasswordTableViewController.h"
#import "BEKBorderedTableViewCell.h"
#import "BEKLoginService.h"
#import "BEKErrorDefines.h"

@interface BEKChangePasswordTableViewController ()
@property (weak, nonatomic) IBOutlet BEKBorderedTableViewCell *changePasswordCell;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation BEKChangePasswordTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = self.loginController.backgroundColor;

    [self showErrorMessage:nil];
}

- (void)showErrorMessage:(NSString *)message
{
    self.errorLabel.text = message;
}

- (IBAction)didTapCancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validate
{
    if (self.currentPasswordTextField.text.length == 0) {
        [self showErrorMessage:NSLocalizedString(@"Type your current password", nil)];
        return NO;
    }

    if (self.passwordTextField.text.length == 0) {
        [self showErrorMessage:NSLocalizedString(@"Type your new password", nil)];
        return NO;
    }

    NSString *message = nil;
    if (![self.loginController validatePassword:self.passwordTextField.text message:&message]) {
        [self showErrorMessage:message];
        return NO;
    }
    
    [self showErrorMessage:nil];
    return YES;
}

- (void)performChangePassword
{
    if ([self validate]) {
        [self.loginController.service changePasswordWithOldPassword:self.currentPasswordTextField.text
                                                        newPassword:self.passwordTextField.text
                                                          authToken:self.loginController.authToken
                                                         completion:^(BOOL success, id result, NSError *error) {
                                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                 if (success) {
                                                                     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                 } else {
                                                                     if ([error.domain isEqualToString:BEKErrorDomain] && error.code == 403) {
                                                                         [self showErrorMessage:@"Existing password is incorrect."];
                                                                     } else {
                                                                         [self showErrorMessage:@"Change password failed."];
                                                                     }
                                                                     
                                                                     [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                                                 }
                                                             }];
                                                         }];
    } else {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.changePasswordCell) {
        [self performChangePassword];
    }
}
@end
