//
//  LEFrameRecord.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEFrameRecord.h"

@implementation LEFrameRecord

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    if((self = [super init]))
    {
        _fileURL = fileURL;
    }
    
    return self;
}

@end
