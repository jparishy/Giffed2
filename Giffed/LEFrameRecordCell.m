//
//  LEFrameRecordCell.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEFrameRecordCell.h"

#import "LEFrameRecordViewModel.h"
#import "UIView+LECommonLayoutConstraints.h"

@interface LEFrameRecordCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end

@implementation LEFrameRecordCell

+ (NSString *)cellIdentifier
{
    return NSStringFromClass(self);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeThumbnailImageView];
    }
    
    return self;
}

- (void)initializeThumbnailImageView
{
    self.thumbnailImageView = [[UIImageView alloc] init];
    self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.thumbnailImageView];
    [self.contentView le_addContraintsForFilledView:self.thumbnailImageView insets:UIEdgeInsetsZero];
}

- (void)setRecordViewModel:(LEFrameRecordViewModel *)recordViewModel
{
    _recordViewModel = recordViewModel;
    
    UIImage *image = [recordViewModel image];
    self.thumbnailImageView.image = image;
}

@end
