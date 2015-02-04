//
//  UIViewHelper.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/21/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewHelper : NSObject
+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners;
+ (void) roundCorners:(UIView *) view byRoundingCorners:(UIRectCorner)corners radius:(double) radius;
+ (UIView *)circleWithColor:(UIColor *)color radius:(int)radius;
+ (void) insertLeftPaddingToTextField:(UITextField *) textField width:(double)width;
+ (NSString *) getCountString:(NSNumber*) count;
+ (NSString *) formatTime:(NSDate *)time;
+ (void) applySameSizeConstraintToView:(UIView*)view superView:(UIView *)superView;
@end
