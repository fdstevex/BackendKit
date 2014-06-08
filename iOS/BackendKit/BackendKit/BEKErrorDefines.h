//
//  BEKErrorDefines.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-24.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *BEKErrorDomain;
extern NSString *BEKReasonKey;

typedef enum {
    BEKErrorEmailAlreadyRegistered = 100,
    BEKErrorEmailOrPasswordInvalid = 101,
    BEKErrorEmailValidationRequired = 102,
    BEKErrorEmailLoginFailedBecauseEmailNotVerified = 103,
    BEKErrorEmailValidationFailed = 104,
    BEKErrorAuthenticationFailed = 403,
    BEKErrorValidationTokenInvalid = 405,
    BEKErrorResetPasswordTokenInvalid = 405,
    BEKErrorForgotPasswordTokenInvalid = 406,
    BEKErrorResetPasswordLinkTokenInvalid = 407,
    BEKErrorRequestThrottled = 429,
    BEKErrorInternalRegistrationFailed = 501,
    BEKErrorInternalDatabaseError = 502,
    BEKErrorInternalUnableToSendMail = 503,
} BEKErrorCode;

@interface BEKErrorDefines : NSObject

@end
