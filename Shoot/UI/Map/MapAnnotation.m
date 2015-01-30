//
//  MapAnnotation.m
//  Shoot
//
//  Created by LV on 1/27/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count {
    if ((self = [super init])) {
        self.coordinate = coordinate;
        self.imageCount = count;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
