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

static NSString * USER_TAG_SHOOTS_KEY_PATH_URL = @"user_tag_shoots";
static const NSString * QUERY_URL = @"shoot/query";
static const NSString * QUERY_BY_USER_URL = @"shoot/query/:id";
static const NSString * TAGS_FOR_SHOOT_URL = @"shoot/userTagsForShoot/:id";
static const NSString * TAGS_FOR_SHOOT_AND_TYPE_URL = @"shoot/userTagsForShoot/:id/:type";

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([UserTagShoot class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                               @"latitude" : @"latitude",
                                                               @"longitude" : @"longitude",
                                                               @"deleted" : @"shouldBeDeleted",
                                                               @"is_feed" : @"is_feed",
                                                               @"user.id" : @"userID",
                                                               @"shoot.id" : @"shootID",
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
                           TAGS_FOR_SHOOT_URL,
                           TAGS_FOR_SHOOT_AND_TYPE_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:RKRequestMethodGET pathPattern:url keyPath:USER_TAG_SHOOTS_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];

    }
}

- (NSArray *) findUserTagShootsLocallyByUserId:(NSNumber *)userID shootID:(NSNumber *)shootID {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@ && shootID == %@", userID, shootID]];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    return results;
}

- (NSArray *) findUserTagShootsLocallyByUserId:(NSNumber *)userID forType:(NSNumber *)tagType {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@ and type == %@", userID, tagType]];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    return results;
}

@end
