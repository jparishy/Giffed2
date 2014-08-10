//
//  LEFramesViewController.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LEFrameRecord;

@interface LEFramesViewController : UIViewController

@property (nonatomic, copy, readonly) NSArray *frames;

- (void)addFrame:(LEFrameRecord *)frame;
- (void)discardFrames;

@end
