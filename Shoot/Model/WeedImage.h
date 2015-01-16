//
//  Image.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-25.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface WeedImage : NSObject

@property (nonatomic, retain) NSNumber *imageId;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;

@property (nonatomic, retain) Message * message_parent;

@end
