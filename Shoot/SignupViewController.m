//
//  SignupViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-13.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "AppDelegate.h"
#import "SignupViewController.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"
#import <RestKit/RestKit.h>

@interface SignupViewController ()

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) SignUpSubViewController *usernameController;
@property (strong, nonatomic) SignUpSubViewController *emailController;
@property (strong, nonatomic) SignUpSubViewController *passwordController;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation SignupViewController

static const NSInteger USERNAME_INDEX = 0;
static const NSInteger EMAIL_INDEX = 1;
static const NSInteger PASSWORD_INDEX = 2;

static const NSInteger STEPS = 3;

bool availableUsername = false;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[SignupViewController class], nil];
    pageControl.pageIndicatorTintColor = [ColorDefinition grayColor];
    pageControl.currentPageIndicatorTintColor = [ColorDefinition greenColor];
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    self.currentIndex = 0;
    [self scrollToIndex:0];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    for (UIScrollView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void) scrollToIndex:(NSInteger)index
{
    SignUpSubViewController *initialViewController = [self viewControllerAtIndex:index];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    UIPageViewControllerNavigationDirection direction = (index < self.currentIndex ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward);
    
    self.currentIndex = index;
    
    [self.pageController setViewControllers:viewControllers direction:direction animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SignUpSubViewController *)viewControllerAtIndex:(NSInteger)index {
    
    switch (index) {
        case USERNAME_INDEX:
            if (!self.usernameController) {
                self.usernameController = [[SignUpSubViewController alloc] initWithNibName:nil bundle:nil];
                self.usernameController.index = index;
                self.usernameController.delegate = self;
                self.usernameController.viewTitle = @"What username you want to use?";
                self.usernameController.information = @"Username should be unique and it will be used by other user to find/identify you.";
                self.usernameController.isSecureEntry = false;
            }
            return self.usernameController;
        case EMAIL_INDEX:
            if (!self.emailController) {
                self.emailController = [[SignUpSubViewController alloc] initWithNibName:nil bundle:nil];
                self.emailController.index = index;
                self.emailController.delegate = self;
                self.emailController.viewTitle = @"What is your email address?";
                self.emailController.information = @"Email will only be used by us to contact you. Other user will not have access to it.";
                self.emailController.isSecureEntry = false;
                self.emailController.keyboardType = UIKeyboardTypeEmailAddress;
            }
            return self.emailController;
        case PASSWORD_INDEX:
            if (!self.passwordController) {
                self.passwordController = [[SignUpSubViewController alloc] initWithNibName:nil bundle:nil];
                self.passwordController.index = index;
                self.passwordController.delegate = self;
                self.passwordController.viewTitle = @"What password you want to use?";
                self.passwordController.information = @"To better protect your account, we recommend you to use a combination of uppercase and lowercase letters, and numbers.";
                self.passwordController.isSecureEntry = true;
            }
            return self.passwordController;
        default:
            break;
    }
    SignUpSubViewController *childViewController = [[SignUpSubViewController alloc] initWithNibName:nil bundle:nil];
    childViewController.index = index;
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return STEPS;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return self.currentIndex;
}

- (void)signupThroughServer
{
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    user.time = [NSDate date];
    user.username = self.username;
    user.password = self.password;
    user.email = self.email;
    
    [[RKObjectManager sharedManager] postObject:user path:@"user/signup" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate populateCurrentUserFromCookie];
        [self performSegueWithIdentifier:@"signupSuccess" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Sorry we failed to set up your account. Please try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        [self scrollToIndex:0];
    }];
}

- (void)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)continueClicked:(id)sender {
    switch (self.currentIndex) {
        case USERNAME_INDEX:
            self.username = self.usernameController.inputField.text;
            break;
        case EMAIL_INDEX:
            self.email = self.emailController.inputField.text;
            break;
        case PASSWORD_INDEX:
            self.password = self.passwordController.inputField.text;
            break;
        default:
            break;
    }
    if (self.currentIndex < STEPS - 1) {
        [self scrollToIndex:(self.currentIndex + 1)];
    } else {
        [self signupThroughServer];
    }
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
    if (self.currentIndex > 0) {
        switch (self.currentIndex) {
            case EMAIL_INDEX:
                self.email = nil;
                break;
            case PASSWORD_INDEX:
                self.password = nil;
                break;
            default:
                break;
        }
        [self scrollToIndex:(self.currentIndex - 1)];
    }
}

- (NSString *) validateInputValue: (NSString *) inputValue sender:(id)sender
{
    if (!inputValue || [inputValue length] == 0) {
        return @"Value can not be empty.";
    }
    switch (((SignUpSubViewController *)sender).index) {
        case EMAIL_INDEX:
            if ([User isEmailValid:inputValue]) {
                return nil;
            } else {
                return @"Email address is not considered valid.";
            }
        case PASSWORD_INDEX:
            return [User validatePassword:inputValue];
        case USERNAME_INDEX:
            return [User validateUsername:inputValue];
        default:
            break;
    }
    return nil;
}

- (NSString *) finalValidateInputValue: (NSString *) inputValue sender:(id) sender
{
    switch (((SignUpSubViewController *)sender).index) {
        case USERNAME_INDEX:
            return [self validateUsername:inputValue];
        case EMAIL_INDEX:
            return [self validateEmail:inputValue];
        default:
            return nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSString *)validateUsername:(NSString *)username
{
    NSString * usernameInvalidReason = [User validateUsername:username];
    if (!usernameInvalidReason) {
        return usernameInvalidReason;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/hasUsername/%@", ROOT_URL, username]];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: &error ];
    if (error) {
        return @"Failed to validate if username already exists. Please make sure you have internet access or try again later.";
    }
    error = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&error];
    if (error) {
        return @"Failed to validate if username already exists. Please make sure you have internet access or try again later.";
    }
    
    BOOL result = [[parsedObject valueForKey:@"exist"] boolValue];
    if (result) {
        return @"Username has already been taken.";
    } else {
        return nil;
    }
}

- (NSString *)validateEmail:(NSString *)email
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/hasEmail/%@", ROOT_URL, email]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:6];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: &error ];
    if (error) {
        return @"Failed to validate if email has already been registered. Please make sure you have internet access or try again later.";
    }
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&error];
    if (error) {
        return @"Failed to validate if email has already been registered. Please make sure you have internet access or try again later.";
    }
    BOOL result = [[parsedObject valueForKey:@"exist"] boolValue];
    if (result) {
        return @"Email has been registered.";
    } else {
        return nil;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
