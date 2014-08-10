//
//  LEBeginRecordingCountdownView.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEBeginRecordingCountdownView : UIView

@property (nonatomic, assign, readonly, getter=isCountingDown) BOOL countingDown;

- (void)beginCountdownWithCompletion:(void(^)(BOOL cancelled))completion;
- (void)cancelCountdown;

- (void)displayAuxiliaryMessageWithText:(NSString *)text;

@end
