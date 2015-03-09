//
//  ShootTableViewCell.m
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import "ShootTableViewCell.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserViewController.h"
#import "UIViewHelper.h"
#import "Tag.h"

@interface ShootTableViewCell()
@property (nonatomic, retain) UIImageView * userAvatar;
@property (nonatomic, retain) UIImageView * ownerAvatar;
@property (nonatomic, retain) UILabel * usernameLabel;
@property (nonatomic, retain) UILabel * nameLabel;
@property (nonatomic, retain) UILabel * ownerNameLabel;
@property (nonatomic, retain) UIButton * timeLabel;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIButton * like;
@property (nonatomic, retain) UIButton * have;
@property (nonatomic, retain) UIButton * want;
@property (nonatomic, retain) UIButton * likeCount;
@property (nonatomic, retain) UIButton * haveCount;
@property (nonatomic, retain) UIButton * wantCount;
@property (nonatomic, retain) UIButton * tags;

@property (nonatomic, weak) User *user;
@property (nonatomic, weak) User *owner;
@property (nonatomic, weak) UIViewController * parentController;

@end

@implementation ShootTableViewCell

static CGFloat PADDING = 10;
static CGFloat AVATAR_SIZE = 45;
static CGFloat OWNER_AVATAR_SIZE = 30;
static CGFloat BUTTON_HEIGHT = 25;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const CGFloat TIME_LABEL_WIDTH = 60;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55/2.0, self.frame.size.width, self.frame.size.width)];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.clipsToBounds = YES;
        [self addSubview:self.image];
        
        self.ownerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.image.frame.origin.x + self.image.frame.size.width - PADDING - OWNER_AVATAR_SIZE, self.image.frame.origin.y + self.image.frame.size.height - PADDING - OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE)];
        CALayer * ownerAvatarLayer = [self.ownerAvatar layer];
        [ownerAvatarLayer setMasksToBounds:YES];
        [ownerAvatarLayer setBorderColor:[UIColor whiteColor].CGColor];
        [ownerAvatarLayer setBorderWidth:2];
        [ownerAvatarLayer setCornerRadius:self.ownerAvatar.frame.size.width/2.0];
        self.ownerAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        [self addSubview:self.ownerAvatar];
        self.ownerAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.ownerAvatar.clipsToBounds = YES;
        self.ownerAvatar.userInteractionEnabled = true;
        [self.ownerAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOwnerAvatarTapped)]];
        
        self.ownerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.ownerAvatar.frame.origin.y, self.ownerAvatar.frame.origin.x - PADDING * 2, self.ownerAvatar.frame.size.height)];
        [self addSubview:self.ownerNameLabel];
        self.ownerNameLabel.textAlignment = NSTextAlignmentRight;
        self.ownerNameLabel.textColor = [UIColor whiteColor];
        self.ownerNameLabel.font = [UIFont boldSystemFontOfSize:12];
        self.ownerNameLabel.layer.shadowOffset = CGSizeMake(0, 0);
        self.ownerNameLabel.layer.shadowRadius = 10;
        self.ownerNameLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.ownerNameLabel.layer.shadowOpacity = 1.0;
        
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING/2.0, AVATAR_SIZE, AVATAR_SIZE)];
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setBorderColor:[UIColor whiteColor].CGColor];
        [l setBorderWidth:2];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        [self addSubview:self.userAvatar];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.clipsToBounds = YES;
        self.userAvatar.userInteractionEnabled = true;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleAvatarTapped)]];

        CGFloat timeLabelY = 5;
        
        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, timeLabelY, TIME_LABEL_WIDTH, self.image.frame.origin.y - timeLabelY)];
        [self.timeLabel setTitle:@"" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.timeLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat usernameLabelX = PADDING + self.userAvatar.frame.size.width + self.userAvatar.frame.origin.x;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabelX, timeLabelY, self.frame.size.width - usernameLabelX - PADDING - self.timeLabel.frame.size.width, self.image.frame.origin.y - timeLabelY)];
        self.usernameLabel.text = @"";
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:12];
        self.usernameLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.usernameLabel];
        
        self.tags = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.image.frame.size.height + self.image.frame.origin.y + 5, self.frame.size.width - PADDING * 2, BUTTON_HEIGHT)];
        self.tags.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.tags setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        [self.tags setTitle:@"" forState:UIControlStateNormal];
        [self.tags setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
        self.tags.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:self.tags];
        
        CGFloat buttonWidth = (self.frame.size.width - PADDING * 2)/3.0;
        CGFloat countLabelWidth = buttonWidth - BUTTON_SIZE - PADDING * 2;
        
        self.like = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - BUTTON_SIZE/2.0, self.tags.frame.origin.y + self.tags.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
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
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.have.frame.origin.x + self.have.frame.size.width + PADDING, self.have.frame.origin.y, buttonWidth/2.0 - BUTTON_SIZE/2.0 - PADDING, BUTTON_SIZE)];
        [self.haveCount setTitle:@"0" forState:UIControlStateNormal];
        [self.haveCount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        [self addSubview:self.haveCount];
        
    }
    return self;
}

- (void)handleAvatarTapped
{
    UserViewController* viewController = [[UserViewController alloc] initWithNibName:nil bundle:nil];
    viewController.userID = self.user.userID;
    [self.parentController presentViewController:viewController animated:YES completion:nil];
}

- (void)handleOwnerAvatarTapped
{
    UserViewController* viewController = [[UserViewController alloc] initWithNibName:nil bundle:nil];
    viewController.userID = self.owner.userID;
    [self.parentController presentViewController:viewController animated:YES completion:nil];
}

- (void) decorateWith:(Shoot *)shoot user:(User *)user userTagShoots:(NSArray *)userTagShoots parentController:(UIViewController *) parentController
{
    self.parentController = parentController;
    [self.userAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:user.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    self.usernameLabel.text = user.username;
    [self.timeLabel setTitle:[NSString stringWithFormat:@" %@", [UIViewHelper formatTime:((UserTagShoot *)[userTagShoots objectAtIndex:0]).time]] forState:UIControlStateNormal];
    [self.image sd_setImageWithURL:[ImageUtil imageURLOfShoot:shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
    [self.likeCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.like_count]] forState:UIControlStateNormal];
    [self.wantCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.want_count]] forState:UIControlStateNormal];
    [self.haveCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.have_count]] forState:UIControlStateNormal];
    NSMutableString * tags = [[NSMutableString alloc] init];
    [tags appendString:@" "];
    for(UserTagShoot *userTagShoot in userTagShoots) {
        [tags appendString:userTagShoot.tag.tag];
        [tags appendString:@", "];
    }
    [tags deleteCharactersInRange:NSMakeRange(tags.length - 2, 2)];
    [self.tags setTitle:tags forState:UIControlStateNormal];
    switch ([((UserTagShoot *)[userTagShoots objectAtIndex:0]).type integerValue]) {
        case 0:
            [self.tags setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
            break;
        case 1:
            [self.tags setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    self.user = user;
    
    if ([shoot.user.userID isEqualToValue:user.userID]) {
        self.ownerNameLabel.hidden = true;
        self.ownerAvatar.hidden = true;
        self.owner = nil;
    } else {
        self.owner = shoot.user;
        self.ownerNameLabel.hidden = false;
        self.ownerAvatar.hidden = false;
        self.ownerNameLabel.text = [NSString stringWithFormat:@"from @%@", shoot.user.username];
        [self.ownerAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:shoot.user.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    }
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
