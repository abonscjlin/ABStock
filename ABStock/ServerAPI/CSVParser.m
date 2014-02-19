//
//  CSVParser.m
//  ABStock
//
//  Created by fih on 2013/12/24.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import "CSVParser.h"
#import "Element.h"
#import "DocumentRoot.h"
#import "EnginConstant.h"

@implementation CSVParser {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
}
- (void)dealloc {
    [_lines release];
    [super dealloc];
}
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    NSLog(@"parserDidBeginDocument");
    [_lines release];
    _lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    NSLog(@"[didBeginLine]");
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    NSLog(@"[didReadField]%@", field);
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    NSLog(@"didEndLine");
    [_lines addObject:_currentLine];
    [_currentLine release];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
	NSLog(@"[parserDidEndDocument]");
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
    _lines = nil;
}



+(NSArray *)parseCSV:(NSString *)filePath {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"Beginning...");
	NSStringEncoding encoding = ENCODING_BIG5;
    
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:filePath ];
	CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:','];
    [p setRecognizesBackslashesAsEscapes:YES];
    [p setSanitizesFields:YES];
	
	NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding)));
	
	CSVParser * d = [[CSVParser alloc] init];
	[p setDelegate:d];
    
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	[p parse];
	NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
	
	NSLog(@"raw difference: %f", (end-start));
    
    NSLog(@"[d lines] %@", [d lines]);
    
    NSArray *tempArray=[[NSArray alloc] initWithArray:[d lines] copyItems:true];
    
	[d release];
	[p release];
	[pool drain];
    return tempArray;
}

//wantgoo.com parser

+(void)wantgooParser{
    NSString* path = [[NSBundle mainBundle] pathForResource: @"wantgoo" ofType: @"html"];
	NSStringEncoding encoding;
    NSString* source;
	NSString* pattern;
	source = [NSString stringWithContentsOfFile: path usedEncoding: &encoding error: NULL];
	pattern = @"*";
    
	DocumentRoot* document = [Element parseHTML: source];
    NSLog(@"start");
	NSArray* elements = [document selectElements: pattern] ;
	for (Element* element in elements){
        NSString *findPattern=@"script";
        NSString *contentText=[element contentsTextOfChildElement:findPattern];
        NSRange matchRange=[contentText rangeOfString:@"series"];
        if (matchRange.location<1037&&matchRange.location>0) {
            NSString *seriseString=[contentText  substringFromIndex:matchRange.location];
            NSString *dataString=[seriseString substringFromIndex:[seriseString rangeOfString:@"data:"].location+7];
            dataString=[dataString substringToIndex:[dataString length]-13];
            NSMutableArray *datas=[[dataString componentsSeparatedByString:@"],"] mutableCopy];
            NSString *cutTail=datas[[datas count]-1];
            cutTail=[cutTail substringToIndex:[cutTail length]-1];
            datas[[datas count]-1]=cutTail;
            //            NSLog(@"datas%@",datas);
            for (NSString *dataStr in datas) {
                NSArray *dataUnit=[dataStr componentsSeparatedByString:@","];
                NSString *dataTime=[dataUnit[0] substringFromIndex:1];
                NSString *dataValue=[dataUnit[1] substringToIndex:[dataUnit[1] length ]];
                NSLog(@"dataTime:%@,value:%@",dataTime,dataValue);
            }
            //        NSLog(@"contentsTextOfChildElement %@",dataString);
            
            //        NSLog(@"matchRange.location %d",matchRange.location);
            break;
            
        }
	}
    NSLog(@"end");
}


@end