//
//  DayAgendaViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DayAgendaViewController.h"
#import "POICell.h"
#import "SpotDetailViewController.h"
#import "ScheduleEditorViewController.h"
#import "TripPoiListTableViewCell.h"
#import "ScheduleDayEditViewController.h"


#define UPPERVIEW_TAG 1000
#define BOTTOMVIEW_TAG 1001
#define WHITEVIEW_TAG 1002

@interface DayAgendaViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIImageView *upperView;
@property (nonatomic, strong) UIImageView *bottomView;
@end

static NSString *tripPoiListReusableIdentifier = @"tripPoiListCell";

@implementation DayAgendaViewController

- (id)initWithDay:(NSInteger)day
{
    if (self = [super init])
    {
        _currentDay = (int)day;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:tripPoiListReusableIdentifier];
    [self.view addSubview:_tableView];
    
    _dataSource = [_tripDetail.itineraryList objectAtIndex:_currentDay];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [btn setTitle:@"调整" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(editSchedule) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];    //体验和复杂度
    [self startAnimationWithDismiss:YES];
}

// 执行动画
- (void)startAnimationWithDismiss:(BOOL)dismiss
{
    // get image of the screen
    int sep = self.sep;
    
    CGRect upperRect = CGRectMake(0, 64, kWindowWidth, sep-64);
    CGRect bottomRect = CGRectMake(0, sep+64, kWindowWidth, self.view.frame.size.height - sep);
    
    // animate the transform
    if (dismiss) {
        _tableView.contentInset = UIEdgeInsetsMake(sep-64, 0, 0, 0);
    
        CGImageRef imageUp = CGImageCreateWithImageInRect([_sceenImage CGImage], [self scaleRect:upperRect withScale:[UIScreen mainScreen].scale]);
        self.upperView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, sep-64)];
        _upperView.contentMode = UIViewContentModeScaleAspectFit;
        [_upperView setImage:[UIImage imageWithCGImage:imageUp]];

        bottomRect.origin.y = sep;
        CGImageRef imageBottom = CGImageCreateWithImageInRect([_sceenImage CGImage], [self scaleRect:bottomRect withScale:[UIScreen mainScreen].scale ]);
        self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, sep-64, kWindowWidth, self.view.frame.size.height-sep)];

        _bottomView.contentMode = UIViewContentModeScaleAspectFit;
        [_bottomView setImage:[UIImage imageWithCGImage:imageBottom]];
        
        [self.view addSubview:_upperView];
        [self.view addSubview:_bottomView];
        
        self.tableView.alpha = 0.5;
//        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.tableView cache:YES];
        [UIView animateWithDuration:0.5
                         animations:^(void) {
                             [_upperView setFrame:CGRectMake(0, -_upperView.bounds.size.height, _upperView.bounds.size.width, _upperView.bounds.size.height)];
                             [_bottomView setFrame:CGRectMake(0, kWindowHeight, _bottomView.bounds.size.width, _bottomView.bounds.size.height)];
                             _tableView.contentInset = UIEdgeInsetsZero;
                             self.tableView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             
                         }];
    } else {
        self.tableView.alpha = 1.0;
        [UIView animateWithDuration:0.5
                         animations:^(void) {
                             [self.upperView setFrame:CGRectMake(0, 0, kWindowWidth, sep-64)];
                             [self.bottomView setFrame:CGRectMake(0, sep-64, kWindowWidth, self.view.frame.size.height-sep+64)];
                             _tableView.contentInset = UIEdgeInsetsMake(sep-64, 0, 0, 0);
                             self.tableView.alpha = 0.5;
                         } completion:^(BOOL finished) {
            
                             [self.navigationController popViewControllerAnimated:NO];
                         }];
    }
}

- (UIViewController *)popupViewController
{
    [super popupViewController];
    
    return self;
}

- (CGRect) scaleRect:(CGRect)rect withScale:(float) scale
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
}


- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_lxp_day_schedule_detail"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (_dataSource) {
        [_tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"page_lxp_day_schedule_detail"];
}

- (void)setTitleStr:(NSString *)titleStr {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)-150, 40)];
    titleLabel.numberOfLines = 2.0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    
    NSString *dayStr;
    if (_currentDay < 9) {
        dayStr = [NSString stringWithFormat:@"0%d.Day详情", _currentDay+1];
    } else {
        dayStr = [NSString stringWithFormat:@"%d.Day详情", _currentDay+1];
    }

    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 3.0;
    ps.alignment = NSTextAlignmentCenter;
    NSDictionary *attribs = @{NSParagraphStyleAttributeName:ps};
    
    NSString *totalStr = [NSString stringWithFormat:@"%@\n%@", dayStr, titleStr];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: totalStr attributes:attribs];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, dayStr.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:NSMakeRange(dayStr.length+1, totalStr.length-dayStr.length-1)];
    
    titleLabel.attributedText = attrStr;
    self.navigationItem.titleView = titleLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = _dataSource[indexPath.row];
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tripPoiListReusableIdentifier forIndexPath:indexPath];
    cell.tripPoi = tripPoi;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
    SuperPoi *poi = _dataSource[indexPath.row];
    spotDetailCtl.spotId = poi.poiId;
    [self.navigationController pushViewController:spotDetailCtl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


#pragma IBAction - editSchedule
- (void) editSchedule {
    ScheduleEditorViewController *sevc = [[ScheduleEditorViewController alloc] init];
    sevc.rootCtl = self;
    ScheduleDayEditViewController *menuCtl = [[ScheduleDayEditViewController alloc] init];
    sevc.tripDetail = _tripDetail;
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:sevc] menuViewController:menuCtl];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:frostedViewController] animated:YES completion:nil];
}

- (void)goBack
{
    [self startAnimationWithDismiss:NO];
//    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ScheduleUpdateDelegate

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
