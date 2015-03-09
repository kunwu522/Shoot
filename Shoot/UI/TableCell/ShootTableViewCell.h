//
//  ShootTableViewCell.h
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoot.h"
#import "User.h"
#import "UserTagShoot.h"

@interface ShootTableViewCell : UITableViewCell
- (void) decorateWith:(Shoot *)shoot user:(User *)user userTagShoots:(NSArray *)userTagShoots parentController:(UIViewController *) parentController;
+ (CGFloat) height;
@end
