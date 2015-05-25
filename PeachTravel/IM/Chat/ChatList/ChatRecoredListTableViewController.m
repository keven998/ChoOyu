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
    
//    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(dismissCtl:)forControlEvents:UIControlEventTouchUpInside];
//    [button setFrame:CGRectMake(0, 0, 48, 30)];
//    [button setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
//    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
//    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
//    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:reusableChatRecordCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reusableCreateConversationCell];
    
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;

    _dataSource = [NSMutableArray array];
    _dataSource = [self loadDataSource];
    [self loadChattingPeople];
    
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

#pragma mark - Private Methods

- (IBAction)dismissCtl:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    BOOL neeUpdate = NO;
    for (EMConversation *conversation in self.dataSource) {
        if (!conversation.isGroup) {
            if ([self.accountManager TZContactByEasemobUser:conversation.chatter]) {
                [_chattingPeople addObject:[self.accountManager TZContactByEasemobUser:conversation.chatter]];
            } else {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES];

                neeUpdate = YES;
            }
        } else {
            [_chattingPeople addObject:conversation.chatter];
        }
    }
    if (neeUpdate) {
        self.dataSource = [self loadDataSource];
    }
    [self.tableView reloadData];

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
        return 50.0;
    }
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCreateConversationCell forIndexPath:indexPath];
        cell.textLabel.text = @"创建新聊天";
        cell.textLabel.textColor = TEXT_COLOR_TITLE;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    } else {
        ChatRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableChatRecordCell forIndexPath:indexPath];
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        Contact *chatPeople = [self.chattingPeople objectAtIndex:indexPath.row];
        if (!conversation.isGroup) {
            cell.titleLabel.text = chatPeople.nickName;
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:chatPeople.avatar] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        } else{
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    [cell.headerImageView setImage:[UIImage imageNamed:@"ic_group_icon.png"]];
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
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, 30)];
        label.text = @"    最近聊天";
        label.font = [UIFont systemFontOfSize:13.0];
        label.backgroundColor = [UIColor whiteColor];
        sectionView.backgroundColor = APP_PAGE_COLOR;
        label.textColor = TEXT_COLOR_TITLE_SUBTITLE;
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
        createConversationCtl.isPushed = YES;
        [self.navigationController pushViewController:createConversationCtl animated:YES];
    } else {
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        Contact *chatPeople = [self.chattingPeople objectAtIndex:indexPath.row];
        if (!conversation.isGroup) {
//            [_delegate createConversationSuccessWithChatter:chatPeople.easemobUser isGroup:NO chatTitle:chatPeople.nickName];
            
        } else{
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
//                    [_delegate createConversationSuccessWithChatter:group.groupId isGroup:YES chatTitle:group.groupSubject];
                    break;
                }
            }
        }
    }
}

@end
