//
//  SignUpSubViewController.m
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import "SignUpSubViewController.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"

@interface SignUpSubViewController ()

@end

@implementation SignUpSubViewController

static double CANCEL_BUTTON_SIZE = 100;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];

    self.view = contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 100, self.view.frame.size.width, 20)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textColor = [ColorDefinition darkRed];
    self.titleLabel.text = self.viewTitle;
    [self.view addSubview:self.titleLabel];
    
    double horizontalPadding = 20;
    double padding = 5;
    
    self.informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalPadding, padding + self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.view.frame.size.width - 2 * horizontalPadding, 50)];
    self.informationLabel.textColor = [UIColor grayColor];
    self.informationLabel.text = self.information;
    self.informationLabel.numberOfLines = 0;
    self.informationLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.informationLabel];

    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(self.informationLabel.frame.origin.x, self.informationLabel.frame.origin.y + self.informationLabel.frame.size.height + padding, self.informationLabel.frame.size.width, 35)];
    [self.inputField setFont:[UIFont systemFontOfSize:14]];
    self.inputField.textColor = [ColorDefinition darkRed];
    self.inputField.layer.borderWidth = 1;
    self.inputField.layer.borderColor = [[ColorDefinition grayColor] CGColor];
    [UIViewHelper insertLeftPaddingToTextField:self.inputField width:10];
    self.inputField.backgroundColor = [UIColor whiteColor];
    self.inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputField.returnKeyType = UIReturnKeyNext;
    if (self.keyboardType) {
        self.inputField.keyboardType = self.keyboardType;
    }
    self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputField.secureTextEntry = self.isSecureEntry;
    self.inputField.layer.cornerRadius = 5;
    self.inputField.delegate = self;
    [self.inputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.inputField];
    
    self.errorMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.inputField.frame.origin.x, self.inputField.frame.origin.y + self.inputField.frame.size.height + padding, self.inputField.frame.size.width, 45)];
    self.errorMessageLabel.textColor = [UIColor redColor];
    self.errorMessageLabel.numberOfLines = 0;
    self.errorMessageLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.errorMessageLabel];
    
    self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.errorMessageLabel.frame.origin.x, self.errorMessageLabel.frame.origin.y + self.errorMessageLabel.frame.size.height + padding, self.errorMessageLabel.frame.size.width, 25)];
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setBackgroundColor:[ColorDefinition darkRed]];
    self.continueButton.layer.cornerRadius = 5;
    [self.view addSubview:self.continueButton];
    [self.continueButton addTarget:self action:@selector(continueClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - CANCEL_BUTTON_SIZE)/2.0, self.continueButton.frame.origin.y + self.continueButton.frame.size.height + padding, CANCEL_BUTTON_SIZE, 25)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.cancelButton setTitleColor:[ColorDefinition darkRed] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [self isOkayToProceed:false];
}

- (BOOL)isOkayToProceed:(BOOL)isFinal
{
    //if it is final check, do a non final check first
    if (isFinal && ![self isOkayToProceed:false]) {
        return false;
    }
    self.errorMessageLabel.text = @"";
    NSString * errorMessage;
    if (isFinal) {
        errorMessage = [self.delegate finalValidateInputValue:self.inputField.text sender:self];
    } else {
        errorMessage = [self.delegate validateInputValue:self.inputField.text sender:self];
    }
    if (errorMessage) {
        self.errorMessageLabel.text = errorMessage;
    }
    return errorMessage == nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueClicked:textField];
    return YES;
}

- (void)cancelClicked:(id)sender {
    [self.delegate cancelClicked:self];
}

- (void)continueClicked:(id)sender {
    if ([self isOkayToProceed:true]) {
        [self.delegate continueClicked:self];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
