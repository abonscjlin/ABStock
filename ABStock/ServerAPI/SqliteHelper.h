//
//  sqliteHelper.h
//  ABStock
//
//  Created by fih on 2014/1/28.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqliteHelper : NSObject {
    sqlite3 *database;
}

@property(readonly, nonatomic) sqlite3 *database;

+ (SqliteHelper *) newInstance;
- (void) openDatabase;
- (void) closeDatabase;
- (NSString *) getDatabaseFullPath;
- (void) copyDatabaseIfNeeded;
- (sqlite3_stmt *) prepareQuery:(NSString *) query;
-(bool)executeQuery:(NSString*)query;

@end
