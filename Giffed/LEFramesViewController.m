//
//  LEFramesViewController.m
//  Giffed
//
//  Created by Julius Parishy on 7/27/14.
//  Copyright (c) 2014 le. All rights reserved.
//

#import "LEFramesViewController.h"

#import "LEFrameRecord.h"
#import "LEFrameRecordViewModel.h"
#import "LEFrameRecordCell.h"

@interface LEFramesViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *viewModels;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation LEFramesViewController

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
    
    self.viewModels = @[];
    
    [self.collectionView registerClass:[LEFrameRecordCell class] forCellWithReuseIdentifier:[LEFrameRecordCell cellIdentifier]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)frames
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    
    for(LEFrameRecordViewModel *viewModel in self.viewModels)
    {
        [frames addObject:viewModel.record];
    }
    
    return [frames copy];
}

- (void)addFrame:(LEFrameRecord *)record
{
    LEFrameRecordViewModel *viewModel = [[LEFrameRecordViewModel alloc] initWithRecord:record];
    _viewModels = [self.viewModels arrayByAddingObject:viewModel];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.viewModels.count - 1) inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[ indexPath ]];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)discardFrames
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    [self.viewModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    
    self.viewModels = @[];
    
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LEFrameRecordCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[LEFrameRecordCell cellIdentifier] forIndexPath:indexPath];
    
    LEFrameRecordViewModel *recordViewModel = self.viewModels[indexPath.row];
    cell.recordViewModel = recordViewModel;
    
    return cell;
}

@end
