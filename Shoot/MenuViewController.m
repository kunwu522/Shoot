//
//  MenuViewController.m
//  Shoot
//
//  Created by LV on 1/10/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MenuViewController.h"
#import "ColorDefinition.h"
#import "MenuTableViewCell.h"
#import "ImageUtil.h"
#import "AppDelegate.h"
#import "UIViewHelper.h"
#import "ShootImageView.h"
#import "SWRevealViewController.h"

@interface MenuViewController () <NotificationDelegate>

@property (nonatomic) NSInteger badgeCount;
@property (retain, nonatomic) UIView * sectionHeaderView;
@property (retain, nonatomic) ShootImageView * userAvatar;
@property (retain, nonatomic) UILabel *usernameLabel;

@end

@implementation MenuViewController

static NSString * TABEL_CELL_REUSE_ID = @"menuItem";
static CGFloat PADDING = 10.0;
static CGFloat AVATAR_SIZE = 80;
static CGFloat USERNAME_HEIGHT = 15;

static NSInteger SHOOTS_INDEX = 0;
static NSInteger SHOOT_INDEX = 1;
static NSInteger MESSAGE_INDEX = 2;
static NSInteger PROFILE_INDEX = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSectionHeaderView];
    self.view.backgroundColor = [ColorDefinition darkRed];
    [self.tableView setSeparatorColor:self.view.backgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:TABEL_CELL_REUSE_ID];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.notificationDelegate = self;
    [appDelegate updateBadgeCount];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.userAvatar setImageURL:[ImageUtil imageURLOfAvatar:appDelegate.currentUserID] isAvatar:YES];
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", appDelegate.currentUsername];
    return self.sectionHeaderView;
}

- (CGFloat) sectionHeaderViewHeight
{
    return PADDING * 4 + AVATAR_SIZE + USERNAME_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self sectionHeaderViewHeight];
}


- (void) initSectionHeaderView
{
    self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [self sectionHeaderViewHeight])];
    self.sectionHeaderView.backgroundColor = [ColorDefinition darkRed];
    CGFloat userAvatarX = (REAR_VIEW_REVEAL_WIDTH - AVATAR_SIZE)/2.0;
    self.userAvatar = [[ShootImageView alloc] initWithFrame:CGRectMake(userAvatarX, PADDING * 2, AVATAR_SIZE, AVATAR_SIZE)];
    CALayer * l = [self.userAvatar layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:5];
    [l setBorderColor:[UIColor whiteColor].CGColor];
    [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
    self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.userAvatar.clipsToBounds = YES;
    [self.sectionHeaderView addSubview:self.userAvatar];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height + PADDING, REAR_VIEW_REVEAL_WIDTH - 2 * PADDING, USERNAME_HEIGHT)];
    [self.usernameLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.usernameLabel setTextColor:[UIColor whiteColor]];
    [self.usernameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sectionHeaderView addSubview:self.usernameLabel];
}

- (void) updateBadgeCount:(NSInteger) badgeCount
{
    self.badgeCount = badgeCount;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MenuTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABEL_CELL_REUSE_ID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == SHOOTS_INDEX) {
        cell.titleLabel.text = @"Shoots";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"list-icon"] color:[UIColor whiteColor]];
    } else if (indexPath.row == SHOOT_INDEX) {
        cell.titleLabel.text = @"Shoot";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"camera"] color:[UIColor whiteColor]];
    } else if (indexPath.row == MESSAGE_INDEX) {
        cell.titleLabel.text = @"Messages";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"message"] color:[UIColor whiteColor]];
    } else if (indexPath.row == PROFILE_INDEX) {
        cell.titleLabel.text = @"Profile";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"profile-icon"] color:[UIColor whiteColor]];
    } else {
        
    }
    if (self.badgeCount > 0 && indexPath.row == MESSAGE_INDEX) {
        cell.counterLabel.text = [NSString stringWithFormat:@"%@", [UIViewHelper getCountString:[NSNumber numberWithLong:self.badgeCount]]];
        CGSize sizeToMakeLabel = [cell.counterLabel.text sizeWithAttributes:@{NSFontAttributeName:cell.counterLabel.font}];
        
        cell.counterLabel.frame = CGRectMake(cell.counterLabel.frame.origin.x, cell.counterLabel.frame.origin.y, sizeToMakeLabel.width + 8, cell.counterLabel.frame.size.height);
        cell.counterLabel.hidden = false;
    } else {
        cell.counterLabel.hidden = true;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SHOOTS_INDEX) {
        [self performSegueWithIdentifier:@"showShoots" sender:self];
    } else if (indexPath.row == MESSAGE_INDEX) {
        [self performSegueWithIdentifier:@"showNotifications" sender:self];
    } else if (indexPath.row == PROFILE_INDEX) {
        [self performSegueWithIdentifier:@"showUser" sender:self];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
