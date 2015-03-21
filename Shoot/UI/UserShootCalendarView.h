//
//  UserShootCalendarView.h
//  Shoot
//
//  Created by LV on 3/21/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol UserShootCalendarViewDelegate <NSObject>

- (void) scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface UserShootCalendarView : UIView

@property(nonatomic,assign) id<UserShootCalendarViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController;
- (void) reloadForType:(NSNumber *)tagType;

@end
