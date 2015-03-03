//
//  FollowButton.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "FollowButton.h"
#import "ColorDefinition.h"
#import <RestKit/RestKit.h>
#import "User.h"
#import "ImageUtil.h"

@interface FollowButton ()
@property (nonatomic, retain) id user_id;
@property (nonatomic, retain) NSNumber * relationshipWithCurrentUser;
@end


@implementation FollowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        double effectiveWidth = FOLLOW_BUTTON_WIDTH;
        double effectiveHeight = FOLLOW_BUTTON_HEIGHT;
        double preferredWidth = FOLLOW_BUTTON_WIDTH;
        double preferredHeight = FOLLOW_BUTTON_HEIGHT;
        if (frame.size.width/frame.size.height > preferredWidth/preferredHeight) {
            effectiveWidth = frame.size.width;
            effectiveHeight = preferredHeight / preferredWidth * frame.size.width;
        } else {
            effectiveHeight = frame.size.height;
            effectiveWidth = preferredWidth / preferredHeight * frame.size.height;
        }
        self.followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.followButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.followButton.layer.cornerRadius = frame.size.height/2.0;
        self.followButton.tintColor = [UIColor whiteColor];
        self.followButton.backgroundColor = [ColorDefinition blueColor];
        [self addSubview:self.followButton];
        self.layer.cornerRadius = 5;
    }
    return self;
}

- (void) setUser_id:(id)user_id relationshipWithCurrentUser:(NSNumber *) relationshipWithCurrentUser
{
    _user_id = user_id;
    _relationshipWithCurrentUser = relationshipWithCurrentUser;

    if (relationshipWithCurrentUser) {
        if ([relationshipWithCurrentUser intValue] == 0) {
            self.followButton.hidden = TRUE;
            self.layer.borderColor = [UIColor clearColor].CGColor;
        } else if ([relationshipWithCurrentUser intValue] < 3){
            [self makeFollowButton:self.followButton];
            self.followButton.hidden = false;
        } else {
            [self makeFollowingButton:self.followButton];
            self.followButton.hidden = false;
        }
    } else {
        self.followButton.hidden = true;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)makeFollowButton:(UIButton *)button
{
    CGFloat iconSize = MIN(self.followButton.frame.size.width, self.followButton.frame.size.height) * 0.7;
    [button setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"follow"] atSize:CGSizeMake(iconSize, iconSize)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton:(UIButton *)button
{
    CGFloat iconSize = MIN(self.followButton.frame.size.width, self.followButton.frame.size.height) * 0.7;
    [button setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"followed"] atSize:CGSizeMake(iconSize, iconSize)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)follow:(id)sender
{
    self.followButton.enabled = false;
    [self makeFollowingButton:self.followButton];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationship_with_currentUser;
        self.followButton.enabled = true;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
        [self makeFollowButton:self.followButton];
        self.followButton.enabled = true;
    }];
}

- (void)unfollow:(id)sender
{
    self.followButton.enabled = false;
    [self makeFollowButton:self.followButton];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationship_with_currentUser;
        self.followButton.enabled = true;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Unfollow failed with error: %@", error);
        [self makeFollowingButton:self.followButton];
        self.followButton.enabled = true;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
