//
//  Dao.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@interface Dao : NSObject

//+ (instancetype)sharedManager;

- (RKObjectMapping *) getErrorResponseMapping;
- (RKEntityMapping *) createResponseMapping;
- (RKEntityMapping *) getResponseMapping;
- (RKEntityMapping *) getRequestMapping;
- (void) registerRestKitMapping;

@end
