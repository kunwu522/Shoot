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
        [self.followButton setFrame:CGRectMake(frame.size.width/2.0 - effectiveWidth/2.0, frame.size.height/2.0 - effectiveHeight/2.0, effectiveWidth, effectiveHeight)];
        self.followButton.tintColor = [UIColor whiteColor];
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
    [button setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    button.tintColor = [ColorDefinition blueColor];
    self.layer.borderColor = [ColorDefinition blueColor].CGColor;
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton:(UIButton *)button
{
    [button setImage:[UIImage imageNamed:@"followed.png"] forState:UIControlStateNormal];
    button.tintColor = [ColorDefinition greenColor];
    self.layer.borderColor = [ColorDefinition greenColor].CGColor;
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)follow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationship_with_currentUser;
        [self makeFollowingButton:self.followButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.user_id] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.relationshipWithCurrentUser = ((User *)[mappingResult.array objectAtIndex:0]).relationship_with_currentUser;
        [self makeFollowButton:self.followButton];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Follow failed with error: %@", error);
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
