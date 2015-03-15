//
//  ShootControl.h
//  Shoot
//
//  Created by LV on 3/14/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoot.h"

@interface ShootControl : UIView

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode;

- (void) decorateWith:(Shoot *)shoot parentController:(UIViewController *) parentController;

+ (CGFloat) getMinimalHeight;

@end
