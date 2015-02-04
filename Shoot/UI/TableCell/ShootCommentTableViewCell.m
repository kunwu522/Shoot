//
//  ShootCommentTableViewCell.m
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ShootCommentTableViewCell.h"
#import "ImageUtil.h"

@implementation ShootCommentTableViewCell

static const CGFloat PADDING = 10;
static const CGFloat AVATAR_SIZE = 25;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *anonymous1 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        anonymous1.image = [UIImage imageNamed:@"avatar.jpg"];
        anonymous1.layer.cornerRadius = anonymous1.frame.size.width/2.0;
        CALayer *l = [anonymous1 layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:anonymous1.frame.size.width/2.0];
        [self addSubview:anonymous1];
        
        CGFloat comment1X = anonymous1.frame.size.width + anonymous1.frame.origin.x + PADDING;
        
        UILabel *comment1 = [[UILabel alloc] initWithFrame:CGRectMake(comment1X, anonymous1.frame.origin.y, self.frame.size.width - PADDING - 55 - comment1X, 25)];
        comment1.text = @"Some anonymous comment. Another anonymous comment.";
        comment1.font = [UIFont systemFontOfSize:12];
        comment1.textColor = [UIColor darkGrayColor];
        comment1.textAlignment = NSTextAlignmentLeft;
        [self addSubview:comment1];
        
        UIButton *comment1Like = [[UIButton alloc] initWithFrame:CGRectMake(comment1.frame.origin.x + comment1.frame.size.width, comment1.frame.origin.y, 55, comment1.frame.size.height)];
        [comment1Like setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
        [comment1Like setTitle:@"131K" forState:UIControlStateNormal];
        [comment1Like setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        comment1Like.titleLabel.font = [UIFont boldSystemFontOfSize:9];
        [comment1Like setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        CGSize size = [[comment1Like titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName:comment1Like.titleLabel.font}];
        [comment1Like setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -size.width)];
        [comment1Like setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, comment1Like.imageView.image.size.width + 3)];
        [self addSubview:comment1Like];
    }
    return self;
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
