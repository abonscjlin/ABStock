//
//  ViewController.m
//  ABStock
//
//  Created by fih on 2013/12/23.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import "ViewController.h"
#import "RegexKitLite.h"
#import "SqliteHelper.h"
#import "UIView+JDFlipImageView.h"
#import "AppConstant.h"
#import "EnginConstant.h"
@interface ViewController ()
{
//    ServerAPI *serverAPI;
    NSArray *stockInfo;
    NSUserDefaults *userDef;
    NSMutableDictionary *stocksIndexDic;
    SqliteHelper *dbHelper ;
}
@end

@implementation ViewController
@synthesize     inputStockNo;
@synthesize stockNameLab;
@synthesize stockIndexLab;
@synthesize stockRatioLab;
@synthesize stockChangeLab;
@synthesize stockPriceLab;
@synthesize stockUpdateTime;
@synthesize stockCellView;
@synthesize newsLabel;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    serverAPI             = [[ServerAPI alloc] init];
//    serverAPI.delegate    = self;
    [inputStockNo setDelegate:self];
    inputStockNo.keyboardType=UIKeyboardTypeNumberPad;
    
    
    newsLabel.marqueeType = MLContinuous;
    newsLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    newsLabel.continuousMarqueeExtraBuffer = 50.0f;
    newsLabel.numberOfLines = 1;
    newsLabel.opaque = NO;
    newsLabel.enabled = YES;
    newsLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    newsLabel.textAlignment = NSTextAlignmentLeft;
    newsLabel.text=@"this is a test newsthis is a test newsthis is a test newsthis is a test newsthis is a test newsthis is a test newsthis is a test newsthis is a test news";
    
    userDef =[NSUserDefaults standardUserDefaults];
    stocksIndexDic=[[userDef objectForKey:KEY_StocksIndex]mutableCopy];
    dbHelper = [SqliteHelper newInstance];

    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 5
                                             target: self
                                           selector: @selector(getRealtimeCSVRand)
                                           userInfo: nil
                                            repeats: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echoNotification:) name:@"showSomething" object:nil];

}
- (IBAction)sqltest:(id)sender {

    NSString *sql = @"SELECT indexs, name  FROM s_Index";
    sqlite3_stmt *statement = [dbHelper prepareQuery:sql];

    while(sqlite3_step(statement) == SQLITE_ROW){
//        int pid = sqlite3_column_int(statement, 0);
        NSString *index = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];

        NSLog(@"index: %@, name: %@", index, name);
    }
    sqlite3_finalize(statement);
    
}
- (IBAction)trigeNotification:(id)sender {
    NSMutableArray *_ar=[[NSMutableArray alloc]init];
    [_ar addObject:@"gogo"];
    [_ar addObject:@"gogo1"];
    [_ar addObject:@"gogo2"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSomething" object:_ar];
}
-(void)echoNotification:(NSNotification*)notification
{
    NSArray *anyArray = [notification object];
    
    NSLog(@"%@", [anyArray componentsJoinedByString:@"\n"]);
}
- (IBAction)getNews:(id)sender {

    NSString *url=GOOGLENWS_STOCK_longURL([[stocksIndexDic objectForKey:inputStockNo.text] mk_urlEncodedString] );
    RssViewController *rssVC=[[RssViewController alloc]initWithURL:url];
//    self.currencyOperation=[ApplicationDelegate.googlenewsengine getGoogleNews:[stocksIndexDic objectForKey:inputStockNo.text]
//                                                                completionHandler:^(NSMutableArray *chartInfo) {
//                                                                    NSLog(@"name:%@",[stocksIndexDic objectForKey:inputStockNo.text]);
//                                                                    NSLog(@"realtime info from google news ");
//                                                                }
//                                                                     errorHandler:^(NSError* error) {
//                                                                         NSLog(@"Error info from google news");
//                                                                         
//                                                                     }];
    
    
}
- (void)getRealtimeCSVRand {
    
    NSArray *indexKey=[stocksIndexDic allKeys];
    //    int *randIndex =arc4random() % [indexKey count] -1;
    NSString *stockIndex=indexKey[arc4random() % ([indexKey count] -1)];
//    self.currencyOperation=[ApplicationDelegate.wantgooengine getRealTimeStockCSV:stockIndex
//                                                                completionHandler:^(NSMutableArray *rowDatas) {
//                                                                    NSLog(@"name:%@",[stocksIndexDic objectForKey:stockIndex]);
//                                                                    NSLog(@"realtime info from wantgoo ");
//                                                                    self.stockChangeLab.text =rowDatas[STOCK_CHANGE];
//                                                                    self.stockRatioLab.text=rowDatas[STOCK_RATIO];
//                                                                    self.stockIndexLab.text=stockIndex;
//                                                                    self.stockNameLab.text=[stocksIndexDic objectForKey:stockIndex];
//                                                                    self.stockPriceLab.text=rowDatas[STOCK_PRICE];
//                                                                    self.stockUpdateTime.text=rowDatas[STOCK_TIME];
//                                                                    if ([[rowDatas[STOCK_RATIO] substringToIndex:1 ] isEqualToString:@"+" ]) {
//                                                                        stockRatioLab.textColor =[UIColor redColor];
//                                                                    }
//                                                                    else if ([[rowDatas[STOCK_RATIO]substringToIndex:1 ] isEqualToString:@"-" ]) {
//                                                                        stockRatioLab.textColor=[UIColor greenColor];
//                                                                    }
//                                                                }
//                                                                     errorHandler:^(NSError* error) {
//                                                                         NSLog(@"Error info from wantgoo");
//                                                                         
//                                                                     }];
    
    
    self.currencyOperation=[ApplicationDelegate.tseengine  getRealTimeStockCSV:stockIndex
                                                                completionHandler:^(NSMutableArray *rowDatas) {
                                                                    NSLog(@"name:%@",[stocksIndexDic objectForKey:stockIndex]);
                                                                    NSLog(@"realtime info from tse ");
                                                                    double unch=([rowDatas[TSE_Stock_max] doubleValue] + [rowDatas[TSE_Stock_min] doubleValue])/2;
                                                                    double ratio=[rowDatas[TSE_Stock_Ratio] doubleValue];
                                                                    
                                                                    self.stockRatioLab.text=[NSString stringWithFormat:@"%.2f",ratio];
                                                                    self.stockIndexLab.text=stockIndex;
                                                                    self.stockNameLab.text=[stocksIndexDic objectForKey:stockIndex];
                                                                    self.stockPriceLab.text=rowDatas[TSE_Stock_c];
                                                                    self.stockUpdateTime.text=rowDatas[TSE_Stock_time];
                                                                    if (ratio>=0) {
                                                                        stockRatioLab.textColor =[UIColor colorWithRed:0.855 green:0.000 blue:0.000 alpha:1.000];
                                                                        self.stockChangeLab.text =[NSString stringWithFormat:@"▲%@",rowDatas[TSE_Stock_change]];

                                                                        
                                                                    }
                                                                    else {
                                                                        stockRatioLab.textColor=[UIColor colorWithRed:0.000 green:0.855 blue:0.000 alpha:1.000];
                                                                        self.stockChangeLab.text =[NSString stringWithFormat:@"▼%@",rowDatas[TSE_Stock_change]];

                                                                    }
                                                                    [self.stockCellView updateWithFlipAnimationUpdates:^{
                                                                        
                                                                    }];
                                                                  
                                                                }
                                                                     errorHandler:^(NSError* error) {
                                                                         NSLog(@"Error info from tse");
                                                                         
                                                                     }];
    
    
}

- (IBAction)getRealtimeCSV:(id)sender {
    
    self.currencyOperation=[ApplicationDelegate.wantgooengine getRealTimeStockCSV:inputStockNo.text
        completionHandler:^(NSMutableArray *chartInfo) {
                    NSLog(@"name:%@",[stocksIndexDic objectForKey:inputStockNo.text]);
                    NSLog(@"realtime info from wantgoo ");
                  }
                       errorHandler:^(NSError* error) {
                           NSLog(@"Error info from wantgoo");
                           
                       }];
    
//    self.currencyOperation=[ApplicationDelegate.tseengine getRealTimeStockCSV:inputStockNo.text
//                                                                completionHandler:^(NSMutableArray *chartInfo) {
//                                                                    NSLog(@"name:%@",[stocksIndexDic objectForKey:inputStockNo.text]);
//                                                                    NSLog(@"realtime info from tse ");
//                                                                }
//                                                                     errorHandler:^(NSError* error) {
//                                                                         NSLog(@"Error info from tse");
//                                                                         
//                                                                     }];
    
    
}
- (IBAction)getStocksIndex:(id)sender {
    self.currencyOperation=[ApplicationDelegate.stockdogengine getStocksIndex:nil
    completionHandler:^(NSMutableArray *chartInfo){
        NSLog(@"get stocks index");
    } errorHandler:^(NSError* error){
        
    }];

}
- (IBAction)getHisInfo:(id)sender {
    
    dispatch_group_t group = dispatch_group_create();
    for (int i=0; i<1; i++) {
//        dispatch_group_enter(group);
        
           self.currencyOperation=[ApplicationDelegate.wantgooengine getStockHistoryInfo:inputStockNo.text period:PERIOD_WEEK completionHandler:^(NSMutableArray *chartInfo) {
    ////            NSLog(@"chart info from wantgoo :%@",chartInfo);
               
//               dispatch_group_leave(group);

            }
            errorHandler:^(NSError* error) {
               NSLog(@"Error info from wantgoo");
//                dispatch_group_leave(group);
            }];
//        dispatch_group_leave(group);

    }
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        // Do whatever you need to do when all requests are finished
//        NSLog(@"all down!");
//    });
}
- (IBAction)getRealtime:(id)sender {
    self.currencyOperation=[ApplicationDelegate.wantgooengine getRealTimeStockChartInfo:inputStockNo.text
                                                                      completionHandler:^(NSMutableArray *chartInfo) {
                                                                          
                                                                          NSLog(@"realtime info from wantgoo ");
                                                                      }
                                                                           errorHandler:^(NSError* error) {
                                                                               NSLog(@"Error info from wantgoo");
                                                                               
                                                                           }];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    inputStockNo.text=@"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)refershStockInfo
{
//    [serverAPI requestStockNo:inputStockNo.text];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
