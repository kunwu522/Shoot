//
//  Message.h
//  Shoot
//
//  Created by LV on 2/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"

#define NOTIFICATION_TYPE @"notification"
#define MESSAGE_TYPE @"message"

@class MessageImage, Shoot, User;

@interface Message : RemoteObject

@property (nonatomic, retain) NSNumber * is_read;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * sender_id;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) MessageImage *image;
@property (nonatomic, retain) User *participant;
@property (nonatomic, retain) Shoot *related_shoot;

@end
