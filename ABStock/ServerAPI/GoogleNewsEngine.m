//
//  GoogleNewsEngine.m
//  ABStock
//
//  Created by fih on 2014/1/27.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "GoogleNewsEngine.h"
#import "EnginConstant.h"
#import "DBConstant.h"

@implementation GoogleNewsEngine
-(id) initWithDefaultSettings {
    
    if(self = [super initWithHostName:GOOGLENEWS_URL customHeaderFields:@{@"x-client-identifier" : @"iOS"}]) {
        
    }
    return self;
}
-(MKNetworkOperation*)getGoogleNews:(NSString *)_stockName
                  completionHandler:(GoogleNewsResponseBlock) completionBlock
                       errorHandler:(MKNKErrorBlock) errorBlock
{
    
    NSString *_url=GOOGLENWS_STOCK_URL([_stockName mk_urlEncodedString]);
    
    NSLog(@"start");
    
    NSLog(@"[google news url] :%@",_url);
    MKNetworkOperation *op = [self operationWithPath:_url
                                              params:nil
                                          httpMethod:@"GET"];
    
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         // the completionBlock will be called twice.
         // if you are interested only in new values, move that code within the else block
         
         NSString *htmlRowdata=[completedOperation responseString] ;
         
         NSLog(@"[google news  htmlRowdata] %@ ",htmlRowdata);
         //{"Price":"45.35","Change":"▼0.10","Ratio":"-0.22%","Low":"44.25","High":"45.35","Volume":"9,707(億)","Time":"13:30","utcTime":"1390570200000","Color":"green"}
         NSMutableArray *rowDatas=[[[completedOperation responseString] componentsSeparatedByString:@",\""] mutableCopy];
         //         NSLog(@"before rowDatas %@",rowDatas);
//         for (int i=0; i< [rowDatas count]; i++) {
//             NSArray *temp=[rowDatas[i] componentsSeparatedByString:@":\""];
//             //             NSLog(@"before temp %@",temp);
//             
//             NSRange range = NSMakeRange (0, [temp[1] length]-1);
//             rowDatas[i]=[temp[1] substringWithRange:range];
//             //             NSLog(@"after rowDatas %@",rowDatas);
//             
//         }

         //for test
         //         NSLog(@"rowDatas %@",rowDatas);
         //         NSLog(@"price:%@",rowDatas[STOCK_PRICE]);
         //         NSLog(@"change:%@",rowDatas[STOCK_CHANGE]);
         //         NSLog(@"ratio:%@",rowDatas[STOCK_RATIO]);
         //         NSLog(@"low:%@",rowDatas[STOCK_LOW]);
         //         NSLog(@"high:%@",rowDatas[STOCK_HIGH]);
         //         NSLog(@"volume:%@",rowDatas[STOCK_VOLUME]);
//         NSLog(@"time:%@",rowDatas[STOCK_TIME]);
         //         NSLog(@"color:%@",rowDatas[STOCK_COLOR]);
         
         completionBlock(rowDatas);
         
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    //    [self emptyCache];
    [self enqueueOperation:op];
    NSLog(@"end");
    
    return op;

    
}
@end
