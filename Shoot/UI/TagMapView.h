//
//  TagMapView.h
//  Shoot
//
//  Created by LV on 4/1/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

@interface TagMapView : UIView

- (void) reloadForTag:(Tag *)tag;

@end
