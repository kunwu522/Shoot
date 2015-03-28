//
//  TagViewController.m
//  Shoot
//
//  Created by LV on 3/21/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "TagViewController.h"
#import "ColorDefinition.h"
#import "ImageUtil.h"
#import "UIViewHelper.h"

@interface TagViewController ()

@property (nonatomic, retain) UILabel *tagLabel;
@property (nonatomic, retain) UIImageView *imageDisplayView;
@property (retain, nonatomic) UIButton * gridViewButton;
@property (retain, nonatomic) UIButton * listViewButton;
@property (retain, nonatomic) UIButton * locationViewButton;
@property (retain, nonatomic) UIButton * want;
@property (retain, nonatomic) UIButton * wantCount;
@property (retain, nonatomic) UIButton * have;
@property (retain, nonatomic) UIButton * haveCount;

@end

@implementation TagViewController

static const CGFloat PADDING = 10;
static const CGFloat HEADER_HEIGHT = 200;
static const CGFloat TAG_LABEL_HEIGHT = 30;
static const NSInteger LOCATION_VIEW_TAG = 102;

static const CGFloat BUTTON_ICON_SIZE = 15;
static const CGFloat BUTTON_SIZE = 25;
static const CGFloat BUTTON_FONT_SIZE = 11;
static const CGFloat VIEW_BUTTON_HEIGHT = 35;
static const NSInteger GRID_VIEW_TAG = 100;
static const NSInteger LIST_VIEW_TAG = 101;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    self.imageDisplayView.image = [UIImage imageNamed:@"image1.jpg"];
    self.imageDisplayView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageDisplayView.clipsToBounds = YES;
    [self.view addSubview:self.imageDisplayView];
    
    self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.imageDisplayView.frame.origin.y + self.imageDisplayView.frame.size.height + PADDING, self.view.frame.size.width - PADDING * 2, TAG_LABEL_HEIGHT)];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.textColor = [ColorDefinition darkRed];
    self.tagLabel.font = [UIFont boldSystemFontOfSize:14];
    self.tagLabel.text = self.tag.tag;
    [self.view addSubview:self.tagLabel];
    
    CGFloat buttonWidth = (self.view.frame.size.width - PADDING * 2)/2.0;
    CGFloat countLabelWidth = buttonWidth - BUTTON_SIZE - PADDING * 2;
    
    self.want = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 0.5 - BUTTON_SIZE/2.0, self.tagLabel.frame.origin.y + self.tagLabel.frame.size.height + PADDING, BUTTON_SIZE, BUTTON_SIZE)];
    [self.want setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"want-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.want setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.want.backgroundColor = [ColorDefinition lightRed];
    self.want.layer.cornerRadius = self.want.frame.size.width/2.0;
    self.want.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.view addSubview:self.want];
//    [self.want addTarget:self action:@selector(wantIt:)forControlEvents:UIControlEventTouchDown];
    
    self.wantCount = [[UIButton alloc] initWithFrame:CGRectMake(self.want.frame.origin.x + self.want.frame.size.width + PADDING, self.want.frame.origin.y, countLabelWidth, BUTTON_SIZE)];
    [self.wantCount setTitle:[UIViewHelper getCountString:self.tag.want_count] forState:UIControlStateNormal];
    [self.wantCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.wantCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.wantCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.view addSubview:self.wantCount];
//    [self.wantCount addTarget:self action:@selector(showWant:)forControlEvents:UIControlEventTouchDown];
    
    self.have = [[UIButton alloc] initWithFrame:CGRectMake(PADDING + buttonWidth * 1.5 - BUTTON_SIZE/2.0, self.want.frame.origin.y, self.want.frame.size.width, self.want.frame.size.height)];
    [self.have setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"have-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.have setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.have.backgroundColor = [ColorDefinition blueColor];
    self.have.layer.cornerRadius = self.have.frame.size.width/2.0;
    self.have.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.view addSubview:self.have];
    
    self.haveCount = [[UIButton alloc] initWithFrame:CGRectMake(self.have.frame.origin.x + self.have.frame.size.width + PADDING, self.have.frame.origin.y, buttonWidth/2.0 - BUTTON_SIZE/2.0 - PADDING, BUTTON_SIZE)];
    [self.haveCount setTitle:[UIViewHelper getCountString:self.tag.have_count] forState:UIControlStateNormal];
    [self.haveCount setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.haveCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.haveCount.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
    [self.view addSubview:self.haveCount];
//    [self.haveCount addTarget:self action:@selector(showHaveIt:)forControlEvents:UIControlEventTouchDown];
    
    CGFloat viewButtonWidth = self.view.frame.size.width/3.0;
    
    self.gridViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.want.frame.size.height + self.want.frame.origin.y + PADDING * 2, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.gridViewButton.tag = GRID_VIEW_TAG;
//    [self.gridViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.gridViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"grid-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[ColorDefinition darkRed]] forState:UIControlStateNormal];
    [self.view addSubview:self.gridViewButton];
    
    self.listViewButton = [[UIButton alloc] initWithFrame:CGRectMake(viewButtonWidth, self.gridViewButton.frame.origin.y, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.listViewButton.tag = LIST_VIEW_TAG;
//    [self.listViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.listViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"list-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.view addSubview:self.listViewButton];
    
    self.locationViewButton = [[UIButton alloc] initWithFrame:CGRectMake(viewButtonWidth * 2, self.gridViewButton.frame.origin.y, viewButtonWidth, VIEW_BUTTON_HEIGHT)];
    self.locationViewButton.tag = LOCATION_VIEW_TAG;
//    [self.locationViewButton addTarget:self action:@selector(viewChanged:)forControlEvents:UIControlEventTouchDown];
    [self.locationViewButton setImage:[ImageUtil colorImage:[ImageUtil renderImage:[UIImage imageNamed:@"location-icon"] atSize:CGSizeMake(BUTTON_ICON_SIZE, BUTTON_ICON_SIZE)] color:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.view addSubview:self.locationViewButton];
    
    UILabel * topLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.gridViewButton.frame.origin.y, self.view.frame.size.width - PADDING * 4, 0.3)];
    topLine.backgroundColor = [UIColor grayColor];
    [self.view addSubview:topLine];
    
    UILabel * middleLine1 = [[UILabel alloc] initWithFrame:CGRectMake(self.gridViewButton.frame.origin.x + self.gridViewButton.frame.size.width, self.gridViewButton.frame.origin.y + 4, 0.3, self.gridViewButton.frame.size.height - 8)];
    middleLine1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:middleLine1];
    
    UILabel * middleLine2 = [[UILabel alloc] initWithFrame:CGRectMake(self.listViewButton.frame.origin.x + self.listViewButton.frame.size.width, self.listViewButton.frame.origin.y + 4, 0.3, self.listViewButton.frame.size.height - 8)];
    middleLine2.backgroundColor = [UIColor grayColor];
    [self.view addSubview:middleLine2];
    
    UILabel * bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(PADDING * 2, self.gridViewButton.frame.origin.y + self.gridViewButton.frame.size.height, self.view.frame.size.width - PADDING * 4, 0.3)];
    bottomLine.backgroundColor = [UIColor grayColor];
    [self.view addSubview:bottomLine];
}

- (void)doDoubleTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
