//
//  UIView+LECommonLayoutConstraints.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "UIView+LECommonLayoutConstraints.h"

@implementation UIView (LECommonLayoutConstraints)

- (void)le_addContraintsForFilledView:(UIView *)view insets:(UIEdgeInsets)insets
{
    NSDictionary *metrics = @{
        @"left" : @(insets.left),
        @"top" : @(insets.top),
        @"right" : @(insets.right),
        @"bottom" : @(insets.bottom)
    };
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[view]-right-|" options:kNilOptions metrics:metrics views:views];
    NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[view]-bottom-|" options:kNilOptions metrics:metrics views:views];
    
    [self addConstraints:horizontal];
    [self addConstraints:vertical];
}

@end
