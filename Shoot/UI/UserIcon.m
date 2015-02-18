//
//  UserIcon.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 11/16/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "UserIcon.h"

@implementation UserIcon

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        double effectiveSize = frame.size.width;
        if (frame.size.height < effectiveSize) {
            effectiveSize = frame.size.height;
        }
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - effectiveSize/2.0, frame.size.height/2.0 - effectiveSize/2.0, effectiveSize, effectiveSize)];
        [self addSubview:self.icon];
    }
    return self;
}

- (void) setUserType:(NSString *)user_type
{
    UIImage * userIcon = [UserIcon getUserIconForType:user_type];
    if (userIcon) {
        self.icon.image = userIcon;
        self.icon.hidden = false;
    } else {
        self.icon.hidden = true;
    }
}

+ (UIImage *) getUserIconForType:(NSString *) user_type
{
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
