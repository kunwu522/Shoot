//
//  MenuTableViewCell.m
//  Shoot
//
//  Created by LV on 1/10/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "ColorDefinition.h"

@implementation MenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 25, 25)];
        self.icon.contentMode = UIViewContentModeScaleAspectFit;
        self.icon.clipsToBounds = YES;
        [self addSubview:self.icon];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

+ (CGFloat) height
{
    return 45;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        [self setBackgroundColor:[ColorDefinition lightRed]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
