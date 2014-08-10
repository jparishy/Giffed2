//
//  NSFileManager+LETemporary.h
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (LETemporary)

- (NSString *)le_pathForTemporaryFileWithExtension:(NSString *)extension;

@end
