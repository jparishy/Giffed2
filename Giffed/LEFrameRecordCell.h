//
//  LEFrameRecordCell.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LEFrameRecordViewModel;

@interface LEFrameRecordCell : UICollectionViewCell

@property (nonatomic, weak) LEFrameRecordViewModel *recordViewModel;

+ (NSString *)cellIdentifier;

@end
