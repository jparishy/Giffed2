//
//  LESettingsViewController.m
//  Giffed
//
//  Created by Julius Parishy on 8/10/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LESettingsViewController.h"

@interface LESettingsViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (nonatomic, weak) IBOutlet UILabel *modeExplanationLabel;

@end

@implementation LESettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.modeExplanationLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.modeExplanationLabel.frame);
    
    LECaptureMode captureMode = [self captureModeFromSegmentedControl:self.modeSegmentedControl];
    [self updateModeExplanationLabelForCaptureMode:captureMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - State

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.modeSegmentedControl forKey:@"selectedSegmentIndex"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.modeSegmentedControl.selectedSegmentIndex = [coder decodeIntegerForKey:@"selectedSegmentIndex"];
    
    LECaptureMode captureMode = [self captureModeFromSegmentedControl:self.modeSegmentedControl];
    [self updateModeExplanationLabelForCaptureMode:captureMode];
}

#pragma mark - Capture mode

- (LECaptureMode)captureModeFromSegmentedControl:(UISegmentedControl *)segmentedControl
{
    return (segmentedControl.selectedSegmentIndex == 0) ? LECaptureModePicture : LECaptureModeVideo;
}

- (IBAction)modeSegmentedControlValueChanged:(UISegmentedControl *)segmentedControl
{
    LECaptureMode captureMode = [self captureModeFromSegmentedControl:segmentedControl];
    [self updateModeExplanationLabelForCaptureMode:captureMode];
    
    if(self.delegate)
    {
        [self.delegate settingsViewController:self didChangeToCaptureMode:captureMode];
    }
}

- (void)updateModeExplanationLabelForCaptureMode:(LECaptureMode)captureMode
{
    switch(captureMode)
    {
        case LECaptureModePicture:
        {
            NSString *explanation = NSLocalizedString(@"In Picture Mode, you add\none frame at a time to create a GIF", nil);
            self.modeExplanationLabel.text = explanation;
            
            break;
        }
        
        case LECaptureModeVideo:
        {
            NSString *explanation = NSLocalizedString(@"In Video Mode, you record a\nshort video to create a GIF", nil);
            self.modeExplanationLabel.text = explanation;
        }
    }
}

#pragma Camera position

- (IBAction)toggleCameraPositionButtonPressed:(UIButton *)button
{
    static CGFloat multiplier = 1.0f;
    
    const CGFloat angle = M_PI * multiplier;
    multiplier *= -1.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:1.0f delay:0.0f options:options animations:^{
        
        CATransform3D transform = button.layer.transform;
        transform = CATransform3DRotate(transform, angle, 0.0f, 1.0f, 0.0f);
        
        button.layer.transform = transform;
        
    } completion:nil];
    
    if(self.delegate)
    {
        [self.delegate settingsViewControllerDidToggleCameraPosition:self];
    }
}

@end
