//
//  ChatRecoredListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

/**
 *  聊天记录的列表页面，当从 poi 详情界面发送东西的时候回进入此页面来选择接收的对象
 */

#import "ChatRecoredListTableViewController.h"
#import "AccountManager.h"
#import "ChatRecordListTableViewCell.h"
#import "CreateConversationViewController.h"

@interface ChatRecoredListTableViewController () <CreateConversationDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *chattingPeople;       //保存正在聊天的联系人的旅行派信息，显示界面的时候需要用到
@property (nonatomic, strong) AccountManager *accountManager;
@property (nonatomic, strong) IMClientManager *imClientManager;


@end

@implementation ChatRecoredListTableViewController

static NSString *reusableCreateConversationCell = @"createConversationCell";
static NSString *reusableChatRecordCell = @"chatRecordListCell";

- (instancetype)init
{
    self = [super init];
    if (self) {
           }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择";
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:reusableChatRecordCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reusableCreateConversationCell];
    
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCtl:) name:userDidLogoutNoti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (IMClientManager *)imClientManager
{
    if (!_imClientManager) {
        _imClientManager = [IMClientManager shareInstance];
    }
    return _imClientManager;
}

#pragma mark - Private Methods

- (IBAction)dismissCtl:(id)sender
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:chatType:chatTitle:)]) {
        [_delegate createConversationSuccessWithChatter:chatterId chatType:chatType chatTitle:chatTitle];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 54.0;
    }
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCreateConversationCell forIndexPath:indexPath];
        cell.textLabel.text = @"新建聊天";
        cell.textLabel.textColor = COLOR_TEXT_I;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        ChatRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableChatRecordCell forIndexPath:indexPath];
        ChatConversation *tzConversation = [self.dataSource objectAtIndex:indexPath.row];

        if (tzConversation.chatType == IMChatTypeIMChatSingleType) {
            cell.titleLabel.text = tzConversation.chatterName;
            if (tzConversation.chatterId == WenwenUserId) {
                cell.headerImageView.image = [UIImage imageNamed:@"lvxingwenwen.png"];
                cell.headerImageView.layer.cornerRadius = 9;
            } else if (tzConversation.chatterId == PaipaiUserId) {
                cell.headerImageView.layer.cornerRadius = 9;
                cell.headerImageView.image = [UIImage imageNamed:@"lvxingpaipai.png"];
            } else {
                [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:tzConversation.chatterAvatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
                cell.imageView.layer.cornerRadius = 20;
            }
        } else{
            [cell.headerImageView setImage:[UIImage imageNamed:@"icon_chat_group.png"]];
            cell.titleLabel.text = tzConversation.chatterName;
        }
        return cell;
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, self.view.frame.size.width, 33)];
        label.text = @"最近聊天";
        label.font = [UIFont systemFontOfSize:13.0];
        sectionView.backgroundColor = APP_PAGE_COLOR;
        label.textColor = COLOR_TEXT_II;
        [sectionView addSubview:label];
        return sectionView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
        createConversationCtl.delegate = self;
        [self.navigationController pushViewController:createConversationCtl animated:YES];
    } else {
        ChatConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        [_delegate createConversationSuccessWithChatter:conversation.chatterId chatType:conversation.chatType chatTitle:conversation.chatterName];
    }
}



@end
