//
//  TagTableViewCell.h
//  Shoot
//
//  Created by LV on 3/11/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

@interface TagTableViewCell : UITableViewCell

- (void) decorateWithTag:(Tag *)tag;

+ (CGFloat) height;

@end
