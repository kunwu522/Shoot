//
//  UserDao.h
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Dao.h"

@interface UserDao : Dao

- (User *) findUserByIdLocally:(NSNumber *)id;

@end
