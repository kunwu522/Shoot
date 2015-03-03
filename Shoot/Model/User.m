//
//  User.m
//  Shoot
//
//  Created by LV on 2/15/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "User.h"
#import "Message.h"
#import "Shoot.h"
#import "User.h"
#import "UserTagShoot.h"
#import "AppDelegate.h"

@implementation User

@dynamic userID;
@dynamic time;
@dynamic shouldBeDeleted;
@dynamic email;
@dynamic password;
@dynamic follower_count;
@dynamic following_count;
@dynamic have_count;
@dynamic want_count;
@dynamic has_avatar;
@dynamic has_bg_image;
@dynamic relationship_with_currentUser;
@dynamic user_type;
@dynamic username;
@dynamic followers;
@dynamic followings;
@dynamic messages;
@dynamic shoot_tags;
@dynamic shoots;

- (NSString *)title {
    return self.username;
}

+ (NSString *)validateUsername:(NSString *)username
{
    if (!username) {
        return @"Username can not be empty.";
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //    if ([username isEqualToString:appDelegate.currentUser.username]) {
    //        return @"New username should be non-empty and different from previous username.";
    //    }
    NSString *regex = @"[A-Za-z0-9]{1,16}";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([usernameTest evaluateWithObject:username]) {
        return nil;
    } else {
        return @"Username should have 6-16 characters, and only numbers and letters are allowed.";
    }
}

+ (NSString *)validatePassword:(NSString *)password
{
    if (!password) {
        return @"Password can not be empty.";
    }
    NSString *pwRegStr = @"((?=.*\\d)(?=.*[A-Z])(?=.*[a-z]).{6,16})";
    NSPredicate *pwTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pwRegStr];
    if ([pwTest evaluateWithObject:password]) {
        return nil;
    } else {
        return @"Password should have 1-16 characters, including at least 1 uppercase and 1 lowercase and 1 digit.";
    }
}

+ (BOOL)isEmailValid:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString *) _getFormatedAddress:(NSString *) street city:(NSString*) city state:(NSString *) state zip:(NSString *) zip country:(NSString *)country {
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", street, city, state, zip, country];
}

// please make sure this method is in sync with update address
+ (NSString *) getFormatedAddressWithPlaceMark:(CLPlacemark *)placeMark {
    return [User _getFormatedAddress:[NSString stringWithFormat:@"%@ %@", placeMark.subThoroughfare, placeMark.thoroughfare] city:placeMark.locality state:placeMark.administrativeArea zip:placeMark.postalCode country:placeMark.country];
}


@end
