//
//  SearchStockViewController.h
//  ABStock
//
//  Created by Abons on 2014/2/17.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface SearchStockViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *stockListTable;

@end
