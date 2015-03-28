//
//  UserShootCalendarView.m
//  Shoot
//
//  Created by LV on 3/21/15.
//  Copyright (c) 2015 Shoot. All rights reserved.
//

#import "UserShootCalendarView.h"
#import <RestKit/RestKit.h>
#import "MNCalendarView.h"
#import "UserTagShootDao.h"
#import "UIViewHelper.h"

@interface UserShootCalendarView () <MNCalendarViewDataSource, MNCalendarViewDelegate>

@property (retain, nonatomic) User * user;
@property (retain, nonatomic) NSNumber *tagType;
@property (retain, nonatomic) UIViewController *parentController;

@property (retain, nonatomic) MNCalendarView *calendarView;

@end

@implementation UserShootCalendarView

- (instancetype)initWithFrame:(CGRect)frame forUser:(User *)user parentController:(UIViewController *)parentController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.user = user;
        self.parentController = parentController;
        self.calendarView = [[MNCalendarView alloc] initWithFrame:frame withParentController:parentController];
        [UIViewHelper applySameSizeConstraintToView:self.calendarView superView:self];
        self.calendarView.dataSource = self;
        self.calendarView.delegate = self;
    }
    return self;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (NSPredicate *)userShootTagsPredicateFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@ && type == %@ && time >= %@ && time < %@", self.user.userID, self.tagType, fromDate, toDate];
    return predicate;
}

- (void) reloadForType:(NSNumber *)tagType
{
    self.tagType = tagType;
    NSArray *userTagShootDates = [[UserTagShootDao sharedManager] findUserTagShootDatesLocallyByUserId:self.user.userID forType:tagType];
    [self.calendarView setHighlightedDates:userTagShootDates];
    [self.calendarView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
