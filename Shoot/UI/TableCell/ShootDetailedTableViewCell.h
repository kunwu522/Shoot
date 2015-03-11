//
//  ShootDetailedTableViewCell.h
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shoot.h"

#define SHOOT_DETAIL_CELL_COMMENTS_BUTTON_TAG 101;
#define SHOOT_DETAIL_CELL_OTHER_USER_POSTS_BUTTON_TAG 102;

@protocol ShootDetailedTableViewCellDelegate <NSObject>
@required
- (void) viewSwitchedFrom:(NSInteger)oldView to:(NSInteger)newView;
@end

@interface ShootDetailedTableViewCell : UITableViewCell

@property (nonatomic, weak)id<ShootDetailedTableViewCellDelegate> delegate;

- (void) decorateWith:(Shoot *)shoot;
- (void) markImageAtX:(CGFloat)x y:(CGFloat)y;
- (void) hideMarker;

+ (CGFloat) height;
+ (CGFloat) minimalHeight;
+ (CGFloat) heightWithoutImageView;

@end
