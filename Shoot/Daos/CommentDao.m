//
//  CommentDao.m
//  Shoot
//
//  Created by LV on 3/8/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "CommentDao.h"
#import "ShootDao.h"
#import "UserDao.h"
#import "Comment.h"

@implementation CommentDao

static NSString * COMMENTS_KEY_PATH_URL = @"comments";
static NSString * COMMENTS_URL = @"comment/query/:id";
static NSString * CREATE_URL = @"comment/create";

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Comment class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    NSDictionary * mappingDictionary = @{
                                             @"id" : @"commentID",
                                             @"time" : @"time",
                                             @"deleted" : @"shouldBeDeleted",
                                             @"content" : @"content",
                                             @"like_count" : @"like_count",
                                             @"if_cur_user_like_it" : @"if_cur_user_like_it",
                                             @"x" : @"x",
                                             @"y" : @"y"
                                             };
    
    NSMutableDictionary * responseMappingDictionary = [NSMutableDictionary dictionaryWithDictionary:mappingDictionary];
    
    responseMapping.identificationAttributes = @[ @"commentID" ];
    
    [responseMapping addAttributeMappingsFromDictionary:responseMappingDictionary];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shoot" toKeyPath:@"shoot" withMapping:[[ShootDao sharedManager] getResponseMapping]]];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    
    return responseMapping;
}

- (void) registerRestKitMapping
{
    [super registerRestKitMapping];
    RKObjectManager * manager = [RKObjectManager sharedManager];
    RKEntityMapping * commentMapping = [self getResponseMapping];
    
    for(NSString *url in @[
                           COMMENTS_URL
                           ]){
        
        [manager addResponseDescriptor:
         [RKResponseDescriptor responseDescriptorWithMapping:commentMapping method:RKRequestMethodGET pathPattern:url keyPath:COMMENTS_KEY_PATH_URL statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    }
    
    //post response mapping
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:commentMapping method:RKRequestMethodAny pathPattern:CREATE_URL keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //creation request mapping
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[self getRequestMapping] objectClass:[Comment class] rootKeyPath:nil method:RKRequestMethodAny]];
}

@end
