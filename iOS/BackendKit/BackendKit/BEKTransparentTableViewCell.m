//
//  BEKTransparentTableViewCell.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-29.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKTransparentTableViewCell.h"

@implementation BEKTransparentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

@end
