//
//  Https.m
//  stx
//
//  Created by tom.k.wan on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Https.h"
#import "ServerAPI.h"

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

static Https *sharedMyManager = nil;

@implementation Https

#pragma mark Singleton Methods
+ (id)sharedHTTPS {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedHTTPS] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}

#pragma mark

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}
- (id)ASIRequestWithUrl:(NSString *)url 
          withAsyncMode:(BOOL)asyncMode 
                withTag:(NSInteger) tag 
           withDelegate:(id) delegate 
          withParameter:(NSMutableDictionary *) params
        needCertificate:(BOOL)needCertificate
          requestMethod:(NSString *)requestMethod
              needCache:(BOOL)needCache
{
    
    ASIFormDataRequest *req ;
    
    if (url == nil) {
        return nil;
    } else {
        req = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    }
    
    [req setRequestMethod:requestMethod];
    [req setValidatesSecureCertificate:NO];
    [req setTag:tag];
    
//    if (tag != kTagUploadPhoto && tag != kTagUploadFriends && tag != kTagSendTopic) {
//        [req setTimeOutSeconds:10.0];
//        for (NSString *key in [params allKeys])
//            [req setPostValue:[params objectForKey:key] forKey:key];
//    }
//    else
    
    if (tag == asTAGSingleStock)
    {
        [req setTimeOutSeconds:20.0];
//        for (NSString *key in [params allKeys])
//            [req setPostValue:[params objectForKey:key] forKey:key];
    }
    else{
        [req setTimeOutSeconds:40.0];
        [req setData:[params objectForKey:@"upload0"] withFileName:@"aa.png" andContentType:@"image/png" forKey:@"upload0"];
        [req setPostValue:[params objectForKey:@"scr"] forKey:@"scr"];
        
        [req setPostValue:[params objectForKey:@"sid"] forKey:@"sid"];
    }
    
    if (needCache) 
    {
        [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
        //设置缓存方式
//        [req setDownloadCache:[ASIDownloadCache sharedCache]];
        //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
        [req setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
        [req setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        [[ASIDownloadCache sharedCache]setShouldRespectCacheControlHeaders:NO];
         [req setSecondsToCache:60*60*24]; // 缓存 1 天
    }
    if (asyncMode) {
        [req setDelegate:delegate];
        [req startAsynchronous];
        
        return req;
    }
    else {
        
        [req startSynchronous];
        
        NSError *error = [req error];
        NSString *response = @"";
        
        if (!error) {
            
            response = [req responseString];
            
        }
        else {
            return nil;
        }        
        
        return response;
    }
}


@end
