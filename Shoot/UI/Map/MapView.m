//
//  MapView.m
//  Shoot
//
//  Created by LV on 1/29/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MapView.h"
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "UIViewHelper.h"

@interface MapView () <MKMapViewDelegate>

@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) NSMutableSet *annotationSet;

@end

@implementation MapView

static NSString *REUSE_ID = @"MAP_ANNOTATION_CELL_REUSE_ID";
static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.mapView];
        self.mapView.delegate = self;
        self.annotationSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void) setRegion:(MKCoordinateRegion)mapRegion
{
    [self.mapView setRegion:mapRegion];
}

- (MKCoordinateRegion) getRegion
{
    return self.mapView.region;
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
    
    CGFloat minimalDiff = MIN(self.mapView.region.span.latitudeDelta/self.mapView.frame.size.width, self.mapView.region.span.longitudeDelta/self.mapView.frame.size.height) * ([MapAnnotationView getAnnotationSize] + 50);
    
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
    CGFloat targetLongitudeDelta = self.mapView.region.span.longitudeDelta * 0.5;
    [self.mapView setRegion:MKCoordinateRegionMake(annotationView.coordinate, MKCoordinateSpanMake(targetLatitudeDelta, targetLongitudeDelta)) animated:true];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
