//
//  UserViewController.h
//  Shoot
//
//  Created by LV on 1/9/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserViewController : UIViewController

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) User * user;

@end
