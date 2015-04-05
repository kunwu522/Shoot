//
//  UserShootCollectionView.h
//  Shoot
//
//  Created by LV on 3/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserTagShootCollectionView.h"

@interface UserShootCollectionView : UserTagShootCollectionView

- (void) reloadForType:(NSNumber *)tagType;

@end
