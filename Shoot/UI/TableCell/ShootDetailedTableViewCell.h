//
//  ShootDetailedTableViewCell.h
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShootDetailedTableViewCell : UITableViewCell

@property (retain, nonatomic) UIButton * comment;
@property (retain, nonatomic) UIButton * otherUserPosts;

+ (CGFloat) height;
+ (CGFloat) minimalHeight;
+ (CGFloat) heightWithoutImageView;

@end
