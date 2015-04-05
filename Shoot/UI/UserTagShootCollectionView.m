//
//  UserTagShootCollectionView.m
//  Shoot
//
//  Created by LV on 3/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserTagShootCollectionView.h"
#import "ImageCollectionViewCell.h"
#import "ImageDetailedCollectionViewCell.h"
#import "UIViewHelper.h"
#import "UserTagShoot.h"
#import <CoreData.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageUtil.h"

@interface UserTagShootCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) UICollectionView *imageCollectionView;
@property (nonatomic) BOOL isGridView;
@property (retain, nonatomic) UIViewController *parentController;

@end

@implementation UserTagShootCollectionView

static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

static NSString * IMAGE_DETAILED_CELL_REUSE_ID = @"ImageDetailedCell";

static CGFloat PADDING = 5;

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.user = user;
        self.parentController = parentController;
        [self initFetchController];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = PADDING;
        layout.minimumInteritemSpacing = PADDING;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        [UIViewHelper applySameSizeConstraintToView:self.imageCollectionView superView:self];
        [self.imageCollectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
        self.imageCollectionView.dataSource = self;
        self.imageCollectionView.delegate = self;
        [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
        [self.imageCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID];
        [self.imageCollectionView registerClass:[ImageDetailedCollectionViewCell class] forCellWithReuseIdentifier:IMAGE_DETAILED_CELL_REUSE_ID];
        self.isGridView = YES;
        [self addSubview:self.imageCollectionView];
        
        self.showLikeButton = false;
    }
    return self;
}

- (void) initFetchController
{
    NSString *sectionNameKeyPath = @"shootID";
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
}

- (void) reload
{
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch UserTagShoot for user Error: %@",error);
    }
    [self.imageCollectionView reloadData];
}

- (void) setCollectionViewStatus:(BOOL)isGridView
{
    self.isGridView = isGridView;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self getImagesCount];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) getImagesCount
{
    return [[self.fetchedResultsController sections] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserTagShoot *userTagShoot = (UserTagShoot *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
    if (self.isGridView) {
        ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
        [cell.imageView sd_setImageWithURL:[ImageUtil imageURLOfShoot:userTagShoot.shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
        return cell;
    } else {
        ImageDetailedCollectionViewCell *cell = (ImageDetailedCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_DETAILED_CELL_REUSE_ID forIndexPath:indexPath];
        NSArray *userTagShoots = [[[self.fetchedResultsController sections] objectAtIndex:indexPath.row] objects];
        [cell decorateWith:userTagShoot.shoot user:self.user userTagShoots:userTagShoots parentController:self.parentController showLikeCount:self.showLikeButton];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isGridView) {
        return CGSizeMake((self.frame.size.width - PADDING * 4)/3.0, [self getCollectionViewCellHeight]);
    } else {
        return CGSizeMake((self.frame.size.width - PADDING * 2)/1.0, [self getCollectionViewCellHeight]);
    }
}

- (CGFloat) getCollectionViewCellHeight
{
    if (self.isGridView) {
        return (self.frame.size.width - PADDING * 4)/3.0;
    } else {
        return (self.frame.size.width - PADDING * 2) * 3.0 /4.0;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
}

- (CGFloat) getCollectionViewHeight
{
    if (self.isGridView) {
        int rowCount = ceil([self getImagesCount] / 3.0);
        return (PADDING + [self getCollectionViewCellHeight]) * rowCount + PADDING;
    } else {
        return (PADDING + [self getCollectionViewCellHeight]) * [self getImagesCount] + PADDING;
    }
}

@end
