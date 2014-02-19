//
//  ServerAPI.m
//  abonStock
//
//  Created by fih on 2013/12/22.
//  Copyright (c) 2013年 abons. All rights reserved.
//

#import "ServerAPI.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "CSVParser.h"
#import "EnginConstant.h"
static ServerAPI *sharedMyManager = nil;

@implementation ServerAPI
{
    NSString *stockURL;
    CSVParser *parser;

}

- (id)init {
    if (self == [super init]) {
        return self;
    }
    parser= [[CSVParser init]alloc];
    return self;
}

+ (id)sharedSERVERAPI {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}

-(void)requestStockNo:(NSString *)stockNo tag:(int)tag
{
    if (tag==REQUEST_STOCK) {
        stockURL=[NSString stringWithFormat:URL_MIS_TSC_STOCK,stockNo];

    }
    else if (tag==REQUEST_TWSI)
    {
        stockURL=URL_MIS_TSC_INDEX;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:stockURL]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSURL URLWithString:stockURL] lastPathComponent]];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            NSLog(@"fullPath,%@",fullPath);
            NSLog(@"file size:%lld", fileSize);
           
            /*read file*/
            NSError *error1;
                    NSString *fileContents = [NSString stringWithContentsOfFile:fullPath  encoding:encBig5 error:&error1];
            
                    if (error1)
                        NSLog(@"Error reading file: %@", error1.localizedDescription);

                    NSLog(@"contents: %@", fileContents);
                    NSArray *listArray = [fileContents componentsSeparatedByString:@","];
                    NSLog(@"items = %d", [listArray count]);
//            for (int i=0; i<[listArray count]; i++) {
//                
//                NSLog(@"items[%d] : %@",i,listArray[i]);
//                NSLog(@"%@",[CSVParser parseCSV:fullPath]);
//
//                }
            
            if ([self.delegate respondsToSelector:@selector(serverAPIRequestFinished:data:tag:)]) {
                [self.delegate serverAPIRequestFinished:self data:[CSVParser parseCSV:fullPath] tag:tag];
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];


}



-(void)requestStocksIndex
{

    stockURL=@"https://www.stockdog.com.tw/stockdog/index.php";
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:stockURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        NSString *path=[filePath absoluteString];
        NSString *myFile = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@",myFile);

    }];
    [downloadTask resume];

    
}
@end
