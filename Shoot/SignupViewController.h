//
//  SignupViewController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpSubViewController.h"

@interface SignupViewController : UIViewController <SignUpSubViewDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;

@end
