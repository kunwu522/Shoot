//
//  BlurView.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 8/10/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        return;
    }
    
    UIGraphicsBeginImageContextWithOptions(newSuperview.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [newSuperview.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake(self.frame.origin.x * img.scale, self.frame.origin.y * img.scale, self.frame.size.width * img.scale, self.frame.size.height * img.scale));
    UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    [self.imageView setImage:[cropImage applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:1 alpha:0.5]
                                                                            saturationDeltaFactor:1.8
                                                                                        maskImage:nil]];
}

@end
