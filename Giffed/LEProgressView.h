//
//  LEProgressView.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEProgressView : UIView

@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, assign) CGFloat percentage;

- (void)setPercentage:(CGFloat)percentage animated:(BOOL)animated;

@end
