//
//  ImageCollectionViewCell.m
//  Shoot
//
//  Created by LV on 1/19/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        // initialize
        [self addSubview:self.imageView];
        
        NSLayoutConstraint *width =[NSLayoutConstraint
                                    constraintWithItem:self.imageView
                                    attribute:NSLayoutAttributeWidth
                                    relatedBy:0
                                    toItem:self
                                    attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                    constant:0];
        NSLayoutConstraint *height =[NSLayoutConstraint
                                     constraintWithItem:self.imageView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:0
                                     toItem:self
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:1.0
                                     constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.imageView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.imageView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.f];
        [self addConstraint:width];
        [self addConstraint:height];
        [self addConstraint:top];
        [self addConstraint:leading];
    }
    return self;
}

@end
