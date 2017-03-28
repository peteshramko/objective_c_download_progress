//
//  ProcessRequestUsingKVO.h
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#ifndef ProcessRequestUsingKVO_h
#define ProcessRequestUsingKVO_h

@interface ProcessRequestUsingKVO : NSObject

@property long totalBytesInFile;
@property long bytesDownloaded;
@property (nonatomic) NSMutableData   *responseData;

+(ProcessRequestUsingKVO *)singleInstance;
-(void) fetchURLDataWithProgress: (NSString *) urlString;

-(instancetype) init;

@end


#endif /* ProcessRequestUsingKVO_h */
