//
//  TSEEngine.m
//  ABStock
//
//  Created by fih on 2014/1/27.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "TSEEngine.h"
#import "SqliteHelper.h"
#import "EnginConstant.h"
#import "DBConstant.h"

@implementation TSEEngine
{
    SqliteHelper *dbHelper ;

}
-(id) initWithDefaultSettings {
    
    if(self = [super initWithHostName:TSC_URL customHeaderFields:@{@"x-client-identifier" : @"iOS"}]) {
        dbHelper = [SqliteHelper newInstance];

    }
    return self;
}

-(MKNetworkOperation*)getRealTimeStockCSV:(NSString*)_stockNo
                        completionHandler:(RealTimeStockCSVResponseBlock) completionBlock
                             errorHandler:(MKNKErrorBlock) errorBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = paths[0];
	NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",_stockNo]];

    
    NSString *_url=TSC_STOCK_URL(_stockNo);
    
    NSLog(@"[TSEEngine] getRealTimeStockCSV : start");
    
    NSLog(@"[TSC realtime csv url] :%@",_url);
//    MKNetworkOperation *op = [self operationWithPath:_url
//                                              params:nil
//                                          httpMethod:@"GET"];
    
    MKNetworkOperation *op = [self operationWithURLString:_url];
    [op  setHeader:@"x-client-identifier" withValue:@"iOS"];
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:downloadPath append:NO]];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSError *error1;
         NSStringEncoding encoder;
         //big5 support
         NSString *fileContents = [[NSString alloc] initWithContentsOfFile:downloadPath encoding:encoder=-2147481082 error:&error1];
         
//         NSString *htmlRowdata=[completedOperation responseString] ;
         
         //         NSLog(@"[TSC realtime csv htmlRowdata] %@ ",htmlRowdata);

         if (error1) {
             NSLog(@"error from [TSEEngine] getRealTimeStockCSV :%@",[error1 localizedDescription]);
             
         }
         //success
         else{
             //         NSLog(@"[stockdog filepath]:%@",filePath);
             //        NSLog(@"fileContents %@",fileContents);
         
         NSMutableArray *rowDatas=[[fileContents componentsSeparatedByString:@","] mutableCopy];
         
//         NSLog(@"before rowDatas %@",rowDatas);
         for (int i=0; i< [rowDatas count]; i++) {
             //             NSLog(@"before temp %@",temp);
             NSRange range = NSMakeRange (1, [rowDatas[i] length]-2);
             rowDatas[i]=[rowDatas[i] substringWithRange:range];
             
         }
//         NSLog(@"after rowDatas %@",rowDatas);
             //昨日收盤價
            double unch=([rowDatas[TSE_Stock_max] doubleValue] + [rowDatas[TSE_Stock_min] doubleValue])/2;
            NSNumber *ratio=[NSNumber numberWithDouble:([rowDatas[TSE_Stock_c] doubleValue]-unch)/unch*100];
             [rowDatas insertObject:[NSString stringWithFormat:@"%.2f",[ratio doubleValue]] atIndex:TSE_Stock_Ratio];
             NSString *_sqlInsertValues=[NSString stringWithFormat:@"'%@','%@',%.2f,%.2f,%.2f,%.2f,%.2f,%ld,%.2f",rowDatas[TSE_Stock_Index],rowDatas[TSE_Stock_time],[rowDatas[TSE_Stock_c] doubleValue],[rowDatas[TSE_Stock_change] doubleValue],[rowDatas[TSE_Stock_Ratio] doubleValue],[rowDatas[TSE_Stock_l] doubleValue],[rowDatas[TSE_Stock_h]doubleValue],(long)[rowDatas[TSE_Stock_volume] integerValue],[rowDatas[TSE_Stock_o] doubleValue]];
             NSString *_sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO  s_RealtimeCSV VALUES(%@)",_sqlInsertValues];
             
             [dbHelper executeQuery:_sql];
//             [dbHelper closeDatabase];
             completionBlock(rowDatas);
         }
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    //    [self emptyCache];
    [self enqueueOperation:op];
    NSLog(@"[TSEEngine] getRealTimeStockCSV : end");
    
    return op;
}
@end
