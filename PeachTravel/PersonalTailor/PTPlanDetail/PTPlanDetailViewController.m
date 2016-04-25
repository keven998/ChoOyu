//
//  PTPlanDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTPlanDetailViewController.h"
#import "MyGuidesTableViewCell.h"
#import "ChatViewController.h"
#import "PeachTravel-swift.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "PTTakerTableViewCell.h"
#import "DownSheet.h"
#import "TZPayManager.h"
#import "PersonalTailorManager.h"
#import "TripDetailRootViewController.h"
#import "TripPlanSettingViewController.h"

@interface PTPlanDetailViewController ()<UITableViewDelegate, UITableViewDataSource, DownSheetDelegate>

@property (nonatomic, strong) NSArray<MyGuideSummary *>* guideDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *toolBar;
@property (strong, nonatomic) DownSheet *payDownSheet;
@property (strong, nonatomic) TZPayManager *payManager;

@end

@implementation PTPlanDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"方案详情";
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:@"myGuidesCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTTakerTableViewCell" bundle:nil] forCellReuseIdentifier:@"takerCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contentCell"];

    _guideDataSource = _ptPlanDetail.dataSource;
    [self renderToolBar];

}

- (IBAction)chatWithSeller:(UIButton *)sender
{
    
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_ptPlanDetail.seller.userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    
    chatController.chatterName = _ptPlanDetail.seller.nickName;
    
    ChatSettingViewController *menuViewController = [[ChatSettingViewController alloc] init];
    menuViewController.currentConversation= conversation;
    menuViewController.chatterId = conversation.chatterId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    menuViewController.containerCtl = frostedViewController;
    
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    chatController.backBlock = ^{
        [frostedViewController.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

- (void)renderToolBar
{
    if (_toolBar) {
        [_toolBar removeFromSuperview];
        _toolBar = nil;
    }
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    
    if (_publishUserId == [AccountManager shareAccountManager].account.userId && !_hasBuy) {
        UIButton *makePTPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
        [makePTPlanButton setTitle:@"立即支付" forState:UIControlStateNormal];
        [makePTPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [makePTPlanButton addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:makePTPlanButton];
    }
}

- (void)pay:(UIButton *)sender
{
    DownSheetModel *modelOne = [[DownSheetModel alloc] init];
    modelOne.title = @"支付宝";
    modelOne.icon= @"icon_pay_alipay";
    
    DownSheetModel *modelTwo = [[DownSheetModel alloc] init];
    modelTwo.title = @"微信";
    modelTwo.icon = @"icon_pay_wechat";
    
    _payDownSheet = [[DownSheet alloc] initWithlist:@[modelOne, modelTwo] height:40 andTitle:@"选择支付方式"];
    _payDownSheet.delegate = self;
    [_payDownSheet showInView:self];
}

#pragma mark - DownSheetDelegate

- (void)didSelectIndex:(NSInteger)index
{
    _payManager = [[TZPayManager alloc] init];
    TZPayPlatform platform;
    if (index == 0) {
        platform = kAlipay;
    } else {
        platform = kWeichatPay;
    }
    
    [PersonalTailorManager asyncSelectPlan:_ptPlanDetail.planId withPtId:_ptId completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            [_payManager asyncPayPersonalTailorPlan:_ptId payPlatform:platform completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"支付成功"];
                    _ptPlanDetail.hasBuy = YES;
                    [self.tableView reloadData];
                } else {
                    [SVProgressHUD showHint:@"支付失败"];
                }
                
            }];
        } else {
            [SVProgressHUD showHint:@"支付失败"];
        }
    }];
    
}

- (void)shouldDismissSheet
{
    [_payDownSheet dismissSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return _guideDataSource.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_guideDataSource.count) {
        return 3;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60 ;
        
    } else if (indexPath.section == 1) {
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"整套方案总价:  %ld元\n\n", (NSInteger)_ptPlanDetail.totalPrice];
        [content appendString:_ptPlanDetail.desc];
        CGRect rect = [[[NSAttributedString alloc] initWithString:content] boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return rect.size.height+40;
        
    } else if (indexPath.section == 2) {
        return 136;
    }
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 40)];
    contentLabel.textColor = COLOR_TEXT_I;
    contentLabel.font = [UIFont systemFontOfSize:16.0];
    if (section == 0) {
        contentLabel.text = @"接单人";
    }
    if (section == 1) {
        if (_hasBuy) {
            contentLabel.text = @"方案详情  (已支付)";
        } else {
            contentLabel.text = @"方案详情";
        }
    }
    if (section == 2) {
        contentLabel.text = @"方案行程";
    }
    [headerView addSubview:contentLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PTTakerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"takerCell" forIndexPath:indexPath];
        
        UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
        [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
        [chatButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        chatButton.layer.cornerRadius = 4.0;
        chatButton.layer.borderColor = APP_THEME_COLOR.CGColor;
        chatButton.layer.borderWidth = 0.5;
        chatButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [chatButton addTarget:self action:@selector(chatWithSeller:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = chatButton;
        cell.nicknameLabel.text = [NSString stringWithFormat:@"%@\n", _ptPlanDetail.seller.nickName];
        cell.contentLabel.text = [NSString stringWithFormat:@"在 %@ 号提交了方案", _ptPlanDetail.commitTimeStr];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_ptPlanDetail.seller.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCell" forIndexPath:indexPath];
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.numberOfLines = 0;
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"整套方案总价:  %ld元\n\n", (NSInteger)_ptPlanDetail.totalPrice];
        [content appendString:_ptPlanDetail.desc];
        cell.textLabel.text = content;
        return cell;
        
    } else {
        MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myGuidesCell" forIndexPath:indexPath];
        MyGuideSummary *summary = [_guideDataSource objectAtIndex:indexPath.row];
        if ([summary.status isEqualToString:@"traveled"]) {
            cell.markImageView.hidden = NO;
        } else {
            cell.markImageView.hidden = YES;
        }

        cell.guideSummary = summary;
        cell.isCanSend = NO;
        cell.tag = indexPath.row;
        TaoziImage *image = [summary.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        
        cell.titleBtn.attributedText = nil;
        cell.titleBtn.text = summary.title;
        cell.playedBtn.hidden = YES;
        cell.deleteBtn.hidden = YES;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        [self goPlan:indexPath];
    }
}

- (void)goPlan:(NSIndexPath *)indexPath
{
    MyGuideSummary *guideSummary = [_guideDataSource objectAtIndex:indexPath.row];
    TripDetailRootViewController *tripDetailRootCtl = [[TripDetailRootViewController alloc] init];
    tripDetailRootCtl.canEdit = NO;
    tripDetailRootCtl.userId = [AccountManager shareAccountManager].account.userId;
    tripDetailRootCtl.isMakeNewTrip = NO;
    tripDetailRootCtl.tripId = guideSummary.guideId;
    
    TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailRootCtl menuViewController:tpvc];
    tpvc.rootViewController = tripDetailRootCtl;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

@end
