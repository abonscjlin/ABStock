//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import <QuartzCore/QuartzCore.h>
#import "YAxis.h"
#import "MKNetworkOperation.h"
#import "SVSegmentedControl.h"
#import "REFrostedViewController.h"

@interface CandleViewController : UIViewController<UISearchBarDelegate>

@property (nonatomic,retain) Chart *candleChart;
@property (nonatomic,retain) UITableView *autoCompleteView;
@property (nonatomic,retain) UIView *toolBar;
@property (nonatomic,retain) UIView *candleChartFreqView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic) int chartMode;
@property (nonatomic) int tradeStatus;
@property (nonatomic,retain) NSString *lastTime;
@property (nonatomic,retain) UILabel *status;
@property (nonatomic,retain) NSString *req_freq;
@property (nonatomic,retain) NSString *req_type;
@property (nonatomic,retain) NSString *req_url;
@property (nonatomic,retain) NSString *req_security_id;
@property (strong, nonatomic) MKNetworkOperation *currencyOperation;
@property (nonatomic,retain) NSString *stockIndex;

-(id)initWithStockIndex:(NSString *)_stockindex;
-(void)initChart;
-(void)getData;
-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data;
-(void)setData:(NSDictionary *)dic;
-(void)setCategory:(NSArray *)category;
-(BOOL)isCodesExpired;
-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;

@end
