//
//  WantGooEngine.m
//  ABStock
//
//  Created by fih on 2014/1/22.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "WantGooEngine.h"
#import "DocumentRoot.h"
#import "SqliteHelper.h"
#import "EnginConstant.h"
#import "DBConstant.h"

@implementation WantGooEngine
{
    SqliteHelper *dbHelper ;

}
-(id) initWithDefaultSettings {
    
    if(self = [super initWithHostName:WANTGOO_URL customHeaderFields:@{@"x-client-identifier" : @"iOS"}]) {
        dbHelper = [SqliteHelper newInstance];

    }
    return self;
}

-(MKNetworkOperation*)getRealTimeStockCSV:(NSString *)_stockNo
                              completionHandler:(StockChartInfoResponseBlock) completionBlock
                                   errorHandler:(MKNKErrorBlock) errorBlock {
    NSString *_url;
    //大盤
    if ([_stockNo isEqualToString:@"0000"])
        _url=WANTGOO_REALTIME_STOCK_CSV_URL(@"0000");
    //台指
    else if([_stockNo isEqualToString:@"0001"])
        _url=WANTGOO_REALTIME_STOCK_CSV_URL(@"WTX$");
    else
        _url=WANTGOO_REALTIME_STOCK_CSV_URL(_stockNo);
    
    NSLog(@"[WantgooEngine] getRealTimeStockCSV : Start");

    NSLog(@"[wantgoo realtime csv url] :%@",_url);
    MKNetworkOperation *op = [self operationWithPath:_url
                                              params:nil
                                          httpMethod:@"GET"];
    
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSLog(@"[WantgooEngine] getRealTimeStockCSV : End");

         
//         NSString *htmlRowdata=[completedOperation responseString] ;
//         NSLog(@"[wantgoo realtime csv htmlRowdata] %@ ",htmlRowdata);
    //{"Price":"45.35","Change":"▼0.10","Ratio":"-0.22%","Low":"44.25","High":"45.35","Volume":"9,707(億)","Time":"13:30","utcTime":"1390570200000","Color":"green"}
//         NSString *price,*change,*ratio,*low,*high,*volum,*time,*color;
         NSMutableArray *rowDatas=[[[completedOperation responseString] componentsSeparatedByString:@",\""] mutableCopy];
//         NSLog(@"before rowDatas %@",rowDatas);
         for (int i=0; i< [rowDatas count]; i++) {
             NSArray *temp=[rowDatas[i] componentsSeparatedByString:@":\""];
//             NSLog(@"before temp %@",temp);

             NSRange range = NSMakeRange (0, [temp[1] length]-1);
             rowDatas[i]=[temp[1] substringWithRange:range];
//             NSLog(@"after rowDatas %@",rowDatas);

         }
         if ([rowDatas count]>0) {
             rowDatas[STOCK_COLOR]=[rowDatas[STOCK_COLOR] substringToIndex:[rowDatas[STOCK_COLOR] length]-1];
         }
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
         rowDatas[STOCK_RATIO]=[rowDatas[STOCK_RATIO] substringFromIndex:1];
         rowDatas[STOCK_CHANGE]=[rowDatas[STOCK_CHANGE] substringFromIndex:1];

         NSString *time=[self translateShortTimefrom:rowDatas[STOCK_TIME]];
         NSLog(@"wantgoo time:%@",time);
         NSString *_sqlInsertValues=[NSString stringWithFormat:@"'%@','%@',%.2f,%.2f,%.2f,%.2f,%.2f,%ld,%.2f",_stockNo,time,[rowDatas[STOCK_PRICE] doubleValue],[rowDatas[STOCK_CHANGE] doubleValue],[rowDatas[STOCK_RATIO] doubleValue],[rowDatas[STOCK_LOW] doubleValue],[rowDatas[STOCK_HIGH]doubleValue],(long)rowDatas[STOCK_VOLUME] ,0.0f];
         NSString *_sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO  s_RealtimeCSV VALUES(%@)",_sqlInsertValues];
         
         [dbHelper executeQuery:_sql];
         
         completionBlock(rowDatas);
         
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    //    [self emptyCache];
    [self enqueueOperation:op];
    NSLog(@"end");

    return op;
}

-(MKNetworkOperation*)getStockHistoryInfo:(NSString *)_stockNo
                                 period:(int)_period
                      completionHandler:(StockChartInfoStringResponseBlock) completionBlock
                           errorHandler:(MKNKErrorBlock) errorBlock {
    NSArray *periodArray=[NSArray arrayWithObjects:@"d",@"w",@"m", nil];
    NSString *_url=@"";
    //大盤
    if ([_stockNo isEqualToString:@"0000"])
        _url=WANTGOO_STOCK_URL(@"0000", periodArray[_period]);
    //台指
    else if ([_stockNo isEqualToString:@"0001"])
        _url=WANTGOO_STOCK_URL(@"WTX$", periodArray[_period]);
    else
        _url=WANTGOO_STOCK_URL(_stockNo, periodArray[_period]);
    
    NSLog(@"[WantgooEngine] getStockHistoryInfo : Start");
    NSLog(@"[wantgoo history url] :%@",_url);
    MKNetworkOperation *op = [self operationWithPath:_url
                                              params:nil
                                          httpMethod:@"GET"];
        
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSLog(@"[WantgooEngine] getStockHistoryInfo : End");

         NSString *htmlRowdata=[completedOperation responseString] ;
         
//         [self parseStockHistoryInfo:htmlRowdata];
         [self parseStockHistoryInfo:htmlRowdata stockIndex:_stockNo period:_period];

         NSMutableArray *datas=[[NSMutableArray alloc]init];
         [datas addObject:[completedOperation responseString]];
         
         NSString *csvString=[self parseStockHistoryInfo:htmlRowdata stockIndex:_stockNo period:_period];
         completionBlock(csvString);
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    
//    [self emptyCache];
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*)getRealTimeStockChartInfo:(NSString *)_stockNo
                      completionHandler:(StockChartInfoResponseBlock) completionBlock
                           errorHandler:(MKNKErrorBlock) errorBlock {
    NSString *_url=WANTGOO_REALTIME_STOCK_URL(_stockNo);
    
    NSLog(@"[WantgooEngine] getRealTimeStockChartInfo : Start");
    NSLog(@"[wantgoo realtime url] :%@",_url);
    MKNetworkOperation *op = [self operationWithPath:_url
                                              params:nil
                                          httpMethod:@"GET"];


    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSLog(@"[WantgooEngine] getRealTimeStockChartInfo : End");

         NSString *htmlRowdata=[completedOperation responseString] ;
         
//         NSLog(@"[wantgoo realtime htmlRowdata] %@ ",htmlRowdata);
         [self parseStockRealtimeInfo:htmlRowdata stockIndex:_stockNo];
         NSMutableArray *datas=[[NSMutableArray alloc]init];
         [datas addObject:[completedOperation responseString]];
         completionBlock(datas);
         

         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
//    [self emptyCache];
    [self enqueueOperation:op];

    return op;
}


-(NSString*)parseStockHistoryInfo:(NSString*)_source stockIndex:(NSString*)_stockIndex period:(int)_period
{
	NSString* pattern;
	pattern = @"*";
    NSMutableString *csvString=[[NSMutableString alloc] init];//for candleViewController
	DocumentRoot* document = [Element parseHTML: _source];
    NSLog(@"start");
	NSArray* elements = [document selectElements: pattern] ;
	for (Element* element in elements){
        NSString *findPattern=@"script";
        NSString *contentText=[element contentsTextOfChildElement:findPattern];
        NSRange matchRange=[contentText rangeOfString:@"series"];
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
        
//        //for find string test
//        NSLog(@"matchRange %d",matchRange.location);
//        NSLog(@"contentText %@",contentText);
        if (matchRange.location<1518&&matchRange.location>0) {

            NSMutableDictionary *volumeDic;
            NSString *seriseString=[contentText substringFromIndex:matchRange.location] ;
            
//            NSLog(@".location %d",[seriseString rangeOfString:@"name: '成交量(張)',"].location);
            NSString *compareVolumeString=@"";
            if ([_stockIndex isEqualToString:@"0000"]) {
                compareVolumeString=@"name: '成交量(億)',";
                if (_period==PERIOD_WEEK) {
                    UIAlertView* alert =[[UIAlertView alloc] initWithTitle:@"Error!" message:@"not support for ^TWII week"delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                    [alert show];
                    break;
                }
            }
            else if([_stockIndex isEqualToString:@"0001"]){
                compareVolumeString=@"name: '成交量',";

            }
            else{
                compareVolumeString=@"name: '成交量(張)'";

            }
            NSRange rangeOfString=[seriseString rangeOfString:compareVolumeString];
//            NSLog(@"rangeOfString.location %d",rangeOfString.location);
//            NSLog(@"seriseString %@",seriseString);
//            NSLog(@"seriseString lengh %d",[seriseString length]);
            if(rangeOfString.location<50000&&rangeOfString.location>0)
            {
                volumeDic=[[NSMutableDictionary alloc]init];
                int compareOffset=0;
                 if ([_stockIndex isEqualToString:@"0"]) {
                     compareOffset=23;
                 }
                else  if ([_stockIndex isEqualToString:@"1"]) {
                    compareOffset=20;
                }
                else
                    compareOffset=23;
                    
                NSString *volumString=[seriseString substringFromIndex:[seriseString rangeOfString:compareVolumeString].location+compareOffset];
                volumString=[volumString substringToIndex:[volumString rangeOfString:@"], yAxis"].location];
//                NSLog(@"volumString %@",volumString);
                NSMutableArray *volumDatas=[[volumString componentsSeparatedByString:@"],"] mutableCopy];
                NSString *cutTail=volumDatas[[volumDatas count]-1];
                cutTail=[cutTail substringToIndex:[cutTail length]-1];
                volumDatas[[volumDatas count]-1]=cutTail;
                //            NSLog(@"datas%@",datas);
                for (NSString *dataStr in volumDatas) {
                    NSArray *dataUnit=[dataStr componentsSeparatedByString:@","];
//                    NSString *time=[self translateTimefrom:[dataUnit[0] substringFromIndex:1]];
//                    NSString *volume=[dataUnit[1] substringToIndex:[dataUnit[1] length ]];
                    
                    //save only befor now
                    if ([[dataUnit[0] substringFromIndex:1] doubleValue]/1000<=dTime && [[dataUnit[0] substringFromIndex:1] doubleValue] >1232496000000) {
//                        NSLog(@"%@ > current :%@",[dataUnit[0] substringFromIndex:1],curTime);
//                        NSLog(@"%@  ",[self translateTimefrom:[dataUnit[0] substringFromIndex:1]]);
                        [volumeDic setObject:[dataUnit[1] substringToIndex:[dataUnit[1] length ]] forKey:[dataUnit[0] substringFromIndex:1]];
                    }

//                    NSLog(@"dataTime:%@,volum:%@",time,volume);
                }
                NSLog(@"[StockHistoryInfo] volum count:%d",[volumeDic count]);
            }
            NSString *_pareString;
            int locationOffset = 0;
            switch (_period) {
                case 0:
                    _pareString=@"id: 'a',";
                    locationOffset=16;
                    break;
                case 1:
                    _pareString=[NSString stringWithFormat:@"%@)', data: [",_stockIndex];
                    locationOffset=15;
                    break;
                case 2:
                    _pareString=@"月K線圖', data: [[";
                    locationOffset=14;
                    break;
                    
                default:
                    break;
            }
            if ([_stockIndex isEqualToString:@"0000"]) {
                compareVolumeString=@"},{ type: 'column', name: '成交量(億)'";
                
            }
            else if([_stockIndex isEqualToString:@"0001"]){
                compareVolumeString=@"},{ type: 'column', name: '成交量'";
                if (_period==PERIOD_WEEK) {
                    _pareString=@"WTX&)', data: [";
                }

            }
            else{
                compareVolumeString=@"},{ type: 'column', name: '成交量(張)'";

            }
            NSString *dataString=[seriseString substringFromIndex:[seriseString rangeOfString:_pareString].location+locationOffset];

            dataString=[dataString substringToIndex:[dataString rangeOfString:@"},{ type: 'column', name: '成交量"].location-2];
//            NSLog(@"dataString :%@",dataString);

            NSMutableArray *datas=[[dataString componentsSeparatedByString:@"],"] mutableCopy];
            NSString *cutTail=datas[[datas count]-1];
            cutTail=[cutTail substringToIndex:[cutTail length]-1];
            datas[[datas count]-1]=cutTail;
//            NSLog(@"datas: %@",datas);
            for (NSString *dataStr in datas) {

                //o:開盤價, h:當日最高價, l:當日最低價,c:成交價/收盤價
                NSArray *dataUnit=[dataStr componentsSeparatedByString:@","];
//                NSString *time=[self translateTimefrom:[dataUnit[0] substringFromIndex:1]];
//                NSString *open=dataUnit[1] ;
//                NSString *high=dataUnit[2] ;
//                NSString *low=dataUnit[3] ;
//                NSString *close=dataUnit[4] ;
//                NSString *volume=[volumeDic objectForKey:[dataUnit[0] substringFromIndex:1]];
                if ([[dataUnit[0] substringFromIndex:1] doubleValue]/1000<dTime && [[dataUnit[0] substringFromIndex:1] doubleValue] >1232496000000) {
                NSString *_sqlInsertValues=[NSString stringWithFormat:@"'%@','%@',%@,%@,%@,%@,%@",_stockIndex,[self translateTimefrom:[dataUnit[0] substringFromIndex:1]],dataUnit[1],dataUnit[2],dataUnit[3],dataUnit[4],[volumeDic objectForKey:[dataUnit[0] substringFromIndex:1]]];
                NSString *_sql;
                //candleViewController format: Date,Open,High,Low,Close,Volume,Adj Close
                NSString *_csvValues=[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n",[self translateShortDatafrom:[dataUnit[0] substringFromIndex:1]],dataUnit[1],dataUnit[2],dataUnit[3],dataUnit[4],[volumeDic objectForKey:[dataUnit[0] substringFromIndex:1]]];
                [csvString insertString:_csvValues atIndex:0 ];
                switch (_period) {
                    case 0:
                        _sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO  s_HistoryChartInfo_D (indexs,time,open,high,low,close,volume) VALUES(%@)",_sqlInsertValues];                            break;
                    case 1:
                        _sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO  s_HistoryChartInfo_W (indexs,time,open,high,low,close,volume)VALUES(%@)",_sqlInsertValues];                            break;
                    case 2:
                        _sql=[NSString stringWithFormat:@"INSERT OR REPLACE INTO  s_HistoryChartInfo_M (indexs,time,open,high,low,close,volume) VALUES(%@)",_sqlInsertValues];                            break;
                        
                    default:
                        break;
                    }
                    if (ALLOW_WRITE_TO_DB) {
                        [dbHelper executeQuery:_sql];
//                        [dbHelper closeDatabase];
                    }
                }
//                NSLog(@"dataTime:%@,dataOpen:%@,dataHigh:%@,dataLow:%@,dataClose:%@",dataTime,dataOpen,dataHigh,dataLow,dataClose);
            }
            NSLog(@"[StockHistoryInfo] datas count:%d",[datas count]);

            //        NSLog(@"contentsTextOfChildElement %@",dataString);
            //        NSLog(@"matchRange.location %d",matchRange.location);
            break;

        }

	}
//    NSLog(@"[wantgoo]csvString:%@",csvString);
    return csvString;
    NSLog(@"end");
}
-(void)parseStockRealtimeInfo:(NSString*)_source stockIndex:(NSString*)_stockIndex
{
	NSString* pattern;
	pattern = @"*";
	DocumentRoot* document = [Element parseHTML: _source];
    NSLog(@"start");
	NSArray* elements = [document selectElements: pattern] ;
	for (Element* element in elements){
        NSMutableDictionary *volumeDic;
        NSString *findPattern=@"script";
        NSString *contentText=[element contentsTextOfChildElement:findPattern];
        NSRange matchRange=[contentText rangeOfString:@"series"];
        // <2147483646 means not in open time ,so no data available
        NSRange noDataMatchRange=[contentText rangeOfString:@"data: []"];
//        NSLog(@"noDataMatchRange%d",noDataMatchRange.location);
        
        //for find string test
//        NSLog(@"matchRange %d",matchRange.location);
//        NSLog(@"contentText %@",contentText);
        if (matchRange.location<1454&&matchRange.location>0) {
            if (noDataMatchRange.location<2147483646) {
                NSLog(@"no data available");
                UIAlertView* alert =[[UIAlertView alloc] initWithTitle:@"Error!" message:@"no data available"delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
                [alert show];
                break;
            }
            NSString *seriseString=[contentText  substringFromIndex:matchRange.location];
            volumeDic=[[NSMutableDictionary alloc]init];
            
            if([seriseString rangeOfString:@"成交量(張)"].location<20000000&&[seriseString rangeOfString:@"成交量(張)"].location>0)
            {
                NSString *volumString=[seriseString substringFromIndex:[seriseString rangeOfString:@"成交量(張)"].location+16];
                volumString=[volumString substringToIndex:[volumString rangeOfString:@"], yAxis"].location];
//                NSLog(@"volumString%@",volumString);
                NSMutableArray *volumDatas=[[volumString componentsSeparatedByString:@"],"] mutableCopy];
                NSString *cutTail=volumDatas[[volumDatas count]-1];
                cutTail=[cutTail substringToIndex:[cutTail length]-1];
                volumDatas[[volumDatas count]-1]=cutTail;
                //            NSLog(@"datas%@",datas);
                for (NSString *dataStr in volumDatas) {
                    NSArray *dataUnit=[dataStr componentsSeparatedByString:@","];
//                    NSString *time=[self translateTimefrom:[dataUnit[0] substringFromIndex:1]];
//                    NSString *volume=[dataUnit[1] substringToIndex:[dataUnit[1] length ]];
                    [volumeDic setObject:[dataUnit[1] substringToIndex:[dataUnit[1] length ]] forKey:[dataUnit[0] substringFromIndex:1]];
//                    NSLog(@"dataTime:%@,volum:%@",volumTime,volumValue);
                }
                
                NSLog(@"[StockRealtimeInfo] volumDatas count:%d",[volumDatas count]);
            }
            //[[1390554171000,45.35],[1390554185000,45.35],[1390554199000,45.35]
            NSString *dataString=[seriseString substringFromIndex:[seriseString rangeOfString:@"data:"].location+7];
            dataString=[dataString substringToIndex:[seriseString rangeOfString:@"] },"].location-37];
//            NSLog(@"dataString%@",dataString);
            NSMutableArray *datas=[[dataString componentsSeparatedByString:@"],"] mutableCopy];
            NSString *cutTail=datas[[datas count]-1];
            cutTail=[cutTail substringToIndex:[cutTail length]-1];
            datas[[datas count]-1]=cutTail;
            //            NSLog(@"datas%@",datas);
            for (NSString *dataStr in datas) {
                
                NSArray *dataUnit=[dataStr componentsSeparatedByString:@","];
//                NSString *time=[self translateTimefrom:[dataUnit[0] substringFromIndex:1]];
//                NSString *price=[dataUnit[1] substringToIndex:[dataUnit[1] length ]];
//                NSString *volume=[volumeDic objectForKey:[dataUnit[0] substringFromIndex:1]];

                NSString *_sql=[NSString stringWithFormat:@"REPLACE INTO  s_Realtime (indexs,time,price,volume) VALUES('%@','%@',%@,%@)",_stockIndex,[self translateTimefrom:[dataUnit[0] substringFromIndex:1]],[dataUnit[1] substringToIndex:[dataUnit[1] length ]],[volumeDic objectForKey:[dataUnit[0] substringFromIndex:1]]];

                if (ALLOW_WRITE_TO_DB) {
                [dbHelper executeQuery:_sql];
//                [dbHelper closeDatabase];

                }
//                NSLog(@"dataTime:%@,value:%@",dataTime,dataValue);
            }
            NSLog(@"[StockRealtimeInfo] datas count:%d",[datas count]);
            //        NSLog(@"contentsTextOfChildElement %@",dataString);
            //        NSLog(@"matchRange.location %d",matchRange.location);
            break;

        }

	}
    NSLog(@"end");
}

-(NSString*)translateShortDatafrom:(NSString*)_sourcedate
{
    long long int _date =[_sourcedate doubleValue];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:_date/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

-(NSString*)translateShortTimefrom:(NSString*)_sourcedate
{
    long long int _date =[_sourcedate doubleValue];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:_date/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

-(NSString*)translateTimefrom:(NSString*)_sourcedate
{
    long long int _date =[_sourcedate doubleValue];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:_date/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setAMSymbol:@"上午"];
//    [formatter setPMSymbol:@"下午"];
    [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *str = [formatter stringFromDate:date];
//    NSLog(@"1390565960000 :%@",str);
    
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//    long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
//    NSString *curTime = [NSString stringWithFormat:@"%llu",dTime];
//    NSLog(@"TIME : %@",curTime);
    return str;
}

@end
