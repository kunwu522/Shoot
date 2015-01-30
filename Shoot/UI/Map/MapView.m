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

@interface MapView () <MKMapViewDelegate>

@property (retain, nonatomic) MKMapView *mapView;
@property (retain, nonatomic) NSMutableSet *annotationSet;

@end

@implementation MapView

static NSString *REUSE_ID = @"MAP_ANNOTATION_CELL_REUSE_ID";

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

-(void) setAnnotations:(NSArray *) annotations
{
    [self.annotationSet addObjectsFromArray:annotations];
    [self.mapView addAnnotations:annotations];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
