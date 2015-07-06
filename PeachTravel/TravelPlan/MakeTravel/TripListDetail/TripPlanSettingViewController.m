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
#import "TripPlanSettingCell.h"
#import "CityNameCell.h"
#import "Destinations.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "ScheduleEditorViewController.h"

#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface TripPlanSettingViewController ()<UITableViewDelegate,UITableViewDataSource,TripUpdateDelegate,ActivityDelegate,TaoziMessageSendDelegate,CreateConversationDelegate,CreateConversationDelegate, UpdateDestinationsDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIView *_headerView;
    UIButton *_footerButton;
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
    
    [self createTableView];
    [_tableView registerNib:[UINib nibWithNibName:@"TripPlanSettingCell" bundle:nil] forCellReuseIdentifier:@"settingCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"CityNameCell" bundle:nil] forCellReuseIdentifier:@"cityNameCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)setTripDetail:(TripDetail *)tripDetail {
    _tripDetail = tripDetail;
}


-(void)createTableView
{
    
    _tableView = ({
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.opaque = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.bounces = NO;
        _tableView;
    });
    [self createFooterView];
    _tableView.tableFooterView = _footerButton;
    [self.view addSubview:_tableView];
}


-(void)createFooterView
{
    _footerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [_footerButton addTarget:self action:@selector(addPosition) forControlEvents:UIControlEventTouchUpInside];
    UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(38+20+13, 0, SCREEN_WIDTH, 44)];
    addLabel.text = @"添加";
    [_footerButton addSubview:addLabel];
    UIImageView *addImage = [[UIImageView alloc]initWithFrame:CGRectMake(43, 16, 12, 12)];
    addImage.image = [UIImage imageNamed:@"add_contact"];
    [_footerButton addSubview:addImage];
    
}

-(void)addPosition
{
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        [destinations.destinationsSelected addObject:poi];
    }
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];
    makePlanCtl.shouldOnlyChangeDestinationWhenClickNextStep = YES;
    makePlanCtl.myDelegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:makePlanCtl];
    [self presentViewController:navi animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return _tripDetail.destinations.count;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    sectionHeaderView.backgroundColor = APP_PAGE_COLOR;
    UIImageView *greenPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(19, 34, 10, 10)];
    greenPointImageView.image = [UIImage imageNamed:@"chat_drawer_poit"];
    [sectionHeaderView addSubview:greenPointImageView];
    
    UILabel *strLabel = [[UILabel alloc]initWithFrame:CGRectMake(34, 34, 200, 13)];
    strLabel.font = [UIFont systemFontOfSize:12];
    [sectionHeaderView addSubview:strLabel];
    
    if (section == 0) {
        strLabel.text = _tripDetail.tripTitle;
    }
    else {
        strLabel.text = @"目的城市";
    
    }
    return sectionHeaderView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
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
    
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"修改行程";
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"发给好友";
        }
        return cell;
    }
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        CityDestinationPoi *model = _tripDetail.destinations[indexPath.row];
        cell.textLabel.text = model.zhName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle=UITableViewCellSelectionStyleDefault;
        return cell;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ScheduleEditorViewController *sevc = [[ScheduleEditorViewController alloc] init];
            sevc.tripDetail = _tripDetail;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sevc] animated:YES completion:nil];
        } else if (indexPath.row == 1){
            //            [self share:nil];
            [self sendToFriends];
        }
        
    } else if (indexPath.section == 1) {
        CityDetailTableViewController *cityCtl = [[CityDetailTableViewController alloc]init];
        CityDestinationPoi *model = _tripDetail.destinations[indexPath.row];
        cityCtl.cityId = model.cityId;
        [self.navigationController pushViewController:cityCtl animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES ];
    
}

-(void)sendToFriends
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
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.navigationController.view];
}

#pragma mark - CreateConversationDelegate
- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    [self setChatMessageModel:taoziMessageCtl];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatTitle = chatTitle;
    taoziMessageCtl.chatterId = chatterId;
    taoziMessageCtl.chatType = chatType;
    
    [self.chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        [self.navigationController presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
    }];
}
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatType = IMMessageTypeGuideMessageType;
    taoziMessageCtl.messageId = self.tripDetail.tripId;
    
    NSMutableString *summary;
    for (CityDestinationPoi *poi in self.tripDetail.destinations) {
        NSString *s;
        if ([poi isEqual:[self.tripDetail.destinations lastObject]]) {
            s = poi.zhName;
        } else {
            s = [NSString stringWithFormat:@"%@-", poi.zhName];
        }
        [summary appendString:s];
    }
    
    taoziMessageCtl.messageDesc = summary;
    taoziMessageCtl.messageName = self.tripDetail.tripTitle;
    TaoziImage *image = [self.tripDetail.images firstObject];
    taoziMessageCtl.messageImage = image.imageUrl;
    taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%ld天", (long)self.tripDetail.dayCount];
}
#pragma mark - TaoziMessageSendDelegate

//用户确定发送景点给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
    
}

- (void)sendCancel
{
    [self dismissPopup];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.navigationController.popupViewController != nil) {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UpdateDestinationsDelegate

- (void)updateDestinations:(NSArray *)destinations
{
    [self.tripDetail updateTripDestinations:^(BOOL isSuccesss) {
        if (isSuccesss) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (CityDestinationPoi *poi in _tripDetail.destinations) {
                [array addObject:poi.zhName];
            }
            [_tableView reloadData];
        } else {
            
        }
    } withDestinations:destinations];
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
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContentWithoutUrl image:[UIImage imageNamed:@"app_icon.png"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TMCache sharedCache] setObject:detail forKey:@"last_tripdetail"];
    });
}
@end
