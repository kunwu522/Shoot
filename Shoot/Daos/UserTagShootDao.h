//
//  UserTagShootDao.h
//  Shoot
//
//  Created by LV on 2/12/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "Dao.h"

@interface UserTagShootDao : Dao

- (NSArray *) findUserTagShootsLocallyByUserId:(NSNumber *)userID shootID:(NSNumber *)shootID;
- (NSArray *) findUserTagShootsLocallyByUserId:(NSNumber *)userID forType:(NSNumber *)tagType;

@end
