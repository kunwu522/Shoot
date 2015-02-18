//
//  ImageUtil.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/7/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ImageUtil.h"
#import "User.h"
#import "AppDelegate.h"

#define MAX_UPLOAD_IMAGE_SIZE 2 * 1024 * 1024
#define MAX_IMAGE_WIDTH 1500
#define MAX_IMAGE_HEIGHT 1500

@implementation ImageUtil

+ (UIImage *) renderImage:(UIImage *)image atSize:(const CGSize) size
{    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *) colorImage:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return coloredImg;
}

+ (UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    //int kMaxResolution = 320;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    /*if (width > kMaxResolution || height > kMaxResolution)
     {
     CGFloat ratio = width/height;
     if (ratio > 1)
     {
     bounds.size.width = kMaxResolution;
     bounds.size.height = bounds.size.width / ratio;
     }
     else
     {
     bounds.size.height = kMaxResolution;
     bounds.size.width = bounds.size.height * ratio;
     }
     } */
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
    
}

+ (UIImage *)imageWithCompress:(UIImage *)image
{
    //Resize image
    if (image.size.width > MAX_IMAGE_WIDTH || image.size.height > MAX_IMAGE_HEIGHT) {
        image = [ImageUtil imageWithImage:image aspectScaleFitSize:CGSizeMake(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)];
        NSLog(@"after scale, image size: %f-%f", image.size.width, image.size.height);
    }
    
    //Compress image
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while (imageData.length > MAX_UPLOAD_IMAGE_SIZE && compression > maxCompression) {
        compression -=0.1f;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    NSLog(@"Image length: %ld", (unsigned long)imageData.length);
    
    if (imageData.length > MAX_UPLOAD_IMAGE_SIZE) {
        return nil;
    }
    return [[UIImage alloc] initWithData:imageData];
}

+ (UIImage *)imageWithImage:(UIImage *)image aspectScaleFitSize:(CGSize)size
{
    CGFloat ratio = fminf(size.height / image.size.height, size.width / image.size.width);
    
    CGFloat width = image.size.width * ratio;
    CGFloat heigth = image.size.height * ratio;
    
    return [ImageUtil imageWithImage:image toSize:CGSizeMake(width, heigth)];
}

+ (UIImage *)imageWithImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIColor *)averageColorOfImage:(UIImage *)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

+ (NSURL *)imageURLOfAvatar:(NSNumber *)userId
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/avatar_%@", [ImageUtil getBaseUrl], userId]];
}

+ (NSURL *)imageURLOfShoot:(Shoot *)shoot
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/shoot_%@_%@", [ImageUtil getBaseUrl], shoot.user.id, shoot.id]];
}

+ (NSURL *)imageURLOfMessage:(Message *)message
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/message_%@_%@?quality=100", [ImageUtil getBaseUrl], message.sender_id, message.id]];
}

+ (NSString *)imageRelatedURLWithShoot:(Shoot *)shoot
{
    return [NSString stringWithFormat:@"shoot_%@_%@", shoot.user.id, shoot.id];
}

+ (NSURL *)imageURLOfShootId:(NSNumber *)shootId userId:(NSNumber *)userId quality:(long)quality
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/shoot_%@_%@?quality=%ld", [ImageUtil getBaseUrl], userId, shootId, quality]];
}

+ (NSURL *)imageURLOfImageId:(NSString *)imageId quality:(NSNumber *)quality
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?quality=%@", [ImageUtil getBaseUrl], imageId, quality]];
}

+ (UIImage *)imageWithImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    CGFloat width = originalImage.size.width;
    CGFloat height = originalImage.size.height;
    
    CGFloat ratio = width / height;
    CGFloat frameRatio = size.width / size.height;
    
    CGSize newSize;
    
    if (size.width > size.height && frameRatio > ratio) {
        newSize = CGSizeMake(size.width, size.width / ratio);
    } else {
        newSize = CGSizeMake(size.height * ratio, size.height);
    }
    
    UIImage *newImage = nil;
    UIGraphicsBeginImageContext( newSize );
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (CGSize)translateSizeWithFrameSize:(CGSize)size frameSize:(CGSize)frameSize
{
    CGFloat ratio = size.width / size.height;
    CGFloat frameRatio = frameSize.width / size.height;
    
    CGSize newSize;
    if (frameSize.width > frameSize.height && frameRatio > ratio) {
        newSize = CGSizeMake(frameSize.width, frameSize.width / ratio);
    } else {
        newSize = CGSizeMake(frameSize.height * ratio, frameSize.height);
    }
    
    return newSize;
}

+ (CGSize)sizeAspectScaleFitWithSize:(CGSize)originalSize frameSize:(CGSize)frameSize
{
    CGFloat ratio = fminf(frameSize.height / originalSize.height, frameSize.width / originalSize.width);
    
    CGFloat width = originalSize.width * ratio;
    CGFloat heigth = originalSize.height * ratio;
    
    return CGSizeMake(width, heigth);
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToWidth:(CGFloat)width
{
    CGFloat originalWidth = originalImage.size.width;
    CGFloat originalHeight = originalImage.size.height;
    
    CGFloat ratio = originalWidth / originalHeight;
    
    CGSize newSize = CGSizeMake(width, width / ratio);
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToHeight:(CGFloat)height
{
    if (!originalImage) {
        return nil;
    }
    
    CGFloat originalWidth = originalImage.size.width;
    CGFloat originalHeight = originalImage.size.height;
    CGFloat ratio = originalWidth / originalHeight;
    
    CGSize newSize = CGSizeMake(height * ratio, height);
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)originalImage scaledToRatio:(CGFloat)ratio
{
    if (!originalImage) {
        return nil;
    }
    
    CGSize newSize = CGSizeMake(originalImage.size.width * ratio, originalImage.size.height * ratio);
    return [self imageWithImage:originalImage toSize:newSize];
}

+ (NSString *) getBaseUrl
{
    return [ROOT_URL stringByAppendingString:@"image/query"];
}

@end
