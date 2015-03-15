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

@interface ShootControl ()

@property (nonatomic, weak) Shoot *shoot;
@property (nonatomic, weak) UIViewController *parentController;

@property (nonatomic, retain) UIButton * like;
@property (nonatomic, retain) UIButton * have;
@property (nonatomic, retain) UIButton * want;
@property (nonatomic, retain) UIButton * likeCount;
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
        
        self.like = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - BUTTON_SIZE/2.0, 0, BUTTON_SIZE, BUTTON_SIZE)];
        [self.like setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"like-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.like.backgroundColor = [ColorDefinition blueColor];
        self.like.layer.cornerRadius = self.like.frame.size.width/2.0;
        [self addSubview:self.like];
        
        self.likeCount = [[UIButton alloc] initWithFrame:CGRectMake(self.like.frame.origin.x + self.like.frame.size.width + PADDING, self.like.frame.origin.y, countLabelWidth, BUTTON_SIZE)];
        [self.likeCount setTitle:@"0" forState:UIControlStateNormal];
        [self.likeCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.likeCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.likeCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.likeCount];
        
        self.want = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 1.5 - BUTTON_SIZE/2.0, self.like.frame.origin.y, self.like.frame.size.width, self.like.frame.size.height)];
        [self.want setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.want.backgroundColor = [ColorDefinition lightRed];
        self.want.layer.cornerRadius = self.want.frame.size.width/2.0;
        self.want.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.want];
        
        self.wantCount = [[UIButton alloc] initWithFrame:CGRectMake(self.want.frame.origin.x + self.want.frame.size.width + PADDING, self.want.frame.origin.y, countLabelWidth, BUTTON_SIZE)];
        [self.wantCount setTitle:@"0" forState:UIControlStateNormal];
        [self.wantCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.wantCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.wantCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.wantCount];
        
        self.have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 2.5 - BUTTON_SIZE/2.0, self.like.frame.origin.y, self.like.frame.size.width, self.like.frame.size.height)];
        [self.have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [self.have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.have.backgroundColor = [ColorDefinition greenColor];
        self.have.layer.cornerRadius = self.have.frame.size.width/2.0;
        self.have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.have];
        
        self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.have.frame.origin.x + self.have.frame.size.width + PADDING, self.have.frame.origin.y, buttonWidth/2.0 - BUTTON_SIZE/2.0 - PADDING, BUTTON_SIZE)];
        [self.haveCount setTitle:@"0" forState:UIControlStateNormal];
        [self.haveCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.haveCount];

    }
    return self;
}

- (void) decorateWith:(Shoot *)shoot parentController:(UIViewController *) parentController
{
    self.shoot = shoot;
    self.parentController = parentController;
    [self.likeCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.like_count]] forState:UIControlStateNormal];
    [self.wantCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.want_count]] forState:UIControlStateNormal];
    [self.haveCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.have_count]] forState:UIControlStateNormal];
}

+ (CGFloat) getMinimalHeight
{
    return BUTTON_SIZE;
}

@end
