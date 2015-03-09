//
//  NotificationViewController.m
//  Shoot
//
//  Created by LV on 1/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "SWRevealViewController.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "ConversationViewController.h"
#import "UIViewHelper.h"
#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "DetailViewController.h"
#import "UserViewController.h"
#import "UserListView.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, NotificationTableViewCellDelegate, UserListViewDelegate>

@property (retain, nonatomic) UITableView * tableView;
@property (retain, nonatomic) UISearchBar * searchBar;
@property (retain, nonatomic) UIButton * notificationView;
@property (retain, nonatomic) UIButton * messageView;
@property (nonatomic, retain) UIView * redDotForMessages;
@property (nonatomic, retain) UIView * redDotForNotifications;
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSFetchedResultsController *notificationFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *messageFetchedResultsController;
@property (nonatomic, retain) UserListView *userListView;

@property (nonatomic, retain) NSMutableArray* conversations;

@property (nonatomic) NSInteger viewStatus;

@end

@implementation NotificationViewController

static CGFloat ADD_BUTTON_SIZE = 40;
static CGFloat ADD_BUTTON_PADDING = 20;
static double DOT_RADIUS = 4;
static double DOT_PAD = 20.0;

static NSInteger NOTIFICATION_VIEW_TAG = 101;
static NSInteger MESSAGE_VIEW_TAG = 102;

static CGFloat PADDING = 5;
static CGFloat HEADER_HEIGHT = 40;
static CGFloat SEG_CONTROL_HEIGHT = 24;
static NSString * TABEL_CELL_REUSE_ID = @"TableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.tintColor = [UIColor darkGrayColor];
    [self.searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search-icon"] color:[UIColor darkGrayColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:self.searchBar];
    
    self.conversations = [[NSMutableArray alloc] init];
    
    [self initViewButtons];
    
    CGFloat tableViewY = self.messageView.frame.size.height + self.messageView.frame.origin.y + PADDING;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.frame.size.width, self.view.frame.size.height - tableViewY)];
    self.tableView.showsHorizontalScrollIndicator = false;
    self.tableView.showsVerticalScrollIndicator = false;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, ADD_BUTTON_SIZE + ADD_BUTTON_PADDING * 2, self.tableView.contentInset.right)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView registerClass:[NotificationTableViewCell class] forCellReuseIdentifier:TABEL_CELL_REUSE_ID];
    
    self.notificationFetchedResultsController = [self createNSFetchedResultsController:NOTIFICATION_TYPE sectionNameKeyPath:nil];
    self.messageFetchedResultsController = [self createNSFetchedResultsController:MESSAGE_TYPE sectionNameKeyPath:@"participant.userID"];
    
    CGFloat customRefreshControlHeight = 50.0f;
    CGFloat customRefreshControlWidth = 100.0;
    CGRect customRefreshControlFrame = CGRectMake(0.0f, -customRefreshControlHeight, customRefreshControlWidth, customRefreshControlHeight);
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:customRefreshControlFrame];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    self.viewStatus = MESSAGE_VIEW_TAG;
    [self viewSwitched:self.notificationView];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - ADD_BUTTON_SIZE)/2.0, self.view.frame.size.height - ADD_BUTTON_PADDING - ADD_BUTTON_SIZE, ADD_BUTTON_SIZE, ADD_BUTTON_SIZE)];
    [self.view addSubview:addButton];
    [addButton setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"compose"] color:[UIColor whiteColor]] atSize:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(startNewConversation:)forControlEvents:UIControlEventTouchDown];

    addButton.backgroundColor = [ColorDefinition lightRed];
    [addButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    addButton.layer.cornerRadius = addButton.frame.size.width/2.0;
    addButton.layer.borderWidth = 2;
    addButton.layer.shadowOffset = CGSizeMake(0, 0);
    addButton.layer.shadowRadius = 10;
    addButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    addButton.layer.shadowOpacity = 1.0;
    
}

-(void)startNewConversation:(id)sender {
    if (!self.userListView) {
        self.userListView = [[UserListView alloc] initWithFrame:self.view.bounds];
        self.userListView.urlPathToPullUsers = @"user/getUsernamesByPrefix";
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.userListView.urlPathToPullUsersWhenSearchStringIsEmpty = [NSString stringWithFormat:@"user/getFollowingUsers/%@/%d",appDelegate.currentUserID, 10];
        self.userListView.hidden = true;
        self.userListView.delegate = self;
        [self.view addSubview:self.userListView];
    }
    [self.userListView reload];
    self.userListView.alpha = 0.0;
    self.userListView.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        self.userListView.alpha = 1.0;
    }];
}

- (void) selectedUser:(User *) user
{
    [self startConversationWith:user];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetchData];
}

- (NSFetchedResultsController *) createNSFetchedResultsController:(NSString *) type sectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    if (sectionNameKeyPath != nil) {
        NSSortDescriptor *sectionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sectionNameKeyPath ascending:NO];
        fetchRequest.sortDescriptors = @[sectionSortDescriptor, timeSortDescriptor];
    } else {
        fetchRequest.sortDescriptors = @[timeSortDescriptor];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"type = '%@'", type]];
    fetchRequest.predicate = predicate;
    // Setup fetched results
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                                                 sectionNameKeyPath:sectionNameKeyPath
                                                                                                          cacheName:nil];
    
    [fetchedResultsController setDelegate:self];
    return fetchedResultsController;
}

- (void) initViewButtons
{
    CGFloat viewButtonWidth = (self.view.frame.size.width - PADDING * 8)/2.0;
    self.notificationView = [[UIButton alloc] initWithFrame:CGRectMake(PADDING * 4, self.searchBar.frame.size.height + self.searchBar.frame.origin.y + PADDING/2.0, viewButtonWidth, SEG_CONTROL_HEIGHT)];
    [self.notificationView setTitle:@"Notifications" forState:UIControlStateNormal];
    self.notificationView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.notificationView.layer.cornerRadius = self.notificationView.frame.size.height/2.0;
    self.notificationView.tag = NOTIFICATION_VIEW_TAG;
    [self.view addSubview:self.notificationView];
    [self.notificationView addTarget:self action:@selector(viewSwitched:)forControlEvents:UIControlEventTouchDown];
    
    self.messageView = [[UIButton alloc] initWithFrame:CGRectMake(self.notificationView.frame.size.width + self.notificationView.frame.origin.x, self.notificationView.frame.origin.y, viewButtonWidth, SEG_CONTROL_HEIGHT)];
    self.messageView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.messageView.layer.cornerRadius = self.notificationView.frame.size.height/2.0;
    [self.messageView setTitle:@"Messages" forState:UIControlStateNormal];
    self.messageView.tag = MESSAGE_VIEW_TAG;
    [self.view addSubview:self.messageView];
    [self.messageView addTarget:self action:@selector(viewSwitched:)forControlEvents:UIControlEventTouchDown];
    
    [self initRedDotViews];
}

-(void) viewSwitched:(UIButton *)sender {
    
    @synchronized(self) {
        UIButton * previewViewButton = (UIButton *) [self.view viewWithTag:self.viewStatus];
        if (previewViewButton) {
            previewViewButton.backgroundColor = [UIColor whiteColor];
            [previewViewButton setTitleColor:[ColorDefinition lightRed] forState:UIControlStateNormal];
        }
        self.viewStatus = sender.tag;
        
        sender.backgroundColor = [ColorDefinition lightRed];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self loadData];
    }
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [self fetchData];
}

- (void)fetchData
{
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:@"message/query" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.redDotForNotifications.hidden = true;
        self.redDotForMessages.hidden = true;
        NSInteger newMessageCount = 0;
        for (Message * message in mappingResult.array) {
            
            if ([message.type isEqualToString:NOTIFICATION_TYPE] && [message.is_read intValue] == 0) {
                self.redDotForNotifications.hidden = false;
                newMessageCount++;
            } else if ([message.type isEqualToString:MESSAGE_TYPE] && [message.is_read intValue] == 0) {
                self.redDotForMessages.hidden = false;
                newMessageCount++;
            }
        }
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.badgeCount = newMessageCount;
        [appDelegate updateBadgeCount];
        
        [self loadData];
        [self.refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
    }];
}

- (void)loadData
{
    @synchronized(self) {
        NSError *error = nil;
        BOOL fetchSuccessful = [[self getNSFetchedResultsController] performFetch:&error];
        if (! fetchSuccessful) {
            NSLog(@"Fetch Error: %@",error);
        }
        if (self.viewStatus == MESSAGE_VIEW_TAG) {
            [self.conversations removeAllObjects];
            NSMutableArray * latestMessages = [[NSMutableArray alloc] init];
            for (int i = 0; i < [[self.messageFetchedResultsController sections] count]; i++) {
                [latestMessages addObject:[self.messageFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]];
            };
            NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
            [self.conversations addObjectsFromArray:[latestMessages sortedArrayUsingDescriptors:@[sd]]];
        }
        [self.tableView reloadData];
    }
    
}

- (NSFetchedResultsController *) getNSFetchedResultsController
{
    if (self.viewStatus == MESSAGE_VIEW_TAG) {
        return self.messageFetchedResultsController;
    } else {
        return self.notificationFetchedResultsController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.viewStatus == MESSAGE_VIEW_TAG) {
        return 1;
    }
    id sectionInfo = [[[self getNSFetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // only conversation needs to have multiple sections, section per conversation
    if (self.viewStatus == MESSAGE_VIEW_TAG) {
        return [self.conversations count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABEL_CELL_REUSE_ID forIndexPath:indexPath];
    Message *message;
    if (self.viewStatus == MESSAGE_VIEW_TAG) {
        message = [self.conversations objectAtIndex:indexPath.section];
        [cell setBackgroundColor:[UIColor clearColor]];
        NSIndexPath *originalIndexPathForMessage = [[self getNSFetchedResultsController] indexPathForObject:message];
        BOOL hasUnread = false;
        for(Message * message_in_section in [[[[self getNSFetchedResultsController] sections] objectAtIndex:originalIndexPathForMessage.section] objects]) {
            if ([message_in_section.is_read intValue] == 0) {
                hasUnread = true;
            }
        }
        if (hasUnread) {
            [self decorateUnreadCell:cell];
        } else {
            [self decorateReadCell:cell];
        }
    } else {
        message = [[self getNSFetchedResultsController] objectAtIndexPath:indexPath];
        if ([message.is_read intValue] == 0) {
            [self decorateUnreadCell:cell];
        } else {
            [self decorateReadCell:cell];
        }
    }
    
    [cell decorateCellWithMessage:message];
    cell.delegate = self;
    
    return cell;
}

- (void) decorateUnreadCell:(NotificationTableViewCell *)cell
{
    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    cell.userAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.userAvatar.layer.borderWidth = 3;
}

- (void) decorateReadCell:(NotificationTableViewCell *)cell
{
    cell.backgroundColor = [UIColor clearColor];
    cell.userAvatar.layer.borderColor = [UIColor clearColor].CGColor;
    cell.userAvatar.layer.borderWidth = 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NotificationTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [[self getNSFetchedResultsController] objectAtIndexPath:indexPath];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (([message.type isEqualToString:NOTIFICATION_TYPE])) {
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
        if (message.related_shoot) {
            DetailViewController * viewController = [[DetailViewController alloc] initWithNibName:nil bundle:nil];
            viewController.shootID = message.related_shoot.shootID;
            [self presentViewController:viewController animated:YES completion:nil];
        } else {
            UserViewController * viewController = [[UserViewController alloc] initWithNibName:nil bundle:nil];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } else if ([message.type isEqualToString:MESSAGE_TYPE]) {
        [self startConversationWith:message.participant];
    }
   
}

- (void) startConversationWith:(User *) user
{
    ConversationViewController * viewController = [[ConversationViewController alloc] initWithNibName:nil bundle:nil];
    viewController.participant = user;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void) initRedDotViews
{
    self.redDotForMessages = [UIViewHelper circleWithColor:[ColorDefinition lightRed] radius:DOT_RADIUS];
    [self.messageView addSubview:self.redDotForMessages];
    [self.messageView bringSubviewToFront:self.redDotForMessages];
    [self.redDotForMessages setFrame:CGRectMake(DOT_PAD * 1.4, self.messageView.frame.size.height/2.0 - DOT_RADIUS, self.redDotForMessages.frame.size.width, self.redDotForMessages.frame.size.height)];
    self.redDotForMessages.hidden = true;
    
    self.redDotForNotifications = [UIViewHelper circleWithColor:[ColorDefinition lightRed] radius:DOT_RADIUS];
    [self.notificationView addSubview:self.redDotForNotifications];
    [self.notificationView bringSubviewToFront:self.redDotForNotifications];
    [self.redDotForNotifications setFrame:CGRectMake(DOT_PAD, self.notificationView.frame.size.height/2.0 - DOT_RADIUS, self.redDotForNotifications.frame.size.width, self.redDotForNotifications.frame.size.height)];
    self.redDotForNotifications.hidden = true;
}

- (void) showUser:(id) sender
{
//    [self performSegueWithIdentifier:@"showUser" sender:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
