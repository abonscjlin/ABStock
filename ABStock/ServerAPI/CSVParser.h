//
//  CSVParser.h
//  ABStock
//
//  Created by fih on 2013/12/24.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface CSVParser : NSObject <CHCSVParserDelegate>

@property (readonly) NSArray *lines;
+(NSArray *)parseCSV:(NSString *)filePath ;
+(void)wantgooParser;
@end