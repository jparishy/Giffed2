//
//  LELibraryViewController.m
//  Giffed
//
//  Created by Julius Parishy on 8/10/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LELibraryViewController.h"

@interface LELibraryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation LELibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Library", nil);
    
    self.tableView.contentInset = self.tableView.scrollIndicatorInsets;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User interaction

- (IBAction)closeLibraryButtonPressed:(UIButton *)button
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
