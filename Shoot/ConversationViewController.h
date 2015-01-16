//
//  ConversationViewController.h
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"

@interface ConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSNumber * participant_id;
@property (nonatomic, strong) NSString * participant_username;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITableView *usernameList;

@end