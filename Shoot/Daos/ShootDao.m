//
//  ShootDao.m
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootDao.h"
#import "UserDao.h"

@implementation ShootDao

static const NSString * QUERY_SHOOT_BY_ID_URL = @"shoot/queryShootById/:id";
static const NSString * TOP_SHOOT_FOR_TAG_URL = @"shoot/topShootForTag/:tag_id";
static const NSString * LIKE_SHOOT_URL = @"shoot/like/:id";
static const NSString * UNLIKE_SHOOT_URL = @"shoot/unlike/:id";

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Shoot class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                      @"content" : @"content",
                                                      @"want_count" : @"want_count",
                                                      @"have_count" : @"have_count",
                                                      @"like_count" : @"like_count",
                                                      @"latitude" : @"latitude",
                                                      @"longitude" : @"longitude",
                                                      @"score" : @"score",
                                                      @"if_cur_user_want_it" : @"if_cur_user_want_it",
                                                      @"if_cur_user_like_it" : @"if_cur_user_like_it",
                                                      @"if_cur_user_have_it" : @"if_cur_user_have_it",
                                                      }];
    
    NSDictionary *parentObjectMapping = @{
                                          @"id" : @"shootID",
                                          @"time" : @"time",
                                          @"deleted" : @"shouldBeDeleted"
                                          };
    [responseMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    responseMapping.identificationAttributes = @[ @"shootID" ];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    return responseMapping;
}

- (void) registerRestKitMapping
{
    [super registerRestKitMapping];
    RKObjectManager * manager = [RKObjectManager sharedManager];
    RKEntityMapping * shootMapping = [self getResponseMapping];
    
    //register url with "users" as GET response key path
    for(NSString *url in @[
                           QUERY_SHOOT_BY_ID_URL,
                           TOP_SHOOT_FOR_TAG_URL,
                           LIKE_SHOOT_URL,
                           UNLIKE_SHOOT_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:shootMapping method:RKRequestMethodGET pathPattern:url keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
        
    }
}

- (Shoot *) findUserByIdLocally:(NSNumber *)id {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Shoot"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"shootID == %@", id]];
    fetchRequest.predicate = predicate;
    [fetchRequest setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(results == nil || [results count] == 0)
        return nil;
    else
        return  [results objectAtIndex:0];
}

@end
