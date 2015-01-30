//
//  MapAnnotationView.h
//  Shoot
//
//  Created by LV on 1/28/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapCalloutView.h"

@interface MapAnnotationView : MKAnnotationView

@property (nonatomic, retain) MapCalloutView * calloutView;

- (void) decorateWithAnnotation:(id<MKAnnotation>)annotation;

@end
