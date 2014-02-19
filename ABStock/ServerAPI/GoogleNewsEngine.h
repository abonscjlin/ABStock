//
//  GoogleNewsEngine.h
//  ABStock
//
//  Created by fih on 2014/1/27.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "MKNetworkEngine.h"
typedef void (^GoogleNewsResponseBlock)(NSMutableArray *chartInfo);

@interface GoogleNewsEngine : MKNetworkEngine
-(id) initWithDefaultSettings ;
-(MKNetworkOperation*)getGoogleNews:(NSString *)_stockNo
                        completionHandler:(GoogleNewsResponseBlock) completionBlock
                             errorHandler:(MKNKErrorBlock) errorBlock ;



@end
