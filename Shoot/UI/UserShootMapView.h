//
//  UserShootMapView.h
//  Shoot
//
//  Created by LV on 3/16/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserShootMapView : UIView

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user;
- (void) reloadForType:(NSNumber *)tagType;

@end
