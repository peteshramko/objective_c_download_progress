//
//  DownloadProgressViewController.m
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "DownloadProgressViewController.h"
#import "ProcessRequestUsingKVO.h"
#import "ProcessRequestUsingNSNotification.h"


@interface DownloadProgressViewController () <NSProgressReporting>

@property (nonatomic, strong) ProcessRequestUsingKVO              *processRequestUsingKVO;
@property (nonatomic, strong) ProcessRequestUsingNSNotification   *processRequestUsingNSNotification;
@property (strong, nonatomic) IBOutlet UIProgressView             *progressView;
@property (strong, nonatomic) NSNumber                            *bytesReceived;
@property (strong, nonatomic) IBOutlet UIImageView                *GoogleImage;
@property (strong, nonatomic) UIImage                             *downloadedImage;

-(void)removeProcessReferences;

@end

@implementation DownloadProgressViewController

@synthesize processRequestUsingKVO            =  _processRequestUsingKVO;
@synthesize processRequestUsingNSNotification =  _processRequestUsingNSNotification;
@synthesize progressView                      =  _progressView;
@synthesize progress                          =  _progress;

static void *TotalBytesInFileContext          =  &TotalBytesInFileContext;
static void *BytesDownloadedContext           =  &BytesDownloadedContext;


//SEL methodToInvokeIfSomethingHappens;
- (IBAction)startDownloadWithNSNotification:(UIButton *)sender
{
    _GoogleImage.image                                   = nil;
    self.processRequestUsingNSNotification.responseData  = nil;
    [self removeProcessReferences];
    
    [_progressView setProgress:(float)0.00];
    
    _processRequestUsingNSNotification.bytesDownloaded   = nil;
    _processRequestUsingNSNotification.totalBytesInFile  = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:(id)self
                                             selector:@selector(receivedBytesNotice:)
                                                 name:(NSString *)@"receivedBytesNotice"
                                               object:(id)self.processRequestUsingNSNotification.bytesDownloaded];
    
    [[NSNotificationCenter defaultCenter] addObserver:(id)self
                                             selector:@selector(receivedTotalByteCountNotice:)
                                                 name:(NSString *)@"receivedTotalByteCountNotice"
                                               object:(id)self.processRequestUsingNSNotification.totalBytesInFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:(id)self
                                             selector:@selector(displayPictureFromNSNotification:)
                                                 name:(NSString *)@"displayPictureFromNSNotification"
                                               object:(id)self.processRequestUsingNSNotification.totalBytesInFile];
    
    [self.processRequestUsingNSNotification fetchURLDataWithProgress:@"https://upload.wikimedia.org/wikipedia/commons/5/58/Sunset_2007-1.jpg"];
}

- (IBAction)startDownloadWithKVO:(UIButton *)sender
{
    _GoogleImage.image                            = nil;
    self.processRequestUsingKVO.responseData      = nil;
    [self removeProcessReferences];
    
    [_progressView setProgress:(float)0.00];
    
    _processRequestUsingKVO.bytesDownloaded       = 0;
    _processRequestUsingKVO.totalBytesInFile      = 0;
    
    [self addObserver:self
           forKeyPath:@"processRequestUsingKVO.totalBytesInFile"
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:TotalBytesInFileContext];
    
    [self addObserver:self
           forKeyPath:@"processRequestUsingKVO.bytesDownloaded"
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:BytesDownloadedContext];
    
    _progress.completedUnitCount = (int64_t)self.processRequestUsingKVO.totalBytesInFile;
    
    [self.processRequestUsingKVO fetchURLDataWithProgress:@"https://upload.wikimedia.org/wikipedia/commons/5/58/Sunset_2007-1.jpg"];
}

- (void)viewDidLoad
{
    [_progressView setProgress:(float)0.00];
    [super viewDidLoad];
    
    
    self.processRequestUsingNSNotification  =  [ProcessRequestUsingNSNotification singleInstance];
    self.processRequestUsingKVO             =  [ProcessRequestUsingKVO singleInstance];
    _progress                               =  [[NSProgress alloc] init];
    _progress.kind                          =  NSProgressKindFile;
        
    [_progress setTotalUnitCount:-1];
    [_progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
        
    [_progressView setObservedProgress:_progress];
    
    NSLog(@"Program Start");
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    NSLog(@"From KVO");
    
    float f = (float)0.00;
    
    if(self.processRequestUsingKVO.bytesDownloaded > 0 && self.processRequestUsingKVO.totalBytesInFile > 0)
        f = ( (float)self.processRequestUsingKVO.bytesDownloaded  / (float)self.processRequestUsingKVO.totalBytesInFile );
    
    if ([keyPath isEqualToString:@"processRequestUsingKVO.totalBytesInFile"])
    {
        NSLog(@"Total Bytes In File (KVO): %ld", self.processRequestUsingKVO.totalBytesInFile);
        _progress.totalUnitCount  =  (int64_t)self.processRequestUsingKVO.totalBytesInFile;
    }
    else if([keyPath isEqualToString:@"processRequestUsingKVO.bytesDownloaded"])
    {
        NSLog(@"%ld Fraction %f (KVO)", self.processRequestUsingKVO.bytesDownloaded, (float)f);
        _progress.completedUnitCount  =  (int64_t)self.processRequestUsingKVO.bytesDownloaded;
        [_progressView setProgress:f];
        
        if( (self.processRequestUsingKVO.bytesDownloaded == self.processRequestUsingKVO.totalBytesInFile)
              && (self.processRequestUsingKVO.responseData != nil))
        {
            NSData *myData       =   self.processRequestUsingKVO.responseData;
            _downloadedImage     =   [UIImage imageWithData:myData];
            _GoogleImage.image   =   _downloadedImage;
        }
    }
}

-(void)receivedBytesNotice:(NSNotification *)notification
{
    //notification.name;      // the name passed on AddObserver
    //notification.object;    // the object sending you the notification
    //notification.userInfo;  // notification-specific information about what happened
    float num = [self.processRequestUsingNSNotification.bytesDownloaded floatValue];
    float den = [self.processRequestUsingNSNotification.totalBytesInFile floatValue];
    float f   = (float)num/den;
    
    NSLog(@"%@ Fraction %f (NSNotification)", (NSNumber*)self.processRequestUsingNSNotification.bytesDownloaded, (float)f);
    _progress.completedUnitCount  =  (int64_t)self.processRequestUsingNSNotification.bytesDownloaded;
    [_progressView setProgress:f];
}

-(void)receivedTotalByteCountNotice:(NSNotification *)notification
{
    NSLog(@"Total Bytes In File: %@", (NSNumber*)self.processRequestUsingNSNotification.totalBytesInFile);
    _progress.totalUnitCount  =  (int64_t)self.processRequestUsingNSNotification.totalBytesInFile;
}

-(void)displayPictureFromNSNotification:(NSNotification *)notification
{
    NSData *myData       =   self.processRequestUsingNSNotification.responseData;
    _downloadedImage     =   [UIImage imageWithData:myData];
    _GoogleImage.image   =   _downloadedImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)removeProcessReferences
{
    //if([[NSNotificationCenter defaultCenter] observationInfo] != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if([self observationInfo] != nil)
    {
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.totalBytesInFile"
                     context:TotalBytesInFileContext];
        
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.bytesDownloaded"
                     context:BytesDownloadedContext];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //if([[NSNotificationCenter defaultCenter] observationInfo] != nil) // not necessary
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if([self observationInfo] != nil)
    {
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.totalBytesInFile"
                     context:TotalBytesInFileContext];
        
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.bytesDownloaded"
                     context:BytesDownloadedContext];
    }
}

-(void)dealloc
{
    //if([[NSNotificationCenter defaultCenter] observationInfo] == nil) // not necessary
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if([self observationInfo] != nil)
    {
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.totalBytesInFile"
                     context:TotalBytesInFileContext];
        
        [self removeObserver:self
                  forKeyPath:@"processRequestUsingKVO.bytesDownloaded"
                     context:BytesDownloadedContext];
    }
}

@end
