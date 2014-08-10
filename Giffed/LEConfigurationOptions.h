//
//  LEConfigurationOptions.h
//  Giffed
//
//  Created by Julius Parishy on 8/10/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEConfigurationOptions : NSObject

@property (nonatomic, assign) NSInteger numberOfFramesToSkipWhileRecording;
@property (nonatomic, assign) CGSize imageExportResolution;

@property (nonatomic, assign) NSTimeInterval delayTimeForFrameMode;

+ (instancetype)sharedConfigurationOptions;

@end
