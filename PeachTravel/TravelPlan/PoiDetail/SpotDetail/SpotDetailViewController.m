//
//  SpotDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailViewController.h"
#import "SpotDetailView.h"
#import "SpotPoi.h"
#import "AccountManager.h"
#import "SuperWebViewController.h"
#import "SpotDetailCell.h"
#import "SpecialPoiCell.h"
#import "CommentTableViewCell.h"
#import "UIImage+BoxBlur.h"
#import "CityDescDetailViewController.h"

@interface SpotDetailViewController () <UIActionSheetDelegate>

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_default.png"] forState:UIControlStateNormal];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_hilighted.png"] forState:UIControlStateHighlighted];
    talkBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:talkBtn];
    
    super.poiType = kSpotPoi;
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.poi.comments.count + 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        return 60 * SCREEN_HEIGHT/736;
    } else if (indexPath.row == 4) {
        return  372/3;
    } else {
        return 100;
    }
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        SpotDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.categoryLabel.text = @"地址";
            cell.infomationLabel.text = self.poi.address;
            cell.image.image = [UIImage imageNamed:@"poi_icon_add"];
        } else if (indexPath.row == 1) {
            cell.categoryLabel.text = @"开放";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).openTime;
            cell.image.image = [UIImage imageNamed:@"icon_arrow"];
        } else if (indexPath.row == 2) {
            cell.categoryLabel.text = @"票价";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).priceDesc;
            cell.image.image = [UIImage imageNamed:@"poi_icon_ticket_default"];
        }  else if (indexPath.row == 3)   {
            cell.categoryLabel.text = @"电话";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).telephone;
            // 如果没有号码,就显示未知
            if (cell.infomationLabel.text.length == 0) {
//                cell.image.image = [UIImage imageNamed:@"poi_icon_phone"];
                cell.noTelLabel.text = @"未知";
                cell.noTelLabel.hidden = NO;
                cell.image.hidden = YES;
            }
            
        }
        return cell;
    } else if (indexPath.row == 4) {
        SpecialPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"specialCell" forIndexPath:indexPath];
        cell.backgroundColor = APP_PAGE_COLOR;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (((SpotPoi *)self.poi).guideUrl == nil || [((SpotPoi *)self.poi).guideUrl isBlankString]) {
            cell.planBtn.enabled = NO;
        } else {
            [cell.planBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (((SpotPoi *)self.poi).tipsUrl == nil || [((SpotPoi *)self.poi).tipsUrl isBlankString]) {
            cell.tipsBtn.enabled = NO;
        } else {
            [cell.tipsBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        if (((SpotPoi *)self.poi).trafficInfoUrl == nil || [((SpotPoi *)self.poi).trafficInfoUrl isBlankString]) {
            cell.trafficBtn.enabled = NO;
        } else {
            [cell.trafficBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        cell.commentDetail =[self.poi.comments objectAtIndex:1];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        if (indexPath.row == 0) {
            [super jumpToMap];
        } else if (indexPath.row > 0 && indexPath.row < 3) {
            [self showPoidetail:nil];
        } else if (indexPath.row == 3) {
            [super makePhone];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
}


#pragma mark - Private Methods

- (void)loadData
{
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SPOT_DETAIL, _spotId];
    [super loadDataWithUrl:url];
}

/**
 *  实现父类的发送 poi 到旅行派 的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = self.poi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[self.poi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = self.poi.desc;
    taoziMessageCtl.messageName = self.poi.zhName;
    taoziMessageCtl.messageTimeCost = ((SpotPoi *)self.poi).timeCostStr;
    taoziMessageCtl.descLabel.text = self.poi.desc;
    taoziMessageCtl.messageType = IMMessageTypeSpotMessageType;
}

/**
 *  在线预订
 *
 *  @param sender
 */
- (IBAction)book:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] initWithURL:[NSURL URLWithString:((SpotPoi *)self.poi).bookUrl]];
    webCtl.titleStr = @"在线预订";
    //    webCtl.urlStr = ((SpotPoi *)self.poi).bookUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  游玩指南
 *
 *  @param sender
 */
- (IBAction)travelGuide:(id)sender
{
    [MobClick event:@"button_item_poi_travel_notes"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点体验";
    webCtl.urlStr = ((SpotPoi *)self.poi).guideUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  坑爹攻略
 *
 *  @param sender
 */
- (IBAction)kengdie:(id)sender
{
    [MobClick event:@"button_item_poi_travel_tips"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"游玩小贴士";
    webCtl.urlStr = ((SpotPoi *)self.poi).tipsUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  交通指南
 *
 *  @param sender
 */
- (IBAction)trafficGuide:(id)sender
{
    [MobClick event:@"button_item_poi_travel_traffic"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点交通";
    webCtl.urlStr = ((SpotPoi *)self.poi).trafficInfoUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  进入地图导航
 *
 *  @param sender
 */
- (IBAction)jumpToMapview:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
}

- (void)showPoiDesc
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.des = self.poi.desc;
    cddVC.title = @"景点简介";
    [self.navigationController pushViewController:cddVC animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        return;
        
    }
    if (actionSheet.tag != kASShare) {
        NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
        switch (buttonIndex) {
            case 0:
                switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        
                    default:
                        break;
                }
                break;
                
            case 1:
                switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case 2:
                switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }
        
    } else {

        [self shareToTalk];
    }
}



@end








