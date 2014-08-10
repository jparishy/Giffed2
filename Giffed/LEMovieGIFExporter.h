//
//  LEMovieGIFExporter.h
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LEFrameRecord.h"

@interface LEMovieGIFExporter : NSObject

@property (nonatomic, assign, readonly, getter=isExporting) BOOL exporting;

- (instancetype)initWithFileURL:(NSURL *)url;
- (instancetype)initWithFrameRecords:(NSArray *)frameRecords;

- (void)exportGIFWithProgressUpdate:(void(^)(CGFloat progress))progressUpdate completion:(void (^)(NSData *GIFData))completion;

@end
