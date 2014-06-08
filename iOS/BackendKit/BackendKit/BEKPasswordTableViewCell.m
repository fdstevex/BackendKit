//
//  BEKPasswordTableViewCell.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-06-01.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKPasswordTableViewCell.h"

@interface BEKPasswordTableViewCell() <UITextFieldDelegate>
@property (readonly) UITextField *passwordTextField;
@property (readonly) UIButton *showHidePasswordButton;
@property (strong, nonatomic) UIColor *windowTintColor;
@end
@implementation BEKPasswordTableViewCell

- (UIButton *)showHidePasswordButton
{
    return (UIButton *)[self.contentView viewWithTag:2];
}

- (UITextField *)passwordTextField
{
    return (UITextField *)[self.contentView viewWithTag:1];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.showHidePasswordButton.hidden = YES;
    
    self.passwordTextField.delegate = self;
    
    [self.showHidePasswordButton addTarget:self action:@selector(didTapShowHideButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.tintColor) {
        [self.showHidePasswordButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}

- (IBAction)didTapShowHideButton:(id)sender
{
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    
    if (self.passwordTextField.secureTextEntry) {
        [self.showHidePasswordButton setTitle:@"Show" forState:UIControlStateNormal];
    } else {
        [self.showHidePasswordButton setTitle:@"Hide" forState:UIControlStateNormal];
    }

    [self.showHidePasswordButton setTitleColor:self.tintColor forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.showHidePasswordButton.hidden = (newString.length == 0);
    return YES;
}

@end
