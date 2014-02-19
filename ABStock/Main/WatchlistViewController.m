//
//  CustomStockViewController.m
//  ABStock
//
//  Created by fih on 2014/2/1.
//  Copyright (c) 2014年 abons. All rights reserved.
//
#import "StockQuoteTableCell.h"
#import "WatchlistViewController.h"
#import "LeftMenuViewController.h"
#import "SqliteHelper.h"
#import "AppConstant.h"
#import "EnginConstant.h"
#import "MKNetworkOperation.h"
#import "RssViewController.h"
#import "AppNavigationController.h"
#import "CandleViewController.h"

#define AddSectionAlertViewTag 10001
#define AddStockAlertViewTag   10002
#define DelSectionAlertViewTag 10003

@interface WatchlistViewController ()
{
    NSMutableDictionary *sectionDic;
    NSMutableDictionary *subsectionDic;
    NSArray *sectionKeys;
    SqliteHelper *dbHelper ;
    NSUserDefaults *userDef;
    int selectedSegmentIndex;
}
@end

@implementation WatchlistViewController
@synthesize stockTable;
@synthesize segmentedControl;
@synthesize mainView;
@synthesize emptyView;
- (id)init
{
    self = [super init];
    if (self) {
        sectionDic =[[NSMutableDictionary alloc]init];
        subsectionDic=[[NSMutableDictionary alloc]init];
        userDef=[NSUserDefaults standardUserDefaults];
        [self loadSectionData];
        [self refreshSectionAllkeys];
        [stockTable setDelegate:self];
        selectedSegmentIndex=0;
        
    }
    return self;
}

-(void)setTopSegmentedControl
{
    [self refreshSectionAllkeys];
    [segmentedControl removeSegmentAtIndex:0 animated:NO];
    [segmentedControl removeSegmentAtIndex:1 animated:NO];
    
    int segIndex=0;
    //SORT SECTION
    for (int i=0;i<[sectionKeys count];i++) {
        [segmentedControl insertSegmentWithTitle:[sectionDic objectForKey:sectionKeys[i]] atIndex:segIndex animated:YES];
        segIndex++;
    }
    //add "+" image
    [segmentedControl insertSegmentWithTitle:@"" atIndex:[sectionDic count] animated:YES];
    [segmentedControl setImage:[UIImage imageNamed:@"add-section"] forSegmentAtIndex:[sectionDic count]];
    


}
-(void)refreshSectionAllkeys
{
    //SORT SECTION
    sectionKeys=[sectionDic allKeys];
    sectionKeys = [sectionKeys sortedArrayUsingSelector: @selector(compare:)];

}
- (IBAction)topSegmentDidChange:(id)sender {
    
//    NSLog(@"selectedSegmentIndex %d",((SDSegmentedControl*)sender).selectedSegmentIndex);
    if (((SDSegmentedControl*)sender).selectedSegmentIndex!=[sectionDic count]) {
        selectedSegmentIndex=((SDSegmentedControl*)sender).selectedSegmentIndex;
        if (selectedSegmentIndex==-1) {
            selectedSegmentIndex=0;
        }
        [stockTable reloadData];
    }
    else if(((SDSegmentedControl*)sender).selectedSegmentIndex==[sectionDic count])
    {
        [self showAddSectionAlertView];
    }
}
-(void)showAddSectionAlertView
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Section" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.tag=AddSectionAlertViewTag;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Section Name:";
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //ADD NEW SECTION
    if (alertView.tag==AddSectionAlertViewTag) {
        if (buttonIndex==0) {
            //Cancel
            [segmentedControl setSelectedSegmentIndex:[sectionKeys count]-1];

        }
        else if(buttonIndex==1)
        {//OK
            

            dbHelper = [SqliteHelper newInstance];
            NSString *_sql=[NSString stringWithFormat:@"INSERT  INTO  s_Section(name) VALUES('%@')",[[alertView textFieldAtIndex:0] text]];
            
            if ([dbHelper executeQuery:_sql]) {
                [segmentedControl insertSegmentWithTitle:[[alertView textFieldAtIndex:0] text] atIndex:[sectionDic count] animated:YES];
                [self loadSectionData];
                [segmentedControl setSelectedSegmentIndex:[sectionKeys count]-1];
                selectedSegmentIndex=[sectionKeys count]-1;
                NSLog(@"sectionDic %@",sectionDic);
            }
            [stockTable reloadData];
//            [dbHelper closeDatabase];
        }
    }
    //ADD NEW STOCK
    else if (alertView.tag==AddStockAlertViewTag) {
        if (buttonIndex==0) {
            //Cancel
        }
        else if(buttonIndex==1)
        {//OK
            [self refreshSectionAllkeys];

            dbHelper = [SqliteHelper newInstance];
            NSString *_sql=[NSString stringWithFormat:@"INSERT  OR REPLACE INTO  s_Subsection(name,parentSection) VALUES('%@','%@')",[[alertView textFieldAtIndex:0] text],sectionKeys[segmentedControl.selectedSegmentIndex] ];
            NSLog(@"sql %@",_sql);
            if ([dbHelper executeQuery:_sql]) {
                [self loadSectionData];
                [stockTable reloadData];
                NSLog(@"subsectionDic %@",subsectionDic);

            }
//            [dbHelper closeDatabase];
        }
    }
    //DELETE SECTION
    else if (alertView.tag==DelSectionAlertViewTag) {
        if (buttonIndex==0) {
            //Cancel
        }
        else if(buttonIndex==1&&[sectionKeys count]>0)
        {//OK
            NSLog(@"flag");

            [self refreshSectionAllkeys];
            dbHelper = [SqliteHelper newInstance];
            NSString *_sql=[NSString stringWithFormat:@"DELETE FROM s_Subsection WHERE parentSection='%@'",sectionKeys[segmentedControl.selectedSegmentIndex] ];
//            NSLog(@"sql %@",_sql);
            if ([dbHelper executeQuery:_sql]) {
                [self.segmentedControl removeSegmentAtIndex:segmentedControl.selectedSegmentIndex animated:YES];
            }
            
            if ([sectionKeys count]==1) {
            [segmentedControl setSelectedSegmentIndex:0];
            selectedSegmentIndex=0;

            }
            else{
            [segmentedControl setSelectedSegmentIndex:[sectionKeys count]-2];
            selectedSegmentIndex=[sectionKeys count]-2;
            }
            _sql=[NSString stringWithFormat:@"DELETE FROM s_Section where id='%@'",sectionKeys[segmentedControl.selectedSegmentIndex]];
            NSLog(@"flag");

            if ([dbHelper executeQuery:_sql]) {

            [self loadSectionData];
            NSLog(@"sql %@",_sql);


            if ([sectionKeys count]==0) {
                [segmentedControl setSelectedSegmentIndex:0];
                selectedSegmentIndex=0;
            }
            else{
                [segmentedControl setSelectedSegmentIndex:[sectionKeys count]-1];
                selectedSegmentIndex=[sectionKeys count]-1;
            }

            [stockTable reloadData];

        }
            if ([sectionKeys count]==0) {
                [self showAddSectionAlertView];
            }
            //            [dbHelper closeDatabase];
        }
    }
}
-(void)loadSectionData
{
    dbHelper = [SqliteHelper newInstance];
    [sectionDic removeAllObjects];
    [subsectionDic removeAllObjects];
    NSString *sql = @"SELECT *  FROM s_Section";
    sqlite3_stmt *statement = [dbHelper prepareQuery:sql];
    //parent section
    while(sqlite3_step(statement) == SQLITE_ROW){
        //        int pid = sqlite3_column_int(statement, 0);
        NSString *_id = [NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 0) ];
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSLog(@"Section id:%@, name: %@", _id,name);
        [sectionDic setObject:name forKey:_id];
    }
    sqlite3_finalize(statement);
    //create subsection dic
    for (NSString *_key in sectionDic) {
        NSMutableArray *tempArray=[[NSMutableArray alloc]init];
        [subsectionDic setObject:tempArray forKey:_key];
    }
    sql = @"SELECT *  FROM s_Subsection";
    statement = [dbHelper prepareQuery:sql];
    //insert subsection data
    while(sqlite3_step(statement) == SQLITE_ROW){
        //        int pid = sqlite3_column_int(statement, 0);
        //        NSString *_id = [NSString stringWithFormat:@"%d",sqlite3_column_int(statement, 0) ];
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSString *parentSection = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        
        //        NSLog(@"Section name: %@", name);
        [(NSMutableArray*)[subsectionDic objectForKey:parentSection] addObject:name];
    }
    sqlite3_finalize(statement);
    [self refreshSectionAllkeys];

    //    NSLog(@"sectionDic %@",sectionDic);
    //    NSLog(@"subsectionDic %@",subsectionDic);
    //    NSLog(@"subsectionDic count %d",[subsectionDic count]);
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftMenuGestureRecognized:)];
    gesture.delegate = self;
    [self.mainView addGestureRecognizer:gesture];
    [self setTopSegmentedControl];
    if ([sectionKeys count]==0) {
        [self showAddSectionAlertView];
    }

}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.title=@"Watchlist";
    // left button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageLeftBtn = [UIImage imageNamed: @"navbar-listicon.png"];
    [leftButton setImage:imageLeftBtn forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, 25, 25);
    //    [leftButton addTarget:self action:@selector(goGoogleNewsPage) forControlEvents:UIControlEventTouchUpInside];
    [leftButton addTarget:(AppNavigationController*)self.navigationController action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
    // right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imageRightBtn = [UIImage imageNamed: @"navi-delete.png"];
    [rightButton setImage:imageRightBtn forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 25, 25);
    [rightButton addTarget:(AppNavigationController*)self.navigationController  action:@selector(showDeleteSectionAlerView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    

}
-(void)showDeleteSectionAlerView
{
    if ([sectionKeys count]>0) {
    NSString *title=[NSString stringWithFormat:@"Delete %@ ?",[sectionDic objectForKey:sectionKeys[segmentedControl.selectedSegmentIndex]]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.tag=DelSectionAlertViewTag;

    [alert show];
    }
    
}
- (void)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

-(void)reloadStock
{
    NSLog(@"reload");
    [stockTable reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goGoogleNewsPage
{
    RssViewController *RVC=[[RssViewController alloc]init];
    [self.navigationController pushViewController:RVC animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [subsectionDic count];
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if ([sectionKeys count]>0) {
        if ([(NSMutableArray*)[subsectionDic objectForKey:sectionKeys[selectedSegmentIndex]]count]==0) {
            emptyView.hidden=NO;
        }
        else
            emptyView.hidden=YES;
    }
    else if([sectionKeys count]==0)
        emptyView.hidden=NO;


    if ([sectionKeys count]==0&&selectedSegmentIndex==0) {

        return 0;
    }
    else
        return [(NSMutableArray*)[subsectionDic objectForKey:sectionKeys[selectedSegmentIndex]]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    int _section=[indexPath section];
//    NSLog(@"sectionKeys  :%@",sectionKeys );
//    NSLog(@"sectionKeys count :%d",[sectionKeys count]);
//    NSLog(@"segmentedControl.selectedSegmentIndex %d",segmentedControl.selectedSegmentIndex );
//    NSLog(@"all key %@",sectionKeys);
    int _row=[indexPath row];
//    NSLog(@"_row :%d",_row);
    NSString *stockIndexforCell=[(NSMutableArray*)[subsectionDic objectForKey:sectionKeys[segmentedControl.selectedSegmentIndex]] objectAtIndex:_row];
    NSString *stockName=[(NSMutableDictionary*)[userDef objectForKey:KEY_STOCKINDEX] objectForKey:stockIndexforCell];
    
    //    static NSString *CellIdentifier = @"StockQuoteTableCell";
    NSString *CellIdentifier = [NSString stringWithFormat:@"StockQuoteTableCell_%@",stockIndexforCell];
    
    
    StockQuoteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =  [[[[NSBundle mainBundle] loadNibNamed:@"StockQuoteTableCell" owner:self options:nil] lastObject]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
        cell.indexLabel.text=stockIndexforCell;
        cell.nameLabel.text=stockName;
        [cell initAllState];
        [cell getRealtimeInfo:nil];
    }
    [cell setStockNews];

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0) {
        return 25;
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *stockIndex=[(NSMutableArray*)[subsectionDic objectForKey:sectionKeys[segmentedControl.selectedSegmentIndex]] objectAtIndex:indexPath.row];
    CandleViewController *candleVC=[[CandleViewController alloc]initWithStockIndex:stockIndex];
    AppNavigationController *appNavigationController = [[AppNavigationController alloc] initWithRootViewController:candleVC];
    appNavigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
//    self.frostedViewController.contentViewController = appNavigationController;
    [self presentViewController:appNavigationController animated:YES completion:nil];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIImageView *footerView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-section.png"]];
    footerView.contentMode=UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSubsection:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [footerView addGestureRecognizer:singleTap];
    [footerView setUserInteractionEnabled:YES];
    
    return footerView;
}
- (void)addSubsection:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@", [gestureRecognizer view]);
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Stock" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.tag=AddStockAlertViewTag;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Stock Name:";
    [alert show];
}

//delete stock
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbHelper = [SqliteHelper newInstance];
    NSString *indexs=[(NSMutableArray*)[subsectionDic objectForKey:sectionKeys[selectedSegmentIndex]] objectAtIndex:indexPath.row];
    NSString *_sql=[NSString stringWithFormat:@"DELETE FROM s_Subsection WHERE name='%@' and parentSection='%@'",indexs,sectionKeys[segmentedControl.selectedSegmentIndex ]];
    NSLog(@"sql %@",_sql);
    if ([dbHelper executeQuery:_sql]) {
        [self loadSectionData];
        [stockTable reloadData];
        NSLog(@"subsectionDic %@",subsectionDic);
        
    }
    
    NSLog(@"delete :%d",indexPath.row);
}
- (void)leftMenuGestureRecognized:(UIPanGestureRecognizer *)sender
{
//    NSLog(@"panGestureRecognized:%@",sender);
    [self.frostedViewController panGestureRecognized:sender];

    
}
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //讓delete出現時不要有gestureRecognizer
    int deleteAreaWidth=150;
//    NSLog(@"%f:%f isin(200,0,120,568):%d",[touch locationInView:self.stockTable].x,[touch locationInView:self.stockTable].y,CGRectContainsPoint(CGRectMake(stockTable.frame.size.width-deleteAreaWidth, 0, deleteAreaWidth, stockTable.frame.size.height), [touch locationInView:self.stockTable]));
    if (CGRectContainsPoint(CGRectMake(stockTable.frame.size.width-deleteAreaWidth, 0, deleteAreaWidth, stockTable.frame.size.height), [touch locationInView:self.stockTable]))
        return NO;
    
    return YES;
}

@end
