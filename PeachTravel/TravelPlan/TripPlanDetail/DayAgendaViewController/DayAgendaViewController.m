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
#import "MyTripSpotsMapViewController.h"
#import "BlurEffectMenu.h"
#import "AddPoiViewController.h"
#import "PoiDetailViewControllerFactory.h"
#import "AddTravelViewController.h"
#import "PlanTrafficTableViewCell.h"
#import "PlanMemoViewController.h"

#define UPPERVIEW_TAG 1000
#define BOTTOMVIEW_TAG 1001
#define WHITEVIEW_TAG 1002

@interface DayAgendaViewController ()<UITableViewDelegate, UITableViewDataSource, BlurEffectMenuDelegate, addPoiDelegate, AddTravelViewControllerDelegate, PlanMemoViewControllerDelegate>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = [NSString stringWithFormat:@"第%d天", _currentDay+1];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:tripPoiListReusableIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"PlanTrafficTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    [self.view addSubview:_tableView];
    
    _dataSource = [_tripDetail.itineraryList objectAtIndex:_currentDay];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    [btn setImage:[UIImage imageNamed:@"iconfont_jia.png"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(editSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self startAnimationWithDismiss:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
    [mapBtn setImage:[UIImage imageNamed:@"icon_navigation_map.png"] forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(mapView) forControlEvents:UIControlEventTouchUpInside];
    mapBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:btn]];

    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:mapBtn]];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [editButton setImage:[UIImage imageNamed:@"iconfont_qiehuan_2.png"] forState:UIControlStateNormal];
    editButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [editButton addTarget:self action:@selector(editTripDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editButton];
    
    [barItems addObject:editButtonItem];


    self.navigationItem.rightBarButtonItems = barItems;
    
    [self setupHeaderView];
}

- (void)editTripDetail:(id)sender
{
    ScheduleEditorViewController *sevc = [[ScheduleEditorViewController alloc] init];
    ScheduleDayEditViewController *menuCtl = [[ScheduleDayEditViewController alloc] init];
    sevc.tripDetail = _tripDetail;
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:sevc menuViewController:menuCtl];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    [self.navigationController pushViewController:frostedViewController animated:YES];
    
}


- (void)setupHeaderView
{
    if ([[[_tripDetail.travelNoteItems objectAtIndex:_currentDay] firstObject] length]) {
        _tableView.tableHeaderView = nil;
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 40, 40)];
        imageView.image = [UIImage imageNamed:@"icon_plan_memo"];
        [headerView addSubview:imageView];
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:[[_tripDetail.travelNoteItems objectAtIndex:_currentDay] firstObject] attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-74, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, kWindowWidth-74, rect.size.height+10)];
        [headerView addSubview:contentLabel];
        contentLabel.textColor = COLOR_TEXT_II;
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.text = [[_tripDetail.travelNoteItems objectAtIndex:_currentDay] firstObject];
        if (rect.size.height+10 < 60) {
            headerView.frame = CGRectMake(0, 0, kWindowWidth, 60);
        } else {
            headerView.frame = CGRectMake(0, 0, kWindowWidth, rect.size.height+10+20);
        }
        
        _tableView.tableHeaderView = headerView;
    } else
    {
        _tableView.tableHeaderView = nil;
    }
}

- (void)mapView {
    MyTripSpotsMapViewController *mapViewCtl = [[MyTripSpotsMapViewController alloc] init];
    mapViewCtl.tripDetail = _tripDetail;
    mapViewCtl.titleText = [NSString stringWithFormat:@"第%d天", _currentDay+1];
    mapViewCtl.currentDay = _currentDay;
    [self.navigationController pushViewController:mapViewCtl animated:YES];
    
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
        _tableView.contentInset = UIEdgeInsetsMake(sep, 0, 0, 0);
    
        CGImageRef imageUp = CGImageCreateWithImageInRect([_sceenImage CGImage], [self scaleRect:upperRect withScale:[UIScreen mainScreen].scale]);
        self.upperView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, sep-64)];
        _upperView.contentMode = UIViewContentModeScaleAspectFit;
        [_upperView setImage:[UIImage imageWithCGImage:imageUp]];

        bottomRect.origin.y = sep;
        CGImageRef imageBottom = CGImageCreateWithImageInRect([_sceenImage CGImage], [self scaleRect:bottomRect withScale:[UIScreen mainScreen].scale ]);
        self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, sep, kWindowWidth, self.view.frame.size.height-sep)];

        _bottomView.contentMode = UIViewContentModeScaleAspectFit;
        [_bottomView setImage:[UIImage imageWithCGImage:imageBottom]];
        
        [self.view addSubview:_upperView];
        [self.view addSubview:_bottomView];
        
        self.tableView.alpha = 0.5;

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
        [UIView animateWithDuration:0.3
                         animations:^(void) {
                             [self.upperView setFrame:CGRectMake(0, 64, kWindowWidth, sep-64)];
                             [self.bottomView setFrame:CGRectMake(0, sep, kWindowWidth, self.view.frame.size.height-sep)];
                             _tableView.contentInset = UIEdgeInsetsMake(sep, 0, 0, 0);
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
    [super viewWillAppear:animated];
      
    if (_dataSource) {
        [_tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)dealloc
{
    self.tableView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 70;
    }
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[_tripDetail.trafficItems objectAtIndex:_currentDay] count];
    }
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PlanTrafficTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        PlanTravelModel *model = [[_tripDetail.trafficItems objectAtIndex:_currentDay] objectAtIndex:indexPath.row];
        cell.titleLabel.text = model.trafficName;
        cell.pointLabel.text = [NSString stringWithFormat:@"%@ -> %@", model.startPointName, model.endPointName];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ -> %@", model.startDate, model.endDate];
        if ([model.type isEqualToString:@"airline"]) {
            cell.headerImageView.image = [UIImage imageNamed:@"icon_plan_airline"];
        }
        if ([model.type isEqualToString:@"trainRoute"]) {
            cell.headerImageView.image = [UIImage imageNamed:@"icon_plan_train"];
        }
        if ([model.type isEqualToString:@"other"]) {
            cell.headerImageView.image = [UIImage imageNamed:@"icon_plan_other"];
        }
        return cell;
    } else {
        SuperPoi *tripPoi = _dataSource[indexPath.row];
        TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tripPoiListReusableIdentifier forIndexPath:indexPath];
        cell.tripPoi = tripPoi;
        return cell;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        SuperPoi *tripPoi = [self.dataSource objectAtIndex:indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        switch (tripPoi.poiType) {
            case kSpotPoi: {
                SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
                spotDetailCtl.spotId = tripPoi.poiId;
                
                [self.navigationController pushViewController:spotDetailCtl animated:YES];
                
            }
                break;
            default: {
                CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:tripPoi.poiType];
                ctl.poiId = tripPoi.poiId;
                [self.navigationController pushViewController:ctl animated:YES];
                
            }
                break;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定删除当天的交通？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[_tripDetail.trafficItems objectAtIndex:_currentDay] removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
                [_tripDetail saveTrip:^(BOOL isSuccesss) {
                    
                }];
            }
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

#pragma IBAction - editSchedule

- (void) editSchedule
{
    
    
    BlurEffectMenuItem *addMattersItem=[[BlurEffectMenuItem alloc]init];
    [addMattersItem setTitle:@"游玩"];
    [addMattersItem setIcon:[UIImage imageNamed:@"icon_cityDetail_spot"]];
    
    BlurEffectMenuItem *addSchedulesItem=[[BlurEffectMenuItem alloc]init];
    [addSchedulesItem setTitle:@"酒店"];
    [addSchedulesItem setIcon:[UIImage imageNamed:@"icon_cityDetail_restaurant"]];
    
    BlurEffectMenuItem *setupChatItem=[[BlurEffectMenuItem alloc]init];
    [setupChatItem setTitle:@"交通"];
    [setupChatItem setIcon:[UIImage imageNamed:@"icon_cityDetail_traffic"]];
    
    BlurEffectMenuItem *searchContactsItem=[[BlurEffectMenuItem alloc]init];
    [searchContactsItem setTitle:@"备注"];
    [searchContactsItem setIcon:[UIImage imageNamed:@"icon_cityDetail_travelNote"]];
    
    BlurEffectMenu *menu=[[BlurEffectMenu alloc]initWithMenus:@[addMattersItem,addSchedulesItem,setupChatItem,searchContactsItem]];
    [menu setDelegate:self];
    menu.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [menu setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:menu animated:YES completion:nil];
}

- (void)goBack
{
    [self startAnimationWithDismiss:NO];
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BlurEffectMenu Delegate
- (void)blurEffectMenuDidTapOnBackground:(BlurEffectMenu *)menu{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blurEffectMenu:(BlurEffectMenu *)menu didTapOnItem:(BlurEffectMenuItem *)item{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"item.title:%@",item.title);
    if ([item.title isEqualToString:@"游玩"]) {
        AddPoiViewController *ctl = [[AddPoiViewController alloc] init];
        ctl.currentDayIndex = _currentDay;
        ctl.poiType = kSpotPoi;
        ctl.tripDetail = _tripDetail;
        ctl.shouldEdit = YES;
        ctl.delegate = self;
        [self presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        
    }
    if ([item.title isEqualToString:@"酒店"]) {
        AddPoiViewController *ctl = [[AddPoiViewController alloc] init];
        ctl.currentDayIndex = _currentDay;
        ctl.poiType = kHotelPoi;
        ctl.tripDetail = _tripDetail;
        ctl.shouldEdit = YES;
        ctl.delegate = self;
        [self presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        
    }
    if ([item.title isEqualToString:@"交通"]) {
        AddTravelViewController *ctl = [[AddTravelViewController alloc] init];
        [self presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        ctl.delegate = self;
    }
    if ([item.title isEqualToString:@"备注"]) {
        PlanMemoViewController *ctl = [[PlanMemoViewController alloc] init];
        ctl.memo = [[_tripDetail.travelNoteItems objectAtIndex:_currentDay] firstObject];
        [self presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        ctl.delegate = self;
    }
}

- (void)endEditTravel:(id)model
{
    [[_tripDetail.trafficItems objectAtIndex:_currentDay] addObject:model];
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        
    }];
}

- (void)finishEdit
{
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        
    }];
    [_tableView reloadData];
}

- (void)memoSave:(NSString *)memo
{
    if ([[_tripDetail.travelNoteItems objectAtIndex:_currentDay] count] == 0) {
        [[_tripDetail.travelNoteItems objectAtIndex:_currentDay] addObject:memo];
    } else {
        [[_tripDetail.travelNoteItems objectAtIndex:_currentDay] replaceObjectAtIndex:0 withObject:memo];
    }
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        
    }];
    [self setupHeaderView];
}


@end
