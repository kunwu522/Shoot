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
#import "TagTableViewCell.h"
#import "UIViewHelper.h"
#import <RestKit/RestKit.h>
#import "UserTagShootDao.h"
#import "ShootDao.h"
#import "UserDao.h"
#import "Tag.h"
#import "UserTagShoot.h"
#import "AppDelegate.h"

@interface DetailViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, ShootDetailedTableViewCellDelegate>

@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) UITableView *tableView;
@property (weak, nonatomic) ShootDetailedTableViewCell *shootDetailedTableViewCell;
@property (retain, nonatomic) UITableViewCell *commentCell;
@property (retain, nonatomic) UITableView *commentTableView;
@property (retain, nonatomic) UITableView *tagTableView;
@property (retain, nonatomic) NSFetchedResultsController *commentFetchedResultsController;
@property (retain, nonatomic) NSFetchedResultsController *tagFetchedResultsController;

@property (retain, nonatomic) UIView *inputView;
@property (retain, nonatomic) UITextField *inputBox;
@property (retain, nonatomic) UILabel *charCountLabel;
@property (retain, nonatomic) UIButton *postButton;
@property (retain, nonatomic) UIProgressView *postCommentProgressBar;
@property (nonatomic) NSNumber * selectedX;
@property (nonatomic) NSNumber * selectedY;
@property (retain, nonatomic) Comment *pendingComment;

@property (retain, nonatomic) Shoot * shoot;
@property (retain, nonatomic) NSArray * userTagShoots;

@end

@implementation DetailViewController

static CGFloat PADDING = 5;
static CGFloat INPUT_VIEW_HEIGHT = 35;
static CGFloat CHAR_COUNT_LABEL_WIDTH = 20;
static CGFloat POST_BUTTON_WIDTH = 30;
static CGFloat COMMENT_TABLE_HEADER_HEIGHT = 20;

static NSString * DETAILED_TABEL_CELL_REUSE_ID = @"ShootDetailedTableViewCell";
static NSString * COMMENT_TABEL_CELL_REUSE_ID = @"CommentTableViewCell";
static NSString * TAG_TABEL_CELL_REUSE_ID = @"tagTableViewCell";

static const NSInteger DETAILED_TABLE_CELL_ROW_INDEX = 0;
static const NSInteger COMMENTS_TABLE_CELL_ROW_INDEX = 1;

static const NSInteger MAX_CHAR_ALLOWED_FOR_COMMENT = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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
    
    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, INPUT_VIEW_HEIGHT)];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.inputView.bounds;
    [self.inputView addSubview:visualEffectView];
    self.inputView.hidden = true;
    [self.view addSubview:self.inputView];
    self.inputBox = [[UITextField alloc] initWithFrame:CGRectMake(PADDING, self.inputView.frame.size.height * 0.15, self.inputView.frame.size.width - PADDING * 4 - CHAR_COUNT_LABEL_WIDTH - POST_BUTTON_WIDTH, self.inputView.frame.size.height * 0.7)];
    self.inputBox.backgroundColor = [UIColor whiteColor];
    self.inputBox.borderStyle = UITextBorderStyleRoundedRect;
    self.inputBox.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputBox.returnKeyType = UIReturnKeySend;
    self.inputBox.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputBox.layer.cornerRadius = 5;
    self.inputBox.font = [UIFont systemFontOfSize:12];
    self.inputBox.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textUpdated:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:self.inputBox];
    
    [self.inputView addSubview:self.inputBox];
    self.charCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.inputBox.frame.origin.x + self.inputBox.frame.size.width + PADDING, self.inputBox.frame.origin.y, CHAR_COUNT_LABEL_WIDTH, self.inputBox.frame.size.height)];
    self.charCountLabel.textAlignment = NSTextAlignmentRight;
    self.charCountLabel.font = [UIFont systemFontOfSize:11];
    self.charCountLabel.text = [NSString stringWithFormat:@"%ld", MAX_CHAR_ALLOWED_FOR_COMMENT];
    self.charCountLabel.textColor = [UIColor darkGrayColor];
    [self.inputView addSubview:self.charCountLabel];
    self.postButton = [[UIButton alloc] initWithFrame:CGRectMake(self.charCountLabel.frame.origin.x + self.charCountLabel.frame.size.width + PADDING, self.charCountLabel.frame.origin.y, POST_BUTTON_WIDTH, self.inputBox.frame.size.height)];
    CGFloat iconSize = MIN(self.postButton.frame.size.width, self.postButton.frame.size.height);
    [self.postButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"arrow-icon"] atSize:CGSizeMake(iconSize,iconSize)] color:[ColorDefinition lightRed]] forState:UIControlStateNormal];
    [self.postButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"arrow-icon"] atSize:CGSizeMake(iconSize,iconSize)] color:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [self.postButton addTarget:self action:@selector(inputPostButtonPressed:) forControlEvents:UIControlEventTouchDown];
    self.postButton.enabled = false;
    [self.inputView addSubview:self.postButton];
    self.postCommentProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.inputView.frame.size.width, 2)];
    self.postCommentProgressBar.tintColor = [ColorDefinition lightRed];
    [self.inputView addSubview:self.postCommentProgressBar];
    self.postCommentProgressBar.hidden = true;
    
    [self loadData];
    [self fetchData];
}

- (void) initFetchController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shoot.shootID == %@", self.shootID];
    fetchRequest.predicate = predicate;
    // Setup fetched results
    self.commentFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.commentFetchedResultsController setDelegate:self];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserTagShoot"];
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag.tag" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    
    predicate = [NSPredicate predicateWithFormat:@"shoot.shootID == %@", self.shootID];
    fetchRequest.predicate = predicate;
    // Setup fetched results
    self.tagFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:@"tag" cacheName:nil];
    
    [self.tagFetchedResultsController setDelegate:self];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [self fetchData];
}

- (void) fetchData {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/queryShootById/%@", self.shootID]  parameters:nil success:^
     (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self loadData];
         [self.refreshControl endRefreshing];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Failed to call shoot/queryShootById due to error: %@", error);
         [self.refreshControl endRefreshing];
     }];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"comment/query/%@", self.shootID]  parameters:nil success:^
     (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self loadComments];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Failed to call shoot/comments/:id due to error: %@", error);
     }];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/userTagsForShoot/%@", self.shootID]  parameters:nil success:^
     (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self loadTags];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Failed to call shoot/userTagsForShoot/:id due to error: %@", error);
     }];
}

- (void) loadData {
    self.shoot = [[ShootDao sharedManager] findUserByIdLocally:self.shootID];
    [self.tableView reloadData];
}

- (void) loadShoot {
    self.shoot = [[ShootDao sharedManager] findUserByIdLocally:self.shootID];
    [self.shootDetailedTableViewCell decorateWith:self.shoot parentController:self];
}

- (void) loadComments
{
    NSError *error = nil;
    BOOL fetchSuccessful = [self.commentFetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Comment Fetch Error: %@",error);
    }
    [self.commentTableView reloadData];
}

- (void) loadTags
{
    NSError *error = nil;
    BOOL fetchSuccessful = [self.tagFetchedResultsController performFetch:&error];
    if (! fetchSuccessful) {
        NSLog(@"Tag Fetch Error: %@",error);
    }
    [self.tagTableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tagTableView) {
        return [[self.tagFetchedResultsController sections] count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return 2;
    } else if (tableView == self.commentTableView) {
        id sectionInfo = [[self.commentFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else if (tableView == self.tagTableView) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.row == DETAILED_TABLE_CELL_ROW_INDEX) {
            self.shootDetailedTableViewCell = [tableView dequeueReusableCellWithIdentifier:DETAILED_TABEL_CELL_REUSE_ID forIndexPath:indexPath];
            self.shootDetailedTableViewCell.delegate = self;
            [self loadShoot];
            return self.shootDetailedTableViewCell;
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
        return cell;
    } else if (tableView == self.tagTableView) {
        TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_TABEL_CELL_REUSE_ID forIndexPath:indexPath];
        Tag * tag = ((UserTagShoot *)[self.tagFetchedResultsController objectAtIndexPath:indexPath]).tag;
        [cell decorateWithTag:tag];
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
                return MIN([self getTagTableViewHeight], self.view.frame.size.height - [ShootDetailedTableViewCell heightWithoutImageView]);
            } else {
                return MIN([self getCommentTableViewHeight], self.view.frame.size.height - [ShootDetailedTableViewCell minimalHeight]);
            }
        }
    } else if (tableView == self.commentTableView) {
        return [ShootCommentTableViewCell height];
    } else if (tableView == self.tagTableView) {
        return [TagTableViewCell height];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        Comment *comment = [self.commentFetchedResultsController objectAtIndexPath:indexPath];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if ([comment.user.userID isEqual:appDelegate.currentUserID]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        Comment *comment = [self.commentFetchedResultsController objectAtIndexPath:indexPath];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if ([comment.user.userID isEqual:appDelegate.currentUserID]) {
            [[RKObjectManager sharedManager] deleteObject:comment path:[NSString stringWithFormat:@"comment/delete/%@", comment.commentID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [self loadComments];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSLog(@"Failure deleting comment: %@", error.localizedDescription);
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        Comment *comment = [self.commentFetchedResultsController objectAtIndexPath:indexPath];
        [self.shootDetailedTableViewCell markImageAtX:[comment.x doubleValue] y:[comment.y doubleValue]];
    }
}

- (void) initCommentCell
{
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.commentCell.frame.size.width, self.commentCell.frame.size.height)];
    [UIViewHelper applySameSizeConstraintToView:self.commentTableView superView:self.commentCell];
    [self.commentCell addSubview:self.commentTableView];
    
    UILabel *tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.commentCell.frame.size.width, COMMENT_TABLE_HEADER_HEIGHT)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    tableHeaderView.font = [UIFont systemFontOfSize:10];
    tableHeaderView.textAlignment = NSTextAlignmentCenter;
    tableHeaderView.textColor = [UIColor darkGrayColor];
    tableHeaderView.text = @"Long press on image to add comment";
    self.commentTableView.tableHeaderView = tableHeaderView;
    
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    [self.commentTableView setSeparatorColor:[UIColor clearColor]];
    self.commentTableView.showsHorizontalScrollIndicator = false;
    self.commentTableView.showsVerticalScrollIndicator = false;
    self.commentTableView.alwaysBounceVertical = NO;
    [self.commentTableView registerClass:[ShootCommentTableViewCell class] forCellReuseIdentifier:COMMENT_TABEL_CELL_REUSE_ID];
    self.commentTableView.tableFooterView = [[UIView alloc] init];

    [self loadComments];
    
    self.tagTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.commentCell.frame.size.width, self.commentCell.frame.size.height)];
    [UIViewHelper applySameSizeConstraintToView:self.tagTableView superView:self.commentCell];
    [self.commentCell addSubview:self.tagTableView];
    self.tagTableView.dataSource = self;
    self.tagTableView.delegate = self;
    [self.tagTableView setSeparatorColor:[UIColor clearColor]];
    self.tagTableView.showsHorizontalScrollIndicator = false;
    self.tagTableView.showsVerticalScrollIndicator = false;
    self.tagTableView.alwaysBounceVertical = NO;
    [self.tagTableView registerClass:[TagTableViewCell class] forCellReuseIdentifier:TAG_TABEL_CELL_REUSE_ID];
    self.tagTableView.tableFooterView = [[UIView alloc] init];
    
    [self loadTags];
    self.tagTableView.hidden = true;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.commentTableView || scrollView == self.tagTableView){
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

- (CGFloat) getTagTableViewHeight
{
    return [TagTableViewCell height] * [[self.tagFetchedResultsController sections] count];
}

- (CGFloat) getCommentTableViewHeight
{
    id sectionInfo = [[self.commentFetchedResultsController sections] objectAtIndex:0];
    return [ShootCommentTableViewCell height] * [sectionInfo numberOfObjects] + COMMENT_TABLE_HEADER_HEIGHT;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
}

#pragma mark - ShootDetailedTableViewCellDelegate

- (void) longPressedOnImageAtX:(CGFloat)x y:(CGFloat)y
{
    self.selectedX = [NSNumber numberWithFloat:x];
    self.selectedY = [NSNumber numberWithFloat:y];
    [self.inputBox becomeFirstResponder];
}

- (void) imageUnmarked
{
    self.selectedX = nil;
    self.selectedY = nil;
    [self.inputBox endEditing:YES];
}

- (void) viewSwitchedFrom:(NSInteger)oldView to:(NSInteger)newView
{
    if (oldView == newView) {
        return;
    }
    NSInteger commentView = SHOOT_DETAIL_CELL_COMMENTS_BUTTON_TAG;
    NSInteger tagView = SHOOT_DETAIL_CELL_TAGS_BUTTON_TAG;
    if (oldView == commentView) {
        self.commentTableView.hidden = true;
    }
    if (newView == commentView) {
        self.commentTableView.hidden = false;
    }
    
    if (oldView == tagView) {
        self.tagTableView.hidden = true;
    }
    if (newView == tagView) {
        self.tagTableView.hidden = false;
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

- (void) startPosting
{
    RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] managedObjectStore];
    self.pendingComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:objectStore.mainQueueManagedObjectContext];
    self.pendingComment.shoot = self.shoot;
    self.pendingComment.content = self.inputBox.text;
    self.pendingComment.x = self.selectedX;
    self.pendingComment.y = self.selectedY;
    self.shootDetailedTableViewCell.userInteractionEnabled = false;
    self.postButton.enabled = false;
    [self.postCommentProgressBar setProgress:0.0 animated:NO];
    self.postCommentProgressBar.hidden = false;
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.postCommentProgressBar setProgress:0.5 animated:YES];
    });
}

- (void) endPosting
{
    self.pendingComment = nil;
    [self.postCommentProgressBar setProgress:1 animated:YES];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.postCommentProgressBar setHidden:YES];
        self.postButton.enabled = true;
        self.shootDetailedTableViewCell.userInteractionEnabled = true;
        [self.inputBox resignFirstResponder];
    });
}

- (void) inputPostButtonPressed:(id)sender
{
    if (self.inputBox.text.length > 0 && self.inputBox.text.length < MAX_CHAR_ALLOWED_FOR_COMMENT) {
        
        [self startPosting];
        
        [[RKObjectManager sharedManager] postObject:self.pendingComment path:@"comment/create" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self endPosting];
            [self loadComments];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failure saving message: %@", error.localizedDescription);
            [[[RKObjectManager sharedManager] managedObjectStore].mainQueueManagedObjectContext deleteObject:self.pendingComment];
            [self endPosting];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.inputBox) {
        [self inputPostButtonPressed:self];
    }
    return YES;
}


#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, [ShootDetailedTableViewCell height] - [ShootDetailedTableViewCell minimalHeight])];
    CGRect keyboardFrameInWindowsCoordinates;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindowsCoordinates];
    CGPoint kbPosition = keyboardFrameInWindowsCoordinates.origin;
    [self.inputView setFrame:CGRectMake(0, kbPosition.y - self.inputView.frame.size.height, self.inputView.frame.size.width, self.inputView.frame.size.height)];
    self.inputView.alpha = 0.0;
    self.inputView.hidden = false;
    [UIView animateWithDuration:0.5 animations:^{
        self.inputView.alpha = 1.0;
    }];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    self.inputView.hidden = true;
}

#pragma mark - text field change notification
- (void)textUpdated:(NSNotification *)notification
{
    self.charCountLabel.text = [NSString stringWithFormat:@"%ld", MAX_CHAR_ALLOWED_FOR_COMMENT - self.inputBox.text.length];
    if (self.inputBox.text.length > MAX_CHAR_ALLOWED_FOR_COMMENT) {
        self.charCountLabel.textColor = [UIColor redColor];
        self.postButton.enabled = false;
    } else {
        self.charCountLabel.textColor = [UIColor darkGrayColor];
        if (self.inputBox.text.length <= 0) {
            self.postButton.enabled = false;
        } else {
            self.postButton.enabled = true;
        }
    }
    
}

@end
