//
//  StockDogEngine.h
//  ABStock
//
//  Created by fih on 2014/1/22.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "MKNetworkEngine.h"
typedef void (^StocksIndexResponseBlock)(NSMutableArray *chartInfo);

@interface StockDogEngine : MKNetworkEngine
-(id) initWithDefaultSettings ;

-(MKNetworkOperation*)getStocksIndex:(NSString*)all
                   completionHandler:(StocksIndexResponseBlock) completionBlock
                        errorHandler:(MKNKErrorBlock) errorBlock ;
@end
