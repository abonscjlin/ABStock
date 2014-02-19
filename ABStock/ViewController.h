//
//  ViewController.h
//  ABStock
//
//  Created by fih on 2013/12/23.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssViewController.h"
#import "MarqueeLabel.h"
@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *inputStockNo;
@property (strong, nonatomic) MKNetworkOperation *currencyOperation;
@property (strong, nonatomic) IBOutlet UILabel *stockNameLab;
@property (strong, nonatomic) IBOutlet UILabel *stockIndexLab;
@property (strong, nonatomic) IBOutlet UILabel *stockRatioLab;
@property (strong, nonatomic) IBOutlet UILabel *stockChangeLab;
@property (strong, nonatomic) IBOutlet UILabel *stockPriceLab;
@property (strong, nonatomic) IBOutlet UILabel *stockUpdateTime;
@property (strong, nonatomic) IBOutlet UIView *stockCellView;

@property (strong, nonatomic) IBOutlet MarqueeLabel *newsLabel;

@end
