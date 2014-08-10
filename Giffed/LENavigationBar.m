//
//  LEBlurredNavigationBar.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LENavigationBar.h"

#import "UIView+LECommonLayoutConstraints.h"

@interface LENavigationBar ()

@property (nonatomic, strong, readonly) UIView *colorView;

@end

@implementation LENavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureProperties];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureProperties];
}

- (void)configureProperties
{
    self.translucent = YES;
    
    self.barTintColor = [UIColor whiteColor];
    self.barStyle = UIBarStyleBlackTranslucent;
    
    UIImage *clearImage = [[UIImage alloc] init];
    [self setBackgroundImage:clearImage forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:clearImage];
    
    [self initializeColorView];
}

- (void)initializeColorView
{
    _colorView = [[UIView alloc] initWithFrame:self.bounds];
    self.colorView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    
    [self insertSubview:self.colorView atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topMarign = 20.0f;
    
    CGRect frame = self.bounds;
    frame.origin.y -= topMarign;
    frame.size.height += topMarign;
    
    self.colorView.frame = frame;
}

@end
