//
//  TagViewController.m
//  Shoot
//
//  Created by LV on 3/21/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <RestKit/RestKit.h>
#import "TagViewController.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"
#import "Shoot.h"
#import "User.h"
#import "TagShootCollectionView.h"
#import "LikeButton.h"
#import "TagMapView.h"

@interface TagViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UILabel *tagLabel;
@property (retain, nonatomic) UIImageView *imageDisplayView;
@property (retain, nonatomic) UIButton * gridViewButton;
@property (retain, nonatomic) UIButton * listViewButton;
@property (retain, nonatomic) UIButton * locationViewButton;
@property (retain, nonatomic) LikeButton * like;
@property (retain, nonatomic) UIButton * want;
@property (retain, nonatomic) UIButton * wantCount;
@property (retain, nonatomic) UIButton * have;
@property (retain, nonatomic) UIButton * haveCount;
@property (retain, nonatomic) UIImageView * ownerAvatar;
@property (retain, nonatomic) UILabel * ownerNameLabel;
@property (retain, nonatomic) UITableView * tableView;
@property (retain, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) UIView * sectionHeaderView;
@property (retain, nonatomic) UITableViewCell * imagesCell;
@property (retain, nonatomic) TagShootCollectionView * tagShootCollectionView;
@property (retain, nonatomic) TagMapView *tagMapView;
@property (nonatomic) NSInteger imageViewStatus;

@end

@implementation TagViewController

static const CGFloat PADDING = 10;
static const CGFloat HEADER_HEIGHT = 200;
static const CGFloat TAG_LABEL_HEIGHT = 30;
static const NSInteger LOCATION_VIEW_TAG = 102;

static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const CGFloat VIEW_BUTTON_HEIGHT = 35;
static const NSInteger GRID_VIEW_TAG = 100;
static const NSInteger LIST_VIEW_TAG = 101;

static const CGFloat OWNER_AVATAR_SIZE = 30;

static NSString * IMAGE_CELL_REUSE_ID = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    
    CGFloat customRefreshControlHeight = 50.0f;
    CGFloat customRefreshControlWidth = 100.0;
    CGRect customRefreshControlFrame = CGRectMake(0.0f, -customRefreshControlHeight, customRefreshControlWidth, customRefreshControlHeight);
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:customRefreshControlFrame];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageDisplayView.clipsToBounds = YES;
    [tableHeaderView addSubview:self.imageDisplayView];
    
    self.ownerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.imageDisplayView.frame.origin.x + self.imageDisplayView.frame.size.width - PADDING - OWNER_AVATAR_SIZE, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height - PADDING - OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE)];
    CALayer * ownerAvatarLayer = [self.ownerAvatar layer];
    [ownerAvatarLayer setMasksToBounds:YES];
    [ownerAvatarLayer setBorderColor:[UIColor whiteColor].CGColor];
    [ownerAvatarLayer setBorderWidth:2];
    [ownerAvatarLayer setCornerRadius:self.ownerAvatar.frame.size.width/2.0];
    self.ownerAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    [tableHeaderView addSubview:self.ownerAvatar];
    self.ownerAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.ownerAvatar.clipsToBounds = YES;
    self.ownerAvatar.userInteractionEnabled = true;
    //    [self.ownerAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOwnerAvatarTapped)]];
    
    self.ownerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.ownerAvatar.frame.origin.y, self.ownerAvatar.frame.origin.x - PADDING * 2, self.ownerAvatar.frame.size.height)];
    [tableHeaderView addSubview:self.ownerNameLabel];
    self.ownerNameLabel.textAlignment = NSTextAlignmentRight;
    self.ownerNameLabel.textColor = [UIColor whiteColor];
    self.ownerNameLabel.font = [UIFont boldSystemFontOfSize:12];
    self.ownerNameLabel.layer.shadowOffset = CGSizeMake(0, 0);
    self.ownerNameLabel.layer.shadowRadius = 10;
    self.ownerNameLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.ownerNameLabel.layer.shadowOpacity = 1.0;
    
    CGFloat likeButtonSize = LIKE_BUTTON_HEIGHT;
    CGFloat likeButtonWidth = LIKE_BUTTON_WIDTH;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = CGRectMake(PADDING * 1.5, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height - PADDING * 1.25 - BUTTON_SIZE, likeButtonWidth + PADDING * 0.5, likeButtonSize + 0.5 * PADDING);
    [tableHeaderView addSubview:visualEffectView];
    visualEffectView.clipsToBounds = YES;
    visualEffectView.layer.cornerRadius = visualEffectView.frame.size.height/2.0;

    self.like = [[LikeButton alloc] initWithFrame:CGRectMake(PADDING * 2, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height - PADDING - likeButtonSize, likeButtonWidth, likeButtonSize) isSimpleMode:NO];
    [tableHeaderView addSubview:self.like];
    
    [self initSectionHeaderView];
    [self.tableView reloadData];
    
    [self refreshView:self.refreshControl];
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
    return self.sectionHeaderView.frame.size.height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.imageViewStatus == LOCATION_VIEW_TAG) {
        return [self getMapViewHeight];
    }
    if (self.tagShootCollectionView) {
        return [self.tagShootCollectionView getCollectionViewHeight];
    } else {
        return 0;
    }
}

- (CGFloat) getMapViewHeight
{
   return self.view.frame.size.height - self.sectionHeaderView.frame.size.height;
}

- (void) initSectionHeaderView
{
    self.imageViewStatus = GRID_VIEW_TAG;
    self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TAG_LABEL_HEIGHT + BUTTON_SIZE + VIEW_BUTTON_HEIGHT + PADDING * 4)];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.sectionHeaderView.bounds;
    [self.sectionHeaderView addSubview:visualEffectView];
    
    self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, self.view.frame.size.width - PADDING * 2, TAG_LABEL_HEIGHT)];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.textColor = [ColorDefinition darkRed];
    self.tagLabel.font = [UIFont boldSystemFontOfSize:14];
    self.tagLabel.text = self.tag.tag;
    [self.sectionHeaderView addSubview:self.tagLabel];
    
    CGFloat buttonWidth = (self.view.frame.size.width - PADDING * 2)/2.0;
    CGFloat countLabelWidth = buttonWidth - BUTTON_SIZE - PADDING * 2;
    
    self.want = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 0.5 - BUTTON_SIZE/2.0, self.tagLabel.frame.origin.y + self.tagLabel.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
    [self.want setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.want.backgroundColor = [ColorDefinition lightRed];
    self.want.layer.cornerRadius = self.want.frame.size.width/2.0;
    self.want.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.sectionHeaderView addSubview:self.want];
    //    [self.want addTarget:self action:@selector(wantIt:)forControlEvents:UIControlEventTouchDown];
    
    self.wantCount = [[UIButton alloc] initWithFrame:CGRectMake(self.want.frame.origin.x + self.want.frame.size.width + PADDING, self.want.frame.origin.y, countLabelWidth, BUTTON_SIZE)];
    [self.wantCount setTitle:[UIViewHelper getCountString:self.tag.want_count] forState:UIControlStateNormal];
    [self.wantCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.wantCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.wantCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.sectionHeaderView addSubview:self.wantCount];
    //    [self.wantCount addTarget:self action:@selector(showWant:)forControlEvents:UIControlEventTouchDown];
    
    self.have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 1.5 - BUTTON_SIZE/2.0, self.want.frame.origin.y, self.want.frame.size.width, self.want.frame.size.height)];
    [self.have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.have.backgroundColor = [ColorDefinition greenColor];
    self.have.layer.cornerRadius = self.have.frame.size.width/2.0;
    self.have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.sectionHeaderView addSubview:self.have];
    
    self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.have.frame.origin.x + self.have.frame.size.width + PADDING, self.have.frame.origin.y, buttonWidth/2.0 - BUTTON_SIZE/2.0 - PADDING, BUTTON_SIZE)];
    [self.haveCount setTitle:[UIViewHelper getCountString:self.tag.have_count] forState:UIControlStateNormal];
    [self.haveCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.sectionHeaderView addSubview:self.haveCount];
    //    [self.haveCount addTarget:self action:@selector(showHaveIt:)forControlEvents:UIControlEventTouchDown];
    
    CGFloat viewButtonWidth = self.view.frame.size.width/3.0;
    
    self.gridViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.want.frame.size.height + self.want.frame.origin.y + PADDING * 2, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.gridViewButton.tag = GRID_VIEW_TAG;
    [self.gridViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.gridViewButton];
    
    self.listViewButton = [[UIButton alloc] initWithFrame:CGRectMake(viewButtonWidth, self.gridViewButton.frame.origin.y, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.listViewButton.tag = LIST_VIEW_TAG;
    [self.listViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.listViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"list-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.listViewButton];
    
    self.locationViewButton = [[UIButton alloc] initWithFrame:CGRectMake(viewButtonWidth * 2, self.gridViewButton.frame.origin.y, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.locationViewButton.tag = LOCATION_VIEW_TAG;
    [self.locationViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.locationViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"location-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.sectionHeaderView addSubview:self.locationViewButton];
    
    UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.gridViewButton.frame.origin.y, self.view.frame.size.width - PADDING * 4, 0.3)];
    topLine.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:topLine];
    
    UILabel * middleLine1 = [[UILabel alloc] initWithFrame:CGRectMake(self.gridViewButton.frame.origin.x + self.gridViewButton.frame.size.width, self.gridViewButton.frame.origin.y + 4, 0.3, self.gridViewButton.frame.size.height - 8)];
    middleLine1.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:middleLine1];
    
    UILabel * middleLine2 = [[UILabel alloc] initWithFrame:CGRectMake(self.listViewButton.frame.origin.x + self.listViewButton.frame.size.width, self.listViewButton.frame.origin.y + 4, 0.3, self.listViewButton.frame.size.height - 8)];
    middleLine2.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:middleLine2];
    
    UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.gridViewButton.frame.origin.y + self.gridViewButton.frame.size.height, self.view.frame.size.width - PADDING * 4, 0.3)];
    bottomLine.backgroundColor = [UIColor grayColor];
    [self.sectionHeaderView addSubview:bottomLine];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imagesCell) {
        self.imagesCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:IMAGE_CELL_REUSE_ID forIndexPath:indexPath];
        [self initImagesCell];
        self.imagesCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self.imagesCell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        CGFloat yPos = -scrollView.contentOffset.y;
        if (yPos > 0) {
            CGRect imgRect = self.imageDisplayView.frame;
            imgRect.origin.y = scrollView.contentOffset.y;
            imgRect.size.height = HEADER_HEIGHT + yPos;
            self.imageDisplayView.frame = imgRect;
        }
    } else {
        CGFloat yPos = scrollView.contentOffset.y;
        if (yPos > 0 && self.tableView.contentOffset.y < HEADER_HEIGHT + self.sectionHeaderView.frame.size.height) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MIN(self.tableView.contentOffset.y + yPos, HEADER_HEIGHT + self.sectionHeaderView.frame.size.height))];
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
            
        } else  if (yPos < 0 && self.tableView.contentOffset.y > 0) {
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, MAX(self.tableView.contentOffset.y + yPos, 0))];
        }
    }
}

-(void)refreshView:(UIRefreshControl *)refreshControl {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/topShootForTag/%@", self.tag.tagID]  parameters:nil success:^
     (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         Shoot *shoot = (Shoot *)mappingResult.array[0];
         [self.imageDisplayView sd_setImageWithURL:[ImageUtil imageURLOfShoot:shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
         [self.like decorateWithShoot:shoot parentController:self];
         self.ownerNameLabel.text = [NSString stringWithFormat:@"from @%@", shoot.user.username];
         [self.ownerAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:shoot.user.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
         [self.refreshControl endRefreshing];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Failed to call shoot/topShootForTag/:tag_id due to error: %@", error);
         [self.refreshControl endRefreshing];
     }];
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/queryByTag/%@", self.tag.tagID]  parameters:nil success:^
     (RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self updateUserCollectionViews];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Failed to call shoot/queryByTag/:tag_id due to error: %@", error);
     }];
    
}

- (void) initImagesCell
{
    self.tagShootCollectionView = [[TagShootCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.imagesCell.frame.size.height) forUser:nil parentController:self];
    [self.imagesCell addSubview:self.tagShootCollectionView];
    [UIViewHelper applySameSizeConstraintToView:self.tagShootCollectionView superView:self.imagesCell];
    
    self.tagMapView = [[TagMapView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [self getMapViewHeight])];
    [self.imagesCell addSubview:self.tagMapView];
    self.tagMapView.hidden = true;
    
    [self viewChanged:self.gridViewButton];
}

- (void) updateUserCollectionViews
{
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
    if (sender.tag == LOCATION_VIEW_TAG) {
        self.tagShootCollectionView.hidden = true;
        self.tagMapView.hidden = false;
        [self.tagMapView reloadForTag:self.tag];
        [UIView animateWithDuration:0.5 animations:^{
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, HEADER_HEIGHT)];
        }];
    } else {
        self.tagShootCollectionView.hidden = false;
        [self.tagShootCollectionView setCollectionViewStatus:(self.imageViewStatus == GRID_VIEW_TAG)];
        self.tagMapView.hidden = true;
        [self.tagShootCollectionView reloadForTag:self.tag];
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
