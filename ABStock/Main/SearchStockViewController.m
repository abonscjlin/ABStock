//
//  SearchStockViewController.m
//  ABStock
//
//  Created by Abons on 2014/2/17.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "SearchStockViewController.h"
#import "ResourceHelper.h"
#import "StockQuoteTableCell.h"
#import "AppNavigationController.h"
enum CELL_Type{
    SearchStockType=0,
    WatchListType=1
}CELL_Type;

@interface SearchStockViewController ()
{
    NSMutableDictionary *stockIndexDic;
    NSMutableArray *searchResults;
    UISearchBar *stockSearchBar;
}
@end

@implementation SearchStockViewController
@synthesize stockListTable;

- (id)init
{
    self = [super init];
    if (self) {

        searchResults=[[NSMutableArray alloc]init];
        [searchResults removeAllObjects];
        stockIndexDic= [ApplicationDelegate.stockIndexDic mutableCopy];
        [stockListTable setDelegate:self];

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
    
    //search bar
    stockSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 63, self.view.frame.size.width, 40)];
	[stockSearchBar setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.75]];
	stockSearchBar.delegate = self;

//    [stockSearchBar setShowsCancelButton:YES];// 是否显示取消按钮
//    [stockSearchBar setShowsCancelButton:YES animated:YES];
    
    if ([stockSearchBar respondsToSelector:@selector(barTintColor)]) {
        [stockSearchBar setBarTintColor:[UIColor clearColor]];
    }
    
	stockSearchBar.barStyle = UIBarMetricsDefault;
	stockSearchBar.placeholder = @"enter security";
	stockSearchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	stockSearchBar.autocapitalizationType = NO;
	[self.view addSubview:stockSearchBar];
    
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.navigationItem.title=@"Search";
    // left button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageLeftBtn = [UIImage imageNamed: @"navbar-listicon.png"];
    [leftButton setImage:imageLeftBtn forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    [leftButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
    // right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageRightBtn = [UIImage imageNamed: @"navi-delete.png"];
    [rightButton setImage:imageRightBtn forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 25, 25);
//    [rightButton addTarget:self action:@selector(showDeleteSectionAlerView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"[searchResults count] %d",[searchResults count]);
    return [searchResults count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [stockListTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=indexPath.row;
    NSLog(@"flag1");
    NSString *CellIdentifier = [NSString stringWithFormat:@"searchResult_%@",[[searchResults[row] componentsSeparatedByString:@" "] objectAtIndex:0]];
    NSLog(@"flag2");

    StockQuoteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =  [[[[NSBundle mainBundle] loadNibNamed:@"StockQuoteTableCell" owner:self options:nil] lastObject]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
        cell.indexLabel.text=[[searchResults[row] componentsSeparatedByString:@" "] objectAtIndex:0];
        cell.nameLabel.text=[[searchResults[row] componentsSeparatedByString:@" "] objectAtIndex:1];
        [cell setCellType:SearchStockType];
        [cell initAllState];
        [cell getRealtimeInfo:nil];
        
    }

    return cell;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.text=@"";

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [stockSearchBar setFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    [stockSearchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    unichar chinese = [searchText characterAtIndex:0];
//    if ((chinese >= 0x4e00 && chinese <= 0x9fff)) {
//        NSLog(@"chinese");
//    }
    [searchResults removeAllObjects];
    NSLog(@"[searchText length] %d",[searchText length]);
    // (chinese >= 0x4e00 && chinese <= 0x9fff) 判斷中文
    if (([searchText length]>=2)||(chinese >= 0x4e00 && chinese <= 0x9fff)) {
        for(NSString *key in stockIndexDic){
            if([key hasPrefix:searchText]|| [[stockIndexDic objectForKey:key] hasPrefix:searchText]){
                [searchResults addObject:[NSString stringWithFormat:@"%@ %@",key,[stockIndexDic objectForKey:key]]];
            }
        }
    }
    NSLog(@"searchResults:%@",searchResults);
    [stockListTable reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    [stockSearchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [stockSearchBar setFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    return YES;
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarTextDidEndEditing");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [stockSearchBar resignFirstResponder];
    [stockSearchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [stockSearchBar setFrame:CGRectMake(0, 63, self.view.frame.size.width, 40)];
    NSLog(@"CancelButtonClicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)leftMenuGestureRecognized:(UIPanGestureRecognizer *)sender
{
    //    NSLog(@"panGestureRecognized:%@",sender);
    [self.frostedViewController panGestureRecognized:sender];
    
    
}
- (void)showMenu
{
    [stockSearchBar resignFirstResponder];
    [self.frostedViewController presentMenuViewController];
}
@end
