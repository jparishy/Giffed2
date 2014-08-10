//
//  LECaptureView.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LECaptureView.h"

#import "NSFileManager+LETemporary.h"
#import "LEGraphicsUtilities.h"

#import "LEConfigurationOptions.h"

@import AVFoundation;

@interface LECaptureView () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *activeDeviceInput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) AVCaptureMovieFileOutput *fileOutput;
@property (nonatomic, copy) void(^fileOutputFinishedCompletionBlock)(NSURL *);

@end

@implementation LECaptureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeSession];
    [self initializePreviewLayer];
    [self initializeStillImageOutput];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.previewLayer.frame = self.layer.bounds;
}

- (BOOL)updateCameraPosition:(LECameraPosition)cameraPosition error:(NSError **)error
{
    if(self.activeDeviceInput)
    {
        [self.session removeInput:self.activeDeviceInput];
        self.activeDeviceInput = nil;
        
        [self.session stopRunning];
    }
    
    BOOL success = [self startRunningForCameraPosition:cameraPosition error:error];
    if(!success)
    {
        return NO;
    }

    [self.session startRunning];

    return YES;
}

- (void)initializeSession
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
}

- (void)initializePreviewLayer
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.layer addSublayer:self.previewLayer];
}

- (void)initializeStillImageOutput
{
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.stillImageOutput.outputSettings = @{
        AVVideoCodecKey : AVVideoCodecJPEG
    };
    
    [self.session addOutput:self.stillImageOutput];
}

- (AVCaptureDevice *)captureDeviceForCameraPosition:(LECameraPosition)cameraPosition
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in devices)
    {
        switch(cameraPosition)
        {
            case LECameraPositionFront:
            {
                if(device.position == AVCaptureDevicePositionFront)
                {
                    return device;
                }
                
                break;
            }
            
            case LECameraPositionBack:
            {
                if(device.position == AVCaptureDevicePositionBack)
                {
                    return device;
                }
                
                break;
            }
        };
    }
    
    return nil;
}

- (BOOL)startRunningForCameraPosition:(LECameraPosition)cameraPosition error:(NSError **)error
{
    AVCaptureDevice *device = [self captureDeviceForCameraPosition:cameraPosition];
    if(!device)
    {
        // TODO: Return error for device not found
        return NO;
    }
    
    self.activeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:error];
    if(self.activeDeviceInput == nil)
    {
        return NO;
    }
    
    [self.session addInput:self.activeDeviceInput];
    
    self.cameraPosition = cameraPosition;
    
    return YES;
}

#pragma mark - Frames

- (AVCaptureConnection *)videoConnection
{
    for(AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for(AVCaptureInputPort *inputPort in connection.inputPorts)
        {
            if(inputPort.mediaType == AVMediaTypeVideo)
            {
                return connection;
            }
        }
    }
    
    return nil;
}

- (void)captureCurrentImageWithCompletion:(void (^)(NSData *))completion
{
    AVCaptureConnection *connection = [self videoConnection];
    if(connection == nil)
    {
        NSLog(@"Failed to find video connection.");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if(error)
        {
            NSLog(@"Error capturing still image: %@", error.localizedDescription);
            return;
        }
        
        CMSampleBufferRef sampleBuffer = (CMSampleBufferRef)CFRetain(imageDataSampleBuffer);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *JPEGRepresentation = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            CFRelease(sampleBuffer);
            
            UIImage *image = [UIImage imageWithData:JPEGRepresentation];
            
            const CGSize size = [[LEConfigurationOptions sharedConfigurationOptions] imageExportResolution];
            
            UIImage *GIFFrame = LEGIFImageFrame(image, size);
            NSData *GIFData = UIImageJPEGRepresentation(GIFFrame, 1.0f);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(GIFData);
            });
        });
    }];
}

#pragma mark - Recording

- (void)beginRecording
{
    self.fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:self.fileOutput];
    
    NSString *path = [[NSFileManager defaultManager] le_pathForTemporaryFileWithExtension:@"mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [self.fileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

- (void)finishRecordingWithCompletion:(void(^)(NSURL *fileURL))completion
{
    self.fileOutputFinishedCompletionBlock = completion;
    
    [self.fileOutput stopRecording];
}

- (BOOL)isRecording
{
    return self.fileOutput.isRecording;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Output failed: %@", error.localizedDescription);
    }
    else
    {
        self.fileOutputFinishedCompletionBlock(outputFileURL);
        
        [self.session removeOutput:self.fileOutput];
        self.fileOutput = nil;
    }
}

@end
