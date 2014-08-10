//
//  LEBeginRecordingCountdownView.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEBeginRecordingCountdownView.h"

#import "UIView+LECommonLayoutConstraints.h"

@interface LEBeginRecordingCountdownView ()

@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, copy) void(^completionBlock)(BOOL);

@end

@implementation LEBeginRecordingCountdownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeLabels];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeLabels];
}

- (UILabel *)configuredLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:label];
    [self le_addContraintsForFilledView:label insets:UIEdgeInsetsZero];
    
    const CGFloat fontSize = 60.0f;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = self.tintColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.0f;
    
    label.text = text;

    return label;
}

- (void)initializeLabels
{
    self.labels = @[];
    
    void(^addLabelWithText)(NSString *) = ^(NSString *text) {
    
        UILabel *label = [self configuredLabelWithText:text];
        self.labels = [self.labels arrayByAddingObject:label];
    };
    
#if !DEBUG || 1
    const NSInteger numberOfSteps = 3;
    
    for(NSInteger i = 0; i < numberOfSteps; ++i)
    {
        NSString *text = [NSString stringWithFormat:@"%lu", (long)i + 1];
        addLabelWithText(text);
    }
#endif
    
    addLabelWithText(NSLocalizedString(@"Go!", nil));
}

- (void)beginCountdownWithCompletion:(void (^)(BOOL))completion
{
    if(self.isCountingDown)
    {
        [self cancelCountdown];
    }
    
    self.completionBlock = completion;
    
    for(UILabel *label in self.labels)
    {
        label.alpha = 0.0f;
        label.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }
    
    _countingDown = YES;
    
    [self animateLabels:self.labels];
}

- (void)handleTotalAnimationCompletion
{
    if(self.completionBlock)
    {
        self.completionBlock(NO);
        self.completionBlock = nil;
    }
    
    _countingDown = NO;
}

- (void)animateLabels:(NSArray *)labels
{
    if(!self.isCountingDown)
    {
        // We were cancelled
        return;
    }
    
    if(labels.count == 1)
    {
        // We start on 'Go!'
        [self handleTotalAnimationCompletion];
    }
    else if(labels.count == 0)
    {
        return;
    }
    
#if DEBUG && 0
    NSTimeInterval duration = 0.1f;
#else
    NSTimeInterval duration = 1.0f;
#endif

    [self animateLabel:labels[0] duration:duration completion:^{
        
        NSMutableArray *nextLabels = [labels mutableCopy];
        [nextLabels removeObjectAtIndex:0];
        
        [self animateLabels:[nextLabels copy]];
    }];
}

- (void)animateLabel:(UILabel *)label duration:(NSTimeInterval)duration completion:(void(^)())completion
{
    NSParameterAssert(completion);

    [UIView animateKeyframesWithDuration:duration delay:0.0f options:kNilOptions animations:^{
    
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:1.0f animations:^{
            
            label.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.25f animations:^{
            
            label.alpha = 1.0f;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.75f animations:^{
        
            label.alpha = 0.0f;
        }];
    
    } completion:^(BOOL finished) {
        
        completion();
    }];
}

- (void)cancelCountdown
{
    if(!self.isCountingDown)
        return;
    
    for(UILabel *label in self.labels)
    {
        [label.layer removeAllAnimations];
        label.alpha = 0.0f;
    }
    
    if(self.completionBlock)
    {
        self.completionBlock(YES);
        self.completionBlock = nil;
    }
    
    _countingDown = NO;
}

- (void)displayAuxiliaryMessageWithText:(NSString *)text
{
    UILabel *label = [self configuredLabelWithText:text];
    label.alpha = 0.0f;
    
    [self animateLabel:label duration:1.2 completion:^{
        
        [label removeFromSuperview];
    }];
}

@end
