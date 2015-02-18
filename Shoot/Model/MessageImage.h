//
//  MessageImage.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageImage : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * image_id;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSManagedObject *message;

@end
