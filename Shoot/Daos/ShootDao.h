//
//  ShootDao.h
//  Shoot
//
//  Created by LV on 2/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dao.h"
#import "Shoot.h"

@interface ShootDao : Dao

- (Shoot *) findUserByIdLocally:(NSNumber *)id;

@end
