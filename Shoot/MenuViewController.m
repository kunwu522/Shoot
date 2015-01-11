//
//  MenuViewController.m
//  Shoot
//
//  Created by LV on 1/10/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MenuViewController.h"
#import "ColorDefinition.h"
#import "BlurView.h"
#import "MenuTableViewCell.h"
#import "ImageUtil.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

static NSString * TABEL_CELL_REUSE_ID = @"menuItem";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ColorDefinition grayColor];
    [self.tableView setSeparatorColor:self.view.backgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:TABEL_CELL_REUSE_ID];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TABEL_CELL_REUSE_ID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == 1) {
        cell.titleLabel.text = @"Shoots";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"list-icon"] color:[UIColor whiteColor]];
    } else if (indexPath.row == 2) {
        cell.titleLabel.text = @"Messages";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"message"] color:[UIColor whiteColor]];
    } else if (indexPath.row == 3) {
        cell.titleLabel.text = @"Profile";
        cell.icon.image = [ImageUtil colorImage:[UIImage imageNamed:@"profile_icon"] color:[UIColor whiteColor]];
    }
    return cell;
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
