//
//  AppDelegate.m
//  Shoot
//
//  Created by LV on 12/10/14.
//  Copyright (c) 2014 Shoot. All rights reserved.
//

#import "AppDelegate.h"
#import "ColorDefinition.h"
#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserDao.h"
#import "ShootDao.h"
#import "TagDao.h"
#import "UserTagShootDao.h"
#import "MessageDao.h"
#import "UserTagShoot.h"
#import "Shoot.h"

#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

static NSString * USER_ID_COOKIE_NAME = @"user_id";
static NSString * USERNAME_COOKIE_NAME = @"username";
static NSString * PASSWORD_COOKIE_NAME = @"password";

NSString * _deviceToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupRestKit];
    [self populateCurrentUserFromCookie];
    
    if (!self.currentUser || !self.currentUser.userID) {
        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        user.username = @"lv";
        user.userID = [NSNumber numberWithInt:1];
        user.password = @"Lvlv1234";
        NSDictionary *param = @{@"cookie" : @NO};
        [[RKObjectManager sharedManager] postObject:user path:@"user/login" parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.currentUser = [mappingResult firstObject];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"Failure login: %@", error.localizedDescription);
        }];
    } else {
        NSLog(@"%@", self.currentUser.userID);
    }
    
//    [[UIApplication sharedApplication] setStatusBarStyle:[AppDelegate getUIStatusBarStyle]];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    [[UINavigationBar appearance] setBackgroundColor:[ColorDefinition greenColor]];
//    [[UINavigationBar appearance] setTranslucent:YES];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBarTintColor:[ColorDefinition greenColor]];
    
    // Let the device know we want to receive push notifications
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    

    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) setCurrentUser:(User *)currentUser
{
    bool userSwitched = true;
    if (_currentUser && currentUser) {
        if ([_currentUser.userID isEqualToNumber:currentUser.userID]) {
            userSwitched = false;
        }
    } else if (!_currentUser && !currentUser) {
        userSwitched = false;
    }
    if (userSwitched) {
        NSLog(@"user switched from %@ to %@", _currentUser.userID, currentUser.userID);
    }
    _currentUser = currentUser;
    if (userSwitched) {
        [self resetPersistentStores];
        [self setupRestKit];
    }
}

- (void)signoutFrom:(UIViewController *) sender
{
    if (_deviceToken) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/unregisterDevice/%@", _deviceToken] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self logoutLocally:sender];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unregisterDevice failed with error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Failed to logout. Please try again later."
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }];
    } else {
        [self logoutLocally:sender];
    }
}

- (void) logoutLocally:(UIViewController *) sender {
    [self clearLoginCookies];
    _currentUser = nil;
    UIViewController *controller = [[AppDelegate getMainStoryboard] instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    [sender presentViewController:controller animated:YES completion:nil];
}

- (void) populateCurrentUserFromCookie
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return;
    }
    
    NSDate *currentTime = [NSDate date];
    NSHTTPCookie *userIdCookie = [self findCookieByName:USER_ID_COOKIE_NAME isExpiredBy:currentTime];
    NSHTTPCookie *usernameCookie = [self findCookieByName:USERNAME_COOKIE_NAME isExpiredBy:currentTime];
    NSHTTPCookie *passwordCookie = [self findCookieByName:PASSWORD_COOKIE_NAME isExpiredBy:currentTime];
    
    if (userIdCookie == nil || userIdCookie.value == nil || usernameCookie == nil || usernameCookie.value == nil || passwordCookie == nil || passwordCookie.value == nil) {
        NSLog(@"There is no available cookie.");
        return;
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    User * user = [[UserDao new] findUserByIdLocally:[f numberFromString:userIdCookie.value]];
    if (user && user.userID) {
        self.currentUser = user;
        [self registerDeviceToken];
    }
    
}

- (NSHTTPCookie *) findCookieByName:(NSString *)name isExpiredBy:(NSDate *) time
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return nil;
    }
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name] && [cookie.expiresDate compare:time] == NSOrderedDescending) {
            return cookie;
        }
    }
    return nil;
}

- (void) clearLoginCookies
{
    [self removeCookieByName:USER_ID_COOKIE_NAME];
    [self removeCookieByName:USERNAME_COOKIE_NAME];
    [self removeCookieByName:PASSWORD_COOKIE_NAME];
}

- (void) removeCookieByName:(NSString *)name
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (!cookies || cookies.count == 0) {
        return;
    }
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void) registerDeviceToken
{
    if (_deviceToken) {
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"user/registerDevice/%@", _deviceToken] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"registerDevice failed with error: %@", error);
        }];
    }
}

- (void) resetPersistentStores
{
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@"/"];
    
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    
    [RKObjectManager sharedManager].managedObjectStore.managedObjectCache = nil;
    // Clear our object manager
    [RKObjectManager setSharedManager:nil];
    
    // Clear our default store
    [RKManagedObjectStore setDefaultStore:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [self updateBadgeCount];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"received notification as %@", [userInfo objectForKey:@"aps"]);
    NSString * badgeString = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"badge"]];
    self.badgeCount = MAX([badgeString integerValue], [UIApplication sharedApplication].applicationIconBadgeNumber);
    [self updateBadgeCount];
}

- (void) decreaseBadgeCount:(NSInteger) decreaseBy
{
    self.badgeCount = self.badgeCount - decreaseBy;
    [self updateBadgeCount];
}

- (void) updateBadgeCount
{
    if (self.notificationDelegate) {
        [self.notificationDelegate updateBadgeCount:self.badgeCount];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.badgeCount];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    _deviceToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Got device token as %@", _deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void) setupRestKit {
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-REST-API-Key" value:@"your key"];
    //[[manager HTTPClient] setDefaultHeader:@"X-Parse-Application-Id" value:@"your key"];
    
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    [[UserDao sharedManager] registerRestKitMapping];
    [[ShootDao sharedManager] registerRestKitMapping];
    [[TagDao sharedManager] registerRestKitMapping];
    [[MessageDao sharedManager] registerRestKitMapping];
    [[UserTagShootDao sharedManager] registerRestKitMapping];
    
    /**
     Complete Core Data stack initialization
     */
    if (!managedObjectStore.persistentStoreCoordinator) {
        [managedObjectStore createPersistentStoreCoordinator];
    }
    
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Shoot.sqlite", (self.currentUser.userID == nil?@"":self.currentUser.userID)]];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
}

+ (UIStatusBarStyle) getUIStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

+ (UIStoryboard *) getMainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

@end
