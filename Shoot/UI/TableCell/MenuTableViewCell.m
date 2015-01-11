//
//  MenuTableViewCell.m
//  Shoot
//
//  Created by LV on 1/10/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
        [self addSubview:self.icon];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
