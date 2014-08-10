//
//  LERecordingIndicatorView.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LERecordingIndicatorView.h"

@implementation LERecordingIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self registerNotifications];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    self.recording = _recording;
}

- (void)drawRect:(CGRect)rect
{
    [[[UIColor redColor] colorWithAlphaComponent:0.75f] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 1.0f, 1.0f)] fill];
}

- (void)setRecording:(BOOL)recording
{
    _recording = recording;
    
    [self.layer removeAllAnimations];
    
    if(recording)
    {
        [self.layer removeAllAnimations];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(0.0f);
        animation.toValue = @(1.0f);
        animation.duration = 0.5;
        animation.autoreverses = YES;
        animation.repeatCount = HUGE_VALF;
        
        self.layer.opacity = 1.0f;
        
        [self.layer addAnimation:animation forKey:@"opacity"];
    }
    else
    {
        self.layer.opacity = 0.0f;
    }
}

@end
