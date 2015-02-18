//
//  TagDao.m
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagDao.h"
#import "Tag.h"

@implementation TagDao

- (RKEntityMapping *) createResponseMapping
{
    RKEntityMapping * responseMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Tag class]) inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [responseMapping addAttributeMappingsFromDictionary:@{
                                                               @"id" : @"id",
                                                               @"time" : @"time",
                                                               @"tag" : @"tag",
                                                               @"deleted" : @"shouldBeDeleted",
                                                               @"have_count" : @"have_count",
                                                               @"want_count" : @"want_count"
                                                               }];
    
    responseMapping.identificationAttributes = @[ @"id" ];
    return responseMapping;
}

@end
