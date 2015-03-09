//
//  SignUpSubViewController.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 10/30/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpSubViewDelegate <NSObject>
@required
- (void) cancelClicked:(id)sender;
- (void) continueClicked:(id)sender;
//should return nil if value is valid, otherwise return with invalid reason
- (NSString *) validateInputValue: (NSString *) inputValue sender:(id) sender;
//should return nil if value is valid, otherwise return with invalid reason.
//the difference is this method will only be called when user trying to submit, while the other method will be called while typing
- (NSString *) finalValidateInputValue: (NSString *) inputValue sender:(id) sender;
@end

@interface SignUpSubViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel *informationLabel;
@property (strong, nonatomic) UILabel *errorMessageLabel;
@property (strong, nonatomic) UITextField *inputField;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (nonatomic, weak)id<SignUpSubViewDelegate> delegate;

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSString *viewTitle;
@property (assign, nonatomic) NSString *information;
@property (assign, nonatomic) BOOL isSecureEntry;
@property (assign, nonatomic) UIKeyboardType keyboardType;

@end
