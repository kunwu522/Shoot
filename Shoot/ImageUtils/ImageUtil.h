//
//  ImageUtil.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Shoot.h"
#import "Message.h"

@interface ImageUtil : NSObject

+ (UIImage *) renderImage:(UIImage *)image atSize:(const CGSize) size;

+ (UIImage *) colorImage:(UIImage *)image color:(UIColor *)color;

+ (UIImage *)generatePhotoThumbnail:(UIImage *)image;

+ (UIImage *)imageWithCompress:(UIImage *)image;

+ (UIImage *)imageWithImage:(UIImage *)image aspectScaleFitSize:(CGSize)size;

+ (UIColor *)averageColorOfImage:(UIImage *)image;

+ (NSURL *)imageURLOfAvatar: (NSNumber *)userId;

+ (NSURL *)imageURLOfShoot: (Shoot *)shoot;

+ (NSURL *)imageURLOfMessage:(Message *)message;

+ (NSString *)imageRelatedURLWithShoot: (Shoot *)shoot;

+ (NSURL *)imageURLOfShootId:(NSNumber *)shootId userId:(NSNumber *)userId quality:(long)quality;

+ (NSURL *)imageURLOfImageId: (NSString *)imageId quality:(NSNumber *)quality;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToWidth:(CGFloat)width;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToHeight:(CGFloat)height;

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToRatio:(CGFloat)ratio;

+ (CGSize) translateSizeWithFrameSize:(CGSize)size frameSize:(CGSize)frameSize;

+ (CGSize)sizeAspectScaleFitWithSize:(CGSize)originalSize frameSize:(CGSize)frameSize;

@end
