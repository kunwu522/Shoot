//
//  MapAnnotation.h
//  Shoot
//
//  Created by LV on 1/27/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property NSInteger imageCount;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;

- (MKMapItem*)mapItem;

@end
