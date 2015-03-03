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
#import "ColorDefinition.h"

@interface ConversationViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *userAvatar;
@property (nonatomic, retain) UILabel * usernameLabel;

@end

@implementation ConversationViewController

static NSString * USER_TABLE_CELL_REUSE_ID = @"UserTableCell";
static CGFloat USERNAME_TEXT_FIELD_HEIGHT = 25;
static CGFloat PADDING = 5;
static CGFloat AVATAR_SIZE = 50;
static CGFloat HEADER_HEIGHT = 30;

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
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    [self.headerView setBackgroundColor:[ColorDefinition lightRed]];
    [self.view addSubview:self.headerView];
    
    self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 3, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor whiteColor].CGColor];
    [l setBorderWidth:2];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
    
    [self.view addSubview:self.userAvatar];
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    self.userAvatar.userInteractionEnabled = true;
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [self.userAvatar addGestureRecognizer:singleFingerTap];
    
    CGFloat usernameLabelX = self.userAvatar.frame.size.width + self.userAvatar.frame.origin.x + PADDING;
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabelX, self.headerView.frame.origin.y, self.view.frame.size.width - usernameLabelX - PADDING * 2, self.headerView.frame.size.height)];
    [self.view addSubview:self.usernameLabel];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:12];
    self.usernameLabel.textColor = [UIColor whiteColor];
    self.usernameLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.tableView setFrame:CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - (self.headerView.frame.origin.y + self.headerView.frame.size.height))];
    self.tableView.showsVerticalScrollIndicator = false;
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
    //init fetch controller
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type = 'message' and (participant.userID = %@)", self.participant.userID]];
    fetchRequest.predicate = predicate;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    [self loadData];
    [self showConversation];
    
    self.inputToolBarView.hidden = false;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.participant.username];
    [self.userAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:self.participant.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
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
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    self.sendButton.enabled = false;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    
    message.sender_id = appDelegate.currentUser.userID;
    message.participant = self.participant;
    message.time = [NSDate date];
    message.type = MESSAGE_TYPE;
    message.is_read = [NSNumber numberWithInt:1];//to make it marked as read locally
    message.message = [text trimWhitespace];
    [self createMessageOnServer:message];
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer
{
    UserViewController* viewController = [[UserViewController alloc] initWithNibName:nil bundle:nil];
    viewController.userID = self.participant.userID;
    [self presentViewController:viewController animated:YES completion:nil];
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
    NSString *url = [NSString stringWithFormat:@"message/upload/%@", self.participant.userID];
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
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.currentUser.userID isEqualToNumber:message.sender_id]) {
        return JSBubbleMessageTypeOutgoing;
    } else {
        if ([message.is_read intValue] == 0) {
            [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"message/read/%@", message.messageID]  parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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
    return JSAvatarStyleNone;
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
    
    return nil;
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return nil;
}

@end
