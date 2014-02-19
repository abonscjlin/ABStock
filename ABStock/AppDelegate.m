//
//  AppDelegate.m
//  ABStock
//
//  Created by fih on 2013/12/23.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyBoardManager.h"
#import "AppConstant.h"
#import "ViewController.h"
#import "WatchlistViewController.h"
#import "LeftMenuViewController.h"
#import "SqliteHelper.h"
#import "REFrostedViewController.h"
#import "CandleViewController.h"
#import "SearchStockViewController.h"
#import "AppNavigationController.h"
@interface AppDelegate ()

@end
@implementation AppDelegate
{
    UIBackgroundTaskIdentifier  bgTask;
    SqliteHelper *dbHelper;
    NSUserDefaults *userDef;
}
@synthesize navigationController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

//    [IQKeyBoardManager installKeyboardManager];

    self.wantgooengine =[[WantGooEngine alloc]initWithDefaultSettings];
//    [self.wantgooengine useCache];
    self.stockdogengine =[[StockDogEngine alloc]initWithDefaultSettings];
//    [self.stockdogengine useCache];
    self.tseengine =[[TSEEngine alloc] initWithDefaultSettings];
    self.googlenewsengine=[[GoogleNewsEngine alloc]initWithDefaultSettings];
    self.yahooengine=[[YahooEngine alloc]initWithDefaultSettings];
    
    [self loadStockIndextoUserDef];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];


    LeftMenuViewController *menuController = [[LeftMenuViewController alloc] init];
    AppNavigationController *appNavigationController = [[AppNavigationController alloc] initWithRootViewController:[[WatchlistViewController alloc] init]];
    appNavigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    // Create frosted view controller
    //
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:appNavigationController menuViewController:menuController];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.delegate = self;

    
    self.window.rootViewController = frostedViewController;
//    self.window.rootViewController = ssvc;

//    CandleViewController *candle=[[CandleViewController alloc]init];
//    self.window.rootViewController = candle;

    //    navigationController=[[UINavigationController alloc]init];
    
//    [self.window addSubview:navigationController.view];
//    self.window.rootViewController = navigationController;

    
    userDef=[NSUserDefaults standardUserDefaults];
    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)loadStockIndextoUserDef
{
    NSString *sql = @"SELECT indexs, name  FROM  s_Index";
    self.stockIndexDic=[[NSMutableDictionary alloc]init];
    dbHelper=[SqliteHelper newInstance];
    sqlite3_stmt *statement = [dbHelper prepareQuery:sql];
    while(sqlite3_step(statement) == SQLITE_ROW){
        //        int pid = sqlite3_column_int(statement, 0);
        int index =sqlite3_column_int(statement, 0);
        NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        [self.stockIndexDic setObject:name forKey:[NSString stringWithFormat:@"%04d",index]];
//        NSLog(@"name:%@,index:%04d",name,index);
    }
    sqlite3_finalize(statement);
    [userDef setObject:self.stockIndexDic forKey:KEY_STOCKINDEX];
    [userDef synchronize];
}
#pragma mark - App Delegate

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary* dic = [[NSDictionary alloc]init];
    if (application.applicationState == UIApplicationStateActive) {
    //这里可以接受到本地通知中心发送的消息
    dic = notification.userInfo;
    NSLog(@"[LocalNotification] : %@",[dic objectForKey:@"index"]);
    }
    UIApplicationState state = [application applicationState];

    if (state == UIApplicationStateInactive) {
    //这个通知用户已经看过了。
    NSLog(@"UIApplicationStateInactive:%@",[dic objectForKey:@"index"]);
}
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber -= 1;

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");

    if (ALLOW_BackgroundTask){
    [self backgroundHandler];
    }
    
    
}
- (void)backgroundHandler {
    
    NSLog(@"### -->backgroundinghandler");
    
    UIApplication *app = [UIApplication sharedApplication];
        bgTask= [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        int counter=0;
        while (1) {
//            NSLog(@"counter:%d", counter++);
            sleep(1);
        }
    });
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
