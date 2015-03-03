//
//  WLActionSheet.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 10/31/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "ShootActionSheet.h"
#import "ColorDefinition.h"

#define DEFAULT_BUTTON_HEIGHT 35.0
#define GAP_BETWEEN_BUTTONS 1.0
#define GAP_BETWEEN_CANCEL 8.0

@interface ShootActionSheet()

@property (nonatomic) BOOL hasDestructiveButton;
@property (nonatomic) BOOL hasCancelButtion;

@property (nonatomic, retain) NSMutableArray *buttons;

@property (nonatomic, retain) UIView *background;

@end

@implementation ShootActionSheet

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    self.backgroundColor = [UIColor clearColor];
    _buttons = [[NSMutableArray alloc]init];
    
    _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    _background.backgroundColor = [UIColor darkGrayColor];
    _background.alpha = 0.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelActoinSheet)];
    [_background addGestureRecognizer:tapGesture];
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<ShootActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *titles = [[NSMutableArray alloc]init];
    va_list ap;
    va_start(ap, otherButtonTitles);
    for (NSString *otherTitle = otherButtonTitles; otherTitle != nil; otherTitle = va_arg(ap, NSString* ))
    {
        [titles addObject:otherTitle];
    }
    va_end(ap);
    
    self = [self init];
    self.delegate = delegate;
    
    if (destructiveButtonTitle) {
        [titles insertObject:destructiveButtonTitle atIndex:0];
        _hasDestructiveButton = YES;
    } else {
        _hasDestructiveButton = NO;
    }
    
    if (cancelButtonTitle) {
        ShootActionSheetButton *cancelButton = [[ShootActionSheetButton alloc]initWithAllCornersRounded];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [_buttons addObject:cancelButton];
        _hasCancelButtion = YES;
    } else {
        _hasCancelButtion = NO;
    }
    
    switch (titles.count) {
        case 0:
            break;
        case 1: {
            ShootActionSheetButton *otherButton = nil;
            if (title) {
                otherButton = [[ShootActionSheetButton alloc]initWithBottomCornersRounded];
            } else {
                otherButton = [[ShootActionSheetButton alloc]initWithAllCornersRounded];
            }
            [otherButton setTitle:[titles objectAtIndex:0] forState:UIControlStateNormal];
            [_buttons insertObject:otherButton atIndex:0];
            break;
        }
        case 2: {
            ShootActionSheetButton *lastOtherButton = [[ShootActionSheetButton alloc]initWithBottomCornersRounded];
            [lastOtherButton setTitle:[titles lastObject] forState:UIControlStateNormal];
            
            ShootActionSheetButton *secoundButton;
            if (title) {
                secoundButton = [[ShootActionSheetButton alloc] init];
            } else {
                secoundButton = [[ShootActionSheetButton alloc] initWithTopCornersRounded];
            }
            [secoundButton setTitle:[titles objectAtIndex:0] forState:UIControlStateNormal];
            
            [_buttons insertObject:secoundButton atIndex:0];
            [_buttons insertObject:lastOtherButton atIndex:1];
            break;
        }
        default: {
            ShootActionSheetButton *lastOtherButton = [[ShootActionSheetButton alloc]initWithBottomCornersRounded];
            [lastOtherButton setTitle:[titles lastObject] forState:UIControlStateNormal];
            
            ShootActionSheetButton *firstOtherButton;
            if (title) {
                firstOtherButton = [[ShootActionSheetButton alloc]init];
            } else {
                firstOtherButton = [[ShootActionSheetButton alloc]initWithTopCornersRounded];
            }
            [firstOtherButton setTitle:[titles objectAtIndex:0] forState:UIControlStateNormal];
            [_buttons insertObject:firstOtherButton atIndex:0];
            
            for (int i = 1; i < (titles.count - 2); i++) {
                ShootActionSheetButton *middleButton = [[ShootActionSheetButton alloc]init];
                [middleButton setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
                [_buttons insertObject:middleButton atIndex:i];
            }
            [_buttons insertObject:lastOtherButton atIndex:(titles.count - 1)];
            break;
        }
    }
    
    if (destructiveButtonTitle) {
        [[_buttons objectAtIndex:0] setTitleColor:[ColorDefinition orangeColor] forState:UIControlStateNormal];
    }
    
    for (int i = 0; i < _buttons.count; i++) {
        [[_buttons objectAtIndex:i] setIndex:i];
    }
    
    //Add action
    [self addActionToButton];

    //Decorate button
    [self setupActionSheetFrame];
    
    return self;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [view insertSubview:_background belowSubview:self];
    
    self.center = CGPointMake(CGRectGetWidth(view.frame) * 0.5, CGRectGetHeight([UIScreen mainScreen].bounds) + CGRectGetHeight(self.frame) * 0.5);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.center = CGPointMake(self.center.x, CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(self.frame) * 0.5);
        _background.alpha = 0.7;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)showFromTabBar:(UITabBar *)view
{
    [view.superview addSubview:self];
    [view.superview insertSubview:_background belowSubview:self];
    
    self.center = CGPointMake(CGRectGetWidth(view.superview.frame) * 0.5, CGRectGetHeight(view.superview.frame) + CGRectGetHeight(self.frame) * 0.5);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.center = CGPointMake(self.center.x, CGRectGetHeight(view.superview.frame) - CGRectGetHeight(self.frame) * 0.5);
        _background.alpha = 0.7;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    return [[_buttons objectAtIndex:buttonIndex] titleLabel].text;
}

#pragma mark - private

- (void)setupActionSheetFrame
{
    CGFloat height;
    NSUInteger buttonCountWithoutCancel = _buttons.count;
    if (_hasCancelButtion) {
        height = DEFAULT_BUTTON_HEIGHT + GAP_BETWEEN_CANCEL * 2;
        buttonCountWithoutCancel -= 1;
    } else {
        height = GAP_BETWEEN_CANCEL;
    }
    
    if (buttonCountWithoutCancel > 0) {
        height += (DEFAULT_BUTTON_HEIGHT + (GAP_BETWEEN_BUTTONS * 0.5f)) * buttonCountWithoutCancel;
    }
    
    self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), height);
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) - DEFAULT_BUTTON_HEIGHT * 0.5 - GAP_BETWEEN_CANCEL);
    
    if (_hasCancelButtion) {
        ShootActionSheetButton *button = [_buttons lastObject];
        button.center = center;
        [self addSubview:button];
        center = CGPointMake(center.x, center.y - DEFAULT_BUTTON_HEIGHT - GAP_BETWEEN_CANCEL);
    }
    
    for (int i = 0; i < buttonCountWithoutCancel; i++) {
        ShootActionSheetButton *button = [_buttons objectAtIndex:i];
        [self addSubview:button];
        button.center = CGPointMake(center.x, center.y - ((buttonCountWithoutCancel - 1- i) * (DEFAULT_BUTTON_HEIGHT + GAP_BETWEEN_BUTTONS / 2)));
    }
}

- (void)addActionToButton
{
    for (ShootActionSheetButton *button in _buttons) {
        if ([button isKindOfClass:[ShootActionSheetButton class]]) {
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(buttonHightlight:) forControlEvents:UIControlEventTouchDown];
        }
    }
}

- (void)buttonPress:(ShootActionSheetButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:button.index];
    }
    [self removeView];
}

- (void)cancelActoinSheet
{
    [self removeView];
}

- (void)removeView
{
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _background.alpha = 0.0f;
        self.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.5f, CGRectGetHeight([UIScreen mainScreen].bounds) + CGRectGetHeight(self.frame) * 0.5f);
    } completion:^(BOOL finished) {
        [_background removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)buttonHightlight:(ShootActionSheetButton *)button
{
    button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

@end

@implementation ShootActionSheetButton

@synthesize index;

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, DEFAULT_BUTTON_HEIGHT)];
    self.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self setTitleColor:[ColorDefinition lightRed] forState:UIControlStateNormal];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [ColorDefinition lightRed].CGColor;
    self.layer.cornerRadius = 5;
    self.alpha = 1.0;
    
    return self;
}

- (id)initWithTopCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    return self;
}

- (id)initWithBottomCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    return self;
}

- (id)initWithAllCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
    return self;
}

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

@end
