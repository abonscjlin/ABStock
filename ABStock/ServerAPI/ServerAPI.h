//
//  ServerAPI.h
//  abonStock
//
//  Created by fih on 2013/12/22.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ASIHTTPRequestDelegate.h"



@class ServerAPI;
@protocol ServerAPIDelegate <NSObject>
@optional
- (void)serverAPIRequestFinished:(ServerAPI *)api   data:(id)data tag:(NSInteger)tag;
- (void)serverAPIRequestFaild:(ServerAPI *)api error:(NSError *)error tag:(NSInteger)tag;

@end



@interface ServerAPI : NSObject
@property (nonatomic, strong) id<ServerAPIDelegate> delegate;
-(void)requestStocksIndex;
-(void)requestStockNo:(NSString *)stockNo tag:(int)tag;

@end
