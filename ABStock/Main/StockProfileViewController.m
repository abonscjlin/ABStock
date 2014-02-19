//
//  StockProfileViewController.m
//  ABStock
//
//  Created by Abons on 2014/2/19.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "StockProfileViewController.h"
#import "AppNavigationController.h"
@interface StockProfileViewController ()
{
    NSString *stockIndex;
}
@end

@implementation StockProfileViewController

- (id)initWithStockIndex:(NSString*)_stockIndex
{
    self = [super init];
    if (self) {

        if ([_stockIndex isEqualToString:@""]) {
            stockIndex=@"1101";
        }
        else
            stockIndex=_stockIndex;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
#endif
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftMenuGestureRecognized:)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
    
    
    self.title=@"1101/台泥 45.5";
    // left button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageLeftBtn = [UIImage imageNamed: @"navbar-listicon.png"];
    [leftButton setImage:imageLeftBtn forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    //    [leftButton addTarget:self action:@selector(goGoogleNewsPage) forControlEvents:UIControlEventTouchUpInside];
    [leftButton addTarget:(AppNavigationController*)self.navigationController action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}
- (void)showMenu
{
    [self.frostedViewController presentMenuViewController];
}
- (void)leftMenuGestureRecognized:(UIPanGestureRecognizer *)sender
{
    //    NSLog(@"panGestureRecognized:%@",sender);
    [self.frostedViewController panGestureRecognized:sender];
    
    
}

@end
