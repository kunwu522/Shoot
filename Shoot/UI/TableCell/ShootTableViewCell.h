//
//  ShootTableViewCell.h
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShootTableViewCell : UITableViewCell
@property (nonatomic, weak) UIViewController * parentController;
- (void) decorate:(UIImage *) image parentController:(UIViewController *)parentController;
+ (CGFloat) height;
@end
