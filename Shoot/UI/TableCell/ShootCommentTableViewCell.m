//
//  ShootCommentTableViewCell.m
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootCommentTableViewCell.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"
#import "AppDelegate.h"
#import "ShootImageView.h"

@interface ShootCommentTableViewCell ()

@property (nonatomic, retain) ShootImageView *anonymous;
@property (nonatomic, retain) UILabel *comment;
@property (nonatomic, retain) UIButton *commentLike;

@end

@implementation ShootCommentTableViewCell

static const CGFloat PADDING = 10;
static const CGFloat AVATAR_SIZE = 25;
static const CGFloat LIKE_BUTTON_WIDTH = 60;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.anonymous = [[ShootImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.anonymous.image = [UIImage imageNamed:@"avatar.jpg"];
        self.anonymous.layer.cornerRadius = self.anonymous.frame.size.width/2.0;
        CALayer *l = [self.anonymous layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.anonymous.frame.size.width/2.0];
        [self addSubview:self.anonymous];
        
        CGFloat commentX = self.anonymous.frame.size.width + self.anonymous.frame.origin.x + PADDING;
        
        self.comment = [[UILabel alloc] initWithFrame:CGRectMake(commentX, self.anonymous.frame.origin.y, self.frame.size.width - PADDING - LIKE_BUTTON_WIDTH - commentX, 25)];
        
        self.comment.font = [UIFont systemFontOfSize:12];
        self.comment.textColor = [UIColor darkGrayColor];
        self.comment.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.comment];
        
        self.commentLike = [[UIButton alloc] initWithFrame:CGRectMake(self.comment.frame.origin.x + self.comment.frame.size.width, self.comment.frame.origin.y, LIKE_BUTTON_WIDTH, self.comment.frame.size.height)];
        [self.commentLike setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.commentLike.titleLabel.font = [UIFont boldSystemFontOfSize:9];
        [self.commentLike setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.commentLike.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.commentLike];
    }
    return self;
}

- (void) decorateWithComment:(Comment *)commentObj
{
    self.comment.text = commentObj.content;
    [self.commentLike setTitle:[NSString stringWithFormat:@" %@", [UIViewHelper getCountString:commentObj.like_count]] forState:UIControlStateNormal];
    if ([commentObj.if_cur_user_like_it integerValue] == 0) {
        [self.commentLike setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    } else {
        [self.commentLike setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[ColorDefinition lightRed]] forState:UIControlStateNormal];
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.currentUserID isEqualToNumber:commentObj.user.userID]) {
        [self.anonymous setImageURL:[ImageUtil imageURLOfAvatar:appDelegate.currentUserID] isAvatar:YES];
    } else {
        [self.anonymous setImage:[UIImage imageNamed:@"avatar.jpg"]];
    }
}

+ (CGFloat) height
{
    return PADDING * 2 + AVATAR_SIZE;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
