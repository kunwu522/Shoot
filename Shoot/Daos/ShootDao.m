//
//  ShootDao.m
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootDao.h"
#import "Shoot.h"
#import "UserDao.h"

@implementation ShootDao

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Shoot class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"id",
                                                      @"time" : @"time",
                                                      @"deleted" : @"shouldBeDeleted",
                                                      @"content" : @"content",
                                                      @"want_count" : @"want_count",
                                                      @"like_count" : @"like_count",
                                                      @"is_feed" : @"is_feed",
                                                      @"score" : @"score",
                                                      @"if_cur_user_want_it" : @"if_cur_user_want_it",
                                                      @"if_cur_user_like_it" : @"if_cur_user_like_it",
                                                      @"if_cur_user_have_it" : @"if_cur_user_have_it",
                                                      }];
    
    responseMapping.identificationAttributes = @[ @"id" ];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    return responseMapping;
}

@end
