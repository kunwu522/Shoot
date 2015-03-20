//
//  UserShootCollectionView.h
//  Shoot
//
//  Created by LV on 3/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserShootCollectionView : UIView

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController;
- (void) setCollectionViewStatus:(BOOL)isGridView;
- (void) reloadForType:(NSNumber *)tagType;
- (CGFloat) getCollectionViewHeight;

@end
