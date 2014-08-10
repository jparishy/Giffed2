//
//  LECaptureView.h
//  ;
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LECameraPosition)
{
    LECameraPositionFront,
    LECameraPositionBack
};

@interface LECaptureView : UIView

@property (nonatomic, assign) LECameraPosition cameraPosition;

- (BOOL)updateCameraPosition:(LECameraPosition)cameraPosition error:(NSError **)error;

#pragma mark - Frames mode methods

- (void)captureCurrentImageWithCompletion:(void(^)(NSData *GIFData))completion;

#pragma mark - Video mode methods

@property (nonatomic, assign, readonly) BOOL isRecording;

- (void)beginRecording;
- (void)finishRecordingWithCompletion:(void(^)(NSURL *fileURL))completion;

@end
