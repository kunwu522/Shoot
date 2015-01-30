//
//  ImageDetailedCollectionViewCell.m
//  Shoot
//
//  Created by LV on 1/20/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ImageDetailedCollectionViewCell.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"

@implementation ImageDetailedCollectionViewCell

static CGFloat PADDING = 5;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 30)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        
        UILabel * time = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50 - PADDING * 2, PADDING * 2, 50, 15)];
        time.font = [UIFont boldSystemFontOfSize:10];
        time.text = @"Jan 10";
        time.textAlignment = NSTextAlignmentCenter;
        time.textColor = [UIColor darkGrayColor];

        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = time.frame;
        CALayer * l = [visualEffectView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:time.frame.size.height/2.0];
        [self addSubview:visualEffectView];
        [self addSubview:time];
        
        UIButton * like = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width/3.0, 30)];
        [like setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"like-icon"] color:[UIColor grayColor]] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [like setTitle:@" 13M" forState:UIControlStateNormal];
        [like setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        like.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:like];
        
        UIButton * want = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3.0, self.frame.size.height - 30, self.frame.size.width/3.0, 30)];
        [want setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"want-icon"] color:[UIColor grayColor]] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [want setTitle:@" 105K" forState:UIControlStateNormal];
        [want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        want.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:want];
        
        UIButton * have = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 2.0 / 3.0, self.frame.size.height - 30, self.frame.size.width/3.0, 30)];
        [have setImage:[ImageUtil renderImage:[ImageUtil colorImage:[UIImage imageNamed:@"have-icon"] color:[UIColor grayColor]] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
        [have setTitle:@" 35K" forState:UIControlStateNormal];
        [have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        have.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self addSubview:have];
        
    }
    return self;
}


@end
