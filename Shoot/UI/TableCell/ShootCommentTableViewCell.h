//
//  ShootCommentTableViewCell.h
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface ShootCommentTableViewCell : UITableViewCell

- (void) decorateWithComment:(Comment *)commentObj;
+ (CGFloat) height;

@end
