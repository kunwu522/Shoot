//
//  UserViewController.m
//  Shoot
//
//  Created by LV on 1/9/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserViewController.h"
#import "BlurView.h"
#import "ImageUtil.h"
#import "SWRevealViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

static CGFloat PADDING = 5;
static CGFloat AVATAR_SIZE = 80;
static CGFloat HEADER_HEIGHT = 120;
static CGFloat FOLLOWER_LABEL_HEIGHT = 18;

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView * header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.clipsToBounds = YES;
    header.image = [UIImage imageNamed:@"image3.jpg"];
    [self.view addSubview:header];
    
    BlurView *blurView = [[BlurView alloc] initWithFrame:header.frame];
    [self.view addSubview:blurView];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [blurView addGestureRecognizer:doubleTap];
    
    UIImageView * userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - AVATAR_SIZE/2.0, HEADER_HEIGHT - 20, AVATAR_SIZE, AVATAR_SIZE)];
    CALayer * l = [userAvatar layer];
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor whiteColor].CGColor];
    [l setBorderWidth:4];
    [l setCornerRadius:userAvatar.frame.size.width/2.0];
    userAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    [self.view addSubview:userAvatar];
    
    UILabel *followersCount = [[UILabel alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT + PADDING, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    followersCount.text = @"2,423,763";
    followersCount.textColor = [UIColor darkGrayColor];
    followersCount.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    followersCount.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:followersCount];
    
    UILabel *followers = [[UILabel alloc] initWithFrame:CGRectMake(0, followersCount.frame.origin.y + followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    followers.text = @"Followers";
    followers.textColor = [UIColor grayColor];
    followers.font = [UIFont systemFontOfSize:10];
    followers.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:followers];
    
    UILabel *followingCount = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width, HEADER_HEIGHT + PADDING, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    followingCount.text = @"321";
    followingCount.textColor = [UIColor darkGrayColor];
    followingCount.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    followingCount.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:followingCount];
    
    UILabel *followings = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width, followersCount.frame.origin.y + followersCount.frame.size.height, (self.view.frame.size.width - AVATAR_SIZE)/2.0, FOLLOWER_LABEL_HEIGHT)];
    followings.text = @"Follows";
    followings.textColor = [UIColor grayColor];
    followings.font = [UIFont systemFontOfSize:10];
    followings.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:followings];
    
    CGFloat followButtonWidth = 80;
    
    UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2 + followButtonWidth, userAvatar.frame.origin.y + userAvatar.frame.size.height + PADDING, self.view.frame.size.width - PADDING * 4 - followButtonWidth * 2, 40)];
    username.textAlignment = NSTextAlignmentCenter;
    username.text = @"USERNAME";
    username.textColor = [UIColor darkGrayColor];
    username.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [self.view addSubview:username];
    
    UIButton * follow = [[UIButton alloc] initWithFrame:CGRectMake(username.frame.origin.x + username.frame.size.width + PADDING, username.frame.origin.y, followButtonWidth, username.frame.size.height)];
    [follow setImage:[ImageUtil renderImage:[UIImage imageNamed:@"follow"] atSize:CGSizeMake(40, 40)] forState:UIControlStateNormal];
    [self.view addSubview:follow];
    
    UIButton * message = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, username.frame.origin.y, followButtonWidth, username.frame.size.height)];
    [message setImage:[ImageUtil renderImage:[UIImage imageNamed:@"message"] atSize:CGSizeMake(35, 30)] forState:UIControlStateNormal];
    [self.view addSubview:message];
    
    UIButton * wants = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, username.frame.origin.y + username.frame.size.height + PADDING * 2, (self.view.frame.size.width - PADDING * 2)/2.0, 30)];
    [wants setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(15, 15)] color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    [wants setTitle:@" 5 wants" forState:UIControlStateNormal];
    wants.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [wants setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:wants];
    
    UIButton * haves = [[UIButton alloc] initWithFrame:CGRectMake(wants.frame.size.width + wants.frame.origin.x, wants.frame.origin.y, (self.view.frame.size.width - PADDING * 2)/2.0, 30)];
    [haves setImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(15, 15)] forState:UIControlStateNormal];
    [haves setTitle:@" 15 haves" forState:UIControlStateNormal];
    haves.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [haves setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:haves];
    
    UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, wants.frame.origin.y, self.view.frame.size.width - PADDING * 2, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topLine];
    
    UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, wants.frame.origin.y + wants.frame.size.height, self.view.frame.size.width - PADDING * 2, 0.5)];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottomLine];
    
    UILabel * middleLine = [[UILabel alloc] initWithFrame:CGRectMake(wants.frame.origin.x + wants.frame.size.width, wants.frame.origin.y + 4, 1, wants.frame.size.height - 8)];
    middleLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:middleLine];
    
    CGFloat imageSize = (self.view.frame.size.width - PADDING * 4)/3.0;
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, wants.frame.origin.y + wants.frame.size.height + PADDING, imageSize, imageSize)];
    image1.contentMode = UIViewContentModeScaleAspectFill;
    image1.clipsToBounds = YES;
    image1.image = [UIImage imageNamed:@"image1.jpg"];
    [self.view addSubview:image1];
    
    UIImageView *image2 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 2 + imageSize, image1.frame.origin.y, imageSize, imageSize)];
    image2.contentMode = UIViewContentModeScaleAspectFill;
    image2.clipsToBounds = YES;
    image2.image = [UIImage imageNamed:@"image2.jpg"];
    [self.view addSubview:image2];
    
    UIImageView *image3 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 3 + imageSize * 2, image1.frame.origin.y, imageSize, imageSize)];
    image3.contentMode = UIViewContentModeScaleAspectFill;
    image3.clipsToBounds = YES;
    image3.image = [UIImage imageNamed:@"image3.jpg"];
    [self.view addSubview:image3];
    
    UIImageView *image4 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, image1.frame.origin.y + image1.frame.size.height + PADDING, imageSize, imageSize)];
    image4.contentMode = UIViewContentModeScaleAspectFill;
    image4.clipsToBounds = YES;
    image4.image = [UIImage imageNamed:@"image4.jpg"];
    [self.view addSubview:image4];
    
    UIImageView *image5 = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING * 2 + imageSize, image4.frame.origin.y, imageSize, imageSize)];
    image5.contentMode = UIViewContentModeScaleAspectFill;
    image5.clipsToBounds = YES;
    image5.image = [UIImage imageNamed:@"image5.jpg"];
    [self.view addSubview:image5];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
