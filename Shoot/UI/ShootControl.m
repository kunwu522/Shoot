//
//  ShootControl.m
//  Shoot
//
//  Created by LV on 3/14/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootControl.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "UIViewHelper.h"
#import <RestKit/RestKit.h>
#import "UserListView.h"
#import "LikeButton.h"

@interface ShootControl ()

@property (nonatomic, weak) Shoot *shoot;
@property (nonatomic, weak) UIViewController *parentController;

@property (nonatomic, retain) LikeButton * like;
@property (nonatomic, retain) UIButton * have;
@property (nonatomic, retain) UIButton * want;
@property (nonatomic, retain) UIButton * haveCount;
@property (nonatomic, retain) UIButton * wantCount;

@end

@implementation ShootControl

static CGFloat PADDING = 10;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;

- (instancetype)initWithFrame:(CGRect)frame isSimpleMode:(BOOL)isSimpleMode
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat buttonWidth = (self.frame.size.width - PADDING * 2)/3.0;
        CGFloat countLabelWidth = buttonWidth - BUTTON_SIZE - PADDING * 2;
        
        CGFloat likeButtonSize = LIKE_BUTTON_HEIGHT;
        CGFloat likeButtonWidth = LIKE_BUTTON_WIDTH;
        
        self.like = [[LikeButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - likeButtonSize/2.0, 0, likeButtonWidth, likeButtonSize) isSimpleMode:isSimpleMode];
        [self addSubview:self.like];
        
        self.want = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 1.5 - BUTTON_SIZE/2.0, self.like.frame.origin.y, BUTTON_SIZE, BUTTON_SIZE)];
        [self.want setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.want.backgroundColor = [ColorDefinition grayColor];
        self.want.layer.cornerRadius = self.want.frame.size.width/2.0;
        self.want.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.want];
        [self.want addTarget:self action:@selector(wantIt:)forControlEvents:UIControlEventTouchDown];
        
        self.wantCount = [[UIButton alloc] initWithFrame:CGRectMake(self.want.frame.origin.x + self.want.frame.size.width + PADDING, self.want.frame.origin.y, countLabelWidth, BUTTON_SIZE)];
        [self.wantCount setTitle:@"0" forState:UIControlStateNormal];
        [self.wantCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
        self.wantCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.wantCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.wantCount];
        if (!isSimpleMode) {
            [self.wantCount addTarget:self action:@selector(showWant:)forControlEvents:UIControlEventTouchDown];
        }
        
        self.have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 2.5 - BUTTON_SIZE/2.0, self.like.frame.origin.y, BUTTON_SIZE, BUTTON_SIZE)];
        [self.have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.have.backgroundColor = [ColorDefinition grayColor];
        self.have.layer.cornerRadius = self.have.frame.size.width/2.0;
        self.have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.have];
        
        self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.have.frame.origin.x + self.have.frame.size.width + PADDING, self.have.frame.origin.y, buttonWidth/2.0 - BUTTON_SIZE/2.0 - PADDING, BUTTON_SIZE)];
        [self.haveCount setTitle:@"0" forState:UIControlStateNormal];
        [self.haveCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
        self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.haveCount];
        if (!isSimpleMode) {
            [self.haveCount addTarget:self action:@selector(showHaveIt:)forControlEvents:UIControlEventTouchDown];
        }

    }
    return self;
}

- (void) decorateWith:(Shoot *)shoot parentController:(UIViewController *) parentController
{
    self.shoot = shoot;
    self.parentController = parentController;
    [self updateView];
}

- (void) updateView
{
    [self.like decorateWithShoot:self.shoot parentController:self.parentController];

    [self.wantCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:self.shoot.want_count]] forState:UIControlStateNormal];
    self.wantCount.enabled = [self.shoot.want_count integerValue] > 0;
    [self.haveCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:self.shoot.have_count]] forState:UIControlStateNormal];
    self.haveCount.enabled = [self.shoot.have_count integerValue] > 0;
    
    if ([self.shoot.if_cur_user_have_it integerValue] == 0) {
        self.have.backgroundColor = [ColorDefinition grayColor];
        [self.haveCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
    } else {
        self.have.backgroundColor = [ColorDefinition greenColor];
        [self.haveCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    if ([self.shoot.if_cur_user_want_it integerValue] == 0) {
        self.want.backgroundColor = [ColorDefinition grayColor];
        [self.wantCount setTitleColor:[ColorDefinition grayColor] forState:UIControlStateNormal];
    } else {
        self.want.backgroundColor = [ColorDefinition lightRed];
        [self.wantCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)wantIt:(id) sender {
    
}

- (void)showWant:(id) sender {
    
}

- (void)haveIt:(id) sender {
    
}

- (void)showHaveIt:(id) sender {
    
}

+ (CGFloat) getMinimalHeight
{
    return BUTTON_SIZE;
}

@end
