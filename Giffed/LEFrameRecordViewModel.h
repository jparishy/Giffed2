//
//  LEFrameRecordViewModel.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEFrameRecord;

@interface LEFrameRecordViewModel : NSObject

@property (nonatomic, strong, readonly) LEFrameRecord *record;

- (instancetype)initWithRecord:(LEFrameRecord *)record;

- (UIImage *)image;

@end
