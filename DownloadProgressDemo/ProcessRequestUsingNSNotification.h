//
//  ProcessRequestUsingNSNotification.h
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#ifndef ProcessRequestUsingNSNotification_h
#define ProcessRequestUsingNSNotification_h

@interface ProcessRequestUsingNSNotification : NSObject

@property (nonatomic) NSNumber        *totalBytesInFile;
@property (nonatomic) NSNumber        *bytesDownloaded;
@property (nonatomic) NSMutableData   *responseData;

+(ProcessRequestUsingNSNotification *)singleInstance;
-(void) fetchURLDataWithProgress: (NSString *) urlString;

-(instancetype) init;

@end

#endif /* ProcessRequestUsingNSNotification_h */
