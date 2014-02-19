//
//  sqliteHelper.m
//  ABStock
//
//  Created by fih on 2014/1/28.
//  Copyright (c) 2014年 abons. All rights reserved.
//

#import "SqliteHelper.h"
#import "DBConstant.h"

@implementation SqliteHelper

static SqliteHelper *instance = nil;

NSString *DB_NAME = StockDBFileName;
NSString *DB_EXT = StockDBFileExtent;

@synthesize database;

+ (SqliteHelper *) newInstance{
    @synchronized(self) {
        if (instance == nil){
            instance = [[SqliteHelper alloc]init];
            [instance openDatabase];
        }
    }
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (void) openDatabase{
    if (!database){
        [self copyDatabaseIfNeeded];
        int result = sqlite3_open([[self getDatabaseFullPath] UTF8String], &database);
        if (result != SQLITE_OK){
            NSAssert(0, @"Failed to open database");
        }
    }
}

- (void) closeDatabase{
    if (database){
        sqlite3_close(database);
    }
}

- (void) copyDatabaseIfNeeded{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDatabaseFullPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DB_NAME, DB_EXT]];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        NSLog(@"Database file copied from bundle to %@", dbPath);
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
        
    } else {
        
        NSLog(@"Database file found at path %@", dbPath);
        
    }
}

- (NSString *) getDatabaseFullPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DB_NAME, DB_EXT]];

    return path;
}

- (sqlite3_stmt *) prepareQuery:(NSString *) query{
    sqlite3_stmt *statement;
    NSLog(@"prepareQuery start");

    sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    NSLog(@"prepareQuery end");

    return statement;
}
-(bool)executeQuery:(NSString*)query
{
    char *errorMsg;
    bool success=(sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK);
//    NSLog(@"executeQuery start");


    if (success) {
//        NSLog(@"TABLE OK");
        
    } else {
        NSLog(@"executeQuery error: %s", errorMsg);
        
    }
    
//    NSLog(@"executeQuery end");
    return success;
    
    
}
@end
