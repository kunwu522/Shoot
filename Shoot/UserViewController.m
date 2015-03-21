//
//  UserViewController.m
//  Shoot
//
//  Created by LV on 1/9/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "UserViewController.h"
#import "SWRevealViewController.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "ImageCollectionViewCell.h"
#import "ImageDetailedCollectionViewCell.h"
#import "UserShootCalendarView.h"
#import "UIViewHelper.h"
#import "UserDao.h"
#import "ShootImageView.h"
#import "AppDelegate.h"
#import "ShootActionSheet.h"
#import "UserListView.h"
#import "ConversationViewController.h"
#import "UserShootCollectionView.h"
#import "UserTagShoot.h"
#import "UserShootMapView.h"

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, UserShootCalendarViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) UIImageView * header;
@property (retain, nonatomic) ShootImageView * userAvatar;
@property (retain, nonatomic) UIButton *followersCount;
@property (retain, nonatomic) UILabel *followers;
@property (retain, nonatomic) UIButton *followingCount;
@property (retain, nonatomic) UILabel *followings;
@property (retain, nonatomic) UILabel *username;
@property (retain, nonatomic) UIButton * follow;
@property (retain, nonatomic) UIButton * message;
@property (retain, nonatomic) UIButton * wants;
@property (retain, nonatomic) UIButton * haves;
@property (retain, nonatomic) UIButton * gridViewButton;
@property (retain, nonatomic) UIButton * listViewButton;
@property (retain, nonatomic) UIButton * locationViewButton;
@property (retain, nonatomic) UIButton * calendarViewButton;
@property (retain, nonatomic) UITableViewCell * imagesCell;
@property (retain, nonatomic) UserShootMapView *mapView;
@property (retain, nonatomic) UserShootCalendarView *calendarView;
@property (retain, nonatomic) UIView * sectionHeaderView;
@property (nonatomic) NSInteger imageViewStatus;
@property (retain, nonatomic) NSNumber *selectedTagType;
@property (retain, nonatomic) UserListView *userListView;
@property (retain, nonatomic) UserShootCollectionView *userShootCollectionView;

@end

@implementation UserViewController

static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

static NSString * IMAGE_DETAILED_CELL_REUSE_ID = @"ImageDetailedCell";

static const NSInteger IMAGE_CELL_ROW_INDEX = 0;

static const NSInteger GRID_VIEW_TAG = 100;
static const NSInteger LIST_VIEW_TAG = 101;
static const NSInteger LOCATION_VIEW_TAG = 102;
static const NSInteger CALENDAR_VIEW_TAG = 103;

static CGFloat PADDING = 5;
static CGFloat AVATAR_SIZE = 85;
static CGFloat AVATAR_OFFSET = 30;
static CGFloat HEADER_HEIGHT = 150;
static CGFloat USERNAME_HEIGHT = 30;
static CGFloat FOLLOWER_LABEL_HEIGHT = 18;
static CGFloat WANTS_BUTTON_HEIGHT = 30;
static CGFloat VIEW_BUTTON_HEIGHT = 35;
static CGFloat BUTTON_SIZE = 15;

static NSString * PHOTO_LIBARARY = @"Photo Library";
static NSString * TAKE_PHOTO = @"Take Photo";

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (!self.userID) {
        self.userID = appDelegate.currentUserID;
    }
    
    self.imageViewStatus = GRID_VIEW_TAG;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = false;
    self.tableView.showsVerticalScrollIndicator = false;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IMAGE_CELL_REUSE_ID];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeaderView;
    
    self.header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    self.header.contentMode = UIViewContentModeScaleAspectFill;
    self.header.clipsToBounds = YES;
    self.header.image = [UIImage imageNamed:@"image4.jpg"];
    [self.view insertSubview:self.header belowSubview:self.tableView];
    
    [self initSectionHeaderView];
    
    [self.tableView reloadData];
    
    [self reloadView];
    [self refreshView];
    
    self.userListView = [[UserListView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.userListView];
    self.userListView.hidden = true;
}

- (void) refreshView
{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/query/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self reloadView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to load user profile. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}

- (void) reloadView
{
    [self updateUserAvatar];
    [self updateView];
}

- (void)updateUserAvatar
{
    [self.userAvatar setImageURL:[ImageUtil imageURLOfAvatar:self.userID] isAvatar:YES];
    [self updateUserBg];
}

- (void)updateUserBg
{
    [self.header sd_setImageWithURL:[ImageUtil imageURLOfBg:self.userID] placeholderImage:[UIImage imageNamed:@"image4.jpg"] options:(SDWebImageHandleCookies | SDWebImageRefreshCached)];
}


- (void)updateView
{
    self.user = [[UserDao sharedManager] findUserByIdLocally:self.userID];
    if (self.user) {
        [self.followersCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString: self.user.follower_count]] forState:UIControlStateNormal];
        self.followersCount.enabled = ([self.user.follower_count integerValue] > 0);
        [self.followingCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString: self.user.following_count]] forState:UIControlStateNormal];
        self.followingCount.enabled = ([self.user.following_count integerValue] > 0);
        self.username.text = self.user.username;
        [self.wants setTitle:[NSString stringWithFormat:@" %@ wants", self.user.want_count] forState:UIControlStateNormal];
        self.wants.enabled = ([self.user.want_count integerValue] > 0);
        [self.haves setTitle:[NSString stringWithFormat:@" %@ haves", self.user.have_count] forState:UIControlStateNormal];
        self.haves.enabled = ([self.user.have_count integerValue] > 0);
        
        if ([self.user.relationship_with_currentUser intValue] == 0) {
            [self makeEditProfileButton];
            [self makeCameraButton];
        } else if ([self.user.relationship_with_currentUser intValue] < 3){
            [self makeFollowButton];
            [self makeMessageButton];
        } else {
            [self makeFollowingButton];
            [self makeMessageButton];
        }
    }
}

- (void)makeMessageButton
{
    [self.message setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"message-filled"] atSize:CGSizeMake(self.username.frame.size.height* 0.7, self.username.frame.size.height * 0.7)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.message setBackgroundColor:[ColorDefinition greenColor]];
    [self.message removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.message addTarget:self action:@selector(message:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeCameraButton
{
    [self.message setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"camera-filled"] atSize:CGSizeMake(self.username.frame.size.height* 0.6, self.username.frame.size.height * 0.6)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.message setBackgroundColor:[ColorDefinition lightRed]];
    [self.message removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.message addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeEditProfileButton
{
    [self.follow setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"setting-icon"] atSize:CGSizeMake(self.username.frame.size.height * 0.6, self.username.frame.size.height * 0.6)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.follow setBackgroundColor:[UIColor grayColor]];
}

- (void)makeFollowButton
{
    [self.follow setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"follow"] atSize:CGSizeMake(self.username.frame.size.height * 0.7, self.username.frame.size.height * 0.7)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.follow setBackgroundColor:[ColorDefinition blueColor]];
    [self.follow removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.follow addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeFollowingButton
{
    [self.follow setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"followed"] atSize:CGSizeMake(self.username.frame.size.height * 0.7, self.username.frame.size.height * 0.7)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.follow setBackgroundColor:[ColorDefinition blueColor]];
    [self.follow removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.follow addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)takePhoto:(id)sender
{
//    ShootActionSheet *as;
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        as = [[ShootActionSheet alloc]initWithTitle:nil
//                                           delegate:self
//                                  cancelButtonTitle:@"Cancel"
//                             destructiveButtonTitle:nil
//                                  otherButtonTitles:PHOTO_LIBARARY, nil];
//    } else {
//        as = [[ShootActionSheet alloc]initWithTitle:nil
//                                           delegate:self
//                                  cancelButtonTitle:@"Cancel"
//                             destructiveButtonTitle:nil
//                                  otherButtonTitles:TAKE_PHOTO, PHOTO_LIBARARY, nil];
//    }
//    [as showInView:self.view];
}

- (void)message:(id)sender
{
    ConversationViewController * viewController = [[ConversationViewController alloc] initWithNibName:nil bundle:nil];
    viewController.participant = self.user;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)follow:(id)sender
{
    self.follow.enabled = false;
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/follow/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.follow.enabled = true;
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        self.follow.enabled = true;
        RKLogError(@"Follow failed with error: %@", error);
    }];
}

- (void)unfollow:(id)sender
{
    self.follow.enabled = false;
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unfollow/%@", self.userID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.follow.enabled = true;
        [self updateView];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Unfollow failed with error: %@", error);
        self.follow.enabled = true;
    }];
}

- (void) showFollowers:(id)sender
{
    if ([self.user.follower_count integerValue] > 0) {
        self.userListView.urlPathToPullUsers = [NSString stringWithFormat:@"user/getFollowers/%@/%d", self.userID, 10];
        [self.userListView reload];
        self.userListView.alpha = 0.0;
        self.userListView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.userListView.alpha = 1.0;
        }];
    }
}

-(void) showFollowings:(id)sender
{
    if ([self.user.following_count integerValue] > 0) {
        self.userListView.urlPathToPullUsers = [NSString stringWithFormat:@"user/getFollowingUsers/%@/%d", self.userID, 10];
        [self.userListView reload];
        self.userListView.alpha = 0.0;
        self.userListView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.userListView.alpha = 1.0;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UserViewController sectionHeaderViewHeight];
}

+ (CGFloat) sectionHeaderViewHeight
{
    return WANTS_BUTTON_HEIGHT + USERNAME_HEIGHT + PADDING + AVATAR_SIZE - AVATAR_OFFSET + VIEW_BUTTON_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView;
}

- (void) initSectionHeaderView
{
    self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [UserViewController sectionHeaderViewHeight])];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.sectionHeaderView.bounds;
    [self.sectionHeaderView addSubview:visualEffectView];
    
    self.userAvatar = [[ShootImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - AVATAR_SIZE/2.0, - AVATAR_OFFSET, AVATAR_SIZE, AVATAR_SIZE)];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor whiteColor].CGColor];
    [l setBorderWidth:3];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    [self.sectionHeaderView addSubview:self.userAvatar];
    
    self.followersCount = [[UIButton alloc] initWithFrame:CGRectMake(0, PADDING * 2, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    [self.followersCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.followersCount.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [self.followersCount addTarget:self action:@selector(showFollowers:) forControlEvents:UIControlEventTouchUpInside];
    [self.followersCount setTitle:@"0" forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.followersCount];
    
    self.followers = [[UILabel alloc] initWithFrame:CGRectMake(0, self.followersCount.frame.origin.y + self.followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followers.text = @"Followers";
    self.followers.textColor = [UIColor grayColor];
    self.followers.font = [UIFont systemFontOfSize:10];
    self.followers.textAlignment = NSTextAlignmentCenter;
    [self.sectionHeaderView addSubview:self.followers];
    
    self.followingCount = [[UIButton alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width, PADDING * 2, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    [self.followingCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.followingCount.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [self.followingCount addTarget:self action:@selector(showFollowings:) forControlEvents:UIControlEventTouchUpInside];
    [self.followingCount setTitle:@"0" forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.followingCount];
    
    self.followings = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width, self.followersCount.frame.origin.y + self.followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followings.text = @"Following";
    self.followings.textColor = [UIColor grayColor];
    self.followings.font = [UIFont systemFontOfSize:10];
    self.followings.textAlignment = NSTextAlignmentCenter;
    [self.sectionHeaderView addSubview:self.followings];
    
    CGFloat followButtonWidth = 80;
    
    self.username = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2 + followButtonWidth, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height, self.view.frame.size.width - PADDING * 4 - followButtonWidth * 2, USERNAME_HEIGHT)];
    self.username.textAlignment = NSTextAlignmentCenter;
    self.username.textColor = [UIColor darkGrayColor];
    self.username.text = @"";
    self.username.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [self.sectionHeaderView addSubview:self.username];
    
    self.follow = [[UIButton alloc] initWithFrame:CGRectMake(self.username.frame.origin.x + self.username.frame.size.width + PADDING + (followButtonWidth - self.username.frame.size.height)/2.0, self.username.frame.origin.y, self.username.frame.size.height, self.username.frame.size.height)];
    self.follow.layer.cornerRadius = self.follow.frame.size.height/2.0;
    [self.sectionHeaderView addSubview:self.follow];
    
    self.message = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + (followButtonWidth - self.username.frame.size.height)/2.0, self.username.frame.origin.y, self.username.frame.size.height, self.username.frame.size.height)];
    self.message.layer.cornerRadius = self.message.frame.size.height/2.0;
    [self.sectionHeaderView addSubview:self.message];
    
    self.wants = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.username.frame.origin.y + self.username.frame.size.height + PADDING * 2, (self.sectionHeaderView.frame.size.width - PADDING * 2)/2.0, WANTS_BUTTON_HEIGHT)];
    [self.wants setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    self.wants.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.wants setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.wants addTarget:self action:@selector(selectedTagTypeChanged:) forControlEvents:UIControlEventTouchDown];
    [self.sectionHeaderView addSubview:self.wants];
    
    int wantTypeTag = USER_TAG_SHOOT_WANT_TYPE;
    self.selectedTagType = [NSNumber numberWithInt:wantTypeTag];
    
    self.haves = [[UIButton alloc] initWithFrame:CGRectMake(self.wants.frame.size.width + self.wants.frame.origin.x, self.wants.frame.origin.y, (self.sectionHeaderView.frame.size.width - PADDING * 2)/2.0, 30)];
    [self.haves setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    self.haves.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.haves setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.haves addTarget:self action:@selector(selectedTagTypeChanged:) forControlEvents:UIControlEventTouchDown];
    [self.sectionHeaderView addSubview:self.haves];
    
    UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.wants.frame.origin.y, self.sectionHeaderView.frame.size.width - PADDING * 4, 0.3)];
    topLine.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:topLine];
    
    UILabel * middleLine = [[UILabel alloc] initWithFrame:CGRectMake(self.wants.frame.origin.x + self.wants.frame.size.width, self.wants.frame.origin.y + 4, 0.3, self.wants.frame.size.height - 8)];
    middleLine.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:middleLine];
    
    UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.wants.frame.origin.y + self.wants.frame.size.height, self.sectionHeaderView.frame.size.width - PADDING * 4, 0.3)];
    bottomLine.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:bottomLine];

    CGFloat buttonWidth = self.sectionHeaderView.frame.size.width/4.0;
    
    self.gridViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomLine.frame.size.height + bottomLine.frame.origin.y, buttonWidth, VIEW_BUTTON_HEIGHT)];
    self.gridViewButton.tag = GRID_VIEW_TAG;
    [self.gridViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(BUTTON_SIZE, BUTTON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.gridViewButton];
    
    self.listViewButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, self.gridViewButton.frame.origin.y, buttonWidth, VIEW_BUTTON_HEIGHT)];
    self.listViewButton.tag = LIST_VIEW_TAG;
    [self.listViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.listViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"list-icon"] atSize:CGSizeMake(BUTTON_SIZE, BUTTON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.listViewButton];
    
    self.locationViewButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * 2, self.gridViewButton.frame.origin.y, buttonWidth, VIEW_BUTTON_HEIGHT)];
    self.locationViewButton.tag = LOCATION_VIEW_TAG;
    [self.locationViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.locationViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"location-icon"] atSize:CGSizeMake(BUTTON_SIZE, BUTTON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.locationViewButton];
    
    self.calendarViewButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * 3, self.gridViewButton.frame.origin.y, buttonWidth, VIEW_BUTTON_HEIGHT)];
    self.calendarViewButton.tag = CALENDAR_VIEW_TAG;
    [self.calendarViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.calendarViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"calendar-icon"] atSize:CGSizeMake(BUTTON_SIZE, BUTTON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.calendarViewButton];
}

- (void) selectedTagTypeChanged:(UIButton *)sender
{
    if (sender == self.wants) {
        int wantTypeTag = USER_TAG_SHOOT_WANT_TYPE;
        self.selectedTagType = [NSNumber numberWithInt:wantTypeTag];
        [self.wants setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.wants setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.haves setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
        [self.haves setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        int haveTypeTag = USER_TAG_SHOOT_HAVE_TYPE;
        self.selectedTagType = [NSNumber numberWithInt:haveTypeTag];
        [self.wants setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
        [self.wants setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.haves setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.haves setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    UIButton *curViewSelection = (UIButton *)[self.sectionHeaderView viewWithTag:self.imageViewStatus];
    [self viewChanged:curViewSelection];
}

- (void) viewChanged:(UIButton *)sender
{
    UIButton *prevSelection = (UIButton *)[self.sectionHeaderView viewWithTag:self.imageViewStatus];
    if (prevSelection) {
        [prevSelection setImage:[ImageUtil colorImage:[prevSelection imageForState:UIControlStateNormal] color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    UIButton *newSelection = (UIButton *)[self.sectionHeaderView viewWithTag:sender.tag];
    [newSelection setImage:[ImageUtil colorImage:[newSelection imageForState:UIControlStateNormal] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
    self.imageViewStatus = sender.tag;
    if (sender.tag == CALENDAR_VIEW_TAG) {
        self.calendarView.hidden = false;
        self.userShootCollectionView.hidden = true;
        self.mapView.hidden = true;
        [self.calendarView reloadForType:self.selectedTagType];
    } else if (sender.tag == LOCATION_VIEW_TAG) {
        self.calendarView.hidden = true;
        self.userShootCollectionView.hidden = true;
        self.mapView.hidden = false;
        [self.mapView reloadForType:self.selectedTagType];
        [UIView animateWithDuration:0.5 animations:^{
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, HEADER_HEIGHT)];
        }];
    } else {
        self.userShootCollectionView.hidden = false;
        [self.userShootCollectionView setCollectionViewStatus:(self.imageViewStatus == GRID_VIEW_TAG)];
        self.calendarView.hidden = true;
        self.mapView.hidden = true;
        [self.userShootCollectionView reloadForType:self.selectedTagType];
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self adjustAvatarSize];
}

- (void) initImagesCell
{
    self.userShootCollectionView = [[UserShootCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.imagesCell.frame.size.height) forUser:self.user parentController:self];
    [self.imagesCell addSubview:self.userShootCollectionView];
    [UIViewHelper applySameSizeConstraintToView:self.userShootCollectionView superView:self.imagesCell];
    
    self.calendarView = [[UserShootCalendarView alloc] initWithFrame:self.view.bounds forUser:self.user parentController:self];
    [UIViewHelper applySameSizeConstraintToView:self.calendarView superView:self.imagesCell];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    self.calendarView.delegate = self;
    self.calendarView.hidden = true;
    
    self.mapView = [[UserShootMapView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.view.frame.size.height - [UserViewController sectionHeaderViewHeight]) forUser:self.user];
    [self.imagesCell addSubview:self.mapView];
    self.mapView.hidden = true;
    
    [self viewChanged:self.gridViewButton];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == IMAGE_CELL_ROW_INDEX) {
        if (!self.imagesCell) {
            self.imagesCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
            [self initImagesCell];
            self.imagesCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return self.imagesCell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == IMAGE_CELL_ROW_INDEX) {
        if (self.userShootCollectionView) {
            return [self getImageCollectionViewHeight];
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self adjustAvatarSize];
    } else {
        CGFloat yPos = scrollView.contentOffset.y;
        if (yPos > 0 && self.tableView.contentOffset.y < HEADER_HEIGHT + [UserViewController sectionHeaderViewHeight]) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MIN(self.tableView.contentOffset.y + yPos, HEADER_HEIGHT + [UserViewController sectionHeaderViewHeight]))];
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
            
        } else  if (yPos < 0 && self.tableView.contentOffset.y > 0) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MAX(self.tableView.contentOffset.y + yPos, 0))];
        }
    }
}

- (void) adjustAvatarSize
{
    UIScrollView *scrollView = self.tableView;
    CGFloat yPos = -scrollView.contentOffset.y;
    if (yPos > 0) {
        CGRect imgRect = self.header.frame;
        imgRect.size.height = HEADER_HEIGHT+yPos;
        self.header.frame = imgRect;
    }
    if (-yPos < HEADER_HEIGHT - AVATAR_OFFSET - PADDING) {
        yPos = - HEADER_HEIGHT + AVATAR_OFFSET + PADDING;
    } else if (-yPos > HEADER_HEIGHT) {
        yPos = - HEADER_HEIGHT;
    }
    
    CGFloat newAvatarSize = AVATAR_SIZE - (-yPos - HEADER_HEIGHT + AVATAR_OFFSET + PADDING);
    [self.userAvatar setFrame:CGRectMake(self.userAvatar.center.x - newAvatarSize/2.0, -AVATAR_OFFSET + (-yPos - HEADER_HEIGHT + AVATAR_OFFSET + PADDING), newAvatarSize, newAvatarSize)];
    CALayer * l = [self.userAvatar layer];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
}

- (CGFloat) getImageCollectionViewHeight
{
    if(self.imageViewStatus == CALENDAR_VIEW_TAG) {
        return self.view.frame.size.height;
    } else if(self.imageViewStatus == LOCATION_VIEW_TAG) {
        return self.view.frame.size.height - [UserViewController sectionHeaderViewHeight];
    } else {
        return [self.userShootCollectionView getCollectionViewHeight];
    }
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
