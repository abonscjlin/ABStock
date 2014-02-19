//
//  YahooEngine.m
//  ABStock
//
//  Created by fih on 2014/2/14.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "YahooEngine.h"
#import "EnginConstant.h"

@implementation YahooEngine

-(id) initWithDefaultSettings {
    
    if(self = [super initWithHostName:YAHOOO_URL customHeaderFields:@{@"x-client-identifier" : @"iOS"}]) {
        
    }
    return self;
}

-(MKNetworkOperation*)getStockCSV:(NSString *)_stockNo
                       withPeriod:(NSString*)_period
                       completionHandler:(YahooEnginResponseBlock) completionBlock
                             errorHandler:(MKNKErrorBlock) errorBlock {
    _stockNo=[NSString stringWithFormat:@"%@.TW",_stockNo];
    NSString *_url=YAHOO_STOCK_URL(_stockNo, _period);

    NSLog(@"[YahooEngine] getStockCSV : Start");
    
    NSLog(@"[Yahoo csv url] :%@/%@",YAHOOO_URL,_url);
    MKNetworkOperation *op = [self operationWithPath:_url
                                              params:nil
                                          httpMethod:@"GET"];
    
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {

         NSLog(@"[YahooEngine] getStockCSV : End");

         NSString *htmlRowdata=[completedOperation responseString] ;

         completionBlock(htmlRowdata);
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    //    [self emptyCache];
    [self enqueueOperation:op];
    
    return op;
}

@end
