//
//  NotificationTableViewCell.h
//  Shoot
//
//  Created by LV on 1/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@protocol NotificationTableViewCellDelegate <NSObject>
@required
- (void) showUser:(id) sender;
@end

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView *userAvatar;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *contentLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, weak)id<NotificationTableViewCellDelegate> delegate;

+ (CGFloat) height;

- (void) decorateCellWithMessage:(Message *) message;

@end
