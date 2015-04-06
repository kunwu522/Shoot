//
//  ShootCommentTableViewCell.m
//  Shoot
//
//  Created by LV on 2/2/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ShootCommentTableViewCell.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"
#import "ColorDefinition.h"
#import "AppDelegate.h"
#import "ShootImageView.h"

@interface ShootCommentTableViewCell ()

@property (nonatomic, retain) ShootImageView *anonymous;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UIButton *commentLike;
@property (nonatomic, retain) Comment *comment;

@end

@implementation ShootCommentTableViewCell

static const CGFloat PADDING = 10;
static const CGFloat AVATAR_SIZE = 25;
static const CGFloat LIKE_BUTTON_WIDTH = 60;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.anonymous = [[ShootImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, AVATAR_SIZE, AVATAR_SIZE)];
        self.anonymous.image = [UIImage imageNamed:@"avatar.jpg"];
        self.anonymous.layer.cornerRadius = self.anonymous.frame.size.width/2.0;
        CALayer *l = [self.anonymous layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.anonymous.frame.size.width/2.0];
        [self addSubview:self.anonymous];
        
        CGFloat commentX = self.anonymous.frame.size.width + self.anonymous.frame.origin.x + PADDING;
        
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentX, self.anonymous.frame.origin.y, self.frame.size.width - PADDING - LIKE_BUTTON_WIDTH - commentX, 25)];
        
        self.commentLabel.font = [UIFont systemFontOfSize:12];
        self.commentLabel.textColor = [UIColor darkGrayColor];
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.commentLabel];
        
        self.commentLike = [[UIButton alloc] initWithFrame:CGRectMake(self.commentLabel.frame.origin.x + self.commentLabel.frame.size.width, self.commentLabel.frame.origin.y, LIKE_BUTTON_WIDTH, self.commentLabel.frame.size.height)];
        [self.commentLike setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.commentLike.titleLabel.font = [UIFont boldSystemFontOfSize:9];
        [self.commentLike setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.commentLike.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.commentLike];
        [self.commentLike addTarget:self action:@selector(likeIt:)forControlEvents:UIControlEventTouchDown];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void) decorateWithComment:(Comment *)commentObj
{
    self.comment = commentObj;
    self.commentLabel.text = commentObj.content;
    [self updateLike];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.currentUserID isEqualToNumber:commentObj.user.userID]) {
        [self.anonymous setImageURL:[ImageUtil imageURLOfAvatar:appDelegate.currentUserID] isAvatar:YES];
    } else {
        [self.anonymous setImage:[UIImage imageNamed:@"avatar.jpg"]];
    }
}

- (void) updateLike
{
    [self.commentLike setTitle:[NSString stringWithFormat:@" %@", [UIViewHelper getCountString:self.comment.like_count]] forState:UIControlStateNormal];
    if ([self.comment.if_cur_user_like_it integerValue] == 0) {
        [self.commentLike setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    } else {
        [self.commentLike setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[ColorDefinition lightRed]] forState:UIControlStateNormal];
    }
}

- (void)likeIt:(id) sender {
    if ([self.comment.if_cur_user_like_it intValue] == 1) {
        self.comment.like_count = [NSNumber numberWithInt:[self.comment.like_count intValue] - 1];
        self.comment.if_cur_user_like_it = [NSNumber numberWithInt:0];
        [self updateLike];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"comment/unlike/%@", self.comment.commentID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *error = nil;
            BOOL successful = [self.comment.managedObjectContext save:&error];
            if (!successful) {
                NSLog(@"Save comment Error: %@", error.localizedDescription);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            RKLogError(@"unlike comment failed with error: %@", error);
            self.comment.like_count = [NSNumber numberWithInt:[self.comment.like_count intValue] + 1];
            self.comment.if_cur_user_like_it = [NSNumber numberWithInt:1];
            [self updateLike];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to unlike comment. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [av show];
        }];
    } else {
        self.comment.like_count = [NSNumber numberWithInt:[self.comment.like_count intValue] + 1];
        self.comment.if_cur_user_like_it = [NSNumber numberWithInt:1];
        [self updateLike];
        [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"comment/like/%@", self.comment.commentID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
         {
             NSError *error = nil;
             BOOL successful = [self.comment.managedObjectContext save:&error];
             if (!successful) {
                 NSLog(@"Save comment Error: %@", error.localizedDescription);
             }
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             RKLogError(@"like comment failed with error: %@", error);
             self.comment.like_count = [NSNumber numberWithInt:[self.comment.like_count intValue] - 1];
             self.comment.if_cur_user_like_it = [NSNumber numberWithInt:0];
             [self updateLike];
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to like comment. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
             [av show];
         }];
    }
}

+ (CGFloat) height
{
    return PADDING * 2 + AVATAR_SIZE;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
