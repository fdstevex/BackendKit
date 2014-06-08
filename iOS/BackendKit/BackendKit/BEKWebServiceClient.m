//
//  BEKWebServiceClient.m
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import "BEKWebServiceClient.h"
#import "BEKErrorDefines.h"
#import "BEKLoginService.h"

@interface BEKWebServiceClient()
@property (strong, nonatomic) NSURL *url;
@end

@implementation BEKWebServiceClient

- (id)initWithAPIURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (NSString *)HTTPBodyFromDictionary:(NSDictionary *)dictionary
{
    NSMutableString *body = [NSMutableString string];
    [dictionary.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (body.length > 0) {
            [body appendString:@"&"];
        }

        NSString *encodedValue = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (__bridge CFStringRef)dictionary[key],
                                                                                             NULL,
                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                             kCFStringEncodingUTF8);

        [body appendFormat:@"%@=%@", key, encodedValue];
    }];
    
    
    return body;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(BEKCompletion)completion
{
    if (!completion) {
        // There's no point in being here if there's no completion handler
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [self.url URLByAppendingPathComponent:@"v1/login"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *bodyString = [self HTTPBodyFromDictionary:@{ @"email": email, @"password": password }];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(NO, nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&jsonError];
        if (!responseDict) {
            // Unparseable JSON
            if (completion) {
                completion(NO, nil, jsonError);
                return;
            }
        }
        
        NSNumber *reasonCode = responseDict[@"reasonCode"];
        NSString *reason = responseDict[@"reason"];
        if (reasonCode != nil) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (reason != nil) {
                userInfo[BEKReasonKey] = reason;
            }
            
            NSError *error = [NSError errorWithDomain:BEKErrorDomain
                                                 code:reasonCode.intValue
                                             userInfo:userInfo];
            completion(NO, responseDict, error);
            return;
        }
        
        if (responseDict[@"authToken"]) {
            // Success!
            completion(YES, responseDict, nil);
        }
    }];
    [postDataTask resume];
}

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                    extra:(NSDictionary *)extra
               completion:(BEKCompletion)completion
{
    if (!completion) {
        // There's no point in being here if there's no completion handler
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [self.url URLByAppendingPathComponent:@"v1/register"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *bodyDictionary = [@{ @"email": email, @"password": password } mutableCopy];
    if (extra != nil) {
        bodyDictionary[@"extra"] = extra;
    }
    
    NSString *bodyString = [self HTTPBodyFromDictionary:bodyDictionary];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(NO, nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&jsonError];
        if (!responseDict) {
            // Unparseable JSON
            if (completion) {
                completion(NO, nil, jsonError);
                return;
            }
        }
        
        NSNumber *reasonCode = responseDict[@"reasonCode"];
        NSString *reason = responseDict[@"reason"];
        if (reasonCode != nil) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (reason != nil) {
                userInfo[BEKReasonKey] = reason;
            }
            
            NSError *error = [NSError errorWithDomain:BEKErrorDomain
                                                 code:reasonCode.intValue
                                             userInfo:userInfo];
            completion(NO, responseDict, error);
            return;
        }
        
        if (responseDict[@"authToken"]) {
            // Success!
            completion(YES, responseDict, nil);
        }
    }];
    [postDataTask resume];
}

- (void)resetPasswordWithEmail:(NSString *)email
                     completion:(BEKCompletion)completion
{
    if (!completion) {
        // There's no point in being here if there's no completion handler
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [self.url URLByAppendingPathComponent:@"v1/resetPassword"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *bodyDictionary = @{ @"email": email };
    NSString *bodyString = [self HTTPBodyFromDictionary:bodyDictionary];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(NO, nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&jsonError];
        if (!responseDict) {
            // Unparseable JSON
            if (completion) {
                completion(NO, nil, jsonError);
                return;
            }
        }
        
        NSNumber *reasonCode = responseDict[@"reasonCode"];
        NSString *reason = responseDict[@"reason"];
        if (reasonCode != nil) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            if (reason != nil) {
                userInfo[BEKReasonKey] = reason;
            }
            
            NSError *error = [NSError errorWithDomain:BEKErrorDomain
                                                 code:reasonCode.intValue
                                             userInfo:userInfo];
            completion(NO, responseDict, error);
            return;
        }

        completion(YES, responseDict, nil);
    }];
    
    [postDataTask resume];
}

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                            authToken:(NSString *)authToken
                           completion:(BEKCompletion)completion
{
    if (!completion) {
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [self.url URLByAppendingPathComponent:@"v1/resetPassword"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:@"BEKCSRF=12345678" forHTTPHeaderField:@"Cookie"];
    request.HTTPShouldHandleCookies = NO;
    
    NSDictionary *bodyDictionary = @{ @"password": oldPassword, @"newpassword": newPassword, @"BEKAuthToken": authToken, @"BEKCSRF": @"12345678" };
    NSString *bodyString = [self HTTPBodyFromDictionary:bodyDictionary];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(NO, nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&jsonError];
        if (!responseDict) {
            // Unparseable JSON
            if (completion) {
                completion(NO, nil, jsonError);
                return;
            }
        }

        NSNumber *success = responseDict[@"success"];
        if (success.boolValue) {
            completion(YES, nil, nil);
        } else {
            NSNumber *reasonCode = responseDict[@"reasonCode"];
            NSString *reason = responseDict[@"reason"];
            if (reasonCode != nil) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (reason != nil) {
                    userInfo[BEKReasonKey] = reason;
                }
                
                NSError *error = [NSError errorWithDomain:BEKErrorDomain
                                                     code:reasonCode.intValue
                                                 userInfo:userInfo];
                completion(NO, responseDict, error);
            } else {
                completion(NO, nil, nil);
            }
        }
    }];
    
    [postDataTask resume];
}

@end
