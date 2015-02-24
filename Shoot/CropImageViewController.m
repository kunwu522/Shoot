//
//  SquareImageViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-27.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "CropImageViewController.h"
#import "ImageUtil.h"

@interface CropImageViewController () <UIGestureRecognizerDelegate> {

}
@property (strong, nonatomic) UIButton *btnSelect;
@property (strong, nonatomic) UIButton *btnCancel;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinch;
@property (nonatomic, weak) UIPanGestureRecognizer   *pan;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) CropImageMaskView *maskView;

//For imageView animation
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) CGRect originalFrame;

@end

@implementation CropImageViewController

static const double TOOLBAR_HEIGHT = 70;

@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void) viewDidLoad
{
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.maskView = [[CropImageMaskView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - TOOLBAR_HEIGHT)];
    [self.maskView setBackgroundColor:[UIColor clearColor]];
    [self.maskView setUserInteractionEnabled:NO];
    if (self.enableImageCrop) {
        [self.maskView setCropSize:CGSizeMake(AVATAR_CROP_SIZE_WIDTH, AVATAR_CROP_SIZE_HEIGHT)];
    } else {
        [self.maskView setCropSize:self.maskView.frame.size];
        self.maskView.hidden = true;
    }
    [self.view addSubview:self.maskView];
    
    CGSize size;
    if (self.enableImageCrop) {
        size = [self calculateImageViewSizeWithImage:self.image scaledToSize:CGSizeMake(AVATAR_CROP_SIZE_WIDTH + 5, AVATAR_CROP_SIZE_HEIGHT + 5)];
    } else {
        double maxHeight = self.view.frame.size.height - TOOLBAR_HEIGHT;
        double maxWidth = self.view.frame.size.width;
        double effectiveHeight = self.image.size.height;
        double effectiveWidth = self.image.size.width;
        if (effectiveWidth > maxWidth || effectiveHeight > maxHeight) {
            if (effectiveWidth > maxWidth) {
                effectiveHeight = maxWidth/effectiveWidth * effectiveHeight;
                effectiveWidth = maxWidth;
            }
            if (effectiveHeight > maxHeight) {
                effectiveWidth = maxHeight/effectiveHeight * effectiveWidth;
                effectiveHeight = maxHeight;
            }
        }
        size = [self calculateImageViewSizeWithImage:self.image scaledToSize:CGSizeMake(effectiveWidth, effectiveHeight)];
    }
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.maskView.cropBounds.origin.x, self.maskView.cropBounds.origin.y, size.width, size.height)];
    //adjust imageView position
    self.imageView.center = self.maskView.center;
    // Set image to imageView
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.maskView];
    
    self.btnSelect = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width/2.0, TOOLBAR_HEIGHT)];
    [self.btnSelect setTitle:@"Select" forState:UIControlStateNormal];
    [self.btnSelect addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchDown];
    [self.btnSelect setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.btnSelect];
    self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width/2.0, TOOLBAR_HEIGHT)];
    [self.btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(canceled:) forControlEvents:UIControlEventTouchDown];
    [self.btnCancel setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.btnCancel];
    
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
    self.pan = pan;
    
    // create pan gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.imageView addGestureRecognizer:pinch];
    self.pinch = pinch;
}

- (void) setImage:(UIImage *)newImage
{
    image = [ImageUtil generatePhotoThumbnail:newImage];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationController].navigationBarHidden = true;
    [self navigationController].hidesBarsOnTap = true;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self navigationController].navigationBarHidden = false;
    [self navigationController].hidesBarsOnTap = false;
}

- (CGSize)calculateImageViewSizeWithImage:(UIImage*)originalImage
              scaledToSize:(CGSize)size;
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat ratio = width / height;
    
    CGSize newSize;
    
    if (width > height) {
        newSize = CGSizeMake(size.height * ratio, size.height);
    } else {
        newSize = CGSizeMake(size.width, size.width / ratio);
    }
    
    return newSize;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Gesture recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    
    UIView *oldImage = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = gesture.view.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = [gesture translationInView: oldImage.superview];
        CGPoint c = oldImage.center;
        if (!self.enableImageCrop) {
            double frameRatio = self.maskView.cropBounds.size.width/self.maskView.cropBounds.size.height;
            double imageFrameRatio = self.imageView.frame.size.width/self.imageView.frame.size.height;
            if (frameRatio > imageFrameRatio) {
                c.y += delta.y;
            } else {
                c.x += delta.x;
            }
        } else {
            c.y += delta.y;
            c.x += delta.x;
        }
        oldImage.center = c;
        [gesture setTranslation: CGPointZero inView: oldImage.superview];
        if ([self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            self.originalCenter = oldImage.center;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (![self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            [UIView animateWithDuration:0.5 animations:^{
                gesture.view.center = self.originalCenter;
            }];
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalFrame = gesture.view.frame;
    } else if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat currentScale = gesture.view.frame.size.width / gesture.view.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;
        gesture.view.transform = CGAffineTransformMakeScale(newScale, newScale);
        gesture.scale = 1;
        if ([self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            self.originalFrame = gesture.view.frame;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (![self isFillFrame:self.maskView.cropBounds currentImageFrame:gesture.view.frame]) {
            [UIView animateWithDuration:0.5 animations:^{
                self.imageView.frame = self.originalFrame;
            }];
        }
    }
    
}

- (BOOL)isFillFrame:(CGRect)frame currentImageFrame:(CGRect)currentFrame
{
    CGFloat boundA = currentFrame.origin.x;
    CGFloat boundB = currentFrame.origin.y;
    CGFloat boundC = currentFrame.origin.x + currentFrame.size.width;
    CGFloat boundD = currentFrame.origin.y + currentFrame.size.height;
    
    if (self.enableImageCrop) {
        if (boundA > frame.origin.x
            || boundB > frame.origin.y
            || boundC < (frame.origin.x + frame.size.width)
            || boundD < (frame.origin.y + frame.size.height)) {
            return NO;
        }
        return YES;
    } else {
        double frameRatio = frame.size.width/frame.size.height;
        double imageFrameRatio = currentFrame.size.width/currentFrame.size.height;
        if (frameRatio > imageFrameRatio) {
            if (boundA < frame.origin.x
                || boundC > (frame.origin.x + frame.size.width)
                || boundB > frame.origin.y
                || boundD < (frame.origin.y + frame.size.height)) {
                return NO;
            }
            return YES;
        } else {
            if (boundB < frame.origin.y
                || boundD > (frame.origin.y + frame.size.height)
                || boundA > frame.origin.x
                || boundC < (frame.origin.x + frame.size.width)) {
                return NO;
            }
            return YES;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.pan && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
    {
        return YES;
    }
    
    return NO;
}

- (void)selected:(id)sender
{
    if (self.enableImageCrop) {
        CGRect frameRect = self.imageView.frame;
        double ratio = self.image.size.width / frameRect.size.width;
        CGRect rect = CGRectMake((self.maskView.cropBounds.origin.x - frameRect.origin.x) * ratio, (self.maskView.cropBounds.origin.y - frameRect.origin.y) * ratio, self.maskView.cropBounds.size.width * ratio, self.maskView.cropBounds.size.height * ratio);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.image CGImage], rect);
        UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
        [self.delegate addItemViewContrller:self didFinishCropImage:cropImage];
    } else {
        [self.delegate addItemViewContrller:self didFinishCropImage:self.image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)canceled:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

@implementation CropImageMaskView

- (void)setCropSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)cropSize {
    return _cropRect.size;
}

- (CGRect)cropBounds {
    return _cropRect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, .4);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, 2.0f);
    
    CGContextClearRect(ctx, _cropRect);
}

@end
