//
//  YahooEngine.h
//  ABStock
//
//  Created by fih on 2014/2/14.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "MKNetworkEngine.h"
typedef void (^YahooEnginResponseBlock)(NSString *chartInfo);

@interface YahooEngine : MKNetworkEngine
-(id) initWithDefaultSettings ;
-(MKNetworkOperation*)getStockCSV:(NSString *)_stockNo
                       withPeriod:(NSString*)_period
                completionHandler:(YahooEnginResponseBlock) completionBlock
                     errorHandler:(MKNKErrorBlock) errorBlock;

@end
