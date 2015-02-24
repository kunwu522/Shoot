//
//  WLImageView.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ShootImageView.h"
#import "ShootImageMaxDisplayView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ShootImageView()

@property (nonatomic, retain) ShootImageMaxDisplayView *maxDisplayView;

@end

@implementation ShootImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (void) initVariables
{
    self.contentMode = UIViewContentModeScaleAspectFit;
    _allowFullScreenDisplay = NO;
    _changeAlphaValueDuringAnimation = YES;
    _shouldDownloadForFullScreenDisplay = YES;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL isAvatar:(BOOL)isAvatar
{
    _imageURL = imageURL;
    [self getImageIdWithURL:imageURL];
    
    if (isAvatar) {
        [self sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"avatar.jpg"] options:(SDWebImageHandleCookies | SDWebImageRefreshCached)];
    } else {
        [self sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageHandleCookies
        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                NSLog(@"Loading image failed, url: %@, error: %@.", imageURL.absoluteString, error);
                self.image = [UIImage imageNamed:@"Oops.png"];
                self.isLoadingSuccessed = NO;
            } else {
                self.isLoadingSuccessed = YES;
            }
        }];
    }
}

- (void)getImageIdWithURL:(NSURL *)imageURL
{
    NSArray *str = [imageURL.absoluteString componentsSeparatedByString:@"/"];
    if (str && str.count > 0) {
        NSString *imageId = [str objectAtIndex:(str.count - 1)];
        if ([imageId containsString:@"?"]) {
            _imageId = [[imageId componentsSeparatedByString:@"?"] objectAtIndex:0];
        } else {
            _imageId = imageId;
        }
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    [self setImageURL:imageURL isAvatar:NO];
}

- (void)setImageURL:(NSURL *)imageURL animate:(BOOL)animate
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView setFrame:CGRectMake((self.frame.size.width - 40) / 2, (self.frame.size.height - 40) / 2, 40, 40)];
    [indicatorView isAnimating];
    [self addSubview:indicatorView];
    [self bringSubviewToFront:indicatorView];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:(SDWebImageHandleCookies | SDWebImageCacheMemoryOnly)
    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (expectedSize == -1) {
            [indicatorView startAnimating];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image && finished) {
            self.image = image;
            self.isLoadingSuccessed = YES;
        } else {
            NSLog(@"Max Image View loading Image failed. image url: %@, error: %@", imageURL, error);
            self.isLoadingSuccessed = NO;
        }
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    }];
}

- (void)setAllowFullScreenDisplay:(BOOL)allowFullScreenDisplay
{
    _allowFullScreenDisplay = allowFullScreenDisplay;
    if (_allowFullScreenDisplay) {
        _maxDisplayView = [[ShootImageMaxDisplayView alloc]initWithImageView:self];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)]];
    } else {
        _maxDisplayView = nil;
    }
}

- (void)displayFullScreen
{
    if (!_imageURL && _shouldDownloadForFullScreenDisplay) {
        return;
    }
    _maxDisplayView = [[ShootImageMaxDisplayView alloc] initWithImageView:self];
    _maxDisplayView.changeAlphaValueDuringAnimation = _changeAlphaValueDuringAnimation;
    _maxDisplayView.shouldDownloadForFullScreenDisplay = _shouldDownloadForFullScreenDisplay;
    self.userInteractionEnabled = YES;
    [(UIView *)[UIApplication sharedApplication].windows.lastObject addSubview:_maxDisplayView];
    [_maxDisplayView display:self];
}

- (void)handleTap:(UIGestureRecognizer *)gesture
{
    if (_allowFullScreenDisplay && !self.isLoadingSuccessed) {
        [(UIView *)[UIApplication sharedApplication].windows.lastObject addSubview:_maxDisplayView];
        [_maxDisplayView display:self];
    }
}

@end
