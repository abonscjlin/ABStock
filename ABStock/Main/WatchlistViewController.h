//
//  CustomStockViewController.h
//  ABStock
//
//  Created by fih on 2014/2/1.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "SDSegmentedControl.h"

@interface WatchlistViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) MKNetworkOperation *currencyOperation;
@property (strong, nonatomic) IBOutlet UITableView *stockTable;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *emptyView;

@end
