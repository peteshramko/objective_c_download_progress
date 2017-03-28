//
//  DownloadProgressViewController.h
//  DownloadProgressDemo
//
//  Created by Peter Shramko on 3/3/17.
//  Copyright © 2017 Peter Shramko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DownloadProgressViewController : UIViewController

@property (nonatomic, strong) NSProgress *progress;


-(void) receivedBytesNotice:(NSNotification *)notification;
-(void) receivedTotalByteCountNotice:(NSNotification *)notification;






@end

