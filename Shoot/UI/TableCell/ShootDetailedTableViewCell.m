//
//  ShootDetailedTableViewCell.m
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootDetailedTableViewCell.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"
#import "ShootImageView.h"

@interface ShootDetailedTableViewCell ()
@property (retain, nonatomic) ShootImageView *userAvatar;
@property (retain, nonatomic) UILabel *username;
@property (retain, nonatomic) UILabel *imageTitle;
@property (retain, nonatomic) UIImageView *imageDisplayView;
@property (retain, nonatomic) UIButton * timeLabel;
@property (retain, nonatomic) UIButton * location;

@end

@implementation ShootDetailedTableViewCell

static const CGFloat PADDING = 10;
static const CGFloat AVATAR_SIZE = 30;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const CGFloat IMAGE_TITLE_HEIGHT = 30;
static const CGFloat COMMENT_BUTTON_HEIGHT = 30;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userAvatar = [[ShootImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.userAvatar.image = [UIImage imageNamed:@"image5.jpg"];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        [self addSubview:self.userAvatar];
        
        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - 40, self.userAvatar.frame.origin.y, 40, AVATAR_SIZE/2.0)];
        [self.timeLabel setTitle:@" 1d" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        self.timeLabel.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat userNameX = self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING;
        self.username = [[UILabel alloc] initWithFrame:CGRectMake(userNameX, self.userAvatar.frame.origin.y, self.timeLabel.frame.origin.x - userNameX - PADDING, self.userAvatar.frame.size.height/2.0)];
        self.username.font = [UIFont boldSystemFontOfSize:11];
        self.username.text = @"USERNAME";
        self.username.textColor = [UIColor darkGrayColor];
        [self addSubview:self.username];
        
        self.location = [[UIButton alloc] initWithFrame:CGRectMake(self.username.frame.origin.x, self.username.frame.origin.y + self.username.frame.size.height, self.frame.size.width - self.username.frame.origin.x - PADDING, self.userAvatar.frame.size.height/2.0)];
        [self.location setTitle:@" Some place name" forState:UIControlStateNormal];
        [self.location setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"location-icon"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.location setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.location.titleLabel.font = [UIFont systemFontOfSize:11.0];
        self.location.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.location setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self addSubview:self.location];
        
        self.imageTitle = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height, self.frame.size.width - PADDING * 4, IMAGE_TITLE_HEIGHT)];
        self.imageTitle.font = [UIFont boldSystemFontOfSize:12];
        self.imageTitle.text = @"#SHOOT NAME PLACEHOLDER#";
        self.imageTitle.textColor = [ColorDefinition darkRed];
        [self addSubview:self.imageTitle];
        
        CGFloat imageViewSize = self.frame.size.width - PADDING;
        self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING/2.0, self.imageTitle.frame.origin.y + self.imageTitle.frame.size.height, imageViewSize, imageViewSize)];
        self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageDisplayView.clipsToBounds = YES;
        self.imageDisplayView.image = [UIImage imageNamed:@"image3.jpg"];
        [self addSubview:self.imageDisplayView];
        
        CGFloat buttonWidth = (self.frame.size.width - PADDING * 2)/3.0;
        
        UIButton * like = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - BUTTON_SIZE, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
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
        
        UIButton * have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 2.5 - BUTTON_SIZE, like.frame.origin.y, like.frame.size.width, like.frame.size.height)];
        [have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        have.backgroundColor = [ColorDefinition greenColor];
        have.layer.cornerRadius = have.frame.size.width/2.0;
        have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:have];
        
        UIButton *haveCount = [[UIButton alloc] initWithFrame:CGRectMake(have.frame.origin.x + have.frame.size.width + PADDING, have.frame.origin.y, buttonWidth/2.0 - PADDING * 2, BUTTON_SIZE)];
        [haveCount setTitle:@"35K" forState:UIControlStateNormal];
        [haveCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [haveCount.titleLabel setTextAlignment:NSTextAlignmentLeft];
        haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:haveCount];
        
        self.comment = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, like.frame.origin.y + like.frame.size.height + PADDING, (self.frame.size.width - PADDING * 2)/2.0, COMMENT_BUTTON_HEIGHT)];
        [self.comment setTitle:@"Comments" forState:UIControlStateNormal];
        self.comment.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [self.comment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self addSubview:self.comment];
        
        self.otherUserPosts = [[UIButton alloc] initWithFrame:CGRectMake(self.comment.frame.size.width + self.comment.frame.origin.x, self.comment.frame.origin.y, (self.frame.size.width - PADDING * 2)/2.0, COMMENT_BUTTON_HEIGHT)];
        [self.otherUserPosts setTitle:@"Posts from others" forState:UIControlStateNormal];
        self.otherUserPosts.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [self.otherUserPosts setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:self.otherUserPosts];
        
        UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.comment.frame.origin.y, self.frame.size.width - PADDING * 2, 0.3)];
        topLine.backgroundColor = [UIColor grayColor];
        [self addSubview:topLine];
        
        UILabel * middleLine = [[UILabel alloc] initWithFrame:CGRectMake(self.comment.frame.origin.x + self.comment.frame.size.width, self.comment.frame.origin.y + 4, 0.3, self.comment.frame.size.height - 8)];
        middleLine.backgroundColor = [UIColor grayColor];
        [self addSubview:middleLine];
        
        UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.comment.frame.origin.y + self.comment.frame.size.height, self.frame.size.width - PADDING * 2, 0.3)];
        bottomLine.backgroundColor = [UIColor grayColor];
        [self addSubview:bottomLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) height
{
    return PADDING + AVATAR_SIZE + IMAGE_TITLE_HEIGHT + [ShootDetailedTableViewCell minimalHeight] - PADDING/2.0;
}

+ (CGFloat) minimalHeight
{
    return PADDING/2.0 + [[UIScreen mainScreen] bounds].size.width - PADDING + [ShootDetailedTableViewCell heightWithoutImageView];
}

+ (CGFloat) heightWithoutImageView
{
    return BUTTON_SIZE + PADDING + COMMENT_BUTTON_HEIGHT + PADDING;
}

@end
