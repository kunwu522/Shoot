//
//  TagShootCollectionView.m
//  Shoot
//
//  Created by LV on 3/29/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagShootCollectionView.h"

@implementation TagShootCollectionView

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController
{
    self = [super initWithFrame:frame forUser:user parentController:parentController];
    if (self) {
        self.showLikeButton = YES;
    }
    return self;
}

- (void) reloadForTag:(Tag *)tag
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"tagID == %@", tag.tagID]];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [self reload];
}

@end
