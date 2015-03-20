//
//  MapView.h
//  Shoot
//
//  Created by LV on 1/29/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapView : UIView

- (MKCoordinateRegion) getRegion;
- (void) setRegion:(MKCoordinateRegion)mapRegion;
- (void) setAnnotations:(NSArray *) annotations;

@end
