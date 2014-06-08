//
//  BEKWebService.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BEKCompletion)(BOOL success, id result, NSError *error);

@protocol BEKWebServiceProtocol <NSObject>

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(BEKCompletion)completion;

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                    extra:(NSDictionary *)extra
               completion:(BEKCompletion)completion;

- (void)resetPasswordWithEmail:(NSString *)email
                    completion:(BEKCompletion)completion;

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                            authToken:(NSString *)authToken
                           completion:(BEKCompletion)completion;

@end

