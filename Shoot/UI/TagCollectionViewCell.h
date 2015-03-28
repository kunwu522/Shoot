//
//  TagCollectionViewCell.h
//  Shoot
//
//  Created by LV on 3/25/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

@interface TagCollectionViewCell : UICollectionViewCell

- (void) decorateWithTag:(Tag *)tag parentController:(UIViewController *)parentController;
- (void) decorateTagType:(NSNumber *)tagType;

+ (CGSize) getExpectedSizeForTag:(Tag *)tag;
+ (CGSize) getExpectedSizeForTypeCell;

@end
