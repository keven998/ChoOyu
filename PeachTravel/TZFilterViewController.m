//
//  TZFilterViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZFilterViewController.h"
#import "RNGridMenu.h"
#import "UIImage+BoxBlur.h"
#import <Accelerate/Accelerate.h>


@interface TZFilterViewController ()
/**
 *  背景面板的 view
 */
@property (nonatomic, strong) UIImageView *backGroundImageView;

/**
 *  筛选的面板
 */
@property (nonatomic, strong) TZFilterView *filterView;

@property (nonatomic, weak) UIViewController *rootViewController;

@property (nonatomic, strong) UIImage *screenShotImage;

@end

@implementation TZFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.backGroundImageView];

    [self.view addSubview:self.filterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewDisApper");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewDisApper");
}

- (TZFilterView*)filterView
{
    if (!_filterView) {
        _filterView = [[TZFilterView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+50, self.view.bounds.size.width, 305)];
        _filterView.backgroundColor = [UIColor whiteColor];
        _filterView.filterTitles = _filterTitles;
        _filterView.lineCountPerFilterType = _lineCountPerFilterType;
        _filterView.selectedItmesIndex = _selectedItmesIndex;
        _filterView.filterItemsArray = _filterItemsArray;
        [_filterView.comfirmBtn addTarget:self action:@selector(comfirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterView;
}

- (UIImageView *)backGroundImageView
{
    if (!_backGroundImageView) {
        _backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.rootViewController.view.bounds.size.width,self.rootViewController.view.bounds.size.height)];
        _backGroundImageView = [[UIImageView alloc] initWithFrame:_rootViewController.view.frame];
        _backGroundImageView.layer.cornerRadius = 5.0;
        _backGroundImageView.clipsToBounds = YES;
        _backGroundImageView.userInteractionEnabled = YES;
        [self screenShotWithView:_rootViewController.view];
        _backGroundImageView.image = self.screenShotImage;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilterView)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        
        [_backGroundImageView addGestureRecognizer:tap];
    }
    return _backGroundImageView;
}

- (void)screenShotWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    image = [UIImage imageWithData:imageData];
    
    _screenShotImage = image;
}

/**
 *  筛选完后点击确认按钮
 *
 *  @param sender
 */
- (void)comfirm:(id)sender
{
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterView.itemsArray.count; i++) {
        NSArray *itemsPerType = [_filterView.itemsArray objectAtIndex:i];
        for (int j = 0; j < itemsPerType.count ; j++) {
            UIButton *btn = [itemsPerType objectAtIndex:j];
            if (btn.selected) {
                [selectedItems addObject:[NSNumber numberWithInteger:j]];
            }
        }
    }
    [_delegate didSelectedItems:selectedItems];
    [self hideFilterView];
}

- (void)showFilterViewInViewController:(UIViewController *)parentViewController
{
    _filterViewIsShowing = YES;
    _rootViewController = parentViewController;

    self.backGroundImageView.frame = CGRectMake(4,4,self.rootViewController.view.bounds.size.width-8,self.rootViewController.view.bounds.size.height-8);
    [_rootViewController addChildViewController:self];
    [_rootViewController.view addSubview:self.view];
    [self screenShotWithView:_rootViewController.view];
    self.backGroundImageView.image = [_screenShotImage drn_boxblurImageWithBlur:0.17];
    [UIView animateWithDuration:0.35 animations:^{
        _filterView.frame = CGRectMake(0, self.view.bounds.size.height-_filterView.frame.size.height, self.view.bounds.size.width, 305);
        _backGroundImageView.frame = CGRectMake(30, 30, self.view.bounds.size.width-60, self.view.bounds.size.height-60);
    } completion:^(BOOL finished) {

    }];
}

- (void)hideFilterView
{
    _filterViewIsShowing = NO;
    _backGroundImageView.frame = CGRectMake(35, 35, self.view.bounds.size.width-70, self.view.bounds.size.height-70);
    [UIView animateWithDuration:0.35 animations:^{
        _filterView.frame = CGRectMake(0, self.view.bounds.size.height+50, self.view.bounds.size.width, 305);
        _backGroundImageView.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}

@end
