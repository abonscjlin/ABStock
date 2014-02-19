//
//  TSEEngine.h
//  ABStock
//
//  Created by fih on 2014/1/27.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "MKNetworkEngine.h"
typedef void (^RealTimeStockCSVResponseBlock)(NSMutableArray *chartInfo);

@interface TSEEngine : MKNetworkEngine
-(id) initWithDefaultSettings ;
-(MKNetworkOperation*)getRealTimeStockCSV:(NSString*)all
                   completionHandler:(RealTimeStockCSVResponseBlock) completionBlock
                        errorHandler:(MKNKErrorBlock) errorBlock ;
@end
