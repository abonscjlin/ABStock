//
//  StockQuoteTableCell.m
//  ABStock
//
//  Created by fih on 2014/2/1.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "StockQuoteTableCell.h"
#define maxNewsFeed 5
enum CELL_Type{
    SearchStockType=0,
    WatchListType=1
}CELL_Type;

@interface StockQuoteTableCell ()
{
    NSTimer *timer;
    BOOL  isStartedUpdate;
    MWFeedParser *feedParser;
    NSURL *feedURL;
    int newsFeedIndex;
    NSDateFormatter *formatter;
    BOOL isNewTitleFirst;
    UILocalNotification *localNotification;
    int cellType;
}

@end

@implementation StockQuoteTableCell
@synthesize nameLabel;
@synthesize priceLabel;
@synthesize indexLabel;
@synthesize newsLabel;
@synthesize timeLabel;
@synthesize ratioLabel;
@synthesize mainCellView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}
-(void)initAllState
{
    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
    isNewTitleFirst=YES;
    localNotification=[[UILocalNotification alloc]init];
    [self setStockNews];
    [self startAutoUpdate];
    [self startGetNews];
}
-(void)setCellType:(int)_type
{
    cellType=_type;
}
-(void)fireLocalNotificationWithMessage:(NSString*)_msg
{
    if (EnableLocalNotification) {
        
        NSDate *now=[NSDate new];
        localNotification.fireDate=[now dateByAddingTimeInterval:3]; //触发通知的时间
        localNotification.repeatInterval=0;
        localNotification.applicationIconBadgeNumber=1;
        localNotification.soundName=UILocalNotificationDefaultSoundName;
        localNotification.alertBody=_msg;
    //    localNotification.alertLaunchImage=@"ABSTOCK-LOGO.png";
        localNotification.alertAction = @"OK";  //提示框按钮
        localNotification.hasAction = YES; //是否显示额外的按钮，为no时alertAction消失
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:indexLabel.text forKey:@"index"];
        localNotification.userInfo = infoDic;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}
-(void)startGetNews
{
    newsFeedIndex=0;
    newsLabel.text=@"";
    feedURL=[NSURL URLWithString:GOOGLENWS_STOCK_longURL([nameLabel.text mk_urlEncodedString])];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
    
}
-(void)setStockNews
{
    isStartedUpdate=NO;
    newsLabel.marqueeType = MLContinuous;
    newsLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    newsLabel.continuousMarqueeExtraBuffer = 50.0f;
    newsLabel.numberOfLines = 1;
    newsLabel.opaque = NO;
    newsLabel.enabled = YES;
    newsLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    newsLabel.textAlignment = NSTextAlignmentLeft;
    
}


#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//	NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (newsFeedIndex<=maxNewsFeed) {
        NSString *newsTitle=[item.title componentsSeparatedByString:@" - "][0];
        if (item.date)
        {
            if (isNewTitleFirst) {
                newsLabel.text=[NSString stringWithFormat:@"%@ - %@",newsTitle,[formatter stringFromDate:item.date]];
                isNewTitleFirst=NO;
            }
            else
                newsLabel.text=[NSString stringWithFormat:@"%@ - %@ | %@",newsTitle,[formatter stringFromDate:item.date],newsLabel.text ];
        }
        else{
            
            if (isNewTitleFirst) {
                newsLabel.text=[NSString stringWithFormat:@"%@",newsTitle];
                isNewTitleFirst=NO;
            }
            else
                newsLabel.text=[NSString stringWithFormat:@"%@ | %@",newsTitle,newsLabel.text];

        }
    }
    newsFeedIndex++;
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
//    NSLog(@"parsedItems:%@",parsedItems);
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);

    newsLabel.text=@"";

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)startAutoUpdate
{
    if (!isStartedUpdate&&cellType!=SearchStockType) {
    timer = [NSTimer scheduledTimerWithTimeInterval: UPDATE_INTERVAL_TIME
                                             target: self
                                           selector: @selector(getRealtimeInfo:)
                                           userInfo: nil
                                            repeats: YES];
        NSLog(@"%@ start auto update",nameLabel.text);
        isStartedUpdate=YES;
    }
}
-(void)getRealtimeInfo:(NSTimer *)timer
{
    //台指期&&大盤
    if ([indexLabel.text isEqualToString:@"0000"]||[indexLabel.text isEqualToString:@"0001"])
        
        self.currencyOperation=[ApplicationDelegate.wantgooengine  getRealTimeStockCSV:indexLabel.text
         completionHandler:^(NSMutableArray *rowDatas) {
             NSLog(@"realtime info from wantgoo ");
             double ratio=[rowDatas[STOCK_RATIO] doubleValue];
             NSLog(@"name :%@ ,price:%@",nameLabel.text,rowDatas[STOCK_PRICE]);
             
             timeLabel.text=rowDatas[STOCK_TIME];
             if (ratio>=0) {
                 ratioLabel.textColor =[UIColor colorWithRed:0.855 green:0.000 blue:0.000 alpha:1.000];
                 ratioLabel.text=[NSString stringWithFormat:@"▲+%@", [NSNumber numberWithDouble:ratio]];
                 priceLabel.text=[NSString stringWithFormat:@"▲+%@ | %@",rowDatas[STOCK_CHANGE],rowDatas[STOCK_PRICE]];
                 
             }
             else {
                 ratioLabel.textColor=[UIColor colorWithRed:0.000 green:0.855 blue:0.000 alpha:1.000];
                 ratioLabel.text=[NSString stringWithFormat:@"▼%@", [NSNumber numberWithDouble:ratio]];
                 priceLabel.text=[NSString stringWithFormat:@"▼%@ | %@",rowDatas[STOCK_CHANGE],rowDatas[STOCK_PRICE]];
                 
             }
             //local notification
             if (ratio>FIRELOCALNOTIFICATION_VALUE_TWINDEX) {
                 NSString *locaoNotificationMsg=[NSString stringWithFormat:@"%@ ration: %@%%",nameLabel.text,[NSNumber numberWithDouble:ratio]];
//                 NSLog(@"locaoNotificationMsg:%@",locaoNotificationMsg);
                 [self fireLocalNotificationWithMessage:locaoNotificationMsg];
             }
             else if (ratio<-FIRELOCALNOTIFICATION_VALUE_TWINDEX) {
                 NSString *locaoNotificationMsg=[NSString stringWithFormat:@"%@ 下跌: %@%%",nameLabel.text,[NSNumber numberWithDouble:ratio]];
//                 NSLog(@"locaoNotificationMsg:%@",locaoNotificationMsg);
                 [self fireLocalNotificationWithMessage:locaoNotificationMsg];
             }
             
             [self updateWithFlipAnimationUpdates];
             self.currencyOperation=nil;
             
         }

              errorHandler:^(NSError* error) {
                  NSLog(@"Error info from wantgoo");
                  self.currencyOperation=nil;
                  
              }];
    
    else
        self.currencyOperation=[ApplicationDelegate.tseengine  getRealTimeStockCSV:indexLabel.text
         completionHandler:^(NSMutableArray *rowDatas) {
             NSLog(@"realtime info from tse ");
             double ratio=[rowDatas[TSE_Stock_Ratio] doubleValue];
             NSLog(@"name :%@ ,price:%@",nameLabel.text,rowDatas[TSE_Stock_c]);

             timeLabel.text=rowDatas[TSE_Stock_time];
             if (ratio>=0) {
                 ratioLabel.textColor =[UIColor colorWithRed:0.855 green:0.000 blue:0.000 alpha:1.000];
                 ratioLabel.text=[NSString stringWithFormat:@"▲+%@", [NSNumber numberWithDouble:ratio]];
                 priceLabel.text=[NSString stringWithFormat:@"▲+%@ | %@",rowDatas[TSE_Stock_change],rowDatas[TSE_Stock_c]];
                 
             }
             else {
                 ratioLabel.textColor=[UIColor colorWithRed:0.000 green:0.855 blue:0.000 alpha:1.000];
                 ratioLabel.text=[NSString stringWithFormat:@"▼%@", [NSNumber numberWithDouble:ratio]];
                 priceLabel.text=[NSString stringWithFormat:@"▼%@ | %@",rowDatas[TSE_Stock_change],rowDatas[TSE_Stock_c]];
                 
             }
             //local notification
             if (ratio>FIRELOCALNOTIFICATION_RATIO_STOCK) {
                 NSString *locaoNotificationMsg=[NSString stringWithFormat:@"%@ 上漲: %@%%",nameLabel.text,[NSNumber numberWithDouble:ratio]];
//                 NSLog(@"locaoNotificationMsg:%@",locaoNotificationMsg);
                 [self fireLocalNotificationWithMessage:locaoNotificationMsg];
             }
             else if (ratio<-FIRELOCALNOTIFICATION_RATIO_STOCK) {
                 NSString *locaoNotificationMsg=[NSString stringWithFormat:@"%@ 下跌: %@%%",nameLabel.text,[NSNumber numberWithDouble:ratio]];
//                 NSLog(@"locaoNotificationMsg:%@",locaoNotificationMsg);
                 [self fireLocalNotificationWithMessage:locaoNotificationMsg];
             }
             
             [self updateWithFlipAnimationUpdates];
             self.currencyOperation=nil;
             
         }
    
          errorHandler:^(NSError* error) {
                  NSLog(@"Error info from tse");
                self.currencyOperation=nil;

              }];
}

-(void)updateWithFlipAnimationUpdates
{
[mainCellView updateWithFlipAnimationUpdates:^{
//    NSLog(@"updateWithFlipAnimationUpdates");
}];
}

@end
