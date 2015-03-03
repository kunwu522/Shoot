//
//  MessageDao.m
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MessageDao.h"
#import "Message.h"
#import "MessageImage.h"
#import "UserDao.h"
#import "ShootDao.h"

@interface MessageDao ()

@end

@implementation MessageDao

static NSString * MESSAGES_KEY_PATH_URL = @"messages";
static NSString * QUERY_URL = @"message/query";
static NSString * CREATE_URL = @"message/create";
static NSString * READ_URL = @"message/read/:id";
static NSString * UPLOAD_URL = @"message/upload/:receiver_id";


- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping *messageMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Message class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    NSDictionary *messageObjectMapping = @{
                                           
                                           @"sender_id" : @"sender_id",
                                           @"message" : @"message",
                                           @"type" : @"type",
                                           @"is_read" : @"is_read"
                                           };
    
    NSDictionary *parentObjectMapping = @{
                                          @"id" : @"messageID",
                                          @"time" : @"time",
                                          @"deleted" : @"shouldBeDeleted"
                                          };
    [messageMapping addAttributeMappingsFromDictionary:parentObjectMapping];
    
    [messageMapping addAttributeMappingsFromDictionary:messageObjectMapping];
    
    [messageMapping setIdentificationAttributes: @[ @"messageID" ]];
    
    RKEntityMapping *messageImageMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([MessageImage class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [messageImageMapping addAttributeMappingsFromDictionary:@{@"id" : @"image_id", @"width" : @"width", @"height" : @"height"}];
    
    [messageMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image_metadata" toKeyPath:@"image" withMapping:messageImageMapping]];
    
    [messageMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"participant" toKeyPath:@"participant" withMapping:[[UserDao sharedManager] getResponseMapping]]];
    
    [messageMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"related_shoot" toKeyPath:@"related_shoot" withMapping:[[ShootDao sharedManager] getResponseMapping]]];
    
    return messageMapping;
}

- (void) registerRestKitMapping
{
    [super registerRestKitMapping];
    
    RKObjectManager * manager = [RKObjectManager sharedManager];
    RKEntityMapping * messageMapping = [self getResponseMapping];
    
    [manager addResponseDescriptor: [RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodGET pathPattern:QUERY_URL keyPath:MESSAGES_KEY_PATH_URL statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor: [RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodGET pathPattern:READ_URL keyPath:nil statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //post response mapping
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodAny pathPattern:CREATE_URL keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:messageMapping method:RKRequestMethodPOST pathPattern:UPLOAD_URL keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    
    //creation request mapping
    [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:[self getRequestMapping] objectClass:[Message class] rootKeyPath:nil method:RKRequestMethodAny]];
}

@end
