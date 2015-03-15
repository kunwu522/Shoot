//
//  TagTableViewCell.m
//  Shoot
//
//  Created by LV on 3/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagTableViewCell.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"

@interface TagTableViewCell()

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *haveCount;
@property (nonatomic, retain) UIButton *wantCount;

@end

@implementation TagTableViewCell

static CGFloat HAVE_COUNT_BUTTON_WIDTH = 50;
static CGFloat WANT_COUNT_BUTTON_WIDTH = 50;
static CGFloat PADDING = 10;
static CGFloat BUTTON_ICON_SIZE = 15;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - HAVE_COUNT_BUTTON_WIDTH, 0, HAVE_COUNT_BUTTON_WIDTH, self.frame.size.height)];
        self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.haveCount setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        self.haveCount.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.haveCount setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
        [self.haveCount setTitle:@" 0" forState:UIControlStateNormal];
        [self addSubview:self.haveCount];
        
        self.wantCount = [[UIButton alloc] initWithFrame:CGRectMake(self.haveCount.frame.origin.x - WANT_COUNT_BUTTON_WIDTH, 0, WANT_COUNT_BUTTON_WIDTH, self.frame.size.height)];
        self.wantCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.wantCount setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        self.wantCount.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.wantCount setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
        [self.wantCount setTitle:@" 0" forState:UIControlStateNormal];
        [self addSubview:self.wantCount];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, 0, self.wantCount.frame.origin.x - PADDING * 2, self.frame.size.height)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        self.titleLabel.textColor = [ColorDefinition darkRed];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    return self;
}

- (void) decorateWithTag:(Tag *)tag
{
    self.titleLabel.text = [NSString stringWithFormat:@"#%@", tag.tag];
    [self.haveCount setTitle:[NSString stringWithFormat:@" %@", tag.have_count] forState:UIControlStateNormal];
    [self.wantCount setTitle:[NSString stringWithFormat:@" %@", tag.want_count] forState:UIControlStateNormal];
}

+ (CGFloat) height
{
    return 40;
}

@end
