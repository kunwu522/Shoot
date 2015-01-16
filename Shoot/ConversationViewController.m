//
//  ConversationViewController.m
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ConversationViewController.h"
#import "AppDelegate.h"
#import "NSString+JSMessagesView.h"
#import "UserViewController.h"
#import "ImageUtil.h"
#import "Message.h"
#import "SWRevealViewController.h"
#import "ColorDefinition.h"

@interface ConversationViewController ()

@property (nonatomic, strong) UIImage *participant_avatar;
@property (nonatomic, strong) UIImage *current_user_avatar;

@property (nonatomic, retain) NSArray *messages;

@end

@implementation ConversationViewController

const NSInteger USER_LIST_TAG = 1;
static NSString * USER_TABLE_CELL_REUSE_ID = @"UserTableCell";

#pragma mark - Initialization
- (UIButton *)sendButton
{
    // Override to use a custom send button
    // The button's frame is set automatically for you
    return [UIButton defaultSendButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];

    self.delegate = self;
    self.dataSource = self;
    self.messages = @[[self getMessage], [self getMessage], [self getMessage], [self getMessage], [self getMessage], [self getMessage], [self getMessage], [self getMessage], [self getMessage]];
    [self reloadView];
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (Message *) getMessage
{
    Message *message = [[Message alloc] init];
    message.message = @"Well it is possible indeed, but the user will only see the error message when the field is cleared. Doesn't sound very useful. Also you can clear the input but I wouldn't be pleased with that if I just entered, say, 30 numbers.";
    return message;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tabBarController].tabBar.hidden = true;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view sendSubviewToBack:self.usernameTextField];
    [self.view sendSubviewToBack:self.usernameList];
    [self tabBarController].tabBar.hidden = false;
}

- (void) reloadView {
    self.inputToolBarView.hidden = false;
    self.title = self.participant_username;
    self.usernameTextField.hidden = true;
    self.usernameList.hidden = true;
}

- (void) loadData {

}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == USER_LIST_TAG) {
        [self.usernameTextField endEditing:true];
    } else {
        [super scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    self.sendButton.enabled = false;
    Message *message = [[Message alloc] init];
    message.id = [NSNumber numberWithInt:-1];
    message.participant_id = self.participant_id;
    message.participant_username = self.participant_username;
    message.time = [NSDate date];
    message.type = MESSAGE_TYPE;
    message.is_read = [NSNumber numberWithInt:1];//to make it marked as read locally
    message.message = [text trimWhitespace];
    [self createMessageOnServer:message];
}

- (void)avatarTappedForIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) createMessageOnServer:(Message *) message {

}

- (void)selectedImage:(UIImage *)image
{
}

- (void) showProgressBar
{
    [self.sendMessageProgressBar setProgress:0.0 animated:NO];
    self.sendMessageProgressBar.hidden = false;
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.sendMessageProgressBar setProgress:0.5 animated:YES];
    });
}

- (void) hideProgressBar
{
    [self.sendMessageProgressBar setProgress:1 animated:YES];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.sendMessageProgressBar setHidden:YES];
    });
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleSquare;
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAlternating;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    return JSAvatarStyleCircle;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (Message *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate date];
}

- (UIImage *)avatarImageForIncomingMessage
{
    
    return [UIImage imageNamed:@"image1.jpg"];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"image2.jpg"];
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
