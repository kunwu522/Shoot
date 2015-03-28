//
//  UserTagShootCollectionViewCell.m
//  Shoot
//
//  Created by LV on 3/19/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "UserTagShootCollectionViewCell.h"
#import "ImageDetailedCollectionViewCell.h"
#import "UIViewHelper.h"
#import "UserTagShoot.h"

NSString *const UserTagShootCollectionViewCellIdentifier = @"UserTagShootCollectionViewCellIdentifier";

@interface UserTagShootCollectionViewCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) UICollectionView *imageCollectionView;
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) UIViewController *parentController;

@end

@implementation UserTagShootCollectionViewCell

static NSString * IMAGE_DETAILED_CELL_REUSE_ID = @"ImageDetailedCell";

static CGFloat PADDING = 5;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = PADDING;
        layout.minimumInteritemSpacing = PADDING;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        [UIViewHelper applySameSizeConstraintToView:self.imageCollectionView superView:self];
        [self.imageCollectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
        self.imageCollectionView.dataSource = self;
        self.imageCollectionView.delegate = self;
        
        [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
        [self.imageCollectionView registerClass:[ImageDetailedCollectionViewCell class] forCellWithReuseIdentifier:IMAGE_DETAILED_CELL_REUSE_ID];
        [self addSubview:self.imageCollectionView];
        [self initFetchController];
    }
    return self;
}

- (void) decorateWithUserTagShootsPredicate:(NSPredicate *)predicate parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"UserTagShootCollectionViewCell Fetch UserTagShoot for user Error: %@",error);
    }
    [self.imageCollectionView reloadData];
}

- (void) initFetchController
{
    NSString *sectionNameKeyPath = @"shootAndUser";
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
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
    NSArray *userTagShoots = [[[self.fetchedResultsController sections] objectAtIndex:indexPath.row] objects];
    ImageDetailedCollectionViewCell *cell = (ImageDetailedCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_DETAILED_CELL_REUSE_ID forIndexPath:indexPath];
    UserTagShoot *firstUserTagShoot = userTagShoots[0];
    [cell decorateWith:firstUserTagShoot.shoot user:firstUserTagShoot.user userTagShoots:userTagShoots parentController:self.parentController];
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(self.frame.size.width - PADDING * 2, [self getCollectionViewCellHeight]);

}

- (CGFloat) getCollectionViewCellHeight
{
    return (self.frame.size.height - PADDING * 2);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
}

@end
