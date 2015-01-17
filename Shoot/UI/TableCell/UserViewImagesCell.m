//
//  UserViewImagesCell.m
//  Shoot
//
//  Created by LV on 1/16/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserViewImagesCell.h"

@implementation UserViewImagesCell

static CGFloat PADDING = 5;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat imageSize = (self.frame.size.width - PADDING * 4)/3.0;
        UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, imageSize, imageSize)];
        image1.contentMode = UIViewContentModeScaleAspectFill;
        image1.clipsToBounds = YES;
        image1.image = [UIImage imageNamed:@"image1.jpg"];
        [self addSubview:image1];
        
        UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 2 + imageSize, image1.frame.origin.y, imageSize, imageSize)];
        image2.contentMode = UIViewContentModeScaleAspectFill;
        image2.clipsToBounds = YES;
        image2.image = [UIImage imageNamed:@"image2.jpg"];
        [self addSubview:image2];
        
        UIImageView *image3 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 3 + imageSize * 2, image1.frame.origin.y, imageSize, imageSize)];
        image3.contentMode = UIViewContentModeScaleAspectFill;
        image3.clipsToBounds = YES;
        image3.image = [UIImage imageNamed:@"image3.jpg"];
        [self addSubview:image3];
        
        UIImageView *image4 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, image1.frame.origin.y + image1.frame.size.height + PADDING, imageSize, imageSize)];
        image4.contentMode = UIViewContentModeScaleAspectFill;
        image4.clipsToBounds = YES;
        image4.image = [UIImage imageNamed:@"image4.jpg"];
        [self addSubview:image4];
        
        UIImageView *image5 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 2 + imageSize, image4.frame.origin.y, imageSize, imageSize)];
        image5.contentMode = UIViewContentModeScaleAspectFill;
        image5.clipsToBounds = YES;
        image5.image = [UIImage imageNamed:@"image5.jpg"];
        [self addSubview:image5];
    }
    return self;
}

@end
