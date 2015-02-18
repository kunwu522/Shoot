//
//  ConversationViewController.m
//  WeedaForiPhone
//
//  Created by LV on 9/14/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ConversationViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RestKit/RestKit.h>
#import "NSString+JSMessagesView.h"
#import "UserTableViewCell.h"
#import "UserViewController.h"
#import "ImageUtil.h"

@interface ConversationViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIImage *participant_avatar;
@property (nonatomic, strong) UIImage *current_user_avatar;

@property (nonatomic, retain) NSMutableArray *users;

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
    self.delegate = self;
    self.dataSource = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [self reloadView];
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) reloadView {
    if ([self isNewConversation]) {
//        self.title = @"New Message";
//        self.users = [NSMutableArray array];
//        [self.view bringSubviewToFront:self.usernameTextField];
//        [self.view bringSubviewToFront:self.usernameList];
//        [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [self.usernameTextField becomeFirstResponder];
//        self.usernameList.tag = USER_LIST_TAG;
//        self.usernameList.hidden = false;
//        [self.usernameList setSeparatorInset:UIEdgeInsetsZero];
//        self.usernameList.tableFooterView = [[UIView alloc] init];
//        self.usernameList.delegate = self;
//        [self.usernameList registerClass:[UserTableViewCell class] forCellReuseIdentifier:USER_TABLE_CELL_REUSE_ID];
//        [self.usernameList setFrame:CGRectMake(self.usernameList.frame.origin.x, self.usernameList.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.usernameList.frame.origin.y)];
//        self.inputToolBarView.hidden = true;
//        [self loadFollowingUsers];
    } else {
        //init fetch controller
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
        fetchRequest.sortDescriptors = @[descriptor];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type = 'message' and (participant.id = %@)", self.participant.id]];
        fetchRequest.predicate = predicate;
        [fetchRequest setFetchBatchSize:10];
        // Setup fetched results
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        [self.fetchedResultsController setDelegate:self];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[ImageUtil imageURLOfAvatar:self.participant.id] options:(SDWebImageHandleCookies | SDWebImageRefreshCached) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (finished) {
                if (image) self.participant_avatar = image;
                else self.participant_avatar = [UIImage imageNamed:@"avatar.jpg"];
                if (self.current_user_avatar) {
                    [self loadData];
                    [self showConversation];
                }
            }
        }];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [[SDWebImageManager sharedManager] downloadImageWithURL:[ImageUtil imageURLOfAvatar:appDelegate.currentUser.id] options:(SDWebImageHandleCookies | SDWebImageRefreshCached) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (finished) {
                if (image) self.current_user_avatar = image;
                else self.current_user_avatar = [UIImage imageNamed:@"avatar.jpg"];
                if (self.participant_avatar) {
                    [self loadData];
                    [self showConversation];
                }
            }
        }];
        
        self.inputToolBarView.hidden = false;
        self.title = self.participant.username;
        self.usernameTextField.hidden = true;
        self.usernameList.hidden = true;
    }
}

- (BOOL) isNewConversation
{
    return self.participant == nil;
}

#pragma mark - Username TextField delegate
- (void)textFieldDidChange:(UITextField *)textField
{
    self.usernameList.hidden = false;
    NSString *usernamePrefix = textField.text;
    if ([usernamePrefix isEqualToString:@""]) {
        [self loadFollowingUsers];
    } else {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getUsernamesByPrefix/%@", usernamePrefix] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self updateUsernameListWithMappingResult:mappingResult];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"Load getUsernamesByPrefix failed with error: %@", error);
        }];
    }
}

- (void) loadFollowingUsers
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/getFollowingUsers/%@/%d",appDelegate.currentUser.id, 10] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self updateUsernameListWithMappingResult:mappingResult];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load getFollowingUsers failed with error: %@", error);
    }];
}

- (void) updateUsernameListWithMappingResult:(RKMappingResult *)mappingResult
{
    [self.users removeAllObjects];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    for (User * user in mappingResult.array) {
        if (![user.id isEqualToNumber:appDelegate.currentUser.id]) {
            [self.users addObject:user];
        }
    }
    [self.usernameList reloadData];
}

- (void) loadData {
    NSError *error = nil;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch Error: %@",error);
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == USER_LIST_TAG) {
        return self.users.count;
    } else {
        id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == USER_LIST_TAG) {
        return 1;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        return USER_TABLE_VIEW_CELL_HEIGHT;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_TABLE_CELL_REUSE_ID forIndexPath:indexPath];
        if (cell) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            User *user = [self.users objectAtIndex:indexPath.row];
            [cell decorateCellWithUser:user];
            cell.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:0.4];
        }
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == USER_LIST_TAG) {
        [self.usernameTextField endEditing:true];
    } else {
        [super scrollViewDidScroll:scrollView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == USER_LIST_TAG) {
        User *user = [self.users objectAtIndex:indexPath.row];
        self.participant = user;
        [self.usernameTextField resignFirstResponder];
        [self reloadView];
    }
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    self.sendButton.enabled = false;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
//    message.id = [NSNumber numberWithInt:-1];
    if (message.objectID.isTemporaryID) {
        NSLog(@"temp id");
    }
    
    message.sender_id = appDelegate.currentUser.id;
    message.participant = self.participant;
    message.time = [NSDate date];
    message.type = MESSAGE_TYPE;
    message.is_read = [NSNumber numberWithInt:1];//to make it marked as read locally
    message.message = [text trimWhitespace];
    [self createMessageOnServer:message];
}

- (void)avatarTappedForIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UserViewController *controller = (UserViewController *)[[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"UserViewController"];
//    [controller setUser_id:message.sender_id];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) createMessageOnServer:(Message *) message {
    [self showProgressBar];
    [[RKObjectManager sharedManager] postObject:message path:@"message/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self loadData];
        [self finishSend];
        [self hideProgressBar];
        self.sendButton.enabled = true;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure saving message: %@", error.localizedDescription);
        [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext deleteObject:message];
        self.sendButton.enabled = true;
        [self hideProgressBar];
    }];

}

- (void)selectedImage:(UIImage *)image
{
    UIImage *compressedImage = [ImageUtil imageWithCompress:image];
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    NSString *url = [NSString stringWithFormat:@"message/upload/%@", self.participant.id];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(compressedImage, 1.0f)
                                    name:@"image"
                                fileName:@"image.jpeg"
                                mimeType:@"image/jpeg"];
    }];
    [self showProgressBar];
    RKManagedObjectRequestOperation *operation = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:(NSURLRequest *)request
                                                                                                      managedObjectContext:(NSManagedObjectContext *)objectStore.mainQueueManagedObjectContext
                                                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                                       [self loadData];
                                                                                                                       [self showConversation];
                                                                                                                       [self hideProgressBar];
                                                                                                                   } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                                       NSLog(@"Uploading image failed. url:%@, error: %@", url, error);
                                                                                                                       [self hideProgressBar];
                                                                                                                   }];
    
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
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
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@", message.objectID);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.currentUser.id isEqualToNumber:message.sender_id]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        if ([message.is_read intValue] == 0) {
            [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"message/read/%@", message.id]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                message.is_read = [NSNumber numberWithInt:1];
                [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext refreshObject:message mergeChanges:YES];
                NSError *error = nil;
                BOOL successful = [message.managedObjectContext save:&error];
                if (! successful) {
                    NSLog(@"Save Error: %@",error);
                }
                [appDelegate decreaseBadgeCount:1];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                RKLogError(@"Failed to call message/read due to error: %@", error);
            }];
        }
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
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return message.time;
}

- (UIImage *)avatarImageForIncomingMessage
{
    
    return self.participant_avatar;
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return self.current_user_avatar;
}

@end
