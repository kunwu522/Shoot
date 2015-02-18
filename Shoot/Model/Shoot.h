//
//  Shoot.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class UserTagShoot, User;

@interface Shoot : RemoteObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSNumber * want_count;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * if_cur_user_want_it;
@property (nonatomic, retain) NSNumber * if_cur_user_like_it;
@property (nonatomic, retain) NSNumber * if_cur_user_have_it;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *user_tags;
@end

@interface Shoot (CoreDataGeneratedAccessors)

- (void)addUser_tagsObject:(UserTagShoot *)value;
- (void)removeUser_tagsObject:(UserTagShoot *)value;
- (void)addUser_tags:(NSSet *)values;
- (void)removeUser_tags:(NSSet *)values;

@end
