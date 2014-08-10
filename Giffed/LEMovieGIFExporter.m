//
//  LEMovieGIFExporter.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEMovieGIFExporter.h"

#import "ANGifEncoder.h"
#import "ANGifNetscapeAppExtension.h"
#import "ANGifImageFrame.h"
#import "ANCutColorTable.h"
#import "ANImageBitmapRep.h"
#import "UIImagePixelSource.h"

#import "NSFileManager+LETemporary.h"

#import "LEGraphicsUtilities.h"
#import "LEConfigurationOptions.h"

@import AVFoundation;

@interface LEMovieGIFExporter ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSArray *frameRecords;

@end

@implementation LEMovieGIFExporter

- (instancetype)initWithFileURL:(NSURL *)url
{
    NSParameterAssert(url);
    
    if((self = [super init]))
    {
        _url = url;
    }
    
    return self;
}

- (instancetype)initWithFrameRecords:(NSArray *)frameRecords
{
    NSParameterAssert(frameRecords);
    
    if((self = [super init]))
    {
        _frameRecords = frameRecords;
    }
    
    return self;
}

- (void)exportGIFWithProgressUpdate:(void(^)(CGFloat progress))progressUpdate completion:(void (^)(NSData *GIFData))completion
{
    if(self.url != nil)
    {
        [self exportGIFForURLWithProgressUpdate:progressUpdate completion:completion];
    }
    else
    {
        [self exportGIFForFrameRecordsWithProgressUpdate:progressUpdate completion:completion];
    }
}

- (void)exportGIFForFrameRecordsWithProgressUpdate:(void(^)(CGFloat))progressUpdate completion:(void (^)(NSData *))completion
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"export-gif" expirationHandler:^{
            
            NSLog(@"Times up.");
        }];
        
        typeof(self) self = weakSelf;
        
        NSString *outputFile = [[NSFileManager defaultManager] le_pathForTemporaryFileWithExtension:@"gif"];
        const CGSize targetSize = [[LEConfigurationOptions sharedConfigurationOptions] imageExportResolution];
        
        ANGifEncoder *encoder = [[ANGifEncoder alloc] initWithOutputFile:outputFile size:targetSize globalColorTable:nil];
        [encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] init]];
        
        NSInteger numberOfFrames = self.frameRecords.count;
        
        NSInteger frameIndex = 0;
        
        for(LEFrameRecord *frameRecord in self.frameRecords)
        {
            /*
             * We allocate quite a lot of images in the next few steps and the memory builds up quick,
             * so we'll release the pool after each image. Much slower this way but stops the app
             * from consuming more than about 5mb at any given time.
             */
            @autoreleasepool {
    
                NSData *data = [NSData dataWithContentsOfURL:frameRecord.fileURL];
                UIImage *image = [UIImage imageWithData:data];
                
                UIImagePixelSource *pixelSource = [[UIImagePixelSource alloc] initWithImage:image];
                ANCutColorTable *colorTable = [[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixelSource];
                
                NSTimeInterval delayTime = [[LEConfigurationOptions sharedConfigurationOptions] delayTimeForFrameMode];
                ANGifImageFrame *frame = [[ANGifImageFrame alloc] initWithPixelSource:pixelSource colorTable:colorTable delayTime:delayTime];
                [encoder addImageFrame:frame];
            }
            
            ++frameIndex;
            
            if(progressUpdate)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    CGFloat progress = ((CGFloat)frameIndex / (CGFloat)numberOfFrames);
                    progressUpdate(progress);
                });
            }
        }
        
        [encoder closeFile];
        
        NSData *data = [NSData dataWithContentsOfFile:outputFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            typeof(self) self = weakSelf;
            self->_exporting = NO;
            
            completion(data);
            
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        });
    });
    
    _exporting = YES;
}

- (void)exportGIFForURLWithProgressUpdate:(void(^)(CGFloat))progressUpdate completion:(void (^)(NSData *))completion
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"export-gif" expirationHandler:^{
            
            NSLog(@"Times up.");
        }];
        
        typeof(self) self = weakSelf;
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
        
        NSError *error = nil;
        AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&error];
        if(!reader)
        {
            NSLog(@"Error creating asset reader: %@", error.localizedDescription);
            return;
        }
    
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        NSDictionary *outputSettings = @{
            (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
        };
        
        AVAssetReaderTrackOutput *trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:outputSettings];
        [reader addOutput:trackOutput];
        
        [reader startReading];

        NSString *outputFile = [[NSFileManager defaultManager] le_pathForTemporaryFileWithExtension:@"gif"];
        CGSize targetSize = [[LEConfigurationOptions sharedConfigurationOptions] imageExportResolution];
        
        ANGifEncoder *encoder = [[ANGifEncoder alloc] initWithOutputFile:outputFile size:targetSize globalColorTable:nil];
        [encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] init]];
        
        const NSTimeInterval duration = ((NSTimeInterval)asset.duration.value / (NSTimeInterval)asset.duration.timescale);
        
        const NSInteger framesToSkip = [[LEConfigurationOptions sharedConfigurationOptions] numberOfFramesToSkipWhileRecording];
        const NSInteger estimatedNumberOfFrames = (NSInteger)(((duration * videoTrack.nominalFrameRate) + 1.0) / (double)(framesToSkip + 1));
        
#if DEBUG && 0
        NSLog(@"Estimated number of frames: %lu", (long)estimatedNumberOfFrames);
#endif

        NSInteger frameIndex = 0;
        CMSampleBufferRef sampleBuffer = NULL;
        
        NSInteger skippedFramesCount = 0;
        
        while((sampleBuffer = [trackOutput copyNextSampleBuffer]) != NULL)
        {
            if(skippedFramesCount == 0)
            {
                /*
                 * We allocate quite a lot of images in the next few steps and the memory builds up quick,
                 * so we'll release the pool after each image. Much slower this way but stops the app
                 * from consuming more than about 5mb at any given time.
                 */
                @autoreleasepool {
                    
                    UIImage *originalImage = LEUIImageFromSampleBuffer(sampleBuffer, UIImageOrientationRight);
                    CFRelease(sampleBuffer);
                    
                    UIImage *image = LEGIFImageFrame(originalImage, targetSize);
                    
                    UIImagePixelSource *pixelSource = [[UIImagePixelSource alloc] initWithImage:image];
                    ANCutColorTable *colorTable = [[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixelSource];
                    
                    ANGifImageFrame *frame = [[ANGifImageFrame alloc] initWithPixelSource:pixelSource colorTable:colorTable delayTime:(1.0f / 30.0)];
                    [encoder addImageFrame:frame];
                }
                
                frameIndex++;
                
                if(progressUpdate)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGFloat progress = ((CGFloat)frameIndex / (CGFloat)estimatedNumberOfFrames);
                        progressUpdate(progress);
                    });
                }
            }
            else
            {
#if DEBUG && 0
                NSLog(@"Skipping frame.");
#endif
            }
            
            skippedFramesCount++;
            
            if(skippedFramesCount > framesToSkip)
            {
                skippedFramesCount = 0;
            }
        }
        
        [encoder closeFile];
        
        NSData *data = [NSData dataWithContentsOfFile:outputFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            typeof(self) self = weakSelf;
            self->_exporting = NO;
            
            completion(data);
            
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        });
    });
    
    _exporting = YES;
}

@end
