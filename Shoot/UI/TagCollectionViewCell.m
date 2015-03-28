//
//  TagCollectionViewCell.m
//  Shoot
//
//  Created by LV on 3/25/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagCollectionViewCell.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"

@interface TagCollectionViewCell ()

@property (nonatomic, retain) Tag * tag;
@property (nonatomic, retain) UIViewController *parentController;
@property (nonatomic, retain) UIButton *cellButton;

@end


@implementation TagCollectionViewCell

static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat FONT_SIZE = 12;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cellButton = [[UIButton alloc] initWithFrame:frame];
        self.cellButton.titleLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        self.cellButton.userInteractionEnabled = NO;
        [self.cellButton setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
        [UIViewHelper applySameSizeConstraintToView:self.cellButton superView:self];
    }
    return self;
}

- (void) decorateWithTag:(Tag *)tag parentController:(UIViewController *)parentController
{
    self.tag = tag;
    self.parentController = parentController;
    [self.cellButton setImage:nil forState:UIControlStateNormal];
    [self.cellButton setTitle:tag.tag forState:UIControlStateNormal];
}

- (void) decorateTagType:(NSNumber *)tagType
{
    self.tag = nil;
    self.parentController = nil;
    [self.cellButton setTitle:nil forState:UIControlStateNormal];
    switch ([tagType integerValue]) {
        case 0:
            [self.cellButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
            break;
        case 1:
            [self.cellButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

+ (CGSize) getExpectedSizeForTag:(Tag *)tag
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE]};
    CGRect rect = [tag.tag boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, [UIFont boldSystemFontOfSize:FONT_SIZE].lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size;
}

+ (CGSize) getExpectedSizeForTypeCell
{
    return CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE);
}


@end
