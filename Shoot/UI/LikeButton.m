//
//  LikeButton.m
//  Shoot
//
//  Created by LV on 3/30/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "LikeButton.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "UserListView.h"
#import <RestKit/RestKit.h>
#import "UIViewHelper.h"

@interface LikeButton ()

@property (nonatomic, retain) UIButton *like;
@property (nonatomic, retain) UIButton *likeCount;
@property (nonatomic, retain) UIViewController *parentController;
@property (nonatomic, retain) Shoot *shoot;

@end

@implementation LikeButton

static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat PADDING = 10;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const NSInteger USERS_LIKE_SHOOT_LIST_TAG = 198;

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode
{
    self = [super initWithFrame:frame];
    if (self) {
        
        double buttonSize = LIKE_BUTTON_HEIGHT;
        double totalWidth = LIKE_BUTTON_WIDTH;
        CGFloat countLabelWidth = totalWidth - buttonSize;
        
        self.like = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
        [self.like setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"like-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.like.backgroundColor = [ColorDefinition grayColor];
        self.like.layer.cornerRadius = self.like.frame.size.width/2.0;
        [self addSubview:self.like];
        [self.like addTarget:self action:@selector(likeIt:)forControlEvents:UIControlEventTouchDown];
        
        self.likeCount = [[UIButton alloc] initWithFrame:CGRectMake(self.like.frame.origin.x + self.like.frame.size.width + PADDING, self.like.frame.origin.y, countLabelWidth, buttonSize)];
        [self.likeCount setTitle:@"0" forState:UIControlStateNormal];
        [self.likeCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
        self.likeCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.likeCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.likeCount];
        if (!isSimpleMode) {
            [self.likeCount addTarget:self action:@selector(showLike:)forControlEvents:UIControlEventTouchDown];
        }
    }
    return self;
}

- (void) decorateWithShoot:(Shoot *)shoot parentController:(UIViewController *)parentController
{
    self.shoot = shoot;
    self.parentController = parentController;
    [self updateView];
}

- (void) updateView
{
    [self.likeCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:self.shoot.like_count]] forState:UIControlStateNormal];
    self.likeCount.enabled = [self.shoot.like_count integerValue] > 0;
    
    if ([self.shoot.if_cur_user_like_it integerValue] == 0) {
        self.like.backgroundColor = [ColorDefinition grayColor];
        [self.likeCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
    } else {
        self.like.backgroundColor = [ColorDefinition blueColor];
        [self.likeCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)likeIt:(id) sender {
    if ([self.shoot.if_cur_user_like_it intValue] == 1) {
        self.shoot.like_count = [NSNumber numberWithInt:[self.shoot.like_count intValue] - 1];
        self.shoot.if_cur_user_like_it = [NSNumber numberWithInt:0];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/unlike/%@", self.shoot.shootID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *error = nil;
            BOOL successful = [self.shoot.managedObjectContext save:&error];
            if (!successful) {
                NSLog(@"Save shoot Error: %@", error.localizedDescription);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unlike shoot failed with error: %@", error);
            self.shoot.like_count = [NSNumber numberWithInt:[self.shoot.like_count intValue] + 1];
            self.shoot.if_cur_user_like_it = [NSNumber numberWithInt:1];
            [self updateView];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to unlike shoot. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [av show];
        }];
    } else {
        self.shoot.like_count = [NSNumber numberWithInt:[self.shoot.like_count intValue] + 1];
        self.shoot.if_cur_user_like_it = [NSNumber numberWithInt:1];
        [self updateView];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"shoot/like/%@", self.shoot.shootID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
         {
             NSError *error = nil;
             BOOL successful = [self.shoot.managedObjectContext save:&error];
             if (!successful) {
                 NSLog(@"Save self.shoot Error: %@", error.localizedDescription);
             }
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             RKLogError(@"water failed with error: %@", error);
             self.shoot.like_count = [NSNumber numberWithInt:[self.shoot.like_count intValue] - 1];
             self.shoot.if_cur_user_like_it = [NSNumber numberWithInt:0];
             [self updateView];
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to like shoot. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
             [av show];
         }];
    }
}

- (void)showLike:(id) sender {
    if (!self.parentController) {
        return;
    }
    UserListView * usersLikeShootView = (UserListView *)[self.parentController.view viewWithTag:USERS_LIKE_SHOOT_LIST_TAG];
    if (!usersLikeShootView) {
        usersLikeShootView = [[UserListView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.parentController.view addSubview:usersLikeShootView];
    }
    usersLikeShootView.urlPathToPullUsers = [NSString stringWithFormat:@"user/getUsersLikeShoot/%@", self.shoot.shootID];
    [usersLikeShootView reload];
    usersLikeShootView.alpha = 0.0;
    usersLikeShootView.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        usersLikeShootView.alpha = 1.0;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
