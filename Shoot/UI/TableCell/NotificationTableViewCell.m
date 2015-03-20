//
//  NotificationTableViewCell.m
//  Shoot
//
//  Created by LV on 1/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "User.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation NotificationTableViewCell
static double PADDING = 10;
static double AVATAR_SIZE = 50;
static double TIME_LABEL_WIDTH = 70;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.userInteractionEnabled = true;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        self.userAvatar.userInteractionEnabled = YES;
        [self.userAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped:)]];
        [self addSubview:self.userAvatar];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING, self.userAvatar.frame.origin.y, self.frame.size.width - PADDING * 4 - AVATAR_SIZE - TIME_LABEL_WIDTH, self.userAvatar.frame.size.height/2.0)];
        self.usernameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.usernameLabel setTextColor:[UIColor blackColor]];
        [self.usernameLabel setFont:[UIFont boldSystemFontOfSize:12]];
        self.usernameLabel.userInteractionEnabled = true;
        [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped:)]];
        [self addSubview:self.usernameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, self.userAvatar.frame.origin.y, TIME_LABEL_WIDTH, AVATAR_SIZE/2.0)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
        [self addSubview:self.timeLabel];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height, self.frame.size.width - PADDING - self.usernameLabel.frame.origin.x, self.userAvatar.frame.size.height/2.0)];
        [self.contentLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.contentLabel setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.contentLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void) decorateCellWithMessage:(Message *) message
{
    self.contentLabel.text = (message.image ? @"[image]" : message.message);
    
    NSString *nameLabel = [NSString stringWithFormat:@"@%@", message.participant.username];
    [self.usernameLabel setText:nameLabel];
    double maxWidth = self.frame.size.width - PADDING * 4 - AVATAR_SIZE - TIME_LABEL_WIDTH;
    CGSize size = [self.usernameLabel sizeThatFits:CGSizeMake(maxWidth, AVATAR_SIZE/2.0)];
    [self.usernameLabel setFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.usernameLabel.frame.origin.y, MIN(size.width, maxWidth), AVATAR_SIZE/2.0)];
    
    self.timeLabel.text = self.timeLabel.text = [UIViewHelper formatTime:message.time];
    
    [self.userAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:message.participant.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)userAvatarTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showUser:)]) {
        [self.delegate showUser:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) height
{
    return AVATAR_SIZE + PADDING * 2;
}

@end
