//
//  TripPlanSettingViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/14.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TripPlanSettingViewController.h"
#import "CityDetailTableViewController.h"
#import "SuperPoi.h"
#import "ShareActivity.h"
#import "TaoziChatMessageBaseViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height
@interface TripPlanSettingViewController ()<UITableViewDelegate,UITableViewDataSource,TripUpdateDelegate,ActivityDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIView *_headerView;
}
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@property (strong,nonatomic) UIView *footerView;
@end

@implementation TripPlanSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _dataArray = [NSMutableArray array];
    [_dataArray addObject:_tripDetail.destinations];
//    [self createFooterView];
    [self createTableView];

    
}

- (void)setTripDetail:(TripDetail *)tripDetail {
    _tripDetail = tripDetail;                  
}
//-(void)createFooterView
//{
//    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
//    UIButton *footerBtn = [[UIButton alloc]initWithFrame:_footerView.bounds];
//    [_footerView addSubview:footerBtn];
//    [footerBtn setTitle:@"添加" forState:UIControlStateNormal];
//    
//}


-(void)createTableView
{
    
    _tableView = ({
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT-30) style:UITableViewStyleGrouped];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.opaque = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.bounces = NO;
        _tableView;
    });
//    _tableView.tableHeaderView = _headerView;
//    _tableView.tableFooterView = _footerView;
    [self.view addSubview:_tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return _tripDetail.destinations.count+1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _tripDetail.tripTitle;;
    }
    else
        return @"已选目的地";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = TEXT_COLOR_TITLE;
        cell.textLabel.highlightedTextColor = TEXT_COLOR_TITLE_DESC;
        
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"分享";
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"转发到其他平台";
        }
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == _tripDetail.destinations.count) {
            cell.textLabel.text = @"添加";
        }
        else{
            CityDestinationPoi *model = _tripDetail.destinations[indexPath.row];
            cell.textLabel.text = model.zhName;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self shareOnTaozi];
        }else if (indexPath.row == 1){
            [self share:nil];
        }
        
    }
    
    
    if (indexPath.section == 1) {
        if (indexPath.row == _tripDetail.destinations.count) {
            NSLog(@"添加");
        }
        else{
            CityDetailTableViewController *cityCtl = [[CityDetailTableViewController alloc]init];
            CityDestinationPoi *model = _tripDetail.destinations[indexPath.row];
            cityCtl.cityId = model.cityId;
            [self.navigationController pushViewController:cityCtl animated:YES];
        }
    }
    
}
-(void)shareOnTaozi
{
    _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
    _chatRecordListCtl.delegate = self;
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:_chatRecordListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)share:(id)sender
{
    [MobClick event:@"event_share_plan_detail"];
    NSArray *shareButtonimageArray = @[@"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_qzone.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"朋友圈", @"微信好友", @"QQ", @"QQ空间", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.view];
}

#pragma mark - AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = _tripDetail.tripDetailUrl;
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"我的《%@》来了，亲们快快来围观～",_tripDetail.tripTitle];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"我的《%@》来了，亲们快快来围观~ %@",_tripDetail.tripTitle, url];
    TaoziImage *image = [_tripDetail.images firstObject];
    NSString *imageUrl = image.imageUrl;
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionCenter];
    switch (imageIndex) {
            
            
        case 0: {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 1: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.qqData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qzoneData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContentWithoutUrl image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 4:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil  socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        default:
            break;
    }
}

/**
 *      TripUpdateDelegate
 */
-(void)tripUpdate:(id)detail
{
    
}
@end
