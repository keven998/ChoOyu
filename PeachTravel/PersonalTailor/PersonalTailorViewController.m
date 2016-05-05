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
#import "OrderManager+BNOrderManager.h"
#import "PTTakerTableViewCell.h"

@interface PersonalTailorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *toolBar;
@property (nonatomic) BOOL isSeller;
@property (nonatomic, strong) PTDetailModel *ptDetailModel;
@property (strong, nonatomic) NSArray<PTPlanDetailModel *> *planDataSource;
@property (strong, nonatomic) NSMutableArray<FrendModel *> *takersWithoutMakePlan;  //接单了但是没有制作方案

@end

@implementation PersonalTailorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"需求详情";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PTTakerTableViewCell" bundle:nil] forCellReuseIdentifier:@"takerCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"statusCell"];


    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
    _tableView.hidden = YES;

}

- (void)refreshPTData
{
    [PersonalTailorManager asyncLoadPTDetailDataWithItemId:_ptId completionBlock:^(BOOL isSuccess, PTDetailModel *ptDetail) {
        if (isSuccess) {
            self.ptDetailModel = ptDetail;
            [self renderToolBar];
            _tableView.hidden = NO;
            [_tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if ([AccountManager shareAccountManager].isLogin) {
        [StoreManager asyncLoadStoreInfoWithStoreId:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
            if (isSuccess && storeDetail) {
                _isSeller = YES;
                
            } else {
                _isSeller = NO;
            }
            [self refreshPTData];
        }];
    } else {
        _isSeller = NO;
        [self refreshPTData];
    }
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
        if ((_ptDetailModel.bountyPaid || _ptDetailModel.planPaid) && !_ptDetailModel.hasRequestRefundMoney) {
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
                    break;
                }
            }
            if (_ptDetailModel.selectPlan.seller.userId == [AccountManager shareAccountManager].account.userId) {
                if (_ptDetailModel.hasRequestRefundMoney) {
                    UIButton *refundMoneyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/2, 49)];
                    [refundMoneyButton setTitle:@"待退款" forState:UIControlStateNormal];
                    [refundMoneyButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                    [refundMoneyButton addTarget:self action:@selector(refundMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
                    [_toolBar addSubview:refundMoneyButton];
                    
                    UIButton *chatWithUser = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth/2, 0, kWindowWidth/2, 49)];
                    [chatWithUser setTitle:@"联系买家" forState:UIControlStateNormal];
                    [chatWithUser setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                    [chatWithUser addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];
                    [_toolBar addSubview:chatWithUser];
                } else {
                    UIButton *chatWithUser = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
                    [chatWithUser setTitle:@"联系买家" forState:UIControlStateNormal];
                    [chatWithUser setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                    [chatWithUser addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];
                    [_toolBar addSubview:chatWithUser];
                }
            } else if (isHasTake) {
                if (_ptDetailModel.planPaid) {
                    UIButton *chatWithUser = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
                    [chatWithUser setTitle:@"联系买家" forState:UIControlStateNormal];
                    [chatWithUser setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                    [chatWithUser addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];
                    [_toolBar addSubview:chatWithUser];
                    
                } else {
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
                }
                
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

- (IBAction)contactSeller:(UIButton *)sender
{
    FrendModel *contact;
    if (sender.tag<_planDataSource.count) {
        contact = [_planDataSource objectAtIndex:sender.tag].seller;
    } else {
        contact = [_takersWithoutMakePlan objectAtIndex:sender.tag];
    }
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:contact.userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    
    chatController.chatterName = contact.nickName;
    
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
    _planDataSource = _ptDetailModel.plans;
    _takersWithoutMakePlan = [[NSMutableArray alloc] init];
    for (FrendModel *taker in _ptDetailModel.takers) {
        BOOL find = NO;
        for (PTPlanDetailModel *plan in _planDataSource) {
            if (plan.seller.userId == taker.userId) {
                find = YES;
                break;
            }
        }
        if (!find) {
            [_takersWithoutMakePlan addObject:taker];
        }
    }
    
    [_tableView reloadData];
}

- (void)makePTPlanAction:(UIButton *)sender
{
    PTMakePlanViewController *ctl = [[PTMakePlanViewController alloc] init];
    ctl.ptId = _ptId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)requestRefundMoney:(UIButton *)sender
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:@"退款明细: "];
    NSString *target;
    if (_ptDetailModel.earnestMoney > 0) {
        [content appendFormat:@"定金: %ld", (NSInteger)_ptDetailModel.earnestMoney];
        target = @"bounty";
    }
    if (_ptDetailModel.planPaid) {
        [content appendFormat:@"方案金额: %ld", (NSInteger)_ptDetailModel.earnestMoney];
        target = @"schedule";

    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定申请退款?" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [PersonalTailorManager asyncApplyRefundMoneyOrderWithPtId:_ptDetailModel.itemId target:target leaveMessage:@"" completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"申请退款成功"];
                    [self refreshPTData];

                } else {
                    [SVProgressHUD showHint:@"申请退款失败"];
                }
            }];
        }
    }];
}

- (void)takePTAction:(UIButton *)sender
{
    [PersonalTailorManager asyncTakePersonalTailor:_ptId completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"接单成功，请尽快提交方案"];
            [self refreshPTData];

        } else {
            [SVProgressHUD showHint:@"接单失败，请重试"];

        }
    }];
}

- (void)refundMoneyAction:(UIButton *)sender
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:@"支付明细: "];
    NSString *target;
    if (_ptDetailModel.earnestMoney > 0) {
        [content appendFormat:@"定金: %ld", (NSInteger)_ptDetailModel.earnestMoney];
        target = @"bounties";
    }
    if (_ptDetailModel.planPaid) {
        [content appendFormat:@"方案金额: %ld", (NSInteger)_ptDetailModel.earnestMoney];
        target = @"schedule";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入退款金额" message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf = [alertView textFieldAtIndex:0];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if ([tf.text floatValue] <= 0) {
                [SVProgressHUD showHint:@"退款金额不能为0"];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入登录密码，完成退款" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [alertView textFieldAtIndex:0];
                tf.secureTextEntry = YES;
                [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [OrderManager asyncVerifySellerPassword:tf.text completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                            if (isSuccess) {
                                [PersonalTailorManager asyncBNAgreeRefundMoneyOrderWithPtId:_ptDetailModel.itemId refundMoney:tf.text.floatValue target:target leaveMessage:@"" completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                                    if (isSuccess) {
                                        [SVProgressHUD showHint:@"退款成功"];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        [SVProgressHUD showHint:@"退款失败"];
                                    }
                                }];
                                
                            } else {
                                [SVProgressHUD showHint:@"密码输入错误,请重试"];
                            }
                        }];
                    }
                    
                }];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_isSeller && [AccountManager shareAccountManager].account.userId != _ptDetailModel.consumer.userId) {
        if (section == 4) {
            return _planDataSource.count + _takersWithoutMakePlan.count;
        }
        return 1;
    }
    if (_isSeller) {
        BOOL isHasTake = NO;
        for (FrendModel *taker in _ptDetailModel.takers) {
            if ([AccountManager shareAccountManager].account.userId == taker.userId) {
                isHasTake = YES;
            }
        }
        if (!isHasTake && [AccountManager shareAccountManager].account.userId != _ptDetailModel.consumer.userId) {
            if (section == 4) {
                return _planDataSource.count + _takersWithoutMakePlan.count;
            }
            return 1;
        }
        
    }
    if (section == 6) {
        return _planDataSource.count + _takersWithoutMakePlan.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isSeller && [AccountManager shareAccountManager].account.userId != _ptDetailModel.consumer.userId) {
        return 5;
    }
    if (_isSeller) {
        BOOL isHasTake = NO;
        for (FrendModel *taker in _ptDetailModel.takers) {
            if ([AccountManager shareAccountManager].account.userId == taker.userId) {
                isHasTake = YES;
            }
        }
        if (!isHasTake && [AccountManager shareAccountManager].account.userId != _ptDetailModel.consumer.userId) {
            return 5;
        }
    }
    return 7;
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
    if (tableView.numberOfSections == 5) {
        if (indexPath.section == 0) {
            PTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTListTableViewCell" forIndexPath:indexPath];
            cell.ptDetailModel = _ptDetailModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if (indexPath.section != 4){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_III;
            if (indexPath.section == 1) {
                NSMutableString *content = [[NSMutableString alloc] init];
                [content appendFormat:@"出行信息\n"];
                [content appendFormat:@"  出发城市: %@\n", _ptDetailModel.fromCity.zhName];
                [content appendFormat:@"  出发日期: %@\n", _ptDetailModel.departureDate];
                [content appendFormat:@"  出发天数: %ld\n", _ptDetailModel.timeCost];
                [content appendFormat:@"  出游人数: %ld", _ptDetailModel.memberCount];
                if (_ptDetailModel.hasChild) {
                    [content appendFormat:@" 含儿童"];
                }
                if (_ptDetailModel.hasOldMan) {
                    [content appendFormat:@" 含老人"];
                }
                [content appendFormat:@"\n  总预算: %ld", (NSInteger)_ptDetailModel.budget];
                
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
                [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 5.0;
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
                [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
                cell.textLabel.attributedText = attr;
                
                
            } else if (indexPath.section == 2) {
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
                
                
            } else if (indexPath.section == 3) {
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
            PTTakerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"takerCell"];
            
            if (indexPath.row<_planDataSource.count) {
                PTPlanDetailModel *plan = [_planDataSource objectAtIndex:indexPath.row];
                
                [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:plan.seller.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ 已经提交方案", plan.commitTimeStr];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.nicknameLabel.text = plan.seller.nickName;
                cell.accessoryView = nil;

                
            } else {
                FrendModel *contact = [_takersWithoutMakePlan objectAtIndex:indexPath.row-_planDataSource.count];
                
                [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.nicknameLabel.text = contact.nickName;
                cell.contentLabel.text = [NSString stringWithFormat:@"已经接单"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
                [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
                [chatButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                chatButton.layer.cornerRadius = 4.0;
                chatButton.layer.borderColor = APP_THEME_COLOR.CGColor;
                chatButton.layer.borderWidth = 0.5;
                chatButton.tag = indexPath.row;
                chatButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
                [chatButton addTarget:self action:@selector(contactSeller:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = chatButton;
            }
            
            return cell;
        }

    } else {
        if (indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell" forIndexPath:indexPath];
            cell.textLabel.textColor = COLOR_PRICE_RED;
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            if (_ptDetailModel.planPaid) {
                cell.textLabel.text = @"已购买方案";
                
            } else if (_ptDetailModel.bountyPaid) {
                cell.textLabel.text = @"已支付定金";
            } else {
                cell.textLabel.text = @"已提交";
            }
            if (_ptDetailModel.hasRequestRefundMoney) {
                cell.textLabel.text = @"已申请退款";
            }
            return cell;
        } else if (indexPath.section == 1) {
            PTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTListTableViewCell" forIndexPath:indexPath];
            cell.ptDetailModel = _ptDetailModel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if (indexPath.section != 6){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_III;
            if (indexPath.section == 2) {
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
                
            } else if (indexPath.section == 3) {
                NSMutableString *content = [[NSMutableString alloc] init];
                [content appendFormat:@"出行信息\n"];
                [content appendFormat:@"  出发城市: %@\n", _ptDetailModel.fromCity.zhName];
                [content appendFormat:@"  出发日期: %@\n", _ptDetailModel.departureDate];
                [content appendFormat:@"  出发天数: %ld\n", _ptDetailModel.timeCost];
                [content appendFormat:@"  出游人数: %ld", _ptDetailModel.memberCount];
                if (_ptDetailModel.hasChild) {
                    [content appendFormat:@" 含儿童"];
                }
                if (_ptDetailModel.hasOldMan) {
                    [content appendFormat:@" 含老人"];
                }
                [content appendFormat:@"\n  总预算: %ld", (NSInteger)_ptDetailModel.budget];
                
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
                [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 5.0;
                [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
                [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
                cell.textLabel.attributedText = attr;
                
                
            } else if (indexPath.section == 4) {
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
                
                
            } else if (indexPath.section == 5) {
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
            PTTakerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"takerCell"];
            
            if (indexPath.row<_planDataSource.count) {
                PTPlanDetailModel *plan = [_planDataSource objectAtIndex:indexPath.row];
                [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:plan.seller.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ 已经提交方案", plan.commitTimeStr];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.nicknameLabel.text = plan.seller.nickName;
                cell.accessoryView = nil;
                
            } else {
                FrendModel *contact = [_takersWithoutMakePlan objectAtIndex:indexPath.row-_planDataSource.count];
                [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.nicknameLabel.text = contact.nickName;
                cell.contentLabel.text = [NSString stringWithFormat:@"已经接单"];
                cell.accessoryType = UITableViewCellAccessoryNone;
                UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
                [chatButton setTitle:@"聊天" forState:UIControlStateNormal];
                [chatButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
                chatButton.layer.cornerRadius = 4.0;
                chatButton.layer.borderColor = APP_THEME_COLOR.CGColor;
                chatButton.layer.borderWidth = 0.5;
                chatButton.tag = indexPath.row;
                chatButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
                [chatButton addTarget:self action:@selector(contactSeller:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = chatButton;
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row<_planDataSource.count) {
        if (indexPath.section == 6) {
            PTPlanDetailModel *plan = [_planDataSource objectAtIndex:indexPath.row];

            if (_ptDetailModel.consumer.userId == [AccountManager shareAccountManager].account.userId || plan.seller.userId == [AccountManager shareAccountManager].account.userId) {
                PTPlanDetailViewController *ctl = [[PTPlanDetailViewController alloc] init];
                ctl.publishUserId = _ptDetailModel.consumer.userId;
                ctl.ptId = _ptDetailModel.itemId;
                ctl.ptPlanDetail = plan;
                [self.navigationController pushViewController:ctl animated:YES];
            }
        }
    }
}

@end




