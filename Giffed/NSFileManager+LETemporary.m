//
//  NSFileManager+LETemporary.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "NSFileManager+LETemporary.h"

@implementation NSFileManager (LETemporary)

- (NSString *)le_pathForTemporaryFileWithExtension:(NSString *)extension
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *temporaryDirectory = [paths firstObject];
    
    NSString *temporaryName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:extension];
    
    return [temporaryDirectory stringByAppendingPathComponent:temporaryName];
}

@end
