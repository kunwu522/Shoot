//
//  UserTagShoot.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Shoot.h"
#import "Tag.h"
#import "User.h"

@interface UserTagShoot : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * shoot_id;
@property (nonatomic, retain) NSNumber * tag_id;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longtitude;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Shoot * shoot;
@property (nonatomic, retain) Tag * tag;
@property (nonatomic, retain) User * user;

@end
