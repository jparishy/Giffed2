//
//  LEFrameRecord.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEFrameRecord : NSObject

@property (nonatomic, strong, readonly) NSURL *fileURL;

- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end
