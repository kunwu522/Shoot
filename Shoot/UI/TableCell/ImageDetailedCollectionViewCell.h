//
//  ImageDetailedCollectionViewCell.h
//  Shoot
//
//  Created by LV on 1/20/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoot.h"
#import "User.h"

@interface ImageDetailedCollectionViewCell : UICollectionViewCell

@property (retain, nonatomic) UIImageView * imageView;

- (void) decorateWith:(Shoot *)shoot user:(User *)user userTagShoots:(NSArray *)userTagShoots parentController:(UIViewController *)parentController;

- (void) decorateWith:(Shoot *)shoot user:(User *)user userTagShoots:(NSArray *)userTagShoots parentController:(UIViewController *)parentController showLikeCount:(BOOL)showLikeCount;

@end
