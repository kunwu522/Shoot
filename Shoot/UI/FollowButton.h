//
//  FollowButton.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FOLLOW_BUTTON_HEIGHT 25.0;
#define FOLLOW_BUTTON_WIDTH 25.0;

@interface FollowButton : UIView

- (void) setUser_id:(id)user_id relationshipWithCurrentUser:(NSNumber *) relationshipWithCurrentUser;

@end
