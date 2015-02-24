//
//  WeedImageMaxDisplayView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ShootImageMaxDisplayView.h"
#import "ImageUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShootImageMaxDisplayView() <UIGestureRecognizerDelegate> {
    CGFloat _lastRotation;
    UIDeviceOrientation _lastOrientation;
}

@end

@implementation ShootImageMaxDisplayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _backgroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.0;
        [self addSubview:_backgroundView];
        
        _originalImageView = imageView;
        
        _imageView = [[ShootImageView alloc]initWithFrame:[self originalImageViewRect]];
        _imageView.image = imageView.image;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        self.userInteractionEnabled = YES;
        _changeAlphaValueDuringAnimation = YES;
        _shouldDownloadForFullScreenDisplay = YES;
    }
    
    return self;
}

- (void)display:(ShootImageView *)imageView
{
    if (!imageView) {
        return;
    }
    
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOrentation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    _lastOrientation = [[UIDevice currentDevice] orientation];
    
    self.frame = [[UIApplication sharedApplication].windows.lastObject frame];
    _backgroundView.frame = [[UIApplication sharedApplication].windows.lastObject frame];
    
    _originalImageView = imageView;
    _imageView.frame = [self originalImageViewRect];
    _imageView.image = imageView.image;
    if (_changeAlphaValueDuringAnimation) {
        [_imageView setAlpha:0.0];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = [self imageFrame];
        [_backgroundView setAlpha:0.9];
        [_imageView setAlpha:1.0];
    } completion:^(BOOL finished) {
        if (finished && _shouldDownloadForFullScreenDisplay) {
            if (imageView.imageId) {
                NSURL *imageURL = [ImageUtil imageURLOfImageId:imageView.imageId quality:[NSNumber numberWithInteger:100]];
                [_imageView setImageURL:imageURL animate:YES];
            }
        }
    }];
}

#pragma Gesture recognizers

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self rotateImageView:UIDeviceOrientationPortrait];
        _imageView.frame = [self originalImageViewRect];
        [_backgroundView setAlpha:0.0];
        if (_changeAlphaValueDuringAnimation) {
            [_imageView setAlpha:0.0];
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)handleOrentation:(NSNotification *)rotationNotification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    [self rotateImageView:orientation];
}

- (void)rotateImageView:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationFaceUp
        || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    int count = [self getCountWithOrientation:orientation];
    int lastCount = [self getCountWithOrientation:_lastOrientation];
    
    CGFloat angle = (count - lastCount) * M_PI_2;
    
    CGAffineTransform currentTransform = _imageView.transform;
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.bounds = [self imageSizeWithOrientation:orientation];
        _imageView.transform = CGAffineTransformRotate(currentTransform, angle);
    }];
    
    _lastOrientation = orientation;

}

- (int)getCountWithOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            return 1;
            break;
        case UIDeviceOrientationLandscapeRight:
            return -1;
            break;
        case UIDeviceOrientationPortrait:
            return 0;
            
        default:
            return 0;
            break;
    }
}

#pragma private

- (CGRect)originalImageViewRect
{
    CGPoint position = [[UIApplication sharedApplication].windows.lastObject convertPoint:CGPointMake(0, 0) fromView:_originalImageView];
    return  CGRectMake(position.x, position.y, _originalImageView.bounds.size.width, _originalImageView.bounds.size.height);
}

- (CGRect)imageFrame
{
    CGSize size = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    CGFloat ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    
    CGFloat width = imageSize.width * ratio;
    CGFloat heigth = imageSize.height * ratio;
    
    return CGRectMake(self.bounds.origin.x, (self.bounds.size.height - heigth) / 2, width, heigth);
}

- (CGRect)imageSizeWithOrientation:(UIDeviceOrientation)orientation
{
    CGSize size = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    CGFloat ratio = 0.0;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        ratio = fmin(size.height / imageSize.width, size.width / imageSize.height);
    } else {
        ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    }
    
    CGFloat width = imageSize.width * ratio;
    CGFloat heigth = imageSize.height * ratio;
    
    return CGRectMake(self.bounds.origin.x, (self.bounds.size.height - heigth) / 2, width, heigth);
}

- (CGSize)imageSizeImageSize:(CGSize)imageSize orientation:(UIDeviceOrientation)orientation
{
    CGSize size = self.bounds.size;
    
    CGFloat ratio = 0.0;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        ratio = fmin(size.height / imageSize.width, size.width / imageSize.height);
    } else {
        ratio = fminf(size.height / imageSize.height, size.width / imageSize.width);
    }
    
    CGFloat width = imageSize.width * ratio;
    CGFloat heigth = imageSize.height * ratio;
    
    return CGSizeMake(width, heigth);
}

@end
