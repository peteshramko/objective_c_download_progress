//
//  ProcessRequestUsingNSNotification.m
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProcessRequestUsingNSNotification.h"

// private methods and properties
@interface ProcessRequestUsingNSNotification () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession             *session;
@property (nonatomic, strong) NSURLSessionDataTask     *session_data_task;
@property (nonatomic, strong) NSURLSessionDownloadTask *session_download_task;
@property (nonatomic) BOOL                              firstCall;
@property (nonatomic, strong) NSURL                    *dataURL;
@property (nonatomic, strong) NSURLRequest             *request;

@end

@implementation ProcessRequestUsingNSNotification

@synthesize totalBytesInFile       =  _totalBytesInFile;
@synthesize session                =  _session;
@synthesize session_data_task      =  _session_data_task;
@synthesize session_download_task  =  _session_download_task;
@synthesize responseData           =  _responseData;

// use singleton pattern
+(ProcessRequestUsingNSNotification *) singleInstance
{
    static ProcessRequestUsingNSNotification *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ProcessRequestUsingNSNotification alloc] init];
    });
    
    
    return _sharedInstance;
}

-(instancetype) init
{
    self  = [super init];
    
    if(self)
    {
        self.session  =  [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                       delegate:self
                                                  delegateQueue:[NSOperationQueue mainQueue]];        
    }
    
    return self;
}


-(void) fetchURLDataWithProgress: (NSString *) urlString
{
    self.firstCall              =  true;
    self.totalBytesInFile       =  [NSNumber numberWithLong:0];
    self.bytesDownloaded        =  [NSNumber numberWithLong:0];
    
    self.dataURL                =  [NSURL URLWithString:urlString];
    self.request                =  [NSURLRequest requestWithURL:self.dataURL];
    
    self.responseData           =  [[NSMutableData alloc] init];
    self.session_data_task      =  [self.session dataTaskWithRequest:self.request];
    [self.session_data_task resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
    
    self.totalBytesInFile = [NSNumber numberWithLong:[dataTask countOfBytesExpectedToReceive]];
    self.bytesDownloaded  = [NSNumber numberWithLong:[dataTask countOfBytesReceived]];
    
    if(self.totalBytesInFile > [NSNumber numberWithInt:1] && self.firstCall)
    {
        self.firstCall         =  false;
        self.totalBytesInFile  =  [NSNumber numberWithLong:[dataTask countOfBytesExpectedToReceive]];
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)@"receivedTotalByteCountNotice" object:(id)_totalBytesInFile];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)@"receivedBytesNotice" object:(id)_bytesDownloaded];
    
    if( (self.bytesDownloaded == self.totalBytesInFile) && (self.totalBytesInFile > [NSNumber numberWithInt:1]))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)@"displayPictureFromNSNotification" object:(id)_totalBytesInFile];
    }
}

@end


