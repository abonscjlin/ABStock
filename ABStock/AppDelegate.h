//
//  AppDelegate.h
//  ABStock
//
//  Created by fih on 2013/12/23.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WantGooEngine.h"
#import "StockDogEngine.h"
#import "TSEEngine.h"
#import "GoogleNewsEngine.h"
#import "YahooEngine.h"
#import "REFrostedViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,REFrostedViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property(strong,nonatomic) WantGooEngine *wantgooengine;
@property(strong,nonatomic) StockDogEngine *stockdogengine;
@property(strong,nonatomic) TSEEngine *tseengine;
@property(strong,nonatomic) GoogleNewsEngine *googlenewsengine;
@property(strong,nonatomic) YahooEngine *yahooengine;
@property(strong,nonatomic) NSMutableDictionary *stockIndexDic;
@end
