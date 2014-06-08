//
//  BEKBorderedTableViewCell.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKBorderedTableViewCell.h"

@interface BEKBorderedTableViewCell()
@property (strong, nonatomic) UIView *topBorderView;
@property (strong, nonatomic) UIView *bottomBorderView;
@end

@implementation BEKBorderedTableViewCell

- (void)awakeFromNib
{
    self.topBorderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.topBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.topBorderView];
    [self.contentView addSubview:self.bottomBorderView];
    
    self.topBorderView.backgroundColor = [UIColor lightGrayColor];
    self.bottomBorderView.backgroundColor = [UIColor lightGrayColor];
    
    NSDictionary *views = @{ @"topBorderView": self.topBorderView, @"bottomBorderView": self.bottomBorderView };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[topBorderView(0.5)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomBorderView]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBorderView(0.5)]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    if (self.tag == 100) {
        // Hide the bottom border
        self.bottomBorderView.hidden = YES;
    }
    
    if (self.tag == 101) {
        // Dim and move the top border

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[topBorderView]-0-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        
    } else {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[topBorderView]-0-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.topBorderView.backgroundColor = [UIColor grayColor];
    self.bottomBorderView.backgroundColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.topBorderView.backgroundColor = [UIColor grayColor];
    self.bottomBorderView.backgroundColor = [UIColor grayColor];
}

@end
