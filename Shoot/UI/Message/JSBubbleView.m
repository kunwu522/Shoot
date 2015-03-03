//
//  JSBubbleView.m
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

#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "ImageUtil.h"
#import "MessageImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

CGFloat const kJSAvatarSize = 50.0f;

#define kMarginTop 8.0f
#define kMarginBottom 8.0f
#define kPaddingTop 8.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f
#define kMaxImageWidth 200.0f

@interface JSBubbleView()

- (void)setup;

+ (UIImage *)bubbleImageTypeIncomingWithStyle:(JSBubbleMessageStyle)aStyle;
+ (UIImage *)bubbleImageTypeOutgoingWithStyle:(JSBubbleMessageStyle)aStyle;

@end



@implementation JSBubbleView

@synthesize type;
@synthesize style;
@synthesize message;
@synthesize selectedToShowCopyMenu;

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)rect
         bubbleType:(JSBubbleMessageType)bubleType
        bubbleStyle:(JSBubbleMessageStyle)bubbleStyle
{
    self = [super initWithFrame:rect];
    if(self) {
        [self setup];
        self.type = bubleType;
        self.style = bubbleStyle;
        self.imageView = [[ShootImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        [self addSubview:self.imageView];
        self.imageView.hidden = true;
        self.imageView.allowFullScreenDisplay = true;
        self.imageView.shouldDownloadForFullScreenDisplay = false;
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)dealloc
{
    self.message = nil;
}

#pragma mark - Setters
- (void)setType:(JSBubbleMessageType)newType
{
    type = newType;
    [self setNeedsDisplay];
}

- (void)setStyle:(JSBubbleMessageStyle)newStyle
{
    style = newStyle;
    [self setNeedsDisplay];
}

- (void)setMessage:(Message *)newMessage
{
    message = newMessage;
    [self setNeedsDisplay];
}

- (void)setSelectedToShowCopyMenu:(BOOL)isSelected
{
    selectedToShowCopyMenu = isSelected;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [JSBubbleView bubbleSizeForMessage:self.message];
    return CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                      self.frame.size.height - kMarginBottom - bubbleSize.height,
                      bubbleSize.width,
                      bubbleSize.height);
}

- (UIImage *)bubbleImage
{
    return [JSBubbleView bubbleImageForType:self.type style:self.style];
}

- (UIImage *)bubbleImageHighlighted
{
    switch (self.style) {
        case JSBubbleMessageStyleDefault:
        case JSBubbleMessageStyleDefaultGreen:
            return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleDefaultIncomingSelected] : [UIImage bubbleDefaultOutgoingSelected];
            
        case JSBubbleMessageStyleSquare:
            return (self.type == JSBubbleMessageTypeIncoming) ? [UIImage bubbleSquareIncomingSelected] : [UIImage bubbleSquareOutgoingSelected];
            
        default:
            return nil;
    }
}

- (void)drawRect:(CGRect)frame
{
    [super drawRect:frame];
    
    CGRect bubbleFrame = [self bubbleFrame];
    UIImage *bgImage = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    [bgImage drawInRect:bubbleFrame blendMode:kCGBlendModeNormal alpha:0.8];
    NSNumber * message_id = message.messageID;
    if (message.image) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[ImageUtil imageURLOfMessage:message]
                                                        options:(SDWebImageHandleCookies)
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                           
                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                           if (finished && [message_id isEqualToNumber:message.messageID]/*check if cell has been reused*/) {
                                                               if (image) {
                                                                   UIImage *originalImg = [ImageUtil renderImage:image atSize:bubbleFrame.size];
                                                                   [self.imageView setFrame:bubbleFrame];
                                                                   self.imageView.hidden = false;
                                                                   [self.imageView setAlpha:0.0];
                                                                   self.imageView.image = image;
                                                                   UIImage *maskImgOrg = [JSBubbleView bubbleImageMaskForType:self.type style:self.style];
                                                                   
                                                                   UIImage *maskImg = [ImageUtil renderImage:maskImgOrg atSize:originalImg.size];
                                                                   
                                                                   [[self maskImage:originalImg withMask:maskImg] drawInRect:bubbleFrame blendMode:kCGBlendModeNormal alpha:1.0];
                                                               } else {
                                                                   UIImage * missingImage = [ImageUtil colorImage:[UIImage imageNamed:@"Oops.png"] color:[UIColor whiteColor]];
                                                                   double height = missingImage.size.height;
                                                                   double width = missingImage.size.width;
                                                                   if (width > bubbleFrame.size.width) {
                                                                       height = bubbleFrame.size.width/width*height;
                                                                       width = bubbleFrame.size.width;
                                                                   }
                                                                   if (height > bubbleFrame.size.height) {
                                                                       width = bubbleFrame.size.height/height*width;
                                                                       height = bubbleFrame.size.height;
                                                                   }
                                                                   
                                                                   [missingImage drawInRect:CGRectMake(bubbleFrame.origin.x + bubbleFrame.size.width/2.0 - width/2.0, bubbleFrame.origin.y + bubbleFrame.size.height/2.0 - height/2.0, width, height) blendMode:kCGBlendModeNormal alpha:1.0];
                                                                   
                                                               }
                                                               
                                                               [self setNeedsDisplay];
                                                           }
                                                       }];
        
        
        
    } else {
        self.imageView.hidden = true;
        
        CGSize textSize = [JSBubbleView textSizeForText:self.message.message];
        
        CGFloat textX = bgImage.leftCapWidth - 3.0f + (self.type == JSBubbleMessageTypeOutgoing ? bubbleFrame.origin.x : 0.0f);
        
        CGRect textFrame = CGRectMake(textX,
                                      kPaddingTop + kMarginTop,
                                      textSize.width,
                                      textSize.height);
        self.type == JSBubbleMessageTypeOutgoing ? [[UIColor blackColor] set] : [[UIColor whiteColor] set];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary *attributes = @{ NSFontAttributeName: [JSBubbleView font],
                                      NSParagraphStyleAttributeName: paragraphStyle,
                                      NSForegroundColorAttributeName: (self.type == JSBubbleMessageTypeOutgoing ? [UIColor blackColor] : [UIColor whiteColor])};
        [self.message.message drawInRect:textFrame withAttributes:attributes];
    }
}

- (UIImage*) maskImage:(UIImage *)originalImage withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([originalImage CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint p = [recognizer locationInView:self];
    if (CGRectContainsPoint([self bubbleFrame], p)) {
        if (!self.imageView.hidden) {
            [self.imageView displayFullScreen];
        }
    }
}

#pragma mark - Bubble view
+ (UIImage *)bubbleImageForType:(JSBubbleMessageType)aType style:(JSBubbleMessageStyle)aStyle
{
    switch (aType) {
        case JSBubbleMessageTypeIncoming:
            return [self bubbleImageTypeIncomingWithStyle:aStyle];
            
        case JSBubbleMessageTypeOutgoing:
            return [self bubbleImageTypeOutgoingWithStyle:aStyle];
            
        default:
            return nil;
    }
}

+ (UIImage *)bubbleImageMaskForType:(JSBubbleMessageType)aType style:(JSBubbleMessageStyle)aStyle
{
    //need to add support for different style
    switch (aType) {
        case JSBubbleMessageTypeIncoming:
            return [UIImage bubbleImageIncomingMask];
            
        case JSBubbleMessageTypeOutgoing:
            return [UIImage bubbleImageOutgoingMask];
            
        default:
            return nil;
    }
}

+ (UIImage *)bubbleImageTypeIncomingWithStyle:(JSBubbleMessageStyle)aStyle
{
    switch (aStyle) {
        case JSBubbleMessageStyleDefault:
            return [UIImage bubbleDefaultIncoming];
            
        case JSBubbleMessageStyleSquare:
            return [UIImage bubbleSquareIncoming];
            
        case JSBubbleMessageStyleDefaultGreen:
            return [UIImage bubbleDefaultIncomingGreen];
            
        default:
            return nil;
    }
}

+ (UIImage *)bubbleImageTypeOutgoingWithStyle:(JSBubbleMessageStyle)aStyle
{
    switch (aStyle) {
        case JSBubbleMessageStyleDefault:
            return [UIImage bubbleDefaultOutgoing];
            
        case JSBubbleMessageStyleSquare:
            return [UIImage bubbleSquareOutgoing];
            
        case JSBubbleMessageStyleDefaultGreen:
            return [UIImage bubbleDefaultOutgoingGreen];
            
        default:
            return nil;
    }
}

+ (UIFont *)font
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt
{
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width * 0.75f;
    CGFloat height = MAX([JSBubbleView numberOfLinesForMessage:txt],
                         [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{ NSFontAttributeName: [JSBubbleView font],
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    CGSize size = [txt boundingRectWithSize:CGSizeMake(width - kJSAvatarSize, height + kJSAvatarSize) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

+ (CGSize)bubbleSizeForMessage:(Message *)message
{
    if (message.image) {
        MessageImage *image = (MessageImage *)message.image;

        if ([image.width floatValue] < kMaxImageWidth) {
            return CGSizeMake(round([image.width floatValue]), round([image.height floatValue]));
        } else {
            return CGSizeMake(kMaxImageWidth,
                              round([image.height floatValue] /[image.width floatValue] * kMaxImageWidth));
        }
    } else {
        CGSize textSize = [JSBubbleView textSizeForText:message.message];
        return CGSizeMake(textSize.width + kBubblePaddingRight,
                          textSize.height + kPaddingTop + kPaddingBottom);
    }
}

+ (CGFloat)cellHeightForMessage:(Message *)message
{
    return [JSBubbleView bubbleSizeForMessage:message].height + kMarginTop + kMarginBottom;
}

+ (int)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (int)numberOfLinesForMessage:(NSString *)txt
{
    return (int)(txt.length / [JSBubbleView maxCharactersPerLine]) + 1;
}

@end