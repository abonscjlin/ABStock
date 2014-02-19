//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CandleViewController.h"
#import "AppConstant.h"
#import "ResourceHelper.h"
#import "SVSegmentedControl.h"
#import "MRCircularProgressView.h"
#import "EnginConstant.h"

#define MAX_K 500
#define PERIODSEGMENT_HEIGHT 20
@interface CandleViewController  (){
	Chart *candleChart;
	UITableView *autoCompleteView;
	UIView *toolBar;
	UIView *candleChartFreqView;
	NSString *lastTime;
	NSTimer *timer;
	UILabel *security;
	UILabel *status;
	int tradeStatus;
	int chartMode;
	NSString *req_freq;
	NSString *req_type;
	NSString *req_url;
	NSString *req_security_id;
    UIColor *chartBackgroundColor;
    SVSegmentedControl *periodSegment;
    UILabel *stockNameLabel;
    UIButton *CancelButton;
    MRCircularProgressView *circularStatus;
}
@end

@implementation CandleViewController

@synthesize candleChart;
@synthesize autoCompleteView;
@synthesize toolBar;
@synthesize candleChartFreqView;
@synthesize timer;
@synthesize chartMode;
@synthesize tradeStatus;
@synthesize lastTime;
@synthesize status;
@synthesize req_freq;
@synthesize req_type;
@synthesize req_url;
@synthesize req_security_id;
@synthesize stockIndex;
-(id)initWithStockIndex:(NSString *)_stockindex
{
    self=[super init];
    if (self) {
        if ([_stockindex isEqualToString:@""]) {
            stockIndex=@"1101";
        }
        stockIndex=_stockindex;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //left menu

    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
            self.automaticallyAdjustsScrollViewInsets = YES;
        }
    #endif
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
	

	//init vars
	self.chartMode  = 1; //1,candleChart
	self.tradeStatus= 1;
	self.req_freq   = @"d";
	self.req_type   = @"H";
	self.req_url    = @"http://ichart.yahoo.com/table.csv?s=%@&g=%@";
	
	[self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
    
	//candleChart
    self.candleChart = [[Chart alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-PERIODSEGMENT_HEIGHT-20)];
    //set chart background color
    chartBackgroundColor=[UIColor colorWithRed:0   green:0 blue:0 alpha:1.000];
    [candleChart setBackgroundColor:chartBackgroundColor withFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-0)];
	[self.view addSubview:candleChart];
    

	//status bar
	self.status = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 200, 40)];
	self.status.font = [UIFont systemFontOfSize:14];
	self.status.backgroundColor = [UIColor clearColor];
    self.status.textColor = [UIColor whiteColor];
	[self.toolBar addSubview:status];

    //circular status
    circularStatus=[[MRCircularProgressView alloc]initWithFrame:CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2-70, 40 , 40)];
    circularStatus.progressArcWidth=5.0f;
    circularStatus.progressColor=[UIColor redColor];
    [circularStatus setProgress:0.0f animated:YES];
    [circularStatus setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:circularStatus];
    
    //period segment
    [self creatPeriodSegmentController];
    
    //cancel button
    CancelButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-28, 5, 27,27)];
    CancelButton.titleLabel.font= [UIFont boldSystemFontOfSize:12];
    [CancelButton setTitle:@"X" forState:UIControlStateNormal];
    [CancelButton setBackgroundColor:[UIColor blackColor]];
    CancelButton.clipsToBounds=YES;
    CancelButton.layer.cornerRadius=3;
    CancelButton.layer.borderColor=[UIColor whiteColor].CGColor;
    CancelButton.layer.borderWidth=1.0f;
    [CancelButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:CancelButton];
    
    //name label
    stockNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
    NSString *stockName=[((NSMutableDictionary*)ApplicationDelegate.stockIndexDic) objectForKey:stockIndex];
    stockNameLabel.text=[NSString stringWithFormat:@"%@ | %@",stockIndex,stockName];
    [stockNameLabel setFont:[UIFont systemFontOfSize:14]];
    [stockNameLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1]];
    [stockNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:stockNameLabel];
    
    //init chart
    [self initChart];

    
    //load default security data
    
	[self getData];
	
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

}
-(void)initChart{
	NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"10",@"10",@"10",@"10",nil];
	[self.candleChart setPadding:padding];
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	[secs addObject:@"4"];
	[secs addObject:@"1"];
	[secs addObject:@"1"];
	[self.candleChart addSections:3 withRatios:secs];
	[self.candleChart getSection:2].hidden = YES;
	[[[self.candleChart sections] objectAtIndex:0] addYAxis:0];
	[[[self.candleChart sections] objectAtIndex:1] addYAxis:0];
	[[[self.candleChart sections] objectAtIndex:2] addYAxis:0];
	
	[self.candleChart getYAxis:2 withIndex:0].baseValueSticky = NO;
	[self.candleChart getYAxis:2 withIndex:0].symmetrical = NO;
	[self.candleChart getYAxis:0 withIndex:0].ext = 0.05;
	NSMutableArray *series = [[NSMutableArray alloc] init];
	NSMutableArray *secOne = [[NSMutableArray alloc] init];
	NSMutableArray *secTwo = [[NSMutableArray alloc] init];
	NSMutableArray *secThree = [[NSMutableArray alloc] init];

	//candleChart init
    [self.candleChart setSeries:series];
	
	[[[self.candleChart sections] objectAtIndex:0] setSeries:secOne];
	[[[self.candleChart sections] objectAtIndex:1] setSeries:secTwo];
	[[[self.candleChart sections] objectAtIndex:2] setSeries:secThree];
	[[[self.candleChart sections] objectAtIndex:2] setPaging:YES];
	
	NSString *indicatorsString =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indicators" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[indicatorsString dataUsingEncoding:NSUTF8StringEncoding]  options:kNilOptions error:&jsonError];
	if(indicatorsString != nil){
		for(NSObject *indicator in json){
			if([indicator isKindOfClass:[NSArray class]]){
				NSMutableArray *arr = [[NSMutableArray alloc] init];
				for(NSDictionary *indic in (NSArray*)indicator){
					NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
					[self setOptions:indic ForSerie:serie];
					[arr addObject:serie];
				}
			    [self.candleChart addSerie:arr];
			}else{
				NSDictionary *indic = (NSDictionary *)indicator;
				NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
				[self setOptions:indic ForSerie:serie];
				[self.candleChart addSerie:serie];
			}
		}
	}
    
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
	[serie setObject:[options objectForKey:@"name"] forKey:@"name"];
	[serie setObject:[options objectForKey:@"label"] forKey:@"label"];
	[serie setObject:[options objectForKey:@"type"] forKey:@"type"];
	[serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
	[serie setObject:[options objectForKey:@"section"] forKey:@"section"];
	[serie setObject:[options objectForKey:@"color"] forKey:@"color"];
	[serie setObject:[options objectForKey:@"negativeColor"] forKey:@"negativeColor"];
	[serie setObject:[options objectForKey:@"selectedColor"] forKey:@"selectedColor"];
	[serie setObject:[options objectForKey:@"negativeSelectedColor"] forKey:@"negativeSelectedColor"];
}


-(BOOL)isCodesExpired{
	NSDate *date = [NSDate date];
	double now = [date timeIntervalSince1970];
	double last = now;
	NSString *autocompTime = (NSString *)[ResourceHelper  getUserDefaults:@"autocompTime"];
    NSLog(@"autocompTime :%@",autocompTime);
	if(autocompTime!=nil){
		last = [autocompTime doubleValue];
		if(now - last >3600*8){
		    return YES;
		}else{
		    return NO;
		}
    }else{
	    return YES;
	}
}

-(int)getPeriodWithInt
{
    if ([req_freq isEqualToString:@"d"]) {
        return PERIOD_DAY;
    }
    else if ([req_freq isEqualToString:@"w"]) {
            return PERIOD_WEEK;
    }
    else  if ([req_freq isEqualToString:@"m"]) {
        return PERIOD_MONTH;
    }
    else
        return 0;
    
}

-(void)getData{

	self.status.text = @"Loading...";
    
    [circularStatus setProgress:0.6f animated:YES];
    [circularStatus setAlpha:1];

	if(chartMode == 0){
		[self.candleChart getSection:2].hidden = YES;
	}else{
	    [self.candleChart getSection:2].hidden = NO;
	}
    [periodSegment setEnabled:NO];
    
    if ([stockIndex isEqualToString:@"0000"]||[stockIndex isEqualToString:@"0001"]) {
        int _period=[self getPeriodWithInt];
        self.currencyOperation=[ApplicationDelegate.wantgooengine getStockHistoryInfo:stockIndex period:_period
            completionHandler:^(NSString* htmlRowdata){
            
                [circularStatus setProgress:0.8f animated:NO];
                
                [self parseData:htmlRowdata];
                [periodSegment setEnabled:YES];
            
        }
                                
            errorHandler:^(NSError* error) {
               NSLog(@"Error info from wantgoo");
               [periodSegment setEnabled:YES];
               [UIView animateWithDuration:0.5 animations:^{
                   [circularStatus setAlpha:0];
               }];
                   
        }];
    }
    else
        self.currencyOperation=[ApplicationDelegate.yahooengine getStockCSV:stockIndex withPeriod:req_freq completionHandler:^(NSString* htmlRowdata){
        
            [circularStatus setProgress:0.8f animated:NO];
            NSLog(@"htmlRowdata %@",htmlRowdata);
            [self parseData:htmlRowdata];
            [periodSegment setEnabled:YES];
        
    }
                            
        errorHandler:^(NSError* error) {
            NSLog(@"Error info from yahoo");
            [periodSegment setEnabled:YES];
            [UIView animateWithDuration:0.5 animations:^{
                [circularStatus setAlpha:0];
            }];
        
    }];
}

- (void)parseData:(NSString *)request
{
    [circularStatus setProgress:0.95f animated:YES];

	self.status.text = @"";
    NSMutableArray *data =[[NSMutableArray alloc] init];
	NSMutableArray *category =[[NSMutableArray alloc] init];

    NSArray *lines = [request componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger idx;

    //    for (idx = lines.count-1; idx > 0; idx--) {
    int max_k=MAX_K;
    if ((MAX_K>lines.count)) {
        max_k=lines.count;
    }
    for (idx = max_k-1; idx > 0; idx--) {

        NSString *line = [lines objectAtIndex:idx];
        if([line isEqualToString:@""]){
            continue;
        }
        NSArray *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        if ([[arr objectAtIndex:5] integerValue]>0 ) {//成交量小於零不記入
            [category addObject:[arr objectAtIndex:0]];
            //Date,Open,High,Low,Close,Volume,Adj Close
            NSMutableArray *item =[[NSMutableArray alloc] init];
            [item addObject:[arr objectAtIndex:1]]; //open
            [item addObject:[arr objectAtIndex:4]]; //close
            [item addObject:[arr objectAtIndex:2]]; //high
            [item addObject:[arr objectAtIndex:3]]; //low
            [item addObject:[arr objectAtIndex:5]]; //vloume
            [data addObject:item];
        }

    }
//    NSLog(@"time :%@",[category objectAtIndex:0]);
	if(data.count==0){
		self.status.text = @"Error!";
        [UIView animateWithDuration:0.5 animations:^{
            [circularStatus setAlpha:0];
        }];
	    return;
	}

	if (chartMode == 0) {
		if([self.req_type isEqualToString:@"T"]){
			if(self.timer != nil)
				[self.timer invalidate];
			
			[self.candleChart reset];
			[self.candleChart clearData];
			[self.candleChart clearCategory];
			
			if([self.req_freq hasSuffix:@"m"]){
				self.req_type = @"L";
				self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getData) userInfo:nil repeats:YES];
			}
		}else{
		    NSString *time = [category objectAtIndex:0];
			if([time isEqualToString:self.lastTime]){
				if([time hasSuffix:@"1500"]){
					if(self.timer != nil)
						[self.timer invalidate];
				}
				return;
			}
			if ([time hasSuffix:@"1130"] || [time hasSuffix:@"1500"]) {
				if(self.tradeStatus == 1){
					self.tradeStatus = 0;
				}
			}else{
				self.tradeStatus = 1;
			}
		}
	}else{
		if(self.timer != nil)
			[self.timer invalidate];
		[self.candleChart reset];
		[self.candleChart clearData];
		[self.candleChart clearCategory];
	}
	
	self.lastTime = [category lastObject];
	
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	[self generateData:dic From:data];
	[self setData:dic];
	
	if(chartMode == 0){
		[self setCategory:category];
	}else{
		NSMutableArray *cate = [[NSMutableArray alloc] init];
		for(int i=60;i<category.count;i++){
			[cate addObject:[category objectAtIndex:i]];
		}
	    [self setCategory:cate];
	}
    
    [circularStatus setProgress:1.0f animated:NO];
	[self.candleChart setNeedsDisplay];

    [UIView animateWithDuration:1 animations:^{
        [circularStatus setAlpha:0];
        
    }];
//    [circularStatus setHidden:YES];

}

-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data{
	if(self.chartMode == 1){
        NSLog(@"start caculate indicator");
        //data format
        //[0]:open,[1]:close,[2]:high,[3]:low,[4]:volume
        
		//price
		NSMutableArray *price = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			[price addObject: [data objectAtIndex:i]];
		}
		[dic setObject:price forKey:@"price"];
		
		//VOL
		NSMutableArray *vol = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:4] floatValue]/100]];
			[vol addObject:item];
		}
		[dic setObject:vol forKey:@"vol"];
        NSLog(@"data count:%d",[data count]);
        
        //MV 5
		NSMutableArray *mv5 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-5;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:4] floatValue];
			}
			val = val/5/100;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[mv5 addObject:item];
		}
		[dic setObject:mv5 forKey:@"mv5"];
        
        //MV 20
		NSMutableArray *mv20 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-20;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:4] floatValue];
			}
			val = val/20/100;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[mv20 addObject:item];
		}
		[dic setObject:mv20 forKey:@"mv20"];
        
        //MV 60
		NSMutableArray *mv60 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-60;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:4] floatValue];
			}
			val = val/60/100;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[mv60 addObject:item];
		}
		[dic setObject:mv60 forKey:@"mv60"];
        
//        NSLog(@"[data]:%@",data);
        
        //MA 5
		NSMutableArray *ma5 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-5;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/5;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma5 addObject:item];
		}
		[dic setObject:ma5 forKey:@"ma5"];
        
		//MA 10
		NSMutableArray *ma10 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-10;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/10;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma10 addObject:item];
		}
		[dic setObject:ma10 forKey:@"ma10"];
		
        //MA 20
		NSMutableArray *ma20 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-20;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/20;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma20 addObject:item];
		}
		[dic setObject:ma20 forKey:@"ma20"];
		
		//MA 60
		NSMutableArray *ma60 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-60;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/60;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma60 addObject:item];
		}
		[dic setObject:ma60 forKey:@"ma60"];
        
        //CCI 14
        int cciConstant=14;
		NSMutableArray *cci =[[NSMutableArray alloc] init];
        NSMutableArray *Tptn=[[NSMutableArray alloc]init];
        NSMutableArray *MDtn=[[NSMutableArray alloc]init];
        NSMutableArray *MAtn=[[NSMutableArray alloc]init];

	    for(int i = 60-(cciConstant);i < data.count;i++){
            float Tpt=0;
            float MAt=0;
            for(int j=i;j>i-cciConstant;j--){
                //TP t ＝ ( 最高價t ＋ 最低價t ＋ 收盤價t  ) ／３
                Tpt += ([[[data objectAtIndex:j] objectAtIndex:1] floatValue]+[[[data objectAtIndex:j] objectAtIndex:2] floatValue]+[[[data objectAtIndex:j] objectAtIndex:3] floatValue])/3;
                /*FOR LOG*/
//                NSLog(@"TPt%d = (%@ + %@ +%@ )/%d = %f",j,[[data objectAtIndex:j] objectAtIndex:1],[[data objectAtIndex:j] objectAtIndex:2],[[data objectAtIndex:j] objectAtIndex:3],cciConstant,([[[data objectAtIndex:j] objectAtIndex:1] floatValue]+[[[data objectAtIndex:j] objectAtIndex:2] floatValue]+[[[data objectAtIndex:j] objectAtIndex:3] floatValue])/3);
			}
            //MA t ＝(  TPt  +  TPt-1  + ．．． +  TP t-n+1 ) ／ ｎ
            MAt=Tpt/cciConstant;
            
            [Tptn addObject:[NSNumber numberWithFloat:([[[data objectAtIndex:i] objectAtIndex:1] floatValue]+[[[data objectAtIndex:i] objectAtIndex:2] floatValue]+[[[data objectAtIndex:i] objectAtIndex:3] floatValue])/3]];

            [MAtn addObject:[NSNumber numberWithFloat:MAt]];
            /*FOR LOG*/
//            NSLog(@"MAt%d = %f",i,Tpt/cciConstant);
		}
        /*FOR LOG*/
//        NSLog(@"MAtn :%@",MAtn);
//        NSLog(@"Tptn :%@",Tptn);
        int keeper=0;
        for (int i= cciConstant-1; i<[Tptn count]; i++) {
            float MD=0;
            float ccit=0;
            for(int j=i;j>i-cciConstant;j--){
                MD+=fabs([[MAtn objectAtIndex:j]floatValue]-[[Tptn objectAtIndex:j]floatValue]);
                /*FOR LOG*/
                //                NSLog(@"MD%d=| %@-%@ | =%f",j,[MAtn objectAtIndex:j],[Tptn objectAtIndex:j],fabs([[MAtn objectAtIndex:j]floatValue]-[[Tptn objectAtIndex:j]floatValue]));
            }
            /*FOR LOG*/
//            NSLog(@"MDt%d=%f",i,MD/cciConstant);
            //MD t ＝(｜MAt－TPt｜＋｜MAt-1－TPt-1 ｜＋．．．．＋｜MAt-n+1－TPt-n+1｜)／ｎ
            [MDtn addObject:[NSNumber numberWithFloat: MD/cciConstant] ];
            if (keeper>0) {//前-n+i個資料不要
                ccit=([[Tptn objectAtIndex:i]floatValue]-[[MAtn objectAtIndex:i]floatValue])/(0.015f*[[MDtn objectAtIndex:i-cciConstant+1] floatValue]);                
                NSMutableArray *item = [[NSMutableArray alloc] init];
                [item addObject:[@"" stringByAppendingFormat:@"%f",ccit]];
                [cci addObject:item];
            }
            keeper++;

        }
        /*FOR LOG*/
//        NSLog(@"MDtn :%@",MDtn);
//        NSLog(@"CCI : %@",cci);
		[dic setObject:cci forKey:@"cci"];
        
        
        //CCI Upper and Lower Line
		NSMutableArray *cciUpperLine = [[NSMutableArray alloc] init];
        NSMutableArray *cciLowerLine = [[NSMutableArray alloc] init];
        float upperNoumber = 100;
        float lowerNumber = -100;
	    for(int i = 60;i < data.count;i++){
			NSMutableArray *upperitem = [[NSMutableArray alloc] init];
			[upperitem addObject:[@"" stringByAppendingFormat:@"%f",upperNoumber]];
			[cciUpperLine addObject:upperitem];
            
            NSMutableArray *loweritem = [[NSMutableArray alloc] init];
			[loweritem addObject:[@"" stringByAppendingFormat:@"%f",lowerNumber]];
			[cciLowerLine addObject:loweritem];
            
		}
		[dic setObject:cciUpperLine forKey:@"cciUpperLine"];
		[dic setObject:cciLowerLine forKey:@"cciLowerLine"];
        
        
        //平均圖  KINKO
		NSMutableArray *SK1 = [[NSMutableArray alloc] init];
        NSMutableArray *SK2 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float max9 = 0;
            float max26 = 0;
			float max52 = 0;
			float min9 = 99999;
			float min26 = 99999;
			float min52 = 99999;
            float sk1=0;
            float sk2=0;
            int arrayCount=0;
            for(int j=i;j>i-52;j--){
                if (arrayCount<9) {
                    max9=max9>[[[data objectAtIndex:j] objectAtIndex:2] floatValue]?max9:[[[data objectAtIndex:j] objectAtIndex:2] floatValue];
                    min9=min9<[[[data objectAtIndex:j] objectAtIndex:3] floatValue]?min9:[[[data objectAtIndex:j] objectAtIndex:3] floatValue];
                }
                if (arrayCount<26) {
                    max26=max26>[[[data objectAtIndex:j] objectAtIndex:2] floatValue]?max26:[[[data objectAtIndex:j] objectAtIndex:2] floatValue];
                    min26=min26<[[[data objectAtIndex:j] objectAtIndex:3] floatValue]?min26:[[[data objectAtIndex:j] objectAtIndex:3] floatValue];
                    
                }
                if (arrayCount<52) {
                    max52=max52>[[[data objectAtIndex:j] objectAtIndex:2] floatValue]?max52:[[[data objectAtIndex:j] objectAtIndex:2] floatValue];
                    min52=min52<[[[data objectAtIndex:j] objectAtIndex:3] floatValue]?min52:[[[data objectAtIndex:j] objectAtIndex:3] floatValue];
                }
                arrayCount++;
            }
//            NSLog(@"i:%d MAX52:%f,MIN52:%f",i,max52,min52);

            sk1=((max9+min9)/2+(max26+min26)/2)/2;
            sk2=(max52+min52)/2;
            
			NSMutableArray *itemSK1 = [[NSMutableArray alloc] init];
			[itemSK1 addObject:[@"" stringByAppendingFormat:@"%f",sk1]];
			[SK1 addObject:itemSK1];
			NSMutableArray *itemSK2 = [[NSMutableArray alloc] init];
			[itemSK2 addObject:[@"" stringByAppendingFormat:@"%f",sk2]];
			[SK2 addObject:itemSK2];
		}
		[dic setObject:SK1 forKey:@"sk1"];
		[dic setObject:SK2 forKey:@"sk2"];
//        NSLog(@"SK1:%@",SK1);
//        NSLog(@"SK2:%@",SK2);
//        NSLog(@"cci count %d",[cci count]);
//        NSLog(@"ma10 count %d",[ma10 count]);
//        NSLog(@"price count %d",[price count]);
//        NSLog(@"SK1 count %d",[SK1 count]);


		
		//KDJ
		NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
		NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
		NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
		float prev_k = 50;
		float prev_d = 50;
        float rsv = 0;
	    for(int i = 60;i < data.count;i++){
			float h  = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
			float l = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
			float c = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
		    for(int j=i;j>i-10;j--){
				if([[[data objectAtIndex:j] objectAtIndex:2] floatValue] > h){
				    h = [[[data objectAtIndex:j] objectAtIndex:2] floatValue];
				}
				
				if([[[data objectAtIndex:j] objectAtIndex:3] floatValue] < l){
					l = [[[data objectAtIndex:j] objectAtIndex:3] floatValue];
				}
			}
            
            if(h!=l)
			  rsv = (c-l)/(h-l)*100;
            float k = 2*prev_k/3+1*rsv/3;
			float d = 2*prev_d/3+1*k/3;
			float j = d+2*(d-k);
			
			prev_k = k;
			prev_d = d;
			
			NSMutableArray *itemK = [[NSMutableArray alloc] init];
			[itemK addObject:[@"" stringByAppendingFormat:@"%f",k]];
			[kdj_k addObject:itemK];
			NSMutableArray *itemD = [[NSMutableArray alloc] init];
			[itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
			[kdj_d addObject:itemD];
			NSMutableArray *itemJ = [[NSMutableArray alloc] init];
			[itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
			[kdj_j addObject:itemJ];
		}
		[dic setObject:kdj_k forKey:@"kdj_k"];
		[dic setObject:kdj_d forKey:@"kdj_d"];
		[dic setObject:kdj_j forKey:@"kdj_j"];
		
		//VR
//		NSMutableArray *vr = [[NSMutableArray alloc] init];
//	    for(int i = 60;i < data.count;i++){
//			float inc = 0;
//			float dec = 0;
//			float eq  = 0;
//		    for(int j=i;j>i-24;j--){
//				float o = [[[data objectAtIndex:j] objectAtIndex:0] floatValue];
//				float c = [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
//
//				if(c > o){
//				    inc += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
//				}else if(c < o){
//				    dec += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
//				}else{
//				    eq  += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
//				}
//			}
//			
//			float val = (inc+1*eq/2)/(dec+1*eq/2);
//			NSMutableArray *item = [[NSMutableArray alloc] init];
//			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
//			[vr addObject:item];
//			[item release];
//		}
//		[dic setObject:vr forKey:@"vr"];
//		[vr release];
        
		//RSI6
        //		NSMutableArray *rsi6 = [[NSMutableArray alloc] init];
        //	    for(int i = 60;i < data.count;i++){
        //			float incVal  = 0;
        //			float decVal = 0;
        //			float rs = 0;
        //		    for(int j=i;j>i-6;j--){
        //				float interval = [[[data objectAtIndex:j] objectAtIndex:1] floatValue]-[[[data objectAtIndex:j] objectAtIndex:0] floatValue];
        //				if(interval >= 0){
        //				    incVal += interval;
        //				}else{
        //				    decVal -= interval;
        //				}
        //			}
        //
        //			rs = incVal/decVal;
        //			float rsi =100-100/(1+rs);
        //
        //			NSMutableArray *item = [[NSMutableArray alloc] init];
        //			[item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
        //			[rsi6 addObject:item];
        //			[item release];
        //
        //		}
        //		[dic setObject:rsi6 forKey:@"rsi6"];
        //		[rsi6 release];
        //
        //		//RSI12
        //		NSMutableArray *rsi12 = [[NSMutableArray alloc] init];
        //	    for(int i = 60;i < data.count;i++){
        //			float incVal  = 0;
        //			float decVal = 0;
        //			float rs = 0;
        //		    for(int j=i;j>i-12;j--){
        //				float interval = [[[data objectAtIndex:j] objectAtIndex:1] floatValue]-[[[data objectAtIndex:j] objectAtIndex:0] floatValue];
        //				if(interval >= 0){
        //				    incVal += interval;
        //				}else{
        //				    decVal -= interval;
        //				}
        //			}
        //
        //			rs = incVal/decVal;
        //			float rsi =100-100/(1+rs);
        //
        //			NSMutableArray *item = [[NSMutableArray alloc] init];
        //			[item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
        //			[rsi12 addObject:item];
        //			[item release];
        //		}
        //		[dic setObject:rsi12 forKey:@"rsi12"];
        //		[rsi12 release];

        
		//WR
        //		NSMutableArray *wr = [[NSMutableArray alloc] init];
        //	    for(int i = 60;i < data.count;i++){
        //			float h  = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
        //			float l = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
        //			float c = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
        //		    for(int j=i;j>i-10;j--){
        //				if([[[data objectAtIndex:j] objectAtIndex:2] floatValue] > h){
        //				    h = [[[data objectAtIndex:j] objectAtIndex:2] floatValue];
        //				}
        //						 
        //				if([[[data objectAtIndex:j] objectAtIndex:3] floatValue] < l){
        //					l = [[[data objectAtIndex:j] objectAtIndex:3] floatValue];
        //				}
        //			}
        //			
        //			float val = (h-c)/(h-l)*100;
        //			NSMutableArray *item = [[NSMutableArray alloc] init];
        //			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
        //			[wr addObject:item];
        //			[item release];
        //		}
        //		[dic setObject:wr forKey:@"wr"];
        //		[wr release];
	}else{
		//price 
		NSMutableArray *price = [[NSMutableArray alloc] init];
	    for(int i = 0;i < data.count;i++){
			[price addObject: [data objectAtIndex:i]];
		}
		[dic setObject:price forKey:@"price"];
		
		//VOL
		NSMutableArray *vol = [[NSMutableArray alloc] init];
	    for(int i = 0;i < data.count;i++){
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:4] floatValue]/100]];
			[vol addObject:item];
		}
		[dic setObject:vol forKey:@"vol"];
		
	}
//    NSLog(@"dic %@",dic);
    NSLog(@"end caculate indicator");

}

-(void)setData:(NSDictionary *)dic{
	[self.candleChart appendToData:[dic objectForKey:@"price"] forName:@"price"];
	[self.candleChart appendToData:[dic objectForKey:@"vol"] forName:@"vol"];
	
    [self.candleChart appendToData:[dic objectForKey:@"mv5"] forName:@"mv5"];
	[self.candleChart appendToData:[dic objectForKey:@"mv20"] forName:@"mv20"];
	[self.candleChart appendToData:[dic objectForKey:@"mv60"] forName:@"mv60"];
    
    [self.candleChart appendToData:[dic objectForKey:@"ma5"] forName:@"ma5"];
	[self.candleChart appendToData:[dic objectForKey:@"ma10"] forName:@"ma10"];
	[self.candleChart appendToData:[dic objectForKey:@"ma20"] forName:@"ma20"];
	[self.candleChart appendToData:[dic objectForKey:@"ma60"] forName:@"ma60"];

    [self.candleChart appendToData:[dic objectForKey:@"cci"] forName:@"cci"];
    [self.candleChart appendToData:[dic objectForKey:@"cciUpperLine"] forName:@"cciUpperLine"];
    [self.candleChart appendToData:[dic objectForKey:@"cciLowerLine"] forName:@"cciLowerLine"];

	
	[self.candleChart appendToData:[dic objectForKey:@"kdj_k"] forName:@"kdj_k"];
	[self.candleChart appendToData:[dic objectForKey:@"kdj_d"] forName:@"kdj_d"];
	[self.candleChart appendToData:[dic objectForKey:@"kdj_j"] forName:@"kdj_j"];
	
    
	[self.candleChart appendToData:[dic objectForKey:@"sk1"] forName:@"sk1"];
	[self.candleChart appendToData:[dic objectForKey:@"sk2"] forName:@"sk2"];

    
    //	[self.candleChart appendToData:[dic objectForKey:@"rsi6"] forName:@"rsi6"];
    //	[self.candleChart appendToData:[dic objectForKey:@"rsi12"] forName:@"rsi12"];
	
    //	[self.candleChart appendToData:[dic objectForKey:@"wr"] forName:@"wr"];
    //	[self.candleChart appendToData:[dic objectForKey:@"vr"] forName:@"vr"];
    
	NSMutableDictionary *serie = [self.candleChart getSerie:@"price"];
	if(serie == nil)
		return;
	if(self.chartMode == 1){
		[serie setObject:@"candle" forKey:@"type"];
	}else{
		[serie setObject:@"line" forKey:@"type"];
	}
}

-(void)setCategory:(NSArray *)category{
	[self.candleChart appendToCategory:category forName:@"price"];
	[self.candleChart appendToCategory:category forName:@"line"];
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self.timer invalidate];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


-(void)creatPeriodSegmentController
{
    [periodSegment removeFromSuperview];
    periodSegment = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Day", @"Week", @"Month", nil]];
    [periodSegment addTarget:self action:@selector(periodChanged:) forControlEvents:UIControlEventValueChanged];
	periodSegment.crossFadeLabelsOnDrag = YES;
    [periodSegment setFont:[UIFont systemFontOfSize:12]];
	periodSegment.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
    [periodSegment setFrame:CGRectMake(0, self.view.frame.size.height-PERIODSEGMENT_HEIGHT, self.view.frame.size.width, PERIODSEGMENT_HEIGHT)];
    if ([req_freq isEqualToString:@"d"]) {
        [periodSegment setSelectedSegmentIndex:0 animated:NO];
    }
    else if ([req_freq isEqualToString:@"w"]) {
        [periodSegment setSelectedSegmentIndex:1 animated:NO];
    }
    else if ([req_freq isEqualToString:@"m"]) {
        [periodSegment setSelectedSegmentIndex:2 animated:NO];
    }
    else
        [periodSegment setSelectedSegmentIndex:0 animated:NO];

//    NSLog(@"periodSegment width:%f",periodSegment.frame.size.width);
    [self.view addSubview:periodSegment];
    
}

- (void) viewWillLayoutSubviews
{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //Default orientation
    if(orientation == 0)
    {
        
    }
    //Do something if the orientation is in Portrait
    else if(orientation == UIInterfaceOrientationPortrait)
    {NSLog(@"orientation Portrait");
        [self.candleChart setFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-PERIODSEGMENT_HEIGHT-20)];
        [candleChart setBackgroundColor:chartBackgroundColor withFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self creatPeriodSegmentController];
        [CancelButton setFrame:CGRectMake(self.view.frame.size.width-28, 5, 27,27)];
        [CancelButton setNeedsDisplay];

        [circularStatus setFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2-70, 40 , 40)];
        [circularStatus setNeedsDisplay];
        [self.candleChart setNeedsDisplay];

    }
    // Do something if Left
    else if((orientation == UIInterfaceOrientationLandscapeLeft)||(orientation == UIInterfaceOrientationLandscapeRight))
    {NSLog(@"orientation LandscapeLeft");
        
        [self.candleChart setFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-PERIODSEGMENT_HEIGHT-20)];
        [candleChart setBackgroundColor:chartBackgroundColor withFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width-0)];
        [self creatPeriodSegmentController];
        [CancelButton setFrame:CGRectMake(self.view.frame.size.width-28, 5, 27,27)];
        [CancelButton setNeedsDisplay];

        [circularStatus setFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 40 , 40)];
        [circularStatus setNeedsDisplay];
        
        [self.candleChart setNeedsDisplay];

    }
}

- (void)periodChanged:(SVSegmentedControl*)segmentedControl {
//	NSLog(@"segmentedControl %d did select index %d (via UIControl method)", segmentedControl.tag, segmentedControl.selectedSegmentIndex);
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            req_freq=@"d";
            [self getData];
            break;
        case 1:
            req_freq=@"w";
            [self getData];
            break;
        case 2:
            req_freq=@"m";
            [self getData];
            break;
        default:
            break;
    }
    [circularStatus setProgress:0.3f animated:YES];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
