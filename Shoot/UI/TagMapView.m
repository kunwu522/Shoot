//
//  TagMapView.m
//  Shoot
//
//  Created by LV on 4/1/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "TagMapView.h"
#import "MapView.h"
#import "MapAnnotation.h"
#import "UIViewHelper.h"
#import "UserTagShootDao.h"
#import "UserTagShoot.h"

@interface TagMapView ()

@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) MapView * mapView;

@end

@implementation TagMapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[MapView alloc] initWithFrame:self.bounds];
        [UIViewHelper applySameSizeConstraintToView:self.mapView superView:self];
        [self addSubview:self.mapView];
    }
    return self;
}

- (void) reloadForTag:(Tag *)tag
{
    NSArray *userTagShoots = [[UserTagShootDao sharedManager] findUserTagShootsLocallyByTagId:tag.tagID];
    NSMutableArray *userTagShootsAnnotations = [NSMutableArray new];
    for (UserTagShoot *userTagShoot in userTagShoots) {
        [userTagShootsAnnotations addObject:[userTagShoot getMapAnnotation]];
    }
    [self.mapView setAnnotations:userTagShootsAnnotations];
}

@end
