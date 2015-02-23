//
//  Dao.m
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "Dao.h"

@implementation Dao

//static NSMutableDictionary *_sharedInstances = nil;
//
//+ (instancetype)sharedManager {
//    id sharedInstance = nil;
//    
//    @synchronized(self) {
//        NSString *instanceClass = NSStringFromClass(self);
//        
//        // Looking for existing instance
//        sharedInstance = [_sharedInstances objectForKey:instanceClass];
//        
//        // If there's no instance – create one and add it to the dictionary
//        if (sharedInstance == nil) {
//            sharedInstance = [[super allocWithZone:nil] init];
//            [_sharedInstances setObject:sharedInstance forKey:instanceClass];
//        }
//    }
//    
//    return sharedInstance;
//}
//
//
//+ (void)initialize
//{
//    if (_sharedInstances == nil) {
//        _sharedInstances = [NSMutableDictionary dictionary];
//    }
//}

- (RKObjectMapping *) getErrorResponseMapping {
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    return errorMapping;
}

- (RKEntityMapping *) createResponseMapping {
    return nil;
}

- (void) registerRestKitMapping
{
    
}

- (RKEntityMapping *) getResponseMapping {
    RKEntityMapping * responseMapping = [self createResponseMapping];
    responseMapping.deletionPredicate = [NSPredicate predicateWithFormat:@"shouldBeDeleted == 1"];
    return responseMapping;
}

- (RKEntityMapping *) getRequestMapping {
    return [[self getResponseMapping] inverseMapping];
}

@end
