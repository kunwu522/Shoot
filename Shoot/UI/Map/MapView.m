//
//  MapView.m
//  Shoot
//
//  Created by LV on 1/29/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MapView.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "ImageUtil.h"
#import "BlurView.h"
#import "ImageCollectionViewCell.h"
#import "ColorDefinition.h"
#import "UIViewHelper.h"

@interface MapView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate>

@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) NSMutableSet *annotationSet;
@property (retain, nonatomic) UIButton * gridViewButton;
@property (retain, nonatomic) UIView *visualEffectView;
@property (retain, nonatomic) UICollectionView *imageCollectionView;

@end

@implementation MapView

static NSString *REUSE_ID = @"MAP_ANNOTATION_CELL_REUSE_ID";
static CGFloat GRID_VIEW_BUTTON_SIZE = 20;
static CGFloat PADDING = 10;
static CGFloat COLLECTION_VIEW_ANIMATION_DELTA = 100;
static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.mapView];
        self.mapView.delegate = self;
        self.annotationSet = [[NSMutableSet alloc] init];
        
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
        [self.imageCollectionView reloadData];
        
        self.gridViewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - GRID_VIEW_BUTTON_SIZE - PADDING, self.frame.size.height - GRID_VIEW_BUTTON_SIZE - PADDING, GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)];
        [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(GRID_VIEW_BUTTON_SIZE, GRID_VIEW_BUTTON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.gridViewButton addTarget:self action:@selector(gridViewButtonPressed:)forControlEvents:UIControlEventTouchDown];
        CALayer * l = [self.gridViewButton layer];
        l.shadowOffset = CGSizeMake(0, 0);
        l.shadowRadius = 3;
        l.shadowColor = [UIColor blackColor].CGColor;
        l.shadowOpacity = 0.8;
        [self addSubview:self.gridViewButton];
    }
    return self;
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

- (void) setAnnotations:(NSArray *) annotations
{
    [self.annotationSet removeAllObjects];
    [self.annotationSet addObjectsFromArray:annotations];
    [self refreshAnnotations];
}

- (void) refreshAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableSet *annotationCandidates = [[NSMutableSet alloc] initWithSet:self.annotationSet];
    
    CGFloat minimalDiff = MIN(self.mapView.region.span.latitudeDelta/self.mapView.frame.size.width, self.mapView.region.span.longitudeDelta/self.mapView.frame.size.height) * ([MapAnnotationView getAnnotationSize] + 10);
    
    while ([annotationCandidates count] > 0) {
        MapAnnotation *maxValue = nil;
        for (MapAnnotation *annotation in annotationCandidates) {
            if (maxValue == nil || annotation.imageCount > maxValue.imageCount) {
                maxValue = annotation;
            }
        }
        [annotationCandidates removeObject:maxValue];
        NSInteger count = maxValue.imageCount;
        
        NSMutableArray *discardedItems = [NSMutableArray array];
        for (MapAnnotation *annotation in annotationCandidates) {
            CGFloat xDiff = annotation.coordinate.latitude - maxValue.coordinate.latitude;
            CGFloat yDiff = annotation.coordinate.longitude - maxValue.coordinate.longitude;
            if (xDiff * xDiff + yDiff * yDiff < minimalDiff * minimalDiff) {
                [discardedItems addObject:annotation];
                count = count + annotation.imageCount;
            }
        }
        for (MapAnnotation *annotationToBeDelete in discardedItems) {
            [annotationCandidates removeObject:annotationToBeDelete];
        }
        [self.mapView addAnnotation:[[MapAnnotation alloc] initWithCoordinate:maxValue.coordinate count:count]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        MapAnnotationView *annotationView = (MapAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:REUSE_ID];
        if (annotationView == nil) {
            annotationView = [[MapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:REUSE_ID];
            annotationView.enabled = YES;
        } else {
            [annotationView setAnnotation:annotation];
        }
        [annotationView decorateWithAnnotation:annotation];
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self refreshAnnotations];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MapAnnotation *annotationView = (MapAnnotation *)view;
    CGFloat targetLatitudeDelta = self.mapView.region.span.latitudeDelta * 0.5;
    CGFloat targetLongtitudeDelta = self.mapView.region.span.longitudeDelta * 0.5;
    [self.mapView setRegion:MKCoordinateRegionMake(annotationView.coordinate, MKCoordinateSpanMake(targetLatitudeDelta, targetLongtitudeDelta)) animated:true];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self getImagesCount];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) getImagesCount
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg", indexPath.row % 5 + 1]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 4 == 1 || indexPath.row % 4 == 2) {
        return CGSizeMake([self getCollectionViewCellHeight] * 2, [self getCollectionViewCellHeight]);
    } else {
        return CGSizeMake([self getCollectionViewCellHeight] + PADDING / 4.0 - .1, [self getCollectionViewCellHeight]);
    }
    
}

- (CGFloat) getCollectionViewCellHeight
{
    return (self.frame.size.width - PADDING * 2.5)/3.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
