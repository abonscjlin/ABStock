//
//  Https.h
//  stx
//
//  Created by tom.k.wan on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Https : NSObject {

}

+ (id)sharedHTTPS;

- (id)ASIRequestWithUrl:(NSString *)url
          withAsyncMode:(BOOL)asyncMode
                withTag:(NSInteger) tag
           withDelegate:(id) delegate
          withParameter:(NSMutableDictionary *) params
        needCertificate:(BOOL)needCertificate
          requestMethod:(NSString *)requestMethod
              needCache:(BOOL)needCache;

@end
