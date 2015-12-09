//
//  ChatSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/6/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "ChatGroupSettingCell.h"
#import "PeachTravel-swift.h"
#import "ChatAlbumCollectionViewController.h"
#import "CreateConversationViewController.h"
#import "REFrostedViewController.h"
#import "ChatGroupCell.h"

@interface ChatSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    UIView *_headerView;
}
@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupSettingCell" bundle:nil] forCellReuseIdentifier:@"chatGroupSettingCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];

    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}

- (void)createGroupAction
{
    CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
    FrendModel *frend = [[FrendModel alloc] init];
    frend.userId = _currentConversation.chatterId;
    frend.nickName = _currentConversation.chatterName;
    frend.avatar = _currentConversation.chatterAvatar;
    [_containerCtl.navigationController pushViewController:createConversationCtl animated:YES];

}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return 55.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 64.0)];
    sectionHeaderView.backgroundColor = APP_PAGE_COLOR;
    sectionHeaderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImageView *greenPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 40, 10, 18)];
    greenPointImageView.image = [UIImage imageNamed:@"chat_drawer_poit"];
    greenPointImageView.contentMode = UIViewContentModeCenter;
    [sectionHeaderView addSubview:greenPointImageView];
    
    UILabel *strLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 40, 100, 18)];
    strLabel.font = [UIFont systemFontOfSize:13];
    strLabel.textColor = COLOR_TEXT_I;
    [sectionHeaderView addSubview:strLabel];
    
    if (section == 0) {
        strLabel.text = @"聊天设置";
    } else {
        strLabel.text = @"聊天成员";
    }
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *sectionFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 55.0)];
    UIButton *createGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, width-40, 35)];
    [createGroupBtn setTitle:@"创建群组" forState:UIControlStateNormal];
    [createGroupBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [createGroupBtn addTarget:self action:@selector(createGroupAction) forControlEvents:UIControlEventTouchUpInside];
    [sectionFooterView addSubview:createGroupBtn];
    return sectionFooterView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68 * kWindowHeight / 736;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ChatGroupSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatGroupSettingCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.font = [UIFont systemFontOfSize:15.0];
            IMClientManager *clientManager = [IMClientManager shareInstance];
            ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:_chatterId];
            [cell.switchBtn removeTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventValueChanged];
            [cell.switchBtn addTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventValueChanged];
            cell.switchBtn.on = [conversation isBlockMessage];
            cell.tag = 101;
            return cell;
            
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.textLabel.text = @"清空聊天记录";
            return cell;
        } else if (indexPath.row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.textLabel.text = @"聊天图集";
            return cell;
        }
        
    } else {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        cell.nameLabel.text = _currentConversation.chatterName;
        NSString *avatarStr = _currentConversation.chatterAvatar;
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString: avatarStr] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        return cell;

    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
    } else if (indexPath.row == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认清空全部聊天记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:[NSNumber numberWithInteger:_chatterId]];
            }
        }];
        
    } else if (indexPath.row == 2) {
        ChatAlbumCollectionViewController *ctl = [[ChatAlbumCollectionViewController alloc] initWithNibName:@"ChatAlbumCollectionViewController" bundle:nil];
        [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *albumImages = [self getAllChatAlbumImageInConversation];
            NSArray *images = [self getAllImagePathList];
            dispatch_async(dispatch_get_main_queue(), ^{
                ctl.imageList = images;
                ctl.albumList = albumImages;
            });
        });
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/**
 *  更新群组消息提醒状态，屏蔽和不屏蔽
 *
 *  @param sender
 */
- (IBAction)changeMsgStatus:(UISwitch *)sender {
    [[IMClientManager shareInstance].conversationManager asyncChangeConversationBlockStatusWithChatterId:_chatterId isBlock:sender.isOn completion:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            NSLog(@"免打扰设置成功");
        } else {
            [SVProgressHUD showHint:@"设置失败"];
            [sender setOn:!sender.isOn animated:YES];
        }
    }];
}

/**
 *  获取所有的聊天图片
 *
 *  @return
 */
- (NSArray *)getAllImagePathList
{
    NSArray *imageMessages = [self.currentConversation getAllImageMessageInConversation];

    NSMutableArray *retMessages = [[NSMutableArray alloc] init];
    for (ImageMessage *message in imageMessages) {
        if (message.sendType == IMMessageSendTypeMessageSendSomeoneElse) {
            NSString *imageUrl = message.fullUrl;
            if (imageUrl) {
                [retMessages addObject:imageUrl];
            }
            
        } else {
            [retMessages addObject:message.localPath];
        }
    }
    return retMessages;
}

/**
 *  获取所有的聊天 album 图片消息
 *
 *  @return
 */
- (NSArray *)getAllChatAlbumImageInConversation
{
    NSMutableArray *retMessages = [[NSMutableArray alloc] init];
    NSArray *imageMessages = [self.currentConversation getAllImageMessageInConversation];
    for (ImageMessage *message in imageMessages) {
        [retMessages addObject:message.localPath];
    }
    return retMessages;
}



@end
