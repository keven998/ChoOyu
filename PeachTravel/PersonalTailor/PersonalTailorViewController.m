//
//  PersonalTailorViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PersonalTailorViewController.h"
#import "PTListTableViewCell.h"
#import "PTMakePlanViewController.h"
#import "PersonalTailorManager.h"
#import "PTPlanDetailViewController.h"
#import "StoreManager.h"
#import "ChatViewController.h"
#import "PeachTravel-swift.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"

@interface PersonalTailorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *toolBar;
@property (nonatomic) BOOL isSeller;

@property (strong, nonatomic) NSArray<PTPlanDetailModel *> *planDataSource;

@end

@implementation PersonalTailorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"需求详情";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
    [StoreManager asyncLoadStoreInfoWithStoreId:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
        if (isSuccess && storeDetail) {
            _isSeller = YES;
            
        } else {
            _isSeller = NO;
        }
        [self refreshPTData];

    }];

}

- (void)refreshPTData
{
    [PersonalTailorManager asyncLoadPTDetailDataWithItemId:_ptDetailModel.itemId completionBlock:^(BOOL isSuccess, PTDetailModel *ptDetail) {
        _ptDetailModel = ptDetail;
        _planDataSource = _ptDetailModel.plans;
        [self renderToolBar];
        [_tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    if (_ptDetailModel.consumer.userId == [AccountManager shareAccountManager].account.userId) {
        if (_ptDetailModel.bountyPaid) {
            UIButton *makePTPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
            [makePTPlanButton setTitle:@"申请退款" forState:UIControlStateNormal];
            [makePTPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
            [makePTPlanButton addTarget:self action:@selector(requestRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
            [_toolBar addSubview:makePTPlanButton];
        } else {
            _toolBar.hidden = YES;
        }
        
    } else {
        if (_isSeller) {
            BOOL isHasTake = NO;
            for (FrendModel *taker in _ptDetailModel.takers) {
                if ([AccountManager shareAccountManager].account.userId == taker.userId) {
                    isHasTake = YES;
                }

            }
            
            if (isHasTake) {
                UIButton *makePTPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/2, 49)];
                [makePTPlanButton setTitle:@"制作方案" forState:UIControlStateNormal];
                [makePTPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                [makePTPlanButton addTarget:self action:@selector(makePTPlanAction:) forControlEvents:UIControlEventTouchUpInside];
                [_toolBar addSubview:makePTPlanButton];
                
                UIButton *chatWithUser = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth/2, 0, kWindowWidth/2, 49)];
                [chatWithUser setTitle:@"联系买家" forState:UIControlStateNormal];
                [chatWithUser setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                [chatWithUser addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];
                [_toolBar addSubview:chatWithUser];
                
            } else {
                UIButton *makePTPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
                [makePTPlanButton setTitle:@"接单" forState:UIControlStateNormal];
                [makePTPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                [makePTPlanButton addTarget:self action:@selector(takePTAction:) forControlEvents:UIControlEventTouchUpInside];
                [_toolBar addSubview:makePTPlanButton];
            }
        } else {
            _toolBar.hidden = YES;
        }
    }
}


- (IBAction)contactUser:(UIButton *)sender
{
    
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_ptDetailModel.consumer.userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    
    chatController.chatterName = _ptDetailModel.consumer.nickName;
    
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

- (void)setPtDetailModel:(PTDetailModel *)ptDetailModel
{
    _ptDetailModel = ptDetailModel;
    [_tableView reloadData];
}

- (void)makePTPlanAction:(UIButton *)sender
{
    PTMakePlanViewController *ctl = [[PTMakePlanViewController alloc] init];
    ctl.ptId = _ptDetailModel.itemId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)requestRefundMoney:(UIButton *)sender
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:@"退款明细: "];
    if (_ptDetailModel.earnestMoney > 0) {
        [content appendFormat:@"定金: %ld", (NSInteger)_ptDetailModel.earnestMoney];
    }
    if (_ptDetailModel.planPaid) {
        [content appendFormat:@"方案金额: %ld", (NSInteger)_ptDetailModel.earnestMoney];

    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定取消退款?" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        
    }];
}

- (void)takePTAction:(UIButton *)sender
{
    [PersonalTailorManager asyncTakePersonalTailor:_ptDetailModel.itemId completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"接单成功，请尽快提交方案"];
            [self refreshPTData];

        } else {
            [SVProgressHUD showHint:@"接单失败，请重试"];

        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 5) {
        return _planDataSource.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTListTableViewCell" forIndexPath:indexPath];
        cell.ptDetailModel = _ptDetailModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if (indexPath.section != 5){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = COLOR_TEXT_III;
        if (indexPath.section == 1) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"联系人信息\n"];
            [content appendFormat:@"  姓名: %@ %@\n", _ptDetailModel.contact.lastName, _ptDetailModel.contact.firstName];
            [content appendFormat:@"  电话: %@", _ptDetailModel.contact.telDesc];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;
            
        } else if (indexPath.section == 2) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"出行信息\n"];
            [content appendFormat:@"  出发城市: %@\n", _ptDetailModel.fromCity.zhName];
            [content appendFormat:@"  出发日期: %@\n", _ptDetailModel.departureDate];
            [content appendFormat:@"  出发天数: %ld\n", _ptDetailModel.timeCost];
            [content appendFormat:@"  出游人数: %ld", _ptDetailModel.memberCount];
            if (_ptDetailModel.hasChild) {
                [content appendFormat:@"含儿童"];
            }
            if (_ptDetailModel.hasOldMan) {
                [content appendFormat:@"含老人"];
            }
            [content appendFormat:@"\n  总预算: %@", _ptDetailModel.contact.telDesc];

            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        } else if (indexPath.section == 3) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"旅行信息\n"];
            NSMutableString *destinationStr = [[NSMutableString alloc] init];
            for (CityDestinationPoi *poi in _ptDetailModel.destinations) {
                if ([poi isEqual:[_ptDetailModel.destinations lastObject]]) {
                    [destinationStr appendString:poi.zhName];
                } else {
                    [destinationStr appendFormat:@"%@, ", poi.zhName];
                }
            }
            [content appendFormat:@"  旅游城市: %@\n", destinationStr];
            [content appendFormat:@"  服务包含: %@\n", _ptDetailModel.service];
            [content appendFormat:@"  主题偏向: %@", _ptDetailModel.topic];

            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        } else if (indexPath.section == 4) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"其他需求\n"];
            [content appendFormat:@"%@", _ptDetailModel.memo];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"planCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"planeCell"];
        }
        PTPlanDetailModel *plan = [_planDataSource objectAtIndex:indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:plan.seller.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        cell.imageView.clipsToBounds = YES;
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.textColor = COLOR_TEXT_III;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.text = @"卖家昵称\n";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 已经提交方案", plan.commitTimeStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 5) {
        PTPlanDetailModel *plan = [_planDataSource objectAtIndex:indexPath.row];
        PTPlanDetailViewController *ctl = [[PTPlanDetailViewController alloc] init];
        ctl.ptPlanDetail = plan;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

@end




