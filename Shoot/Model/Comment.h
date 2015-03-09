//
//  Comment.h
//  Shoot
//
//  Created by LV on 3/8/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shoot, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * commentID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * if_cur_user_like_it;
@property (nonatomic, retain) Shoot * shoot;
@property (nonatomic, retain) User * user;

@end
