//
//  GeoDao.h
//  Shoot
//
//  Created by LV on 3/7/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "Dao.h"
#import <MapKit/MapKit.h>

@interface GeoDao : Dao

@property (nonatomic, retain) CLGeocoder * geocoder;

@end
