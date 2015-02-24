//
//  ShootActionSheet.h
//  Shoot
//
//  Created by Tony Wu on 10/31/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShootActionSheet;
@protocol ShootActionSheetDelegate <NSObject>
@optional
- (void)actionSheet:(ShootActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface ShootActionSheet : UIView

- (instancetype)initWithTitle:(NSString *)title
                              delegate:(id<ShootActionSheetDelegate>)delegate
                cancelButtonTitle:(NSString *)cancelButtonTitle
         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)showInView: (UIView *)view;
- (void)showFromTabBar:(UITabBar *)view;

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

@property (nonatomic, assign) id<ShootActionSheetDelegate> delegate;

@end

@interface ShootActionSheetButton : UIButton

@property (nonatomic) NSInteger index;

- (id)initWithTopCornersRounded;
- (id)initWithAllCornersRounded;
- (id)initWithBottomCornersRounded;

@end
