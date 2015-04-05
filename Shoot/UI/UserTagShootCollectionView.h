//
//  UserTagShootCollectionView.h
//  Shoot
//
//  Created by LV on 3/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserTagShootCollectionView : UIView

@property (nonatomic) BOOL showLikeButton;
@property (retain, nonatomic) User * user;
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController;
- (void) setCollectionViewStatus:(BOOL)isGridView;
- (void) reload;
- (CGFloat) getCollectionViewHeight;

@end
