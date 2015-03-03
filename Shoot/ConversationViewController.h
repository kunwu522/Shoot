//
//  ConversationViewController.h
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "User.h"

@interface ConversationViewController : JSMessagesViewController

@property (nonatomic, retain) User * participant;

@end