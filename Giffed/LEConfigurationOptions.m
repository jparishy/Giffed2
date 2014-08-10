//
//  LEConfigurationOptions.m
//  Giffed
//
//  Created by Julius Parishy on 8/10/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEConfigurationOptions.h"

@implementation LEConfigurationOptions

+ (instancetype)sharedConfigurationOptions
{
    static LEConfigurationOptions *configurationOptions = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        configurationOptions = [[LEConfigurationOptions alloc] init];
        [configurationOptions setDefaultConfigurationOptions];
    });
    
    return configurationOptions;
}

- (void)setDefaultConfigurationOptions
{
    self.numberOfFramesToSkipWhileRecording = 3;
    self.imageExportResolution = CGSizeMake(320, 320);
    
    self.delayTimeForFrameMode = 0.25;
}

@end
