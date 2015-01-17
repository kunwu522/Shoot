//
//  UserViewController.m
//  Shoot
//
//  Created by LV on 1/9/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserViewController.h"
#import "SWRevealViewController.h"
#import "UserViewImagesCell.h"
#import "ImageUtil.h"

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (retain, nonatomic) UIImageView * header;
@property (retain, nonatomic) UIImageView * userAvatar;
@property (retain, nonatomic) UILabel *followersCount;
@property (retain, nonatomic) UILabel *followers;
@property (retain, nonatomic) UILabel *followingCount;
@property (retain, nonatomic) UILabel *followings;
@property (retain, nonatomic) UILabel *username;
@property (retain, nonatomic) UIButton * follow;
@property (retain, nonatomic) UIButton * message;

@end

@implementation UserViewController

static NSString * HEADER_CELL_REUSE_ID = @"HeaderCell";
static NSString * TAB_CELL_REUSE_ID = @"TabCell";
static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

static const NSInteger IMAGE_CELL_ROW_INDEX = 0;

static CGFloat PADDING = 5;
static CGFloat AVATAR_SIZE = 80;
static CGFloat AVATAR_OFFSET = 20;
static CGFloat HEADER_HEIGHT = 120;
static CGFloat USERNAME_HEIGHT = 40;
static CGFloat FOLLOWER_LABEL_HEIGHT = 18;
static CGFloat WANTS_BUTTON_HEIGHT = 30;

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UserViewImagesCell class] forCellReuseIdentifier:IMAGE_CELL_REUSE_ID];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT + AVATAR_SIZE - AVATAR_OFFSET)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeaderView;
    
    self.header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    self.header.contentMode = UIViewContentModeScaleAspectFill;
    self.header.clipsToBounds = YES;
    self.header.image = [UIImage imageNamed:@"image3.jpg"];
    [tableHeaderView addSubview:self.header];
    
    self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - AVATAR_SIZE/2.0, HEADER_HEIGHT - AVATAR_OFFSET, AVATAR_SIZE, AVATAR_SIZE)];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor whiteColor].CGColor];
    [l setBorderWidth:4];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
    self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    [tableHeaderView addSubview:self.userAvatar];
    
    self.followersCount = [[UILabel alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT + PADDING, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followersCount.text = @"2,423,763";
    self.followersCount.textColor = [UIColor darkGrayColor];
    self.followersCount.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    self.followersCount.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:self.followersCount];
    
    self.followers = [[UILabel alloc] initWithFrame:CGRectMake(0, self.followersCount.frame.origin.y + self.followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followers.text = @"Followers";
    self.followers.textColor = [UIColor grayColor];
    self.followers.font = [UIFont systemFontOfSize:10];
    self.followers.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:self.followers];
    
    self.followingCount = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width, HEADER_HEIGHT + PADDING, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followingCount.text = @"321";
    self.followingCount.textColor = [UIColor darkGrayColor];
    self.followingCount.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    self.followingCount.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:self.followingCount];
    
    self.followings = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width, self.followersCount.frame.origin.y + self.followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    self.followings.text = @"Follows";
    self.followings.textColor = [UIColor grayColor];
    self.followings.font = [UIFont systemFontOfSize:10];
    self.followings.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:self.followings];
    
    [self.tableView reloadData];
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
    return WANTS_BUTTON_HEIGHT + USERNAME_HEIGHT + PADDING * 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, WANTS_BUTTON_HEIGHT + USERNAME_HEIGHT + PADDING * 2)];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = view.bounds;
    [view addSubview:visualEffectView];
    
    CGFloat followButtonWidth = 80;
    
    self.username = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2 + followButtonWidth, PADDING, self.view.frame.size.width - PADDING * 4 - followButtonWidth * 2, USERNAME_HEIGHT)];
    self.username.textAlignment = NSTextAlignmentCenter;
    self.username.text = @"USERNAME";
    self.username.textColor = [UIColor darkGrayColor];
    self.username.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [view addSubview:self.username];
    
    self.follow = [[UIButton alloc] initWithFrame:CGRectMake(self.username.frame.origin.x + self.username.frame.size.width + PADDING, self.username.frame.origin.y, followButtonWidth, self.username.frame.size.height)];
    [self.follow setImage:[ImageUtil renderImage:[UIImage imageNamed:@"follow"] atSize:CGSizeMake(40, 40)] forState:UIControlStateNormal];
    [view addSubview:self.follow];
    
    self.message = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.username.frame.origin.y, followButtonWidth, self.username.frame.size.height)];
    [self.message setImage:[ImageUtil renderImage:[UIImage imageNamed:@"message"] atSize:CGSizeMake(35, 30)] forState:UIControlStateNormal];
    [view addSubview:self.message];
    
    UIButton * wants = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.username.frame.origin.y + self.username.frame.size.height + PADDING, (view.frame.size.width - PADDING * 2)/2.0, WANTS_BUTTON_HEIGHT)];
    [wants setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    [wants setTitle:@" 5 wants" forState:UIControlStateNormal];
    wants.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [wants setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [view addSubview:wants];
    
    UIButton * haves = [[UIButton alloc] initWithFrame:CGRectMake(wants.frame.size.width + wants.frame.origin.x, wants.frame.origin.y, (view.frame.size.width - PADDING * 2)/2.0, 30)];
    [haves setImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
    [haves setTitle:@" 15 haves" forState:UIControlStateNormal];
    haves.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [haves setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [view addSubview:haves];
    
    UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, wants.frame.origin.y, view.frame.size.width - PADDING * 2, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:topLine];
    
    UILabel * middleLine = [[UILabel alloc] initWithFrame:CGRectMake(wants.frame.origin.x + wants.frame.size.width, wants.frame.origin.y + 4, 1, wants.frame.size.height - 8)];
    middleLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:middleLine];
    
    UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, wants.frame.origin.y + wants.frame.size.height, view.frame.size.width - PADDING * 2, 0.5)];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:bottomLine];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == IMAGE_CELL_ROW_INDEX) {
        UserViewImagesCell *cell = (UserViewImagesCell *)[tableView dequeueReusableCellWithIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == IMAGE_CELL_ROW_INDEX) {
        return 500;
    } else {
        return 0;
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = -scrollView.contentOffset.y;
    if (yPos > 0) {
        CGRect imgRect = self.header.frame;
        imgRect.origin.y = scrollView.contentOffset.y;
        imgRect.size.height = HEADER_HEIGHT+yPos;
        self.header.frame = imgRect;
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
