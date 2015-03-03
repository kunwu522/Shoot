//
//  UserListView.m
//  Shoot
//
//  Created by LV on 2/28/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserListView.h"
#import "ColorDefinition.h"
#import "UserTableViewCell.h"
#import "ImageUtil.h"
#import <RestKit/RestKit.h>

@interface UserListView () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic, retain) UITableView * tableView;
@property (retain, nonatomic) UISearchBar * searchBar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, copy) NSArray *filteredUsers;
@property (nonatomic, copy) NSPredicate *originalPredicate;

@end

@implementation UserListView

static CGFloat HEADER_VIEW_HEIGHT = 45;
static CGFloat PADDING = 5;
static NSString * TABEL_CELL_REUSE_ID = @"UserTableViewCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = self.bounds;
        [self addSubview:visualEffectView];
        
        CGFloat closeButtonSize = 20;
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - closeButtonSize - PADDING * 2, (HEADER_VIEW_HEIGHT - closeButtonSize)/2.0, closeButtonSize, closeButtonSize)];
        [self addSubview:self.closeButton];
        [self.closeButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"cancel-icon"] atSize:CGSizeMake(closeButtonSize, closeButtonSize)] color:[ColorDefinition lightRed]] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, PADDING, self.closeButton.frame.origin.x, HEADER_VIEW_HEIGHT - PADDING * 2)];
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.tintColor = [UIColor darkGrayColor];
        self.searchBar.delegate = self;
        [self.searchBar setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"search-icon"] color:[UIColor darkGrayColor]] atSize:CGSizeMake(10, 10)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        [self addSubview:self.searchBar];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_HEIGHT, self.frame.size.width, self.frame.size.height - HEADER_VIEW_HEIGHT)];
        [self addSubview:self.tableView];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        self.tableView.showsHorizontalScrollIndicator = false;
        self.tableView.showsVerticalScrollIndicator = false;
        [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:TABEL_CELL_REUSE_ID];
        
    }
    return self;
}

-(void) closeButtonPressed:(id)sender
{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = true;
    }];
    [self endEditing:YES];
    self.searchBar.text = @"";
    self.users = @[];
    [self loadData];
}

- (void) setFetchRequest:(NSFetchRequest *)fetchRequest
{
    _fetchRequest = fetchRequest;
    self.originalPredicate = self.fetchRequest.predicate;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
}

-(void)reload
{
    // Setup fetched results
    if (self.fetchRequest) {
        [self loadData];
    } else {
        if (self.urlPathToPullUsers) {
            if (!self.refreshControl) {
                CGFloat customRefreshControlHeight = 50.0f;
                CGFloat customRefreshControlWidth = 100.0;
                CGRect customRefreshControlFrame = CGRectMake(0.0f,
                                                              -customRefreshControlHeight,
                                                              customRefreshControlWidth,
                                                              customRefreshControlHeight);
                self.refreshControl = [[UIRefreshControl alloc] initWithFrame:customRefreshControlFrame];
                [self.refreshControl addTarget:self action:@selector(fetachData:) forControlEvents:UIControlEventValueChanged];
                self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading..."];
                [self.tableView addSubview:self.refreshControl];
            }
            [self.refreshControl beginRefreshing];
            [self fetachData:self.refreshControl];
        } else if (self.users && [self.users count] > 0) {
            [self loadData];
        }
    }
}

-(void)fetachData:(UIRefreshControl *)refresh
{
    NSString *url;
    if (self.urlPathToPullUsersWhenSearchStringIsEmpty) {
        if ([self.searchBar.text isEqual:@""]) {
            url = self.urlPathToPullUsersWhenSearchStringIsEmpty;
        } else {
            url = [NSString stringWithFormat:@"%@/%@", self.urlPathToPullUsers, self.searchBar.text];
        }
    } else {
        url = self.urlPathToPullUsers;
    }
    
    [[RKObjectManager sharedManager] getObjectsAtPath:url parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self setUsers:mappingResult.array];
        [self loadData];
        [refresh endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load %@ failed with error: %@", self.urlPathToPullUsers, error);
        [refresh endRefreshing];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to get users. Please pull to try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}

- (void) filterUsers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchBar.text]];
    if (self.fetchRequest && self.originalPredicate) {
        self.fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate, self.originalPredicate]];
    } else {
        self.filteredUsers = [self.users filteredArrayUsingPredicate:predicate];
    }
}

- (void) loadData
{
    [self filterUsers];
    if (self.fetchRequest) {
        NSError *error = nil;
        BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
        if (! fetchSuccessful) {
            NSLog(@"Fetch Error: %@",error);
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.fetchRequest) {
        return self.filteredUsers.count;
    } else {
        id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.fetchRequest) {
        return 1;
    } else {
        return [[self.fetchedResultsController sections] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_TABLE_VIEW_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABEL_CELL_REUSE_ID forIndexPath:indexPath];
    if (cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        User * user = [self getUserForIndexPath:indexPath];
        [cell decorateCellWithUser:user];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:true];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectedUser:)]) {
        [self.delegate selectedUser:[self getUserForIndexPath:indexPath]];
        [self closeButtonPressed:self];
    }
}

- (User *) getUserForIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchRequest) {
        return [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        return [self.filteredUsers objectAtIndex:indexPath.row];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.urlPathToPullUsersWhenSearchStringIsEmpty) {
        [self fetachData:self.refreshControl];
    } else {
        [self loadData];
    }
}

@end
