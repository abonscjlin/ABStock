//
//  WantGooEngine.h
//  ABStock
//
//  Created by fih on 2014/1/22.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^StockChartInfoResponseBlock)(NSMutableArray *chartInfo);
typedef void (^StockChartInfoStringResponseBlock)(NSString *chartInfo);

@interface WantGooEngine : MKNetworkEngine
-(id) initWithDefaultSettings ;
-(MKNetworkOperation*)getStockHistoryInfo:(NSString *)_stockNo
                                 period:(int)_period
                      completionHandler:(StockChartInfoStringResponseBlock) completionBlock
                           errorHandler:(MKNKErrorBlock) errorBlock ;


-(MKNetworkOperation*)getRealTimeStockChartInfo:(NSString *)_stockNo
                              completionHandler:(StockChartInfoResponseBlock) completionBlock
                                   errorHandler:(MKNKErrorBlock) errorBlock ;

-(MKNetworkOperation*)getRealTimeStockCSV:(NSString *)_stockNo
                        completionHandler:(StockChartInfoResponseBlock) completionBlock
                             errorHandler:(MKNKErrorBlock) errorBlock ;
@end
