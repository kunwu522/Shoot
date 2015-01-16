//
//  NotificationTableViewCell.h
//  Shoot
//
//  Created by LV on 1/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *contentLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIImageView *userAvatar;

+ (CGFloat) height;

@end
