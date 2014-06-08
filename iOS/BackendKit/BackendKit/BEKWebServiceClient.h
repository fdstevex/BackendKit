//
//  BEKWebServiceClient.h
//  BackendKit
//
//  Created by Steve Tibbett on 2014-05-22.
//  Copyright (c) 2014 Fall Day Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEKWebServiceProtocol.h"


@interface BEKWebServiceClient : NSObject <BEKWebServiceProtocol>

- (id)initWithAPIURL:(NSURL *)url;

@end
