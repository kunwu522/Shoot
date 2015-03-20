//
//  UserTagShoot.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MapAnnotation.h"

#define USER_TAG_SHOOT_WANT_TYPE 0;
#define USER_TAG_SHOOT_HAVE_TYPE 1;

@class Tag, Shoot, User;

@interface UserTagShoot : NSManagedObject

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSNumber * shootID;
@property (nonatomic, readonly) NSString * shootAndUser;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * is_feed;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Shoot * shoot;
@property (nonatomic, retain) Tag * tag;
@property (nonatomic, retain) User * user;

- (MapAnnotation *) getMapAnnotation;

@end
