//
//  LEFrameRecordViewModel.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEFrameRecordViewModel.h"

#import "LEFrameRecord.h"

@implementation LEFrameRecordViewModel

- (instancetype)initWithRecord:(LEFrameRecord *)record
{
    if((self = [super init]))
    {
        _record = record;
    }
    
    return self;
}

- (UIImage *)image
{
    NSData *data = [NSData dataWithContentsOfURL:self.record.fileURL];
    UIImage *image = [UIImage imageWithData:data];
    
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
}

@end
