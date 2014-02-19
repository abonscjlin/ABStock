//
//  StockQuoteTableCell.h
//  ABStock
//
//  Created by fih on 2014/2/1.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
#import "MKNetworkOperation.h"
#import "UIView+JDFlipImageView.h"
#import "AppConstant.h"
#import "EnginConstant.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"

@interface StockQuoteTableCell : UITableViewCell<MWFeedParserDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *indexLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratioLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet MarqueeLabel *newsLabel;
@property (strong, nonatomic) IBOutlet UIView *mainCellView;
@property (strong, nonatomic) MKNetworkOperation *currencyOperation;

-(void)setStockNews;
-(void)updateWithFlipAnimationUpdates;
-(void)startAutoUpdate;
-(void)initAllState;
-(void)setCellType:(int)_type;
-(void)getRealtimeInfo:(NSTimer *)timer;
@end
