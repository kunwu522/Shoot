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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 220)];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.clipsToBounds = YES;
        [self addSubview:self.image];
        
        self.blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 35, 35)];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setBorderColor:[UIColor whiteColor].CGColor];
        [l setBorderWidth:2];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        [self addSubview:self.userAvatar];
        self.userAvatar.userInteractionEnabled = true;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];

        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - 40, 0, 40, self.blurView.frame.size.height)];
        [self.timeLabel setTitle:@" 1d" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.timeLabel.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat usernameLabelX = PADDING + self.userAvatar.frame.size.width + self.userAvatar.frame.origin.x;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabelX, 0, self.frame.size.width - usernameLabelX - PADDING - self.timeLabel.frame.size.width, self.blurView.frame.size.height)];
        self.usernameLabel.text = @"USERNAME";
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:11];
        self.usernameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.usernameLabel];
        
        UIButton * like = [[UIButton alloc] initWithFrame:CGRectMake(0, 220, self.frame.size.width/3.0, 30)];
        [like setImage:[ImageUtil renderImage:[UIImage imageNamed:@"like-icon"] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [like setTitle:@" 13M" forState:UIControlStateNormal];
        [like setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        like.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:like];
        
        UIButton * want = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3.0, 220, self.frame.size.width/3.0, 30)];
        [want setImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [want setTitle:@" 105K" forState:UIControlStateNormal];
        [want setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        want.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:want];
        
        UIButton * have = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 2.0 / 3.0, 220, self.frame.size.width/3.0, 30)];
        [have setImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [have setTitle:@" 35K" forState:UIControlStateNormal];
        [have setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        have.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:have];
        
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
    [self.blurView removeFromSuperview];
    self.image.image = image;
    [self insertSubview:self.blurView aboveSubview:self.image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) height
{
    return 250;
}

@end
