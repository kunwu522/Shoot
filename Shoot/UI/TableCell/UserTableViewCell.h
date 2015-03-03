//
//  UserTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/20/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowButton.h"
#import "UserIcon.h"
#import "User.h"

#define USER_TABLE_VIEW_CELL_HEIGHT 50.0f;

@protocol UserTableViewCellDelegate <NSObject>
@optional
- (void) followingStatusChangedForUser:(User *) user to:(NSNumber *)newStatus;
@end

@interface UserTableViewCell : UITableViewCell

@property (nonatomic, strong) FollowButton *followButton;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *userAvatar;
@property (nonatomic, strong) UserIcon *storeTypeIcon;

- (void)decorateCellWithUser:(User *)user;
- (void)decorateCellWithUser:(User *)user subtitle:(NSString*) subtitle;

@end
