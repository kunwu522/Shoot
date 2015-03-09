//
//  DetailViewController.m
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "ShootDetailedTableViewCell.h"
#import "ShootCommentTableViewCell.h"
#import "ImageCollectionViewCell.h"
#import "UIViewHelper.h"
#import <RestKit/RestKit.h>
#import "UserTagShootDao.h"
#import "ShootDao.h"
#import "UserDao.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, ShootDetailedTableViewCellDelegate>

@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UITableViewCell *commentCell;
@property (retain, nonatomic) UITableView *commentTableView;
@property (retain, nonatomic) UICollectionView *imageCollectionView;
@property (strong, nonatomic) NSFetchedResultsController *commentFetchedResultsController;

@property (retain, nonatomic) Shoot * shoot;
@property (retain, nonatomic) NSArray * userTagShoots;

@end

@implementation DetailViewController

static CGFloat PADDING = 5;

static NSString * DETAILED_TABEL_CELL_REUSE_ID = @"ShootDetailedTableViewCell";
static NSString * COMMENT_TABEL_CELL_REUSE_ID = @"CommentTableViewCell";
static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

static const NSInteger DETAILED_TABLE_CELL_ROW_INDEX = 0;
static const NSInteger COMMENTS_TABLE_CELL_ROW_INDEX = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [self initFetchController];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.showsHorizontalScrollIndicator = false;
    self.tableView.showsVerticalScrollIndicator = false;
    [self.tableView registerClass:[ShootDetailedTableViewCell class] forCellReuseIdentifier:DETAILED_TABEL_CELL_REUSE_ID];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:COMMENT_TABEL_CELL_REUSE_ID];
    
    CGFloat customRefreshControlHeight = 50.0f;
    CGFloat customRefreshControlWidth = 100.0;
    CGRect customRefreshControlFrame = CGRectMake(0.0f, -customRefreshControlHeight, customRefreshControlWidth, customRefreshControlHeight);
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:customRefreshControlFrame];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    [self loadData];
    [self refreshView:self.refreshControl];
}

- (void) initFetchController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    NSSortDescriptor *timeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[timeSortDescriptor];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shoot.shootID == %@", self.shootID];
    fetchRequest.predicate = predicate;
    // Setup fetched results
    self.commentFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.commentFetchedResultsController setDelegate:self];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [self fetchData];
}

- (void) fetchData {
    @synchronized(self) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/queryShootById/%@", self.shootID]  parameters:nil success:^
         (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
             [self loadData];
             [self.refreshControl endRefreshing];
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             RKLogError(@"Failed to call shoot/queryById due to error: %@", error);
             [self.refreshControl endRefreshing];
         }];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"comment/query/%@", self.shootID]  parameters:nil success:^
         (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
             [self loadComments];
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             RKLogError(@"Failed to call shoot/comments/:id due to error: %@", error);
         }];
    }
}

- (void) loadData {
    self.shoot = [[ShootDao sharedManager] findUserByIdLocally:self.shootID];
    [self.tableView reloadData];
}

- (void) loadComments
{
    NSError *error = nil;
    BOOL fetchSuccessful = [self.commentFetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Fetch Error: %@",error);
    }
    [self.commentTableView reloadData];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return 2;
    } else if (tableView == self.commentTableView) {
        id sectionInfo = [[self.commentFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.row == DETAILED_TABLE_CELL_ROW_INDEX) {
            ShootDetailedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DETAILED_TABEL_CELL_REUSE_ID forIndexPath:indexPath];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell decorateWith:self.shoot];
            return cell;
        } else if(indexPath.row == COMMENTS_TABLE_CELL_ROW_INDEX) {
            if (self.commentCell == nil) {
                self.commentCell = [tableView dequeueReusableCellWithIdentifier:COMMENT_TABEL_CELL_REUSE_ID forIndexPath:indexPath];
                [self initCommentCell];
                self.commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return self.commentCell;
        }
    } else if (tableView == self.commentTableView) {
        ShootCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_TABEL_CELL_REUSE_ID forIndexPath:indexPath];
        Comment *comment = [self.commentFetchedResultsController objectAtIndexPath:indexPath];
        [cell decorateWithComment:comment];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.row == DETAILED_TABLE_CELL_ROW_INDEX) {
            return [ShootDetailedTableViewCell height];
        } else if (indexPath.row == COMMENTS_TABLE_CELL_ROW_INDEX) {
            if (self.commentTableView.hidden) {
                return MIN([self getImageCollectionViewHeight], self.view.frame.size.height - [ShootDetailedTableViewCell heightWithoutImageView]);
            } else {
                return MIN([self getCommentsViewHeight], self.view.frame.size.height - [ShootDetailedTableViewCell minimalHeight]);
            }
        }
    } else if (tableView == self.commentTableView) {
        return [ShootCommentTableViewCell height];
    }
    return 0;
}

- (void) initCommentCell
{
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.commentCell.frame.size.width, self.commentCell.frame.size.height)];
    self.commentTableView.layer.borderWidth = 1;
    [UIViewHelper applySameSizeConstraintToView:self.commentTableView superView:self.commentCell];
    
    [self.commentCell addSubview:self.commentTableView];
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    [self.commentTableView setSeparatorColor:[UIColor clearColor]];
    self.commentTableView.showsHorizontalScrollIndicator = false;
    self.commentTableView.showsVerticalScrollIndicator = false;
    [self.commentTableView registerClass:[ShootCommentTableViewCell class] forCellReuseIdentifier:COMMENT_TABEL_CELL_REUSE_ID];
    self.commentTableView.tableFooterView = [[UIView alloc] init];

    [self loadComments];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = PADDING;
    layout.minimumInteritemSpacing = PADDING;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.commentCell.frame.size.height) collectionViewLayout:layout];
    [UIViewHelper applySameSizeConstraintToView:self.imageCollectionView superView:self.commentCell];
    [self.imageCollectionView setContentInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
    self.imageCollectionView.dataSource = self;
    self.imageCollectionView.delegate = self;
    [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.imageCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID];
    [UIViewHelper applySameSizeConstraintToView:self.imageCollectionView superView:self.commentCell];
    [self.imageCollectionView reloadData];
    self.imageCollectionView.hidden = true;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.commentTableView || scrollView == self.imageCollectionView){
        CGFloat yPos = scrollView.contentOffset.y;
        CGFloat maxOffset;
        if (scrollView == self.commentTableView) {
            maxOffset = [ShootDetailedTableViewCell height] - [ShootDetailedTableViewCell minimalHeight];
        } else {
            maxOffset = [ShootDetailedTableViewCell height] - [ShootDetailedTableViewCell heightWithoutImageView];
        }
        
        if (yPos > 0 && self.tableView.contentOffset.y < maxOffset) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MIN(self.tableView.contentOffset.y + yPos, maxOffset))];
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
            
        } else  if (yPos < 0 && self.tableView.contentOffset.y > 0) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MAX(self.tableView.contentOffset.y + yPos, 0))];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self getImagesCount];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) getImagesCount
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg", indexPath.row % 5 + 1]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.commentCell.frame.size.width - PADDING * 4)/3.0, [self getCollectionViewCellHeight]);
}

- (CGFloat) getCollectionViewCellHeight
{
    return (self.commentCell.frame.size.width - PADDING * 4)/3.0;
}

- (CGFloat) getImageCollectionViewHeight
{
    int rowCount = ceil([self getImagesCount] / 3.0);
    return (PADDING + [self getCollectionViewCellHeight]) * rowCount + PADDING;
}

- (CGFloat) getCommentsViewHeight
{
    id sectionInfo = [[self.commentFetchedResultsController sections] objectAtIndex:0];
    return [ShootCommentTableViewCell height] * [sectionInfo numberOfObjects];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
}

- (void) viewSwitchedFrom:(NSInteger)oldView to:(NSInteger)newView
{
    if (self.commentTableView.hidden) {
        self.commentTableView.hidden = false;
        self.imageCollectionView.hidden = true;
    } else {
        self.commentTableView.hidden = true;
        self.imageCollectionView.hidden = false;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
