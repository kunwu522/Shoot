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

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView * tableView;

@end

@implementation NotificationViewController

static CGFloat HEADER_HEIGHT = 50;
static CGFloat PADDING = 10;
static NSString * TABEL_CELL_REUSE_ID = @"TableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UILabel * header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    header.backgroundColor = [ColorDefinition blueColor];
    [self.view addSubview:header];
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - HEADER_HEIGHT, HEADER_HEIGHT)];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.tintColor = [UIColor whiteColor];
    [searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search_icon"] color:[UIColor whiteColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.view addSubview:searchBar];
    
    UIImageView * compose = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - HEADER_HEIGHT + PADDING, PADDING, HEADER_HEIGHT - PADDING * 2, HEADER_HEIGHT - PADDING * 2)];
    compose.image = [ImageUtil colorImage:[UIImage imageNamed:@"compose"] color:[UIColor whiteColor]];
    [self.view addSubview:compose];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - HEADER_HEIGHT)];
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[NotificationTableViewCell class] forCellReuseIdentifier:TABEL_CELL_REUSE_ID];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABEL_CELL_REUSE_ID forIndexPath:indexPath];
    cell.userAvatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg", indexPath.row + 1]];
    cell.usernameLabel.text = @"USERNAME";
    cell.contentLabel.text = @"Some content for placeholder purpose.";
    cell.timeLabel.text = @"1d";
    
    if (indexPath.row == 2) {
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//        cell.contentLabel.textColor = [UIColor grayColor];
//        cell.usernameLabel.textColor = [UIColor darkGrayColor];
        cell.userAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.userAvatar.layer.borderWidth = 3;
    } else {
        cell.backgroundColor = [UIColor clearColor];
//        cell.contentLabel.textColor = [UIColor lightGrayColor];
//        cell.usernameLabel.textColor = [UIColor blackColor];
        cell.userAvatar.layer.borderColor = [UIColor clearColor].CGColor;
        cell.userAvatar.layer.borderWidth = 0;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NotificationTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationViewController * viewController = [[ConversationViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
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
