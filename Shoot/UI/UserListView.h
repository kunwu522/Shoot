//
//  UserListView.h
//  Shoot
//
//  Created by LV on 2/28/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/CoreData.h>
#import "User.h"

@protocol UserListViewDelegate <NSObject>
@optional
- (void) selectedUser:(User *) user;
@end

@interface UserListView : UIView

@property (nonatomic, retain) NSArray *users;
@property (nonatomic, copy) NSString *urlPathToPullUsers;
@property (nonatomic, copy) NSString *urlPathToPullUsersWhenSearchStringIsEmpty;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;

@property (nonatomic, weak)id<UserListViewDelegate> delegate;

-(void)reload;

@end
