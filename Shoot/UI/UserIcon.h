//
//  UserIcon.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserIcon : UIView

@property (nonatomic, strong) UIImageView *icon;
- (void) setUserType:(NSString *)user_type;

@end
