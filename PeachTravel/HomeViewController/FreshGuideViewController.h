//
//  ICETutorialController.h
//
//
//  Created by Patrick Trillsam on 25/03/13.
//  Copyright (c) 2013 Patrick Trillsam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TUTORIAL_LABEL_TEXT_COLOR               [UIColor whiteColor]
#define TUTORIAL_LABEL_HEIGHT                   45
#define TUTORIAL_TITLE_FONT                     [UIFont fontWithName:@"Helvetica-Bold" size:17.0f]
#define TUTORIAL_TITLE_LINES_NUMBER             1
#define TUTORIAL_TITLE_OFFSET                   180
#define TUTORIAL_SUB_TITLE_FONT                 [UIFont fontWithName:@"Helvetica" size:15.0f]
#define TUTORIAL_SUB_TITLE_LINES_NUMBER         2
#define TUTORIAL_SUB_TITLE_OFFSET               150

typedef NS_OPTIONS(NSUInteger, ScrollingState) {
    ScrollingStateAuto      = 1 << 0,
    ScrollingStateManual    = 1 << 1,
    ScrollingStateLooping   = 1 << 2,
};

typedef void (^ButtonBlock)(UIButton *button);

@protocol ICETutorialControllerDelegate;
@interface  FreshGuideViewController: TZViewController <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL autoScrollEnabled;
@property (nonatomic, weak) id<ICETutorialControllerDelegate> delegate;

- (instancetype)initWithPages:(NSArray *)pages;
- (instancetype)initWithPages:(NSArray *)pages
                     delegate:(id<ICETutorialControllerDelegate>)delegate;

- (void)setPages:(NSArray*)pages;
- (NSUInteger)numberOfPages;

- (void)startScrolling;
- (void)stopScrolling;

- (ScrollingState)getCurrentState;

@end

@protocol ICETutorialControllerDelegate <NSObject>

@optional
- (void)tutorialController:(FreshGuideViewController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex;
- (void)tutorialControllerDidReachLastPage:(FreshGuideViewController *)tutorialController;
- (void)tutorialController:(FreshGuideViewController *)tutorialController didClickOnLeftButton:(UIButton *)sender;
- (void)tutorialController:(FreshGuideViewController *)tutorialController didClickOnRightButton:(UIButton *)sender;
@end
