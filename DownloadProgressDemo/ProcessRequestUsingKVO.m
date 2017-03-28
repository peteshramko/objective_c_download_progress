//
//  ProcessRequestUsingKVO.m
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProcessRequestUsingKVO.h"

// private methods and properties
@interface ProcessRequestUsingKVO () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession             *session;
@property (nonatomic, strong) NSURLSessionDataTask     *session_data_task;
@property (nonatomic, strong) NSURLSessionDownloadTask *session_download_task;
@property (nonatomic) BOOL                             firstCall;
@property (nonatomic, strong) NSURL                    *dataURL;
@property (nonatomic, strong) NSURLRequest             *request;

//-(instancetype) init;

@end

@implementation ProcessRequestUsingKVO

//@dynamic totalBytesInFile;
@synthesize totalBytesInFile       =  _totalBytesInFile;
@synthesize session                =  _session;
@synthesize session_data_task      =  _session_data_task;
@synthesize session_download_task  =  _session_download_task;
@synthesize responseData           =  _responseData;

// use singleton pattern
+(ProcessRequestUsingKVO *) singleInstance
{
    static ProcessRequestUsingKVO *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ProcessRequestUsingKVO alloc] init];
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

/*
 NSURLSession Data fetch
 */

-(void) fetchURLDataWithProgress: (NSString *) urlString
{
    self.firstCall              =  true;
    
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
    
    self.bytesDownloaded  = [dataTask countOfBytesReceived];
    
    if( ([dataTask countOfBytesExpectedToReceive] > (long)1) && self.firstCall)
    {
        self.firstCall  =  false;
        self.totalBytesInFile  =  [dataTask countOfBytesExpectedToReceive];
    }
}


@end


