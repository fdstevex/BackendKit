//
//  BEKWebClient.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKLoginService.h"

NSString *BEKResponseAuthTokenKey = @"authToken";
NSString *BEKResponseReason = @"reason";
NSString *BEKResponseReasonCode = @"reasonCode";

@interface BEKLoginService()
@property (strong, nonatomic) id<BEKWebServiceProtocol> service;
@end

@implementation BEKLoginService

- (id)initWithWebService:(id<BEKWebServiceProtocol>)service
{
    self = [super init];
    if (self) {
        self.service = service;
    }
    return self;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(BEKCompletion)completion
{
    [self.service loginWithEmail:email
                        password:password
                      completion:^(BOOL success, id result, NSError *error) {
                          if (completion) {
                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                  completion(success, result, error);
                              }];
                          }
                      }];
}

- (void)registerWithEmail:(NSString *)email
                      password:(NSString *)password
                         extra:(NSDictionary *)extra
                    completion:(BEKCompletion)completion
{
    [self.service registerWithEmail:email
                           password:password
                              extra:extra
                         completion:^(BOOL success, id result, NSError *error) {
                             if (completion) {
                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                     completion(success, result, error);
                                 }];
                             }
                         }];
}

- (void)resetPasswordWithEmail:(NSString *)email
                     completion:(BEKCompletion)completion
{
    [self.service resetPasswordWithEmail:email
                               completion:^(BOOL success, id result, NSError *error) {
                             if (completion) {
                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                     completion(success, result, error);
                                 }];
                             }
                         }];
}

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                            authToken:(NSString *)authToken
                           completion:(BEKCompletion)completion
{
    [self.service changePasswordWithOldPassword:oldPassword
                                    newPassword:newPassword
                                      authToken:authToken
                                     completion:^(BOOL success, id result, NSError *error) {
                                         if (completion) {
                                             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                 completion(success, result, error);
                                             }];
                                         }
                                     }];
}

@end
