//
//  Tag.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class UserTagShoot;

@interface Tag : RemoteObject

@property (nonatomic, retain) NSNumber * have_count;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * want_count;
@property (nonatomic, retain) NSSet *tag_users;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addTag_usersObject:(UserTagShoot *)value;
- (void)removeTag_usersObject:(UserTagShoot *)value;
- (void)addTag_users:(NSSet *)values;
- (void)removeTag_users:(NSSet *)values;

@end
