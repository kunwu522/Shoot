//
//  TagCollectionView.m
//  Shoot
//
//  Created by LV on 3/25/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagCollectionView.h"
#import "TagCollectionViewCell.h"
#import "UserTagShoot.h"
#import "TagViewController.h"

@interface TagCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *haveTags;
@property (nonatomic, retain) NSArray *wantTags;
@property (nonatomic, retain) UIViewController *parentController;

@end

@implementation TagCollectionView

static const CGFloat PADDING = 5;
static NSString *CELL_REUSE_ID = @"TagCollectionViewCell";
static NSString *SECTION_HEADER_REUSE_ID = @"TagCollectionViewSectionHeader";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = PADDING;
        layout.minimumInteritemSpacing = PADDING;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        [self.collectionView registerClass:[TagCollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
        [self.collectionView registerClass:[TagCollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SECTION_HEADER_REUSE_ID];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void) setTags:(NSArray *)userTagShoots parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    NSPredicate *wantPredicate = [NSPredicate predicateWithFormat:@"type == 0"];
    self.wantTags = [userTagShoots filteredArrayUsingPredicate:wantPredicate];
    NSPredicate *havePredicate = [NSPredicate predicateWithFormat:@"type == 1"];
    self.haveTags = [userTagShoots filteredArrayUsingPredicate:havePredicate];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.wantTags count];
        case 1:
            return [self.haveTags count];
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TagCollectionViewCell *cell = (TagCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    Tag *tag = [self getTagForIndexPath:indexPath];
    [cell decorateWithTag:tag parentController:self.parentController];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self getTagForIndexPath:indexPath];
    CGSize size = [TagCollectionViewCell getExpectedSizeForTag:tag];
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, 0, PADDING, 0);
}

- (Tag *) getTagForIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return ((UserTagShoot *)[self.wantTags objectAtIndex:indexPath.row]).tag;
        case 1:
            return ((UserTagShoot *)[self.haveTags objectAtIndex:indexPath.row]).tag;
        default:
            return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize minimalSize = [TagCollectionViewCell getExpectedSizeForTypeCell];
    switch (section) {
        case 0:
            return [self.wantTags count]?CGSizeMake(minimalSize.width + PADDING * 2, minimalSize.height + PADDING * 2):CGSizeZero;
        case 1:
            return [self.haveTags count]?CGSizeMake(minimalSize.width + PADDING * 2, minimalSize.height + PADDING * 2):CGSizeZero;
        default:
            return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        TagCollectionViewCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SECTION_HEADER_REUSE_ID forIndexPath:indexPath];
        [headerView decorateTagType:[NSNumber numberWithLong:indexPath.section]];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = [self getTagForIndexPath:indexPath];
    [self tappedTag:tag];
}

- (void)tappedTag:(Tag *)tag
{
    if (self.parentController) {
        TagViewController* viewController = [[TagViewController alloc] initWithNibName:nil bundle:nil];
        viewController.tag = tag;
        [self.parentController presentViewController:viewController animated:YES completion:nil];
    }
}


@end
