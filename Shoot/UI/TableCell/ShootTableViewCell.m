//
//  ShootTableViewCell.m
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import "ShootTableViewCell.h"
#import "BlurView.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import "UserViewController.h"

@interface ShootTableViewCell()
@property (nonatomic, retain) UIImageView * userAvatar;
@property (nonatomic, retain) UILabel * usernameLabel;
@property (nonatomic, retain) UILabel * nameLabel;
@property (nonatomic, retain) UIButton * timeLabel;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIButton * ilikeButton;
@property (nonatomic, retain) UIButton * ihaveButton;
@property (nonatomic, retain) UIButton * iwantButton;
@property (nonatomic, retain) BlurView * blurView;
@end

@implementation ShootTableViewCell

static CGFloat PADDING = 10;
static CGFloat AVATAR_SIZE = 45;
static CGFloat BUTTON_HEIGHT = 25;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55/2.0, self.frame.size.width, self.frame.size.width)];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.clipsToBounds = YES;
        [self addSubview:self.image];
        
        self.blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING/2.0, AVATAR_SIZE, AVATAR_SIZE)];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setBorderColor:[UIColor whiteColor].CGColor];
        [l setBorderWidth:2];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.image = [UIImage imageNamed:@"image5.jpg"];
        [self addSubview:self.userAvatar];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.clipsToBounds = YES;
        self.userAvatar.userInteractionEnabled = true;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];

        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - 40, 0, 40, self.blurView.frame.size.height)];
        [self.timeLabel setTitle:@" 1d" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.timeLabel.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat usernameLabelX = PADDING + self.userAvatar.frame.size.width + self.userAvatar.frame.origin.x;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabelX, 0, self.frame.size.width - usernameLabelX - PADDING - self.timeLabel.frame.size.width, self.blurView.frame.size.height)];
        self.usernameLabel.text = @"USERNAME";
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:11];
        self.usernameLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.usernameLabel];
        
        UIButton *label1 = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.image.frame.size.height + self.image.frame.origin.y + 5, self.frame.size.width - PADDING * 2, BUTTON_HEIGHT)];
        label1.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [label1 setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        [label1 setTitle:@" #testtag1 #testtag2" forState:UIControlStateNormal];
        [label1 setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
        label1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:label1];
        
        CGFloat buttonWidth = (self.frame.size.width - PADDING * 2)/3.0;
        
        UIButton * like = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - BUTTON_SIZE, label1.frame.origin.y + label1.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
        [like setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"like-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        like.backgroundColor = [ColorDefinition blueColor];
        like.layer.cornerRadius = like.frame.size.width/2.0;
        [self addSubview:like];
        
        UIButton *likeCount = [[UIButton alloc] initWithFrame:CGRectMake(like.frame.origin.x + like.frame.size.width + PADDING, like.frame.origin.y, buttonWidth/2.0 - PADDING * 2, BUTTON_SIZE)];
        [likeCount setTitle:@"13M" forState:UIControlStateNormal];
        [likeCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [likeCount.titleLabel setTextAlignment:NSTextAlignmentLeft];
        likeCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:likeCount];
        
        UIButton * want = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 1.5 - BUTTON_SIZE, like.frame.origin.y, like.frame.size.width, like.frame.size.height)];
        [want setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        want.backgroundColor = [ColorDefinition lightRed];
        want.layer.cornerRadius = want.frame.size.width/2.0;
        want.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:want];
        
        UIButton *wantCount = [[UIButton alloc] initWithFrame:CGRectMake(want.frame.origin.x + want.frame.size.width + PADDING, want.frame.origin.y, buttonWidth/2.0 - PADDING * 2, BUTTON_SIZE)];
        [wantCount setTitle:@"105K" forState:UIControlStateNormal];
        [wantCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [wantCount.titleLabel setTextAlignment:NSTextAlignmentLeft];
        wantCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:wantCount];
        
        UIButton * have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 2.5 - BUTTON_SIZE/2.0, like.frame.origin.y, like.frame.size.width, like.frame.size.height)];
        [have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        have.backgroundColor = [ColorDefinition greenColor];
        have.layer.cornerRadius = have.frame.size.width/2.0;
        have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:have];
        
//        UIButton *haveCount = [[UIButton alloc] initWithFrame:CGRectMake(have.frame.origin.x + have.frame.size.width + PADDING, have.frame.origin.y, buttonWidth/2.0 - PADDING * 2, BUTTON_SIZE)];
//        [haveCount setTitle:@"35K" forState:UIControlStateNormal];
//        [haveCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [haveCount.titleLabel setTextAlignment:NSTextAlignmentLeft];
//        haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
//        [self addSubview:haveCount];
        
    }
    return self;
}

- (void)handleAvatarTapped
{
    UserViewController* viewController = [[UserViewController alloc] initWithNibName:nil bundle:nil];
    [self.parentController presentViewController:viewController animated:YES completion:nil];
}

- (void) decorate:(UIImage *) image parentController:(UIViewController *) parentController
{
    self.parentController = parentController;
//    [self.blurView removeFromSuperview];
    self.image.image = image;
//    [self insertSubview:self.blurView aboveSubview:self.image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) height
{
    return [[UIScreen mainScreen] bounds].size.width + BUTTON_HEIGHT + BUTTON_SIZE + PADDING * 6;
}

@end
