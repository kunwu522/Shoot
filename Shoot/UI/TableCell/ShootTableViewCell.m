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

@interface ShootTableViewCell()
@property (nonatomic, retain) UIImageView * userAvatar;
@property (nonatomic, retain) UILabel * usernameLabel;
@property (nonatomic, retain) UILabel * nameLabel;
@property (nonatomic, retain) UILabel * timeLabel;
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
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
        [self addSubview:self.image];
        
        self.blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 35, 35)];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setBorderColor:[UIColor whiteColor].CGColor];
        [l setBorderWidth:1];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        [self addSubview:self.userAvatar];

        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - 50, 0, 50, self.blurView.frame.size.height)];
        self.timeLabel.text = @"1d";
        self.timeLabel.textColor = [UIColor darkGrayColor];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat usernameLabelX = PADDING + self.userAvatar.frame.size.width + self.userAvatar.frame.origin.x;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabelX, 0, self.frame.size.width - usernameLabelX - PADDING - self.timeLabel.frame.size.width, self.blurView.frame.size.height)];
        self.usernameLabel.text = @"USERNAME";
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:10];
        self.usernameLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.usernameLabel];
        
        UIButton * like = [[UIButton alloc] initWithFrame:CGRectMake(0, 220, self.frame.size.width/3.0, 40)];
        [like setTitle:@"1.3M Likes" forState:UIControlStateNormal];
        [like setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        like.titleLabel.font = [UIFont boldSystemFontOfSize:10];
//        [self addSubview:like];
        
        UIButton * want = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3.0, 220, self.frame.size.width/3.0, 40)];
        [want setTitle:@"Want It" forState:UIControlStateNormal];
        [want setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        want.titleLabel.font = [UIFont boldSystemFontOfSize:10];
//        [self addSubview:want];
        
        UIButton * have = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 2.0 / 3.0, 220, self.frame.size.width/3.0, 40)];
        [have setTitle:@"Have It" forState:UIControlStateNormal];
        [have setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        have.titleLabel.font = [UIFont boldSystemFontOfSize:10];
//        [self addSubview:have];
        
        UIImageView *likeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        likeImage.image = [UIImage imageNamed:@"like-icon"];
        [self addSubview:likeImage];
        [likeImage setCenter:like.center];
        
        UIImageView *wantImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        wantImage.image = [UIImage imageNamed:@"want-icon"];
        [self addSubview:wantImage];
        [wantImage setCenter:want.center];
        
        UIImageView *haveImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        haveImage.image = [UIImage imageNamed:@"have-icon"];
        [self addSubview:haveImage];
        [haveImage setCenter:have.center];
        
    }
    return self;
}

- (void) decorate:(UIImage *) image
{
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
    return 260;
}

@end
