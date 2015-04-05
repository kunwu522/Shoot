//
//  UserShootMapView.m
//  Shoot
//
//  Created by LV on 3/16/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserShootMapView.h"
#import "MapView.h"
#import "MapAnnotation.h"
#import "UserTagShootDao.h"
#import "UserTagShoot.h"
#import "ImageUtil.h"
#import "ImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserShootMapView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) MapView *mapView;
@property (retain, nonatomic) User * user;
@property (retain, nonatomic) NSNumber *tagType;
@property (retain, nonatomic) UIButton * gridViewButton;
@property (retain, nonatomic) UIView *visualEffectView;
@property (retain, nonatomic) UICollectionView *imageCollectionView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation UserShootMapView

static CGFloat GRID_VIEW_BUTTON_SIZE = 20;
static CGFloat PADDING = 10;
static CGFloat COLLECTION_VIEW_ANIMATION_DELTA = 100;
static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user
{
    self = [super initWithFrame:frame];
    if (self) {
        self.user = user;
        self.mapView = [[MapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.mapView];
        
        self.visualEffectView = [[UIView alloc] initWithFrame:self.bounds];
        self.visualEffectView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        [self addSubview:self.visualEffectView];
        self.visualEffectView.hidden = true;
        [self.visualEffectView setAlpha:0.0];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = PADDING/4.0;
        layout.minimumInteritemSpacing = PADDING/4.0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(PADDING, PADDING + COLLECTION_VIEW_ANIMATION_DELTA, self.frame.size.width - PADDING * 2, self.frame.size.height - PADDING * 2) collectionViewLayout:layout];
        self.imageCollectionView.showsHorizontalScrollIndicator = false;
        self.imageCollectionView.showsVerticalScrollIndicator = false;
        [self.imageCollectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
        self.imageCollectionView.dataSource = self;
        self.imageCollectionView.delegate = self;
        [self.imageCollectionView setAlpha:0.0];
        [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
        [self.imageCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID];
        [self addSubview:self.imageCollectionView];
        self.imageCollectionView.hidden = true;
        
        self.gridViewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - GRID_VIEW_BUTTON_SIZE - PADDING, self.frame.size.height - GRID_VIEW_BUTTON_SIZE - PADDING, GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)];
        [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.gridViewButton addTarget:self action:@selector(gridViewButtonPressed:)forControlEvents:UIControlEventTouchDown];
        CALayer * l = [self.gridViewButton layer];
        l.shadowOffset = CGSizeMake(0, 0);
        l.shadowRadius = 3;
        l.shadowColor = [UIColor blackColor].CGColor;
        l.shadowOpacity = 0.8;
        [self addSubview:self.gridViewButton];
        
        [self initFetchController];
    }
    return self;
}

- (void) initFetchController
{
    NSString *sectionNameKeyPath = @"shootID";
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
}

- (void) gridViewButtonPressed:(UIButton *)sender
{
    if (!self.visualEffectView.hidden) {
        [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.gridViewButton setFrame:CGRectMake(self.frame.size.width - GRID_VIEW_BUTTON_SIZE - PADDING, self.frame.size.height - GRID_VIEW_BUTTON_SIZE - PADDING, GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)];
        [UIView animateWithDuration:0.5 animations:^{
            [self.visualEffectView setAlpha:0.0];
            [self.imageCollectionView setAlpha:0.0];
            [self.imageCollectionView setFrame:CGRectMake(PADDING, PADDING + COLLECTION_VIEW_ANIMATION_DELTA, self.frame.size.width - PADDING * 2, self.frame.size.height - PADDING * 2)];
        } completion:^(BOOL finished){
            self.visualEffectView.hidden = true;
            self.imageCollectionView.hidden = true;
        }];
        
    } else {
        [self filterUserTagShoots];
        self.visualEffectView.hidden = false;
        self.imageCollectionView.hidden = false;
        [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"cancel-icon"] atSize:CGSizeMake(GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.gridViewButton setFrame:CGRectMake(PADDING/2.0, PADDING/2.0, GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)];
        [UIView animateWithDuration:0.5 animations:^{
            [self.imageCollectionView setFrame:CGRectMake(PADDING, PADDING, self.frame.size.width - PADDING * 2, self.frame.size.height - PADDING * 2)];
            [self.visualEffectView setAlpha:1.0];
            [self.imageCollectionView setAlpha:1.0];
        } completion:^(BOOL finished){
            
        }];
    }
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
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
    UserTagShoot *userTagShoot = (UserTagShoot *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
    [cell.imageView sd_setImageWithURL:[ImageUtil imageURLOfShoot:userTagShoot.shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self getCollectionViewCellHeight], [self getCollectionViewCellHeight]);
}

- (CGFloat) getCollectionViewCellHeight
{
    return (self.frame.size.width - PADDING * 2.5)/3.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void) reloadForType:(NSNumber *)tagType
{
    self.tagType = tagType;
    NSArray *userTagShoots = [[UserTagShootDao sharedManager] findUserTagShootsLocallyByUserId:self.user.userID forType:tagType];
    [self filterUserTagShoots];
    if ([userTagShoots count] == 0) {
        return;
    }
    NSMutableArray *userTagShootsAnnotations = [NSMutableArray new];
    for (UserTagShoot *userTagShoot in userTagShoots) {
        [userTagShootsAnnotations addObject:[userTagShoot getMapAnnotation]];
    }
    [self.mapView setAnnotations:userTagShootsAnnotations];
}

- (void) filterUserTagShoots
{
    MKCoordinateRegion mapRegion = [self.mapView getRegion];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@ && type == %@ && longitude < %f && longitude > %f && latitude < %f && latitude > %f", self.user.userID, self.tagType, mapRegion.center.longitude + mapRegion.span.longitudeDelta/2.0, mapRegion.center.longitude - mapRegion.span.longitudeDelta/2.0, mapRegion.center.latitude + mapRegion.span.latitudeDelta/2.0, mapRegion.center.latitude - mapRegion.span.latitudeDelta/2.0]];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch UserTagShoot for user Error: %@",error);
    }
    [self.imageCollectionView reloadData];
}

@end
