//
//  TagShootCollectionView.h
//  Shoot
//
//  Created by LV on 3/29/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserTagShootCollectionView.h"
#import "Tag.h"

@interface TagShootCollectionView : UserTagShootCollectionView

- (void) reloadForTag:(Tag *)tag;

@end
