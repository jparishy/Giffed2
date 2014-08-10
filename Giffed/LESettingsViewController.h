//
//  LESettingsViewController.h
//  Giffed
//
//  Created by Julius Parishy on 8/10/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LECaptureMode)
{
    LECaptureModePicture,
    LECaptureModeVideo
};

@protocol LESettingsViewControllerDelegate;

@interface LESettingsViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<LESettingsViewControllerDelegate> delegate;

@end


@protocol LESettingsViewControllerDelegate <NSObject>

@required
- (void)settingsViewController:(LESettingsViewController *)viewController didChangeToCaptureMode:(LECaptureMode)captureMode;
- (void)settingsViewControllerDidToggleCameraPosition:(LESettingsViewController *)viewController;

@end