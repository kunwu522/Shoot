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

static NSString * SHOOTS_KEY_PATH_URL = @"shoots";
static const NSString * QUERY_URL = @"shoot/query";
static const NSString * QUERY_BY_USER_URL = @"shoot/query/:id";
static const NSString * QUERY_BY_ID_URL = @"shoot/queryById/:id";

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([UserTagShoot class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                               @"latitude" : @"latitude",
                                                               @"longtitude" : @"longtitude",
                                                               @"deleted" : @"shouldBeDeleted",
                                                               @"is_feed" : @"is_feed",
                                                               @"user.userID" : @"userID",
                                                               @"shoot.shootID" : @"shootID",
                                                               @"tag.id" : @"tagID",
                                                               @"time" : @"time",
                                                               @"type" : @"type"
                                                               }];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shoot" toKeyPath:@"shoot" withMapping:[[ShootDao sharedManager] getResponseMapping]]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tag" toKeyPath:@"tag" withMapping:[[TagDao sharedManager] getResponseMapping]]];
    
    responseMapping.identificationAttributes = @[ @"userID", @"shootID", @"tagID" ];
    return responseMapping;
}

- (void) registerRestKitMapping
{
    [super registerRestKitMapping];
    RKObjectManager * manager = [RKObjectManager sharedManager];
    RKEntityMapping * responseMapping = [self getResponseMapping];
    
    //register url with "users" as GET response key path
    for(NSString *url in @[
                           QUERY_URL,
                           QUERY_BY_USER_URL,
                           QUERY_BY_ID_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodGET pathPattern:url keyPath:SHOOTS_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    }
}

@end
