//
//  SquareImageViewController.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-27.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AVATAR_CROP_SIZE_WIDTH 300
#define AVATAR_CROP_SIZE_HEIGHT 300

@class CropImageViewController;
@protocol CropImageDelegate <NSObject>
- (void)addItemViewContrller:(CropImageViewController *)controller didFinishCropImage:(UIImage *)cropedImage;
@end

@interface CropImageViewController : UIViewController

@property (nonatomic, weak) id<CropImageDelegate> delegate;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic) BOOL enableImageCrop;

- (IBAction)selected:(id)sender;
- (IBAction)canceled:(id)sender;

@end

@interface CropImageMaskView : UIView {
    @private
    CGRect _cropRect;
}
- (void)setCropSize:(CGSize)size;
- (CGSize)cropSize;
- (CGRect)cropBounds;
@end
