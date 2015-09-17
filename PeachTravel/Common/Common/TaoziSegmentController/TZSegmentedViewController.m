//
//  TZSegmentedViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZSegmentedViewController.h"
#import "MakePlanSearchController.h"

@interface TZSegmentedViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UIViewController *currentViewController;
//@property (nonatomic, strong) UIView *indicateView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, weak) UISearchBar * searchBar2;

@end

@implementation TZSegmentedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置segment的样式并添加到控制器中
    UIImageView * bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 48)];
    // 设置图片填充格式
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    bgView.clipsToBounds = YES;
    bgView.userInteractionEnabled = YES;
    bgView.image = [UIImage imageNamed:@"Artboard_Top_Bg"];
//    [self.view addSubview:bgView];
    
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:_segmentedTitles];
    
    NSDictionary *normolDic = [NSDictionary dictionaryWithObjectsAndKeys:TEXT_COLOR_TITLE_SUBTITLE,NSForegroundColorAttributeName,nil];
    [segControl setTitleTextAttributes:normolDic forState:UIControlStateNormal];
    
    NSDictionary *selectedDic = [NSDictionary dictionaryWithObjectsAndKeys:APP_THEME_COLOR,NSForegroundColorAttributeName,nil];
    [segControl setTitleTextAttributes:selectedDic forState:UIControlStateSelected];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat segControlX = (screenW - 136) / 2;
    segControl.frame = CGRectMake(segControlX, 10, 136, 28);
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segControl.selectedSegmentIndex = 0;
    segControl.backgroundColor = APP_PAGE_COLOR;
    [bgView addSubview:segControl];
    self.view.backgroundColor = [UIColor whiteColor];
    [segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segmentControl = segControl;
    

    
    for (UIViewController *ctl in _viewControllers) {
//        [ctl.view setFrame:self.view.bounds];
        [ctl.view setFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 70)];
    }
    UIViewController *firstCtl = [_viewControllers firstObject];
    _currentViewController = firstCtl;
    [self addChildViewController:firstCtl];
    [self.view addSubview:firstCtl.view];
    
    self.navigationItem.titleView = segControl;
    
    [self setupSearchBar];
}

#pragma mark - 添加searchBar
- (void)setupSearchBar{
    
    UISearchBar * searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, kWindowWidth, 44);
    searchBar.delegate = self;
    self.searchBar2 = searchBar;
    [_searchBar2 setPlaceholder:@"城市/国家"];
    _searchBar2.tintColor = APP_PAGE_COLOR;
    _searchBar2.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar2 setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar2 setBackgroundColor:APP_PAGE_COLOR];
    _searchBar2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.view addSubview:searchBar];
}


// 设置导航栏标题
- (void)setNavBarTitle:(NSString *)navBarTitle
{
    _navBarTitle = navBarTitle;
    
    self.navigationItem.title = navBarTitle;
}

-(void)segmentAction:(UISegmentedControl *)segment {
    [self changePage:segment.selectedSegmentIndex];
}

- (void)setSelectedIndext:(NSInteger)selectedIndext
{
    if (selectedIndext == _selectedIndext) {
        return;
    }
    [self changePage:selectedIndext];
}

- (void)finishSwithPages
{
    
}

- (void)changePageAction:(UIButton *)sender
{
    [self changePage:sender.tag];
}

- (void)changePage:(NSInteger)pageIndex
{
    UIViewController *newController = [_viewControllers objectAtIndex:pageIndex];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    [self replaceController:_currentViewController newController:newController];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:_duration options:_animationOptions animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentViewController = newController;
        }else{
            self.currentViewController = oldController;
        }
    }];
    [self finishSwithPages];
}


@end
