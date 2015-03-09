//
//  GeoDao.m
//  Shoot
//
//  Created by LV on 3/7/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "GeoDao.h"

@interface GeoDao ()

@end

@implementation GeoDao

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

@end
