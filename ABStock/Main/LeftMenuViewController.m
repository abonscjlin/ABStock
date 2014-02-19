//
//  LeftMenuViewController.m
//  ABStock
//
//  Created by fih on 2014/2/2.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "REFrostedViewController.h"
#import "RssViewController.h"
#import "CandleViewController.h"
#import "SearchStockViewController.h"
#import "WatchlistViewController.h"
#import "AppNavigationController.h"
@interface LeftMenuViewController ()

{
    NSArray *menuItems;
}
@end

@implementation LeftMenuViewController
-(id)init
{
    self=[super init];
    if (self) {
        menuItems=[[NSArray alloc]initWithObjects:@"Home",@"Watchlist" ,@"Candle Chart",@"Search",nil];
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
 
    self.tableView.backgroundColor=[UIColor colorWithWhite:0.1 alpha:1];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    else if (section==1){
        return [menuItems count];
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    if (indexPath.section==0) {
        cell.textLabel.text=@"ABStock";
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor=[UIColor colorWithRed:0.012 green:0.202 blue:0.719 alpha:1.000];
    }
    else if(indexPath.section==1){
        cell.backgroundColor=[UIColor colorWithWhite:0.1 alpha:1 ];
        cell.textLabel.text=menuItems[indexPath.row];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 20;
    }
    else
        return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==1) {
        return 50;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
        return headerView;
    }
    else
        return [[UIView alloc]initWithFrame:CGRectZero];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section==1) {
        UIImageView *footerView=[[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ABSTOCK-LOGO.png"]];
//        footerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        footerView.contentMode=UIViewContentModeScaleAspectFit;

        return footerView;
    }
    else
        return [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==1) {
        WatchlistViewController *watchlistVC = [[WatchlistViewController alloc] init];
        AppNavigationController *appNavigationController = [[AppNavigationController alloc] initWithRootViewController:watchlistVC];
        self.frostedViewController.contentViewController = appNavigationController;
        appNavigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;

    }
    
    if (indexPath.row==2) {
        
        CandleViewController *candleVC=[[CandleViewController alloc]initWithStockIndex:@"1101"];
        AppNavigationController *appNavigationController = [[AppNavigationController alloc] initWithRootViewController:candleVC];
        appNavigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
        self.frostedViewController.contentViewController = appNavigationController;
    }
    if (indexPath.row==3) {
        
        SearchStockViewController *searchVC=[[SearchStockViewController alloc]init];
        AppNavigationController *appNavigationController = [[AppNavigationController alloc] initWithRootViewController:searchVC];
        appNavigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
        self.frostedViewController.contentViewController = appNavigationController;
    }
    
    [self.frostedViewController hideMenuViewController];

    
}

@end
