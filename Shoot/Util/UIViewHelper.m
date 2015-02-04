//
//  UIViewHelper.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewHelper.h"

@implementation UIViewHelper

+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners
{
    [UIViewHelper roundCorners:view byRoundingCorners:corners radius:10.0];
}

+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners radius:(double) radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    view.layer.mask = maskLayer;
}

+ (UIView *)circleWithColor:(UIColor *)color radius:(int)radius {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 * radius, 2 * radius)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.layer.masksToBounds = YES;
    return circle;
}

+ (void) insertLeftPaddingToTextField:(UITextField *) textField width:(double)width
{
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, textField.frame.size.height)];
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString *) getCountString:(NSNumber*) count
{
    if ([count longValue] >= 1000000000) {
        return [NSString stringWithFormat:@"%ldB", (long)([count longValue]/1000000000.0)];
    } else if ([count longValue] >= 1000000) {
        return [NSString stringWithFormat:@"%ldM", (long)([count longValue]/1000000.0)];
    } else if ([count longValue] >= 1000) {
        return [NSString stringWithFormat:@"%ldK", (long)([count longValue]/1000.0)];
    } else {
        return [NSString stringWithFormat:@"%@", count];
    }
}

+ (NSString *) formatTime:(NSDate *)time
{
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:time];
    NSString * timeString;
    if (timeDifference < 60) {
        timeString = [NSString stringWithFormat:@"%ds", (int)timeDifference];
    } else if (timeDifference < 3600) {
        timeString = [NSString stringWithFormat:@"%dm", (int)timeDifference/60];
    } else if (timeDifference < 86400) {
        timeString = [NSString stringWithFormat:@"%dh", (int)timeDifference/3600];
    } else if (timeDifference < 2592000) {
        timeString = [NSString stringWithFormat:@"%dd", (int)timeDifference/86400];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM. dd yyyy"];
        timeString = [dateFormatter stringFromDate:time];
    }
    return timeString;
}

+ (void) applySameSizeConstraintToView:(UIView*)view superView:(UIView *)superView
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    // initialize
    [superView addSubview:view];
    
    NSLayoutConstraint *width =[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:0 toItem:superView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *height =[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:0 toItem:superView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading  multiplier:1.0f constant:0.f];
    [superView addConstraint:width];
    [superView addConstraint:height];
    [superView addConstraint:top];
    [superView addConstraint:leading];
}

@end