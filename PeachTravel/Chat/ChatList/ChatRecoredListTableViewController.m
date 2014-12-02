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
#import "ChatViewController.h"

@interface ChatRecoredListTableViewController () <CreateConversationDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *chattingPeople;       //保存正在聊天的联系人的桃子信息，显示界面的时候需要用到
@property (nonatomic, strong) AccountManager *accountManager;


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
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:reusableChatRecordCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reusableCreateConversationCell];

    _dataSource = [NSMutableArray array];
    _dataSource = [self loadDataSource];
    [self loadChattingPeople];

}

#pragma mark - getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

- (void)loadChattingPeople
{
    if (!_chattingPeople) {
        _chattingPeople = [[NSMutableArray alloc] init];
    } else {
        [_chattingPeople removeAllObjects];
    }
    for (EMConversation *conversation in self.dataSource) {
        if (!conversation.isGroup) {
            if ([self.accountManager TZContactByEasemobUser:conversation.chatter]) {
                [_chattingPeople addObject:[self.accountManager TZContactByEasemobUser:conversation.chatter]];
            } else {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:NO];
            }
        } else {
            [_chattingPeople addObject:conversation.chatter];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:isGroup:)]) {
        [_delegate createConversationSuccessWithChatter:chatter isGroup:isGroup];
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
        return 20;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCreateConversationCell forIndexPath:indexPath];
        cell.textLabel.text = @"创建新的聊天";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    } else {
        ChatRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableChatRecordCell forIndexPath:indexPath];
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        Contact *chatPeople = [self.chattingPeople objectAtIndex:indexPath.row];
        if (!conversation.isGroup) {
            cell.titleLabel.text = chatPeople.nickName;
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:chatPeople.avatar] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        } else{
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    [cell.headerImageView setImage:[UIImage imageNamed:@"chatListCellHead"]];
                    cell.titleLabel.text = group.groupSubject;
                    break;
                }
            }
        }
        return cell;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
        label.text = @"最近聊天";
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor lightGrayColor];
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
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        Contact *chatPeople = [self.chattingPeople objectAtIndex:indexPath.row];
        if (!conversation.isGroup) {
            [_delegate createConversationSuccessWithChatter:chatPeople.easemobUser isGroup:NO];
        } else{
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    [_delegate createConversationSuccessWithChatter:group.groupId isGroup:YES];
                    break;
                }
            }
        }
    }
}

@end
