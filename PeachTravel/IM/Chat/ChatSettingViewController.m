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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
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
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0;
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
    strLabel.text = @"聊天设置";
    return sectionHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68 * SCREEN_HEIGHT / 736;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        [self.containerCtl.navigationController pushViewController:ctl animated:YES];
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
