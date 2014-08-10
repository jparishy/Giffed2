//
//  LEGraphicsUtilities.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEGraphicsUtilities.h"

// Apple's code from the docs
UIImage *LEUIImageFromSampleBuffer(CMSampleBufferRef sampleBuffer, UIImageOrientation orientation)
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
 
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
 
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
 
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
      bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
 
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
 
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:orientation];
 
    // Release the Quartz image
    CGImageRelease(quartzImage);
 
    return (image);
}

UIImage *LEGIFImageFrame(UIImage *sourceImage, CGSize targetSize)
{
    UIGraphicsBeginImageContext(targetSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
#if DEBUG
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, targetSize.width, targetSize.height));
#endif

    CGSize imageSize = sourceImage.size;
    
    CGSize scaledSize = targetSize;
    if(scaledSize.height > scaledSize.width)
    {
        scaledSize.width = imageSize.width * (targetSize.height / imageSize.height);
    }
    else
    {
        scaledSize.height = imageSize.height * (targetSize.width / imageSize.width);
    }
    
    CGRect rect = CGRectMake(0.0f, (targetSize.height - scaledSize.height) / 2.0f, scaledSize.width, scaledSize.height);
    [sourceImage drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
}