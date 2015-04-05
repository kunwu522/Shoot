//
//  UserShootCollectionView.m
//  Shoot
//
//  Created by LV on 3/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserShootCollectionView.h"

@implementation UserShootCollectionView

- (void) reloadForType:(NSNumber *)tagType
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userID == %@ && type == %@", self.user.userID, tagType]];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [self reload];
}

@end
