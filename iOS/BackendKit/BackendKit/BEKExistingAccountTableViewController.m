//
//  BEKExistingAccountTableViewController.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-06-01.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKExistingAccountTableViewController.h"
#import "BEKBorderedTableViewCell.h"
#import "BEKLoginController.h"
#import "SSKeychain.h"

@interface BEKExistingAccountTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet BEKBorderedTableViewCell *signOutCell;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@end

@implementation BEKExistingAccountTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = self.loginController.backgroundColor;

    if (self.loginController.privacyPolicyURL == nil) {
        self.privacyPolicyButton.hidden = YES;
    }
    
    self.accountLabel.text = self.loginController.loggedInWithEmail;
}

- (IBAction)didTapPrivacyPolicy:(id)sender
{
    [self.loginController showPrivacyPolicy];
}

- (void)performSignOut
{
    NSString *email = [self.loginController loggedInWithEmail];
    [SSKeychain deletePasswordForService:@"BackendKit"
                                 account:email];

    [self.loginController refresh];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.signOutCell) {
        [self performSignOut];
    }
}
@end