//
//  UserTagShoot.m
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserTagShoot.h"


@implementation UserTagShoot

@dynamic shootID;
@dynamic userID;
@dynamic tagID;
@dynamic shootAndUser;
@dynamic latitude;
@dynamic longitude;
@dynamic shouldBeDeleted;
@dynamic is_feed;
@dynamic time;
@dynamic type;
@dynamic shoot;
@dynamic tag;
@dynamic user;

- (NSString *) shootAndUser {
    
    [self willAccessValueForKey:@"shootAndUser"];
    
    NSString *shootAndUser = [NSString stringWithFormat:@"%@-%@", self.shootID, self.userID];
    
    [self didAccessValueForKey:@"shootAndUser"];
    
    return shootAndUser;
}

- (MapAnnotation *) getMapAnnotation
{
    return [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]) count:1];
}

@end
