//
//  RemoteObject.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 3/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RemoteObject : NSObject

@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * time;

@end
