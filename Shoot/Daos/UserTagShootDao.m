//
//  UserTagShootDao.m
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserTagShootDao.h"
#import "UserDao.h"
#import "UserTagShoot.h"
#import "ShootDao.h"
#import "TagDao.h"

@implementation UserTagShootDao

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([UserTagShoot class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                               @"user.id" : @"user_id",
                                                               @"shoot.id" : @"shoot_id",
                                                               @"tag.id" : @"tag_id",
                                                               @"latitude" : @"latitude",
                                                               @"longtitude" : @"longtitude",
                                                               @"deleted" : @"shouldBeDeleted",
                                                               @"time" : @"time",
                                                               @"type" : @"type"
                                                               }];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shoot" toKeyPath:@"shoot" withMapping:[[ShootDao sharedManager] getResponseMapping]]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tag" toKeyPath:@"tag" withMapping:[[TagDao sharedManager] getResponseMapping]]];
    
    responseMapping.identificationAttributes = @[ @"user_id", @"shoot_id", @"tag_id" ];
    return responseMapping;
}

@end
