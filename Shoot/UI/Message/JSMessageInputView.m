//
//  JSMessageInputView.m
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

#import "JSMessageInputView.h"
#import "JSBubbleView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "ColorDefinition.h"

@interface JSMessageInputView ()

- (void)setup;
- (void)setupTextView;

@end



@implementation JSMessageInputView

@synthesize sendButton;
@synthesize takePhotoButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
           delegate:(id<UITextViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        self.textView.delegate = delegate;
    }
    return self;
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}
#pragma mark - Setup
- (void)setup
{
    self.alpha = ALPHA;
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    [self setupTextView];
}

- (void)setupTextView
{
    double width = self.frame.size.width - SEND_BUTTON_WIDTH - LEFT_PADDING - TAKE_PHOTO_BUTTON_WIDTH - LEFT_PADDING;
    double height = [JSMessageInputView textViewLineHeight] + TEXTVIEW_INSET * 2;
    
    self.textView = [[JSDismissiveTextView  alloc] initWithFrame:CGRectMake(LEFT_PADDING * 2 + TAKE_PHOTO_BUTTON_WIDTH, (self.frame.size.height - height)/2.0, width, height)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.textContainerInset = UIEdgeInsetsMake(TEXTVIEW_INSET, 0, TEXTVIEW_INSET, CHARACTER_COUNT_LABEL_WIDTH + CHARACTER_COUNT_LABEL_RIGHT_PAD);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.scrollEnabled = YES;
    self.textView.bounds = self.textView.frame;
    self.textView.contentSize = self.textView.frame.size;
    self.textView.userInteractionEnabled = YES;
    self.textView.font = [JSBubbleView font];
    self.textView.textColor = [UIColor blackColor];
    self.textView.tintColor = [ColorDefinition lightRed];
    self.textView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:ALPHA];
    self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeyDefault;
    [self addSubview:self.textView];
    CALayer * l = [self.textView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:3.0];
    
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CHARACTER_COUNT_LABEL_WIDTH, [JSMessageInputView textViewLineHeight])];
    [self adjustCharacterCountLabelAccordingToTextView];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d", MAX_CHARACTER_COUNT];
    [self.characterCountLabel setFont:[JSBubbleView font]];
    self.characterCountLabel.textAlignment = NSTextAlignmentRight;
    [self setCharacterCountLabelTextColor];
    [self addSubview:self.characterCountLabel];
}

- (void)adjustCharacterCountLabelAccordingToTextView
{
    [self.characterCountLabel setFrame:CGRectMake(self.textView.frame.origin.x + self.textView.frame.size.width - CHARACTER_COUNT_LABEL_WIDTH - CHARACTER_COUNT_LABEL_RIGHT_PAD, self.textView.frame.origin.y + self.textView.frame.size.height - [JSMessageInputView textViewLineHeight] - TEXTVIEW_INSET, CHARACTER_COUNT_LABEL_WIDTH, [JSMessageInputView textViewLineHeight])];
}

#pragma mark - Setters
- (void)setSendButton:(UIButton *)btn
{
    if(sendButton)
        [sendButton removeFromSuperview];
    
    sendButton = btn;
    [self addSubview:self.sendButton];
}

- (void)setTakePhotoButton:(UIButton *)btn
{
    if(takePhotoButton)
        [takePhotoButton removeFromSuperview];
    
    takePhotoButton = btn;
    [self addSubview:self.takePhotoButton];
}


#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight
{
    CGRect prevFrame = self.textView.frame;
    
    NSUInteger numLines = [self.textView.text numberOfLines];
    
    self.textView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    if(numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.textView.contentSize.height - self.textView.bounds.size.height);
        [self.textView setContentOffset:bottomOffset animated:YES];
    } else {
        [self.textView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
    [self adjustCharacterCountLabelAccordingToTextView];
}

- (void)textDidChange
{
    [self setCharacterCountLabelTextColor];
    self.sendButton.enabled = ([self.textView.text trimWhitespace].length > 0) && (self.textView.text.length <= MAX_CHARACTER_COUNT);
    self.characterCountLabel.text = [NSString stringWithFormat:@"%ld", MAX_CHARACTER_COUNT - self.textView.text.length];
}

- (void)setCharacterCountLabelTextColor
{
    self.characterCountLabel.textColor = (self.textView.text.length <= MAX_CHARACTER_COUNT) ? [ColorDefinition grayColor] : [UIColor redColor];
}

+ (CGFloat)textViewLineHeight
{
    return [JSBubbleView font].lineHeight;
}

+ (CGFloat)maxLines
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 4.0f : 8.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

@end