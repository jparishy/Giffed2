//
//  LEGraphicsUtilities.h
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

@import CoreGraphics;
@import AVFoundation;

UIImage *LEUIImageFromSampleBuffer(CMSampleBufferRef sampleBuffer, UIImageOrientation orientation);
UIImage *LEGIFImageFrame(UIImage *sourceImage, CGSize targetSize);