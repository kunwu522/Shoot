//
//  UserDao.m
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserDao.h"
#import "ShootDao.h"

@interface UserDao ()

@end

@implementation UserDao

static NSString * USERS_KEY_PATH_URL = @"users";
static NSString * USER_KEY_PATH_URL = @"user";
static NSString * ERRORS_KEY_PATH_URL = @"errors";
static const NSString * USERS_LIKE_SHOOT_URL = @"user/getUsersLikeShoot/:id";
static const NSString * USERS_WANT_SHOOT_URL = @"user/getUsersWantShoot/:id";
static const NSString * USERNAMES_BY_PREFIX_URL = @"user/getUsernamesByPrefix/:prefix";
static const NSString * FOLLOWINGS_URL = @"user/getFollowingUsers/:user_id/:count";
static const NSString * FOLLOWERS_URL = @"user/getFollowers/:user_id/:count";
static const NSString * RECOMMENDED_USERS_URL = @"user/getRecommendedUsers/:count";
static const NSString * USER_BY_ID_URL = @"user/query/:id";
static const NSString * FOLLOW_USER_URL = @"user/follow/:id";
static const NSString * UNFOLLOW_USER_URL = @"user/unfollow/:id";
static const NSString * LOGIN_URL = @"user/login";
static const NSString * SIGN_UP_URL = @"user/signup";
static const NSString * UPDATE_USER_URL = @"user/update";
static const NSString * UPDATE_PASSWORD_URL = @"user/updatePassword/:password";

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([User class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    NSDictionary * userMappingDictionary = @{
                                             @"id" : @"id",
                                             @"time" : @"time",
                                             @"username" : @"username",
                                             @"password" : @"password",
                                             @"email" : @"email",
                                             @"deleted" : @"shouldBeDeleted",
                                             @"follower_count" : @"follower_count",
                                             @"following_count" : @"following_count",
                                             @"relationship_with_currentUser" : @"relationship_with_currentUser",
                                             @"user_type" : @"user_type",
                                             @"has_avatar" : @"has_avatar"
                                             };
    
    NSMutableDictionary * userResponseMappingDictionary = [NSMutableDictionary dictionaryWithDictionary:userMappingDictionary];

    responseMapping.identificationAttributes = @[ @"id" ];

    [userResponseMappingDictionary setValue:@"shouldBeDeleted" forKey:@"deleted"];
    [responseMapping addAttributeMappingsFromDictionary:userResponseMappingDictionary];
//    [self.responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"followers" toKeyPath:@"followers" withMapping:self.responseMapping]];
    
    return responseMapping;
}

- (void) registerRestKitMapping
{
    [super registerRestKitMapping];
    RKObjectManager * manager = [RKObjectManager sharedManager];
    RKEntityMapping * userMapping = [self getResponseMapping];
    
    //register url with "users" as GET response key path
    for(NSString *url in @[
                           USERS_LIKE_SHOOT_URL,
                           USERS_WANT_SHOOT_URL,
                           USERNAMES_BY_PREFIX_URL,
                           FOLLOWINGS_URL,
                           FOLLOWERS_URL,
                           RECOMMENDED_USERS_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodGET pathPattern:url keyPath:USERS_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
        
    }
    
    //register url with "user" as GET response key path
    for(NSString *url in @[
                           USER_BY_ID_URL,
                           FOLLOW_USER_URL,
                           UNFOLLOW_USER_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodGET pathPattern:url keyPath:USER_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
        
    }
    
    //register url with "user" as POST response key path
    for(NSString *url in @[
                           LOGIN_URL,
                           SIGN_UP_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:url keyPath:USER_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
        
    }
    
    //post/put request descriptor
    RKObjectMapping *userRequestMapping = [self getRequestMapping];
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping
                                                                            objectClass:[User class]
                                                                            rootKeyPath:nil
                                                                                 method:RKRequestMethodPOST]];
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping
                                                                        objectClass:[User class]
                                                                        rootKeyPath:nil
                                                                             method:RKRequestMethodPUT]];
    
    //register url with "user" as POST response key path
    for(NSString *url in @[
                           UPDATE_USER_URL,
                           UPDATE_PASSWORD_URL
                           ]){
        
        [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[self getErrorResponseMapping] method:RKRequestMethodPUT pathPattern:url keyPath:ERRORS_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
        
    }
}

- (User *) findUserByIdLocally:(NSNumber *)id {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id = %ld", [id longValue]]];
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
