//
//  LECaptureViewController.m
//  Giffed
//
//  Created by Julius Parishy on 7/26/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LECaptureViewController.h"

#import "LEFramesViewController.h"
#import "LESettingsViewController.h"
#import "LELibraryViewController.h"

#import "LENavigationBar.h"

#import "LECaptureView.h"
#import "LEProgressView.h"
#import "LEBeginRecordingCountdownView.h"
#import "LERecordingIndicatorView.h"
#import "LEFrameRecord.h"
#import "LEMovieGIFExporter.h"

#import "UIView+LECommonLayoutConstraints.h"
#import "NSFileManager+LETemporary.h"

@import MobileCoreServices;

@interface LECaptureViewController () <LESettingsViewControllerDelegate>

@property (nonatomic, assign) LECaptureMode captureMode;

@property (nonatomic, strong) LEFramesViewController *framesViewController;

@property (nonatomic, weak) IBOutlet UIView *framesViewContainer;
@property (nonatomic, weak) IBOutlet UIView *framesViewContainerSeparator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *framesViewContainerHeightConstraint;
@property (nonatomic, assign) CGFloat framesViewContainerOpenHeight;

@property (nonatomic, weak) IBOutlet LECaptureView *captureView;
@property (nonatomic, weak) IBOutlet LEProgressView *progressView;
@property (nonatomic, weak) IBOutlet LEBeginRecordingCountdownView *countdownView;
@property (nonatomic, weak) IBOutlet LERecordingIndicatorView *recordingIndicatorView;

@property (nonatomic, weak) IBOutlet UILabel *exportingLabel;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;

@property (nonatomic, weak) IBOutlet UIView *settingsViewContainer;
@property (nonatomic, strong) LESettingsViewController *settingsViewController;

@property (nonatomic, strong) LEMovieGIFExporter *GIFExporter;

@end

@implementation LECaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeFramesViewController];
    [self initializeSettingsViewController];
    [self updateSaveButtonState];
    
    self.exportingLabel.alpha = 0.0f;
    self.recordingIndicatorView.recording = NO;
    
    self.captureMode = LECaptureModePicture;
    
    [self updateInterfaceForCaptureMode:self.captureMode animated:NO];
    self.title = [self titleForCaptureMode:self.captureMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self beginCapturingWithCameraPosition:LECameraPositionFront];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - State restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.framesViewController forKey:@"framesViewController"];
    [coder encodeObject:self.settingsViewController forKey:@"settingsViewController"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - Frames child view controller

- (void)initializeFramesViewController
{
    self.framesViewContainerOpenHeight = CGRectGetHeight(self.framesViewContainer.bounds);
    
    self.framesViewController = [[LEFramesViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.framesViewController];
    
    UIView *view = self.framesViewController.view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *superview = self.framesViewContainer;

    [superview addSubview:view];
    
    NSDictionary *metrics = @{
        @"height" : @(self.framesViewContainerOpenHeight)
    };
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view, superview);
    
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:kNilOptions metrics:nil views:views];
    NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(==height)]" options:kNilOptions metrics:metrics views:views];
    
    [self.framesViewContainer addConstraints:horizontal];
    [self.framesViewContainer addConstraints:vertical];
    
    [self setFramesViewHidden:YES animated:NO];
}

- (void)setFramesViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    void(^changes)() = ^{
        
        self.framesViewContainerSeparator.alpha = hidden ? 0.0f : 1.0f;
        self.framesViewContainerHeightConstraint.constant = hidden ? 0.0f : self.framesViewContainerOpenHeight;
        
        [self.view layoutIfNeeded];
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            changes();
        } completion:nil];
    }
    else
    {
        changes();
    }
}

#pragma mark - Settings view controller

- (void)initializeSettingsViewController
{
    self.settingsViewController = [[LESettingsViewController alloc] initWithNibName:nil bundle:nil];
    self.settingsViewController.delegate = self;
    
    [self addChildViewController:self.settingsViewController];
    
    UIView *view = self.settingsViewController.view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.settingsViewContainer addSubview:view];
    [self.settingsViewContainer le_addContraintsForFilledView:view insets:UIEdgeInsetsZero];
}

- (void)settingsViewController:(LESettingsViewController *)viewController didChangeToCaptureMode:(LECaptureMode)captureMode
{
    self.captureMode = captureMode;
    
    [self updateInterfaceForCaptureMode:self.captureMode animated:YES];
}

- (void)settingsViewControllerDidToggleCameraPosition:(LESettingsViewController *)viewController
{
    LECameraPosition position = (self.captureView.cameraPosition == LECameraPositionBack) ? LECameraPositionFront : LECameraPositionBack;
    
    [UIView animateWithDuration:0.25f animations:^{
    
        self.captureView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        NSError *error = nil;
        if(![self.captureView updateCameraPosition:position error:&error])
        {
            // TODO: Show user error
            NSLog(@"Failed to update camera position: %@", error.localizedDescription);
        }
        
        [UIView animateWithDuration:0.25f animations:^{
            
            self.captureView.alpha = 1.0f;
        }];
    }];
}

#pragma mark - Capture interactions

- (void)beginCapturingWithCameraPosition:(LECameraPosition)cameraPosition
{
    NSError *error = nil;
    if(![self.captureView updateCameraPosition:cameraPosition error:&error])
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}

#pragma mark - Interaction

- (IBAction)recordButtonPressed:(UIButton *)button
{
    switch(self.captureMode)
    {
        case LECaptureModePicture:
        {
            [self handleRecordButtonPressedForFrameMode];
            break;
        }
        
        case LECaptureModeVideo:
        {
            [self handleRecordButtonPressedForVideoMode];
            break;
        }
    }
}

- (void)configureRecordButtonForRecord
{
    UIImage *image = [UIImage imageNamed:@"record"];
    [self.recordButton setImage:image forState:UIControlStateNormal];
    
    UIImage *imageSelected = [UIImage imageNamed:@"record-selected"];
    [self.recordButton setImage:imageSelected forState:UIControlStateHighlighted];
    [self.recordButton setImage:imageSelected forState:UIControlStateSelected];
}

- (void)configureRecordButtonForStop
{
    UIImage *image = [UIImage imageNamed:@"stop"];
    [self.recordButton setImage:image forState:UIControlStateNormal];
    
    UIImage *imageSelected = nil;
    [self.recordButton setImage:imageSelected forState:UIControlStateHighlighted];
    [self.recordButton setImage:imageSelected forState:UIControlStateSelected];
}

- (void)configureRecordButtonForPictureMode
{
    UIImage *image = [UIImage imageNamed:@"add-frame"];
    [self.recordButton setImage:image forState:UIControlStateNormal];
    
    UIImage *imageSelected = nil;
    [self.recordButton setImage:imageSelected forState:UIControlStateHighlighted];
    [self.recordButton setImage:imageSelected forState:UIControlStateSelected];
}

- (void)handleRecordButtonPressedForVideoMode
{
    if(self.countdownView.isCountingDown)
    {
        [self.countdownView cancelCountdown];
    }
    else if(self.captureView.isRecording)
    {
        [self configureRecordButtonForRecord];
        
        __weak typeof(self) weakSelf = self;
        [self.captureView finishRecordingWithCompletion:^(NSURL *fileURL) {
            
            typeof(self) self = weakSelf;
            
            self.recordingIndicatorView.recording = NO;
            [self beginExportOfMovieWithURL:fileURL];
        }];
    }
    else
    {
        [self.countdownView beginCountdownWithCompletion:^(BOOL cancelled) {
           
            if(cancelled == NO)
            {
                [self configureRecordButtonForStop];
                
                [self.captureView beginRecording];
                
                self.recordingIndicatorView.recording = YES;
            }
            else
            {
                [self configureRecordButtonForRecord];
            }
        }];
        
        [self configureRecordButtonForStop];
    }
}

- (void)handleRecordButtonPressedForFrameMode
{
    __weak typeof(self) weakSelf = self;
    [self.captureView captureCurrentImageWithCompletion:^(NSData *GIFData) {
        
        typeof(self) self = weakSelf;
        [self saveGIFFrameWithData:GIFData completion:^(NSURL *fileURL) {
            
            typeof(self) self = weakSelf;
            
            LEFrameRecord *frame = [[LEFrameRecord alloc] initWithFileURL:fileURL];
            [self.framesViewController addFrame:frame];
            
            [self updateSaveButtonState];
            [self setFramesViewHidden:NO animated:YES];
        }];
    }];
}

- (void)updateInterfaceForCaptureMode:(LECaptureMode)captureMode animated:(BOOL)animated
{
    switch(captureMode)
    {
        case LECaptureModePicture:
        {
            [self configureRecordButtonForPictureMode];
            
            BOOL hidden = (self.framesViewController.frames.count == 0);
            [self setFramesViewHidden:hidden animated:animated];
            
            break;
        }
        
        case LECaptureModeVideo:
        {
            [self configureRecordButtonForRecord];
            
            [self setFramesViewHidden:YES animated:animated];
            
            break;
        }
    }
    
    [self updateSaveButtonState];
}

- (NSString *)titleForCaptureMode:(LECaptureMode)captureMode
{
    switch(captureMode)
    {
        case LECaptureModePicture:
        {
            return NSLocalizedString(@"Picture Mode", nil);
        }
        
        case LECaptureModeVideo:
        {
            return NSLocalizedString(@"Video Mode", nil);
        }
    }
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)barButtonItem
{
    [self beginExportOfFrames:self.framesViewController.frames];
    
    [self updateSaveButtonState];
}

- (void)updateSaveButtonState
{
    switch(self.captureMode)
    {
        case LECaptureModePicture:
        {
            NSString *title = NSLocalizedString(@"Save", nil);
            
            UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed:)];
            rightBarButtonItem.tintColor = [UIColor whiteColor];
            
            self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
            self.navigationItem.rightBarButtonItem.enabled = (self.GIFExporter.isExporting == NO) && (self.framesViewController.frames.count > 1);
            
            break;
        }
        
        case LECaptureModeVideo:
        {
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
    }
}

- (IBAction)settingsTapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    BOOL hidden = !self.settingsViewContainer.isHidden;
    
    if(hidden == NO)
    {
        self.settingsViewContainer.alpha = 0.0f;
        self.settingsViewContainer.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        CGFloat alpha = hidden ? 0.0f : 1.0f;
        self.settingsViewContainer.alpha = alpha;
    } completion:^(BOOL finished) {
        
        self.settingsViewContainer.hidden = hidden;
    }];
    
    self.recordButton.enabled = hidden;
    self.navigationItem.rightBarButtonItem.enabled = hidden;
    self.navigationItem.leftBarButtonItem.enabled = hidden;
    
    if(hidden)
    {
        [self updateInterfaceForCaptureMode:self.captureMode animated:YES];
        self.title = [self titleForCaptureMode:self.captureMode];
    }
    else
    {
        self.title = NSLocalizedString(@"Giffed Settings", nil);
        [self setFramesViewHidden:YES animated:YES];
    }
}

- (IBAction)openLibraryButtonPressed:(UIButton *)button
{
    LELibraryViewController *viewController = [[LELibraryViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[LENavigationBar class] toolbarClass:nil];
    navigationController.viewControllers = @[ viewController ];
    
    navigationController.navigationBar.titleTextAttributes = self.navigationController.navigationBar.titleTextAttributes;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Export/saving

- (void)saveGIFFrameWithData:(NSData *)GIFData completion:(void(^)(NSURL *fileURL))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [[NSFileManager defaultManager] le_pathForTemporaryFileWithExtension:@"jpg"];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        if(![GIFData writeToURL:fileURL options:NSDataWritingAtomic error:&error])
        {
            // TODO: Show to user
            NSLog(@"Error saving frame: %@", error.localizedDescription);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(fileURL);
        });
    });
}

- (void)beginExportOfMovieWithURL:(NSURL *)url
{
    self.GIFExporter = [[LEMovieGIFExporter alloc] initWithFileURL:url];
    
    __weak typeof(self) weakSelf = self;
    [self.GIFExporter exportGIFWithProgressUpdate:^(CGFloat progress) {
        
        typeof(self) self = weakSelf;
        [self.progressView setPercentage:progress animated:YES];
        
    } completion:^(NSData *GIFData) {
        
        typeof(self) self = weakSelf;
        [self handleExportedGIFData:GIFData];
    }];
    
    [self animateStateTransitionForExporting:YES];
}

- (void)beginExportOfFrames:(NSArray *)frames
{
    self.GIFExporter = [[LEMovieGIFExporter alloc] initWithFrameRecords:frames];
    
    __weak typeof(self) weakSelf = self;
    [self.GIFExporter exportGIFWithProgressUpdate:^(CGFloat progress) {
        
        typeof(self) self = weakSelf;
        [self.progressView setPercentage:progress animated:YES];
        
    } completion:^(NSData *GIFData) {
        
        typeof(self) self = weakSelf;
        
        [self.framesViewController discardFrames];
        [self setFramesViewHidden:YES animated:YES];
        
        [self handleExportedGIFData:GIFData];
    }];
    
    [self animateStateTransitionForExporting:YES];
}

- (void)handleExportedGIFData:(NSData *)GIFData
{
    [self animateStateTransitionForExporting:NO];
    
    [UIView animateWithDuration:0.25f delay:0.25f options:kNilOptions animations:^{
    
        self.progressView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
       
        [self.progressView setPercentage:0.0f];
        self.progressView.alpha = 1.0f;
    }];
    
    [self updateSaveButtonState];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setData:GIFData forPasteboardType:(NSString *)kUTTypeGIF];
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [self.countdownView displayAuxiliaryMessageWithText:NSLocalizedString(@"Copied!", nil)];
    }
    else
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = NSLocalizedString(@"You GIF is ready!", nil);
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)animateStateTransitionForExporting:(BOOL)exporting
{
    self.navigationItem.leftBarButtonItem.enabled = !exporting;
    
    void(^notExportingViews)() = ^{
        
        CGFloat alpha = exporting ? 0.0f : 1.0f;
        
        self.recordButton.alpha = alpha;
    };
    
    void(^exportingViews)() = ^{
    
        self.exportingLabel.alpha = exporting ? 1.0f : 0.0f;
    };
    
    if(exporting)
    {
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            notExportingViews();
        } completion:^(BOOL finished) {
            
            if(finished)
            {
                [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    exportingViews();
                } completion:nil];
            }
        }];
    }
    else
    {
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            exportingViews();
        } completion:^(BOOL finished) {
            
            if(finished)
            {
                [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    notExportingViews();
                } completion:nil];
            }
        }];
    }
}

@end
