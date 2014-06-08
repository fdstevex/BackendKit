//
//  BEKLoginUtils.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-31.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKLoginUtils.h"

@implementation BEKLoginUtils

+ (BOOL)isValidEmailAddress:(NSString *)emailAddress
{
    if (emailAddress.length == 0) {
        return NO;
    }
    
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    NSUInteger numMatches = [expression numberOfMatchesInString:emailAddress
                                                        options:0
                                                          range:NSMakeRange(0, emailAddress.length)];
    

    return numMatches != 0;
}

@end
