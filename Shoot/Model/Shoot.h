//
//  Shoot.h
//  Shoot
//
//  Created by LV on 3/8/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, User, UserTagShoot, Message;

@interface Shoot : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * if_cur_user_have_it;
@property (nonatomic, retain) NSNumber * if_cur_user_like_it;
@property (nonatomic, retain) NSNumber * if_cur_user_want_it;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * shootID;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * want_count;
@property (nonatomic, retain) NSNumber * have_count;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *user_tags;
@property (nonatomic, retain) NSSet *comments;
@end

@interface Shoot (CoreDataGeneratedAccessors)

- (void)addUser_tagsObject:(UserTagShoot *)value;
- (void)removeUser_tagsObject:(UserTagShoot *)value;
- (void)addUser_tags:(NSSet *)values;
- (void)removeUser_tags:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
