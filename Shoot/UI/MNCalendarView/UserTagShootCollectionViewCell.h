//
//  UserTagShootCollectionViewCell.h
//  Shoot
//
//  Created by LV on 3/19/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const UserTagShootCollectionViewCellIdentifier;

@interface UserTagShootCollectionViewCell : UICollectionViewCell

- (void) decorateWithUserTagShootsPredicate:(NSPredicate *)predicate parentController:(UIViewController *)parentController;

@end
