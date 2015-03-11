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
#import "Shoot.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewHelper.h"
#import "GeoDao.h"

@interface ShootDetailedTableViewCell ()
@property (retain, nonatomic) ShootImageView *userAvatar;
@property (retain, nonatomic) UILabel *username;
@property (retain, nonatomic) UILabel *imageTitle;
@property (retain, nonatomic) UIImageView *imageDisplayView;
@property (retain, nonatomic) UIButton * timeLabel;
@property (retain, nonatomic) UIButton * location;
@property (nonatomic, retain) UIButton * like;
@property (nonatomic, retain) UIButton * have;
@property (nonatomic, retain) UIButton * want;
@property (nonatomic, retain) UIButton * likeCount;
@property (nonatomic, retain) UIButton * haveCount;
@property (nonatomic, retain) UIButton * wantCount;
@property (nonatomic, retain) UIButton * comment;
@property (nonatomic, retain) UIButton * otherUserPosts;
@property (retain, nonatomic) UIImageView * marker;

@property (nonatomic) NSInteger selectedButton;

@end

@implementation ShootDetailedTableViewCell

static const CGFloat PADDING = 10;
static const CGFloat AVATAR_SIZE = 35;
static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const CGFloat IMAGE_TITLE_HEIGHT = 30;
static const CGFloat COMMENT_BUTTON_HEIGHT = 30;
static const CGFloat TIME_LABEL_WIDTH = 60;
static const CGFloat MARKER_SIZE = 60;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userAvatar = [[ShootImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatar.clipsToBounds = YES;
        CALayer * l = [self.userAvatar layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.userAvatar.frame.size.width/2.0];
        [self addSubview:self.userAvatar];
        
        self.timeLabel = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - PADDING - TIME_LABEL_WIDTH, self.userAvatar.frame.origin.y, TIME_LABEL_WIDTH, AVATAR_SIZE/2.0)];
        [self.timeLabel setTitle:@" 1d" forState:UIControlStateNormal];
        [self.timeLabel setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"time"] atSize:CGSizeMake(10, 10)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self.timeLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.timeLabel.titleLabel.font = [UIFont boldSystemFontOfSize:9.0];
        self.timeLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.timeLabel];
        
        CGFloat userNameX = self.userAvatar.frame.origin.x + self.userAvatar.frame.size.width + PADDING;
        self.username = [[UILabel alloc] initWithFrame:CGRectMake(userNameX, self.userAvatar.frame.origin.y, self.timeLabel.frame.origin.x - userNameX - PADDING, self.userAvatar.frame.size.height/2.0)];
        self.username.font = [UIFont boldSystemFontOfSize:12];
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
        
        self.imageTitle = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.userAvatar.frame.origin.y + self.userAvatar.frame.size.height, self.frame.size.width - PADDING * 4, IMAGE_TITLE_HEIGHT)];
        self.imageTitle.font = [UIFont boldSystemFontOfSize:12];
        self.imageTitle.textColor = [ColorDefinition darkRed];
        [self addSubview:self.imageTitle];
        
        CGFloat imageViewSize = self.frame.size.width - PADDING;
        self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING/2.0, self.imageTitle.frame.origin.y + self.imageTitle.frame.size.height, imageViewSize, imageViewSize)];
        self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageDisplayView.clipsToBounds = YES;
        [self addSubview:self.imageDisplayView];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnImage)];
        [singleTap setNumberOfTapsRequired:1];
        [self.imageDisplayView addGestureRecognizer:singleTap];
        [self.imageDisplayView setUserInteractionEnabled:TRUE];
        
        CGFloat buttonWidth = (self.frame.size.width - PADDING * 2)/3.0;
        CGFloat countLabelWidth = buttonWidth - BUTTON_SIZE - PADDING * 2;
        
        self.like = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth/2.0 - BUTTON_SIZE/2.0, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
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
        
        self.comment = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, self.like.frame.origin.y + self.like.frame.size.height + PADDING, (self.frame.size.width - PADDING * 2)/2.0, COMMENT_BUTTON_HEIGHT)];
        self.comment.tag = SHOOT_DETAIL_CELL_COMMENTS_BUTTON_TAG;
        [self.comment setTitle:@"Comments" forState:UIControlStateNormal];
        [self.comment addTarget:self action:@selector(commentViewChanged:)forControlEvents:UIControlEventTouchDown];
        self.comment.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [self.comment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self addSubview:self.comment];
        
        self.otherUserPosts = [[UIButton alloc] initWithFrame:CGRectMake(self.comment.frame.size.width + self.comment.frame.origin.x, self.comment.frame.origin.y, (self.frame.size.width - PADDING * 2)/2.0, COMMENT_BUTTON_HEIGHT)];
        self.otherUserPosts.tag = SHOOT_DETAIL_CELL_OTHER_USER_POSTS_BUTTON_TAG;
        [self.otherUserPosts setTitle:@"Posts from others" forState:UIControlStateNormal];
        [self.otherUserPosts addTarget:self action:@selector(commentViewChanged:)forControlEvents:UIControlEventTouchDown];
        self.otherUserPosts.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [self.otherUserPosts setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:self.otherUserPosts];
        
        self.selectedButton = SHOOT_DETAIL_CELL_COMMENTS_BUTTON_TAG;
        
        UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.comment.frame.origin.y, self.frame.size.width - PADDING * 2, 0.3)];
        topLine.backgroundColor = [UIColor grayColor];
        [self addSubview:topLine];
        
        UILabel * middleLine = [[UILabel alloc] initWithFrame:CGRectMake(self.comment.frame.origin.x + self.comment.frame.size.width, self.comment.frame.origin.y + 4, 0.3, self.comment.frame.size.height - 8)];
        middleLine.backgroundColor = [UIColor grayColor];
        [self addSubview:middleLine];
        
        UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.comment.frame.origin.y + self.comment.frame.size.height, self.frame.size.width - PADDING * 2, 0.3)];
        bottomLine.backgroundColor = [UIColor grayColor];
        [self addSubview:bottomLine];
        
        self.marker = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MARKER_SIZE, MARKER_SIZE)];
        self.marker.backgroundColor = [UIColor clearColor];
        self.marker.layer.borderWidth = 2;
        self.marker.layer.borderColor = [ColorDefinition lightRed].CGColor;
        self.marker.layer.cornerRadius = MARKER_SIZE/2.0;
        self.marker.hidden = true;
        self.marker.clipsToBounds = YES;
        
        [self addSubview:self.marker];
    }
    return self;
}

- (void) decorateWith:(Shoot *)shoot
{
    [self.userAvatar sd_setImageWithURL:[ImageUtil imageURLOfAvatar:shoot.user.userID] placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:SDWebImageHandleCookies];
    self.username.text = shoot.user.username;
    CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:[shoot.latitude doubleValue] longitude:[shoot.longitude doubleValue]];
    [[GeoDao sharedManager].geocoder reverseGeocodeLocation:coordinate completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = placemarks[0];
            [self.location setTitle:placemark.name forState:UIControlStateNormal];
        }
    }];
    self.imageTitle.text = shoot.content;
    [self.timeLabel setTitle:[NSString stringWithFormat:@" %@", [UIViewHelper formatTime:shoot.time]] forState:UIControlStateNormal];
    [self.imageDisplayView sd_setImageWithURL:[ImageUtil imageURLOfShoot:shoot] placeholderImage:[UIImage imageNamed:@"Oops"] options:SDWebImageHandleCookies];
    [self.likeCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.like_count]] forState:UIControlStateNormal];
    [self.wantCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.want_count]] forState:UIControlStateNormal];
    [self.haveCount setTitle:[NSString stringWithFormat:@"%@", [UIViewHelper getCountString:shoot.have_count]] forState:UIControlStateNormal];
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

- (void) commentViewChanged:(UIButton *)sender
{
    UIButton *curSelectedButton = (UIButton *)[self viewWithTag:self.selectedButton];
    UIButton *newSelectedButton = (UIButton *)[self viewWithTag:sender.tag];
    [curSelectedButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [newSelectedButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(viewSwitchedFrom:to:)]) {
        [self.delegate viewSwitchedFrom:self.selectedButton to:sender.tag];
    }
    self.selectedButton = sender.tag;
}

- (void) markImageAtX:(CGFloat)x y:(CGFloat)y
{
    [self.marker setCenter:CGPointMake(self.imageDisplayView.frame.origin.x + self.imageDisplayView.frame.size.width * x, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height * y)];
    self.marker.hidden = false;
    
    CGFloat internalX = self.imageDisplayView.image.size.width * x;
    CGFloat internalY = self.imageDisplayView.image.size.height * y;
    
    CGFloat size = MARKER_SIZE/self.imageDisplayView.frame.size.width * self.imageDisplayView.image.size.width / 1.5;
    
    CGImageRef subImage = CGImageCreateWithImageInRect(self.imageDisplayView.image.CGImage, CGRectMake(internalX - size/2.0, internalY - size/2.0, size, size));
    self.marker.image = [UIImage imageWithCGImage:subImage];
}

- (void)tappedOnImage
{
    [self hideMarker];
}

- (void) hideMarker
{
    self.marker.hidden = true;
}

@end
