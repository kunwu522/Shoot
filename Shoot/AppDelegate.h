//
//  AppDelegate.h
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <CoreData/CoreData.h>

#define ROOT_URL @"http://www.cannablaze.com/"

@protocol NotificationDelegate <NSObject>
@required
- (void) updateBadgeCount:(NSInteger) badgeCount;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) User * currentUser;
@property NSInteger badgeCount;
@property (nonatomic, weak) id<NotificationDelegate> notificationDelegate;

- (void) decreaseBadgeCount:(NSInteger) decreaseBy;
- (void) updateBadgeCount;
- (void) populateCurrentUserFromCookie;
- (void) clearLoginCookies;
- (void)signoutFrom:(UIViewController *) sender;

+ (UIStatusBarStyle) getUIStatusBarStyle;
+ (UIStoryboard *) getMainStoryboard;
@end


