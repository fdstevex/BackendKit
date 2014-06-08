//
//  BEKForgotPasswordTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-30.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKForgotPasswordTableViewController.h"
#import "BEKBorderedTableViewCell.h"
#import "BEKLoginUtils.h"
#import "BEKLoginController.h"

@interface BEKForgotPasswordTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet BEKBorderedTableViewCell *sendCell;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation BEKForgotPasswordTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.emailTextField.text = self.initialEmailAddress;
    
    self.view.backgroundColor = self.loginController.backgroundColor;

    [self showErrorMessage:nil];
}

- (void)showErrorMessage:(NSString *)message
{
    self.errorLabel.text = message;
}

- (BOOL)validate
{
    if (![BEKLoginUtils isValidEmailAddress:self.emailTextField.text]) {
        [self showErrorMessage:NSLocalizedString(@"The email address is not valid.", nil)];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        return NO;
    }

    return YES;
    
}

- (void)performSend
{
    if ([self validate]) {
        [self.loginController.service resetPasswordWithEmail:self.emailTextField.text
                                                  completion:^(BOOL success, id result, NSError *error) {
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                          if (success) {
                                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                          } else {
                                                              [self showErrorMessage:NSLocalizedString(@"Unable to send password reset email.", nil)];
                                                          }
                                                          
                                                          [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                                      }];
                                                  }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.sendCell) {
        [self performSend];
    }
}

@end
