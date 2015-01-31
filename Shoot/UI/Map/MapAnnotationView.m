//
//  MapAnnotationView.m
//  Shoot
//
//  Created by LV on 1/28/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "MapAnnotationView.h"
#import "MapAnnotation.h"
#import "ImageUtil.h"
#import "ColorDefinition.h"

@interface MapAnnotationView()

@property (nonatomic, retain) UILabel * label;

@end

@implementation MapAnnotationView

static const CGFloat SIZE = 25;

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //setting image to make sure annotation view have certain size
        self.image = [ImageUtil renderImage:[UIImage imageNamed:@"avatar.jpg"] atSize:CGSizeMake(SIZE, SIZE)];
        self.image = nil;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SIZE, SIZE)];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:11];
        self.backgroundColor = [ColorDefinition lightRed];
        [self addSubview:self.label];
    }
    return self;
}

- (void) decorateWithAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        MapAnnotation * mapAnnotation = (MapAnnotation *) annotation;
        self.label.text = [NSString stringWithFormat:@"%ld", [mapAnnotation imageCount]];
        CALayer * l = [self layer];
        [l setMasksToBounds:YES];
        [l setBorderColor:[ColorDefinition darkRed].CGColor];
        [l setBorderWidth:2];
        [l setCornerRadius:self.frame.size.width/2.0];
    }
}

+ (CGFloat) getAnnotationSize
{
    return SIZE;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
