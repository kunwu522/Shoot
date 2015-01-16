//
//  Message.h
//  WeedaForiPhone
//
//  Created by LV on 9/9/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RemoteObject.h"

#define NOTIFICATION_TYPE @"notification"
#define MESSAGE_TYPE @"message"

@interface Message : RemoteObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * related_weed_id;
@property (nonatomic, retain) NSNumber * sender_id;
@property (nonatomic, retain) NSNumber * participant_id;
@property (nonatomic, retain) NSString * participant_username;
@property (nonatomic, retain) NSString * participant_type;
@property (nonatomic, retain) NSNumber * is_read;
@property (nonatomic, retain) NSObject * image;

@end
