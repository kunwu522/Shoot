//
//  ImageDetailedCollectionViewCell.m
//  Shoot
//
//  Created by LV on 1/20/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageDetailedCollectionViewCell.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"
#import "UserTagShoot.h"
#import "Tag.h"

@interface ImageDetailedCollectionViewCell ()

@property (nonatomic, retain) UIButton * tags;
@property (nonatomic, retain) UIButton * timeLabel;
@property (nonatomic, retain) UIImageView * ownerAvatar;
@property (nonatomic, retain) UILabel * ownerNameLabel;

@property (nonatomic, weak) User *user;
@property (nonatomic, weak) User *owner;

@end

@implementation ImageDetailedCollectionViewCell

static CGFloat PADDING = 5;
static const CGFloat TAG_HEIGHT = 25;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat OWNER_AVATAR_SIZE = 30;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - TAG_HEIGHT - PADDING * 2)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        
        self.ownerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width - PADDING - OWNER_AVATAR_SIZE, self.imageView.frame.origin.y + self.imageView.frame.size.height - PADDING - OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE, OWNER_AVATAR_SIZE)];
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
//        [self.ownerAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOwnerAvatarTapped)]];
        
        self.ownerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.ownerAvatar.frame.origin.y, self.ownerAvatar.frame.origin.x - PADDING * 2, self.ownerAvatar.frame.size.height)];
        [self addSubview:self.ownerNameLabel];
        self.ownerNameLabel.textAlignment = NSTextAlignmentRight;
        self.ownerNameLabel.textColor = [UIColor whiteColor];
        self.ownerNameLabel.font = [UIFont boldSystemFontOfSize:12];
        self.ownerNameLabel.layer.shadowOffset = CGSizeMake(0, 0);
        self.ownerNameLabel.layer.shadowRadius = 10;
        self.ownerNameLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.ownerNameLabel.layer.shadowOpacity = 1.0;
        
        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50 - PADDING * 2, PADDING * 2, 50, 15)];
        [self.timeLabel setTitle:@"" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:9.0];

        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = self.timeLabel.frame;
        CALayer * l = [visualEffectView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.timeLabel.frame.size.height/2.0];
        [self addSubview:visualEffectView];
        [self addSubview:self.timeLabel];
        
        self.tags = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.imageView.frame.size.height + self.imageView.frame.origin.y + 5, self.frame.size.width - PADDING * 2, TAG_HEIGHT)];
        self.tags.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.tags setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        [self.tags setTitle:@"" forState:UIControlStateNormal];
        [self.tags setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
        self.tags.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:self.tags];
        
    }
    return self;
}

- (void) decorateWith:(Shoot *)shoot user:(User *)user userTagShoots:(NSArray *)userTagShoots
{
    self.user = user;
    self.owner = shoot.user;
    
    [self.timeLabel setTitle:[NSString stringWithFormat:@" %@", [UIViewHelper formatTime:((UserTagShoot *)[userTagShoots objectAtIndex:0]).time]] forState:UIControlStateNormal];
    [self.imageView sd_setImageWithURL:[ImageUtil imageURLOfShoot:shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
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

@end
