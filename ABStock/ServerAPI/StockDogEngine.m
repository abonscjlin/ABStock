//
//  StockDogEngine.m
//  ABStock
//
//  Created by fih on 2014/1/22.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "StockDogEngine.h"
#import "Element.h"
#import "DocumentRoot.h"
#import "SqliteHelper.h"
#import "EnginConstant.h"
#import "DBConstant.h"

@implementation StockDogEngine
{
    NSUserDefaults *userDef;
    SqliteHelper *dbHelper ;

}
-(id) initWithDefaultSettings {
    
    if(self = [super initWithHostName:STOCKDOG_URL customHeaderFields:@{@"x-client-identifier" : @"iOS"}]) {
        userDef=[NSUserDefaults standardUserDefaults];
        dbHelper = [SqliteHelper newInstance];
    }
    return self;
}

-(MKNetworkOperation*)getStocksIndex:(NSString*)all
                      completionHandler:(StocksIndexResponseBlock) completionBlock
                           errorHandler:(MKNKErrorBlock) errorBlock {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = paths[0];
	NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"stockIndex.txt"];

//    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSString *filePath=[homeDir stringByAppendingPathComponent:@"stockIndex.txt"];
    
    MKNetworkOperation *op = [self operationWithURLString:STOCKDOG_STOCKSINDEX_URL];
    [op  setHeader:@"x-client-identifier" withValue:@"iOS"];
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:downloadPath append:NO]];

    [op addCompletionHandler:
     ^(MKNetworkOperation* completedRequest) {
         NSError *error1;
         NSStringEncoding encoder;
         //big5 support
         NSString *fileContents = [[NSString alloc] initWithContentsOfFile:downloadPath encoding:encoder=-2147481082 error:&error1];
         if (error1) {
             NSLog(@"error:%@",[error1 localizedDescription]);

         }
         //success
         else{
//         NSLog(@"[stockdog filepath]:%@",filePath);
//        NSLog(@"fileContents %@",fileContents);
         [self parseStocksIndexFromString:fileContents];
         NSMutableArray *datas=[[NSMutableArray alloc]init];
             
         completionBlock(datas);
         }
    }
    errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        
        DLog(@"%@", error);
        [UIAlertView showWithError:error];
        errorBlock(error);

    }];

    
    
    [self enqueueOperation:op];
    return op;
}

-(void)parseStocksIndexFromString:(NSString*)_source
{
	NSString *pattern = @"*";
	DocumentRoot* document = [Element parseHTML: _source];
    NSLog(@"start");
	NSArray* elements = [document selectElements: pattern] ;
	for (Element* element in elements){
        NSString *findPattern=@"script";
        NSString *contentText=[element contentsTextOfChildElement:findPattern];
        NSRange matchRange=[contentText rangeOfString:@"source:"];
        //for find string test
//        NSLog(@"matchRange %d",matchRange.location);
//        NSLog(@"contentText %@",contentText);
        if (matchRange.location<69&&matchRange.location>0) {
            NSMutableDictionary *stocksIndexDic=[[NSMutableDictionary alloc]init];
            NSString *seriseString=[contentText  substringFromIndex:matchRange.location];
            NSString *dataString=[seriseString substringFromIndex:[seriseString rangeOfString:@"source:"].location+9];
            dataString=[dataString substringToIndex:[dataString length]-41];
            //"0015 富邦","0050 台灣50","0051 中100"
            NSMutableArray *datas=[[dataString componentsSeparatedByString:@","] mutableCopy];
            for (NSString *dataStr in datas) {
                //0015 富邦
                NSArray *dataUnit=[dataStr componentsSeparatedByString:@" "];
//                NSString *dataIndex=[dataUnit[0] substringFromIndex:1];
//                NSString *dataStockName=[dataUnit[1] substringToIndex:[dataUnit[1] length ]-1];
                NSString *_sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO s_Index values('%@','%@')",[dataUnit[0] substringFromIndex:1],[dataUnit[1] substringToIndex:[dataUnit[1] length ]-1]];
                [dbHelper executeQuery:_sql];

                [stocksIndexDic setObject:[dataUnit[1] substringToIndex:[dataUnit[1] length ]-1] forKey:[dataUnit[0] substringFromIndex:1]];
//                NSLog(@"index:%@,name:%@",dataIndex,dataStockName);
            }
            NSLog(@"stocksIndex count %d",[datas count] );
            [userDef setObject:stocksIndexDic forKey:KEY_StocksIndex];
            [userDef synchronize];
//            NSLog(@"stocksIndexDic count %d",[stocksIndexDic count] );

            break;
        }
	}
    NSLog(@"end");
}
@end
