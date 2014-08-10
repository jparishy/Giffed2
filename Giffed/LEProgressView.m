//
//  LEProgressView.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEProgressView.h"

@interface LEProgressView ()

@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) NSLayoutConstraint *rightConstraint;

@end

@implementation LEProgressView

@synthesize foregroundColor=_foregroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeForegroundView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeForegroundView];
}

- (CGFloat)constraintConstantForPercentage:(CGFloat)percentage
{
    return -CGRectGetWidth(self.bounds) * (1.0f - percentage);
}

- (void)initializeForegroundView
{
    self.foregroundView = [[UIView alloc] init];
    self.foregroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.foregroundView.backgroundColor = self.foregroundColor;
    
    [self addSubview:self.foregroundView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_foregroundView);
    
    NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_foregroundView]-0-|" options:kNilOptions metrics:nil views:views];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.foregroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
    
    self.rightConstraint = [NSLayoutConstraint constraintWithItem:self.foregroundView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:[self constraintConstantForPercentage:0.0f]];
    
    [self addConstraints:vertical];
    [self addConstraints:@[ left, self.rightConstraint ]];
}

- (void)setPercentage:(CGFloat)percentage
{
    [self setPercentage:percentage animated:NO];
}

- (void)setPercentage:(CGFloat)percentage animated:(BOOL)animated
{
    void(^changes)() = ^{
        
        _percentage = percentage;
        
        self.rightConstraint.constant = [self constraintConstantForPercentage:percentage];
        [self layoutIfNeeded];
    };
    
    if(animated)
    {
        NSTimeInterval duration = 0.6f;
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        
        [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
            
            changes();
        } completion:nil];
    }
    else
    {
        changes();
    }
}

- (UIColor *)foregroundColor
{
    if(!_foregroundColor)
    {
        _foregroundColor = [UIColor whiteColor];
    }
    
    return _foregroundColor;
}

- (void)setForegroundColor:(UIColor *)foregroundColor
{
    _foregroundColor = foregroundColor;
    
    self.foregroundView.backgroundColor = foregroundColor;
}

@end
