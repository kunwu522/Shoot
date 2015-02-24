//
//  WLImageView.h
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/8/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShootImageView : UIImageView

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) NSString *imageId;
@property (nonatomic) NSInteger quality;

@property (nonatomic) BOOL isLoadingSuccessed;

@property (nonatomic) BOOL allowFullScreenDisplay;
@property (nonatomic) BOOL shouldDownloadForFullScreenDisplay;
@property (nonatomic) BOOL changeAlphaValueDuringAnimation;

- (void)setImageURL:(NSURL *)imageURL isAvatar:(BOOL)isAvatar;
- (void)setImageURL:(NSURL *)imageURL animate:(BOOL)animate;
- (void)displayFullScreen;

@end
