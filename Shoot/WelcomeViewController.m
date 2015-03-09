//
//  WelcomeViewController.m
//  WeedaForiPhone
//
//  Created by Tony Wu on 14-4-7.
//  Copyright (c) 2014年 Weeda. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "MasterViewController.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"
#import <RestKit/RestKit.h>

@interface WelcomeViewController () <UITextFieldDelegate>{
    
}

@property (strong, nonatomic) UITextField *txtUsername;
@property (strong, nonatomic) UITextField *txtPassword;
@property (strong, nonatomic) UIButton *btnSignIn;
@property (strong, nonatomic) UIButton *btnSignUp;
@property (strong, nonatomic) UILabel *lbForgotPw;

@property (nonatomic, strong) UIImageView *titleImage;

@property (nonatomic, retain) UIView *forgotPwView;
@property (nonatomic, retain) UITextField *inputField;
@property (nonatomic, retain) UILabel *errorMessage;
@property (nonatomic) BOOL isEmailValid;

@property (nonatomic, retain) NSMutableDictionary *subViewCenterY;

- (IBAction)backgroudTab:(id)sender;

@end

@implementation WelcomeViewController

static NSString * USER_ID_COOKIE_NAME = @"user_id";
static NSString * USERNAME_COOKIE_NAME = @"username";
static NSString * PASSWORD_COOKIE_NAME = @"password";
static double ICON_INITIAL_SIZE = 60;
static double SIGN_UP_SIZE = 100;

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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ColorDefinition darkRed];
    
    _subViewCenterY = [[NSMutableDictionary alloc] init];
    
    self.titleImage = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - ICON_INITIAL_SIZE)/2.0, 190, ICON_INITIAL_SIZE, ICON_INITIAL_SIZE)];
    self.titleImage.image = [UIImage imageNamed:@"icon_white.png"];
    [self.view addSubview:self.titleImage];
    [self.view bringSubviewToFront:self.titleImage];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:110.0] forKey:@"titleImage"];
    
    double leftPadding = 20;
    
    self.txtUsername = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 175, self.view.frame.size.width - 2 * leftPadding, 35)];
    [self.view addSubview:self.txtUsername];
    self.txtUsername.alpha = 0;
    [self.txtUsername setFont:[UIFont systemFontOfSize:14]];
    self.txtUsername.placeholder = @"Username";
    self.txtUsername.textColor = [ColorDefinition darkRed];
    self.txtUsername.layer.borderWidth = 1;
    self.txtUsername.layer.borderColor = [[UIColor whiteColor] CGColor];
    [UIViewHelper insertLeftPaddingToTextField:self.txtUsername width:10];
    self.txtUsername.backgroundColor = [UIColor whiteColor];
    self.txtUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtUsername.returnKeyType = UIReturnKeyGo;
    self.txtUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtUsername.delegate = self;
    [UIViewHelper roundCorners:self.txtUsername byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:5];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:self.txtUsername.center.y] forKey:@"txtUsername"];
    
    self.txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(self.txtUsername.frame.origin.x, self.txtUsername.frame.origin.y + self.txtUsername.frame.size.height + 1,  self.txtUsername.frame.size.width,  self.txtUsername.frame.size.height)];
    [self.view addSubview:self.txtPassword];
    self.txtPassword.alpha = 0;
    [self.txtPassword setFont:self.txtUsername.font];
    self.txtPassword.placeholder = @"Password";
    self.txtPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtPassword.returnKeyType = UIReturnKeyGo;
    self.txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtPassword.delegate = self;
    self.txtPassword.textColor = [ColorDefinition darkRed];
    self.txtPassword.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.txtPassword.layer.borderWidth = 1;
    self.txtPassword.secureTextEntry = true;
    [UIViewHelper insertLeftPaddingToTextField:self.txtPassword width:10];
    self.txtPassword.backgroundColor = [UIColor whiteColor];
    [UIViewHelper roundCorners:self.txtPassword byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:5];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:self.txtPassword.center.y] forKey:@"txtPassword"];
    
    double lbForgotPwWidth = 105;
    double lbForgotPwHeight = 21;
    self.lbForgotPw = [[UILabel alloc] initWithFrame:CGRectMake(self.txtPassword.frame.origin.x + self.txtPassword.frame.size.width - lbForgotPwWidth, self.txtPassword.frame.origin.y + self.txtPassword.frame.size.height + 1, lbForgotPwWidth, lbForgotPwHeight)];
    self.lbForgotPw.text = @"Forgot Password?";
    [self.lbForgotPw setFont:[UIFont systemFontOfSize:12]];
    [self.lbForgotPw setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.lbForgotPw];
    self.lbForgotPw.userInteractionEnabled = YES;
    [self.lbForgotPw addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgorPassword:)]];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:self.lbForgotPw.center.y] forKey:@"lbForgotPw"];
    
    self.btnSignIn = [[UIButton alloc] initWithFrame:CGRectMake(self.txtUsername.frame.origin.x, self.lbForgotPw.frame.origin.y + self.lbForgotPw.frame.size.height + 20, self.txtUsername.frame.size.width, self.txtUsername.frame.size.height)];
    [self.btnSignIn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchDown];
    [self.btnSignIn setBackgroundColor:[ColorDefinition lightRed]];
    [self.btnSignIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.btnSignIn.titleLabel setTextColor:[UIColor whiteColor]];
    [self.btnSignIn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    self.btnSignIn.layer.cornerRadius = 5;
    [self.view addSubview:self.btnSignIn];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:self.btnSignIn.center.y] forKey:@"btnSignIn"];
    
    self.btnSignUp = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - SIGN_UP_SIZE) / 2.0, self.btnSignIn.frame.origin.y + self.btnSignIn.frame.size.height + 5, SIGN_UP_SIZE, self.txtUsername.frame.size.height)];
    [self.btnSignUp addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchDown];
    [self.btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.btnSignUp.titleLabel setTextColor:[UIColor whiteColor]];
    [self.btnSignUp.titleLabel setFont:self.lbForgotPw.font];
    [self.view addSubview:self.btnSignUp];
    [_subViewCenterY setObject:[NSNumber numberWithDouble:self.btnSignUp.center.y] forKey:@"btnSignUp"];
    
    self.btnSignIn.alpha = 0;
    self.btnSignUp.alpha = 0;
    self.lbForgotPw.alpha = 0;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self signIn:textField];
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    sleep(2);
    [self checkCookiesAndGetCurrentUser];
}

- (void) showLoginUI
{
    [UIView animateWithDuration:0.5 animations:^{
        self.titleImage.center = CGPointMake(self.titleImage.center.x, 110);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.txtUsername.alpha = 1;
            self.txtPassword.alpha = 1;
            self.btnSignUp.alpha = 1;
            self.btnSignIn.alpha = 1;
            self.lbForgotPw.alpha = 1;
        }];
    }];
}

- (void) hideLoginUI
{
    [UIView animateWithDuration:0.5 animations:^{
        self.txtUsername.alpha = 0;
        self.txtPassword.alpha = 0;
        self.btnSignUp.alpha = 0;
        self.btnSignIn.alpha = 0;
        self.lbForgotPw.alpha = 0;
        self.titleImage.center = CGPointMake(self.titleImage.center.x, 190);
    }];
}

#pragma mark - Navigation

- (void) checkCookiesAndGetCurrentUser
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //everytime, first clear all the login cookies. Login will refresh it
    [appDelegate clearLoginCookies];
    if (appDelegate.currentUsername && appDelegate.currentUserPassword) {
        [self signInThoughServerWithUsername:appDelegate.currentUsername password:appDelegate.currentUserPassword byCookie:YES];
    } else {
        [self showLoginUI];
        return;
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

- (void)signIn:(id)sender {
    if ([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""]) {
        [self alertStatus:@"Please enter Username and Password" :@"" :0];
        return;
    }
    
    [self hideLoginUI];
    [self signInThoughServerWithUsername:[self.txtUsername text] password:[self.txtPassword text] byCookie:NO];
}

- (void)signInThoughServerWithUsername:(NSString *) username password:(NSString *)password byCookie:(BOOL)isUseCookie
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *param;
    if (isUseCookie) {
        param = @{@"username" : username, @"password" : password, @"cookie" : @YES};
    } else {
        param = @{@"username" : username, @"password" : password, @"cookie" : @NO};
    }
    [[RKObjectManager sharedManager] postObject:nil path:@"user/login" parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [appDelegate populateCurrentUserFromCookie];
        [self performSegueWithIdentifier:@"masterView" sender:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure login: %@", error.localizedDescription);
        [self alertStatus:@"Failed to login. Please enter the correct Username and Password." :@"" :0];
        [self showLoginUI];
    }];
}

- (void)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signUp" sender:self];
}

- (void)backgroudTab:(id)sender {
    [self.view endEditing:YES];
}

- (void)forgorPassword:(UIGestureRecognizer *)recognizer
{
    if (self.txtUsername.text.length == 0) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:@"Please input your username" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    [self.view endEditing:YES];
    
    _forgotPwView = [[UIView alloc] initWithFrame:self.view.bounds];
    _forgotPwView.backgroundColor = [UIColor whiteColor];
    
    UIView *statusBarBackground = [UIView new];
    statusBarBackground.backgroundColor = [ColorDefinition greenColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [ColorDefinition greenColor];
    titleLabel.text = @"Forgot your password?";
    
    UILabel *descView = [UILabel new];
    descView.textColor = [UIColor grayColor];
    descView.text = @"Please input the email which you used for signup the account.";
    descView.numberOfLines = 0;
    descView.font = [UIFont systemFontOfSize:12];
    
    _inputField = [UITextField new];
    [_inputField setFont:[UIFont systemFontOfSize:14]];
    _inputField.textColor = [ColorDefinition greenColor];
    _inputField.layer.borderWidth = 1;
    _inputField.layer.borderColor = [[ColorDefinition grayColor] CGColor];
    [UIViewHelper insertLeftPaddingToTextField:_inputField width:10];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputField.returnKeyType = UIReturnKeyNext;
    _inputField.keyboardType = UIKeyboardTypeEmailAddress;
    _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputField.layer.cornerRadius = 5;
    _inputField.delegate = self;
    [_inputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _errorMessage = [UILabel new];
    _errorMessage.textColor = [UIColor redColor];
    _errorMessage.numberOfLines = 0;
    _errorMessage.font = [UIFont systemFontOfSize:12];
    
    UIButton *continueButton = [UIButton new];
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton setBackgroundColor:[ColorDefinition greenColor]];
    continueButton.layer.cornerRadius = 5;
    [continueButton addTarget:self action:@selector(continueClicked:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *cancelButton = [UIButton new];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cancelButton setTitleColor:[ColorDefinition greenColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchDown];
    
    [_forgotPwView addSubview:statusBarBackground];
    [_forgotPwView addSubview:titleLabel];
    [_forgotPwView addSubview:descView];
    [_forgotPwView addSubview:_inputField];
    [_forgotPwView addSubview:_errorMessage];
    [_forgotPwView addSubview:continueButton];
    [_forgotPwView addSubview:cancelButton];
    
    statusBarBackground.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descView.translatesAutoresizingMaskIntoConstraints = NO;
    _inputField.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMessage.translatesAutoresizingMaskIntoConstraints = NO;
    continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *vs = NSDictionaryOfVariableBindings(statusBarBackground, titleLabel, descView, _inputField, _errorMessage, continueButton, cancelButton);
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarBackground(20)]-80-[titleLabel(20)]-5-[descView(50)]-5-[_inputField(35)]-5-[_errorMessage(45)]-5-[continueButton(25)]-5-[cancelButton(25)]" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBarBackground]|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[descView]-20-|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_inputField]-20-|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_errorMessage]-20-|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[continueButton]-20-|" options:0 metrics:nil views:vs]];
    [_forgotPwView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[cancelButton]-20-|" options:0 metrics:nil views:vs]];
    
    _forgotPwView.center = CGPointMake(CGRectGetWidth(self.view.frame) * 0.5f, CGRectGetHeight(self.view.frame) + CGRectGetHeight(_forgotPwView.frame) * 0.5f);
    [self.view addSubview:_forgotPwView];
    
//    [UIView animateWithDuration:0.2 animations:^{
//        _forgotPwView.center = CGPointMake(_forgotPwView.center.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_forgotPwView.frame) * 0.5f);
//    }];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.5 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _forgotPwView.center = CGPointMake(_forgotPwView.center.x, CGRectGetHeight(self.view.frame) - CGRectGetHeight(_forgotPwView.frame) * 0.5f);
    } completion:^(BOOL finished) {
        ;
    }];
}

// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        _txtUsername.center = CGPointMake(_txtUsername.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"txtUsername"]).doubleValue - 37);
        _txtPassword.center = CGPointMake(_txtPassword.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"txtPassword"]).doubleValue - 37);
        _btnSignIn.center = CGPointMake(_btnSignIn.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"btnSignIn"]).doubleValue - 37);
        _btnSignUp.center = CGPointMake(_btnSignUp.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"btnSignUp"]).doubleValue - 37);
        _lbForgotPw.center = CGPointMake(_lbForgotPw.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"lbForgotPw"]).doubleValue - 37);
        _titleImage.center = CGPointMake(_titleImage.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"titleImage"]).doubleValue - 37);
    }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        _txtUsername.center = CGPointMake(_txtUsername.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"txtUsername"]).doubleValue);
        _txtPassword.center = CGPointMake(_txtPassword.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"txtPassword"]).doubleValue);
        _btnSignIn.center = CGPointMake(_btnSignIn.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"btnSignIn"]).doubleValue);
        _btnSignUp.center = CGPointMake(_btnSignUp.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"btnSignUp"]).doubleValue);
        _lbForgotPw.center = CGPointMake(_lbForgotPw.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"lbForgotPw"]).doubleValue);
        _titleImage.center = CGPointMake(_titleImage.center.x, ((NSNumber *)[_subViewCenterY objectForKey:@"titleImage"]).doubleValue);
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (![User isEmailValid:textField.text]) {
        _isEmailValid = NO;
        _errorMessage.text = @"Email address is not considered valid.";
    } else {
        _errorMessage.text = nil;
        _isEmailValid = YES;
    }
}

- (void)continueClicked:(id)sender
{
    if (!_isEmailValid) {
        return;
    }
    
    NSDictionary *postDictionary = @{@"email":_inputField.text, @"username":self.txtUsername.text};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];
//    NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ROOT_URL, @"mail/forgotPassword"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", jsonData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode >= 400) {
            _errorMessage.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Email has been sent. Please check you email and reset your password." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [self cancelClicked:self];
            [av show];
        }
    } else {
        _errorMessage.text = @"Sending email failed, please try it later.";
    }
}

- (void)cancelClicked:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _forgotPwView.center = CGPointMake(_forgotPwView.center.x, CGRectGetHeight(self.view.frame) + CGRectGetHeight(_forgotPwView.frame) * 0.5f);
    } completion:^(BOOL finished) {
        if (finished) {
            [_forgotPwView removeFromSuperview];
            _forgotPwView = nil;
        }
    }];
    
}

@end
