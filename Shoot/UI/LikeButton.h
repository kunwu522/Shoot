//
//  LikeButton.h
//  Shoot
//
//  Created by LV on 3/30/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoot.h"

#define LIKE_BUTTON_HEIGHT 25.0;
#define LIKE_BUTTON_WIDTH 85.0;

@interface LikeButton : UIView

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode;
- (void) decorateWithShoot:(Shoot *)shoot parentController:(UIViewController *)parentController;

@end
