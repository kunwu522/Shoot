//
//  JSMessageInputView.h
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "JSDismissiveTextView.h"

#define SEND_BUTTON_WIDTH 60.0f
#define TAKE_PHOTO_BUTTON_WIDTH 23.0f
#define LEFT_PADDING 12.0f
#define CHARACTER_COUNT_LABEL_WIDTH 28.0f
#define CHARACTER_COUNT_LABEL_RIGHT_PAD 5.0f
#define MAX_CHARACTER_COUNT 140
#define TEXTVIEW_INSET 4
#define ALPHA 0.85f

@interface JSMessageInputView : UIImageView

@property (strong, nonatomic) JSDismissiveTextView *textView;
@property (strong, nonatomic) UILabel *characterCountLabel;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *takePhotoButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
           delegate:(id<UITextViewDelegate>)delegate;

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;
- (void)textDidChange;

+ (CGFloat)textViewLineHeight;
+ (CGFloat)maxLines;
+ (CGFloat)maxHeight;

@end