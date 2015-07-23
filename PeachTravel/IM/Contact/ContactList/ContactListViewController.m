//
//  ContactListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/30.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListViewController.h"
#import "AccountManager.h"
#import "ChatViewController.h"
#import "FrendRequestTableViewController.h"
#import "ContactListTableViewCell.h"
#import "OptionOfFASKTableViewCell.h"
#import "AddContactTableViewController.h"
#import "ConvertMethods.h"
#import "BaseTextSettingViewController.h"
#import "REFrostedViewController.h"
#import "ChatSettingViewController.h"
#import "OtherUserInfoViewController.h"
#import "UIBarButtonItem+MJ.h"
#define contactCell      @"contactCell"
#define requestCell      @"requestCell"

@interface ContactListViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate,FriendRequestManagerDelegate>

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) AccountManager *accountManager;

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_friend.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addContact)];
    self.navigationItem.title = @"我的好友";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
    
    [self.view addSubview:self.contactTableView];
    [self.accountManager loadContactsFromServer];
    
    // 增加监听未读数的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUnreadCount:) name:NoticationClearUnreadCount object:nil];
    
    // 改变未读数
    
//    [IMClientManager shareInstance].frendRequestManager.delegate = self;
}

#pragma mark - 实现好友请求的代理方法
//- (void)friendRequestNumberNeedUpdate
//{
//    [self.contactTableView reloadData];
//}

// 接收通知后实现方法
- (void)clearUnreadCount:(NSNotification *)note
{
    [self.contactTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_friends_lists"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick endLogPageView:@"page_friends_lists"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _contactTableView.delegate = nil;
    _emptyView = nil;
}

#pragma mark - IBAction
- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addContact {
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

#pragma mark - private method

- (void)removeEmptyView {
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    addContactCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

#pragma mark - setter & getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.separatorColor = COLOR_LINE;
        _contactTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contactTableView.showsVerticalScrollIndicator = NO;
        [_contactTableView registerNib:[UINib nibWithNibName:@"OptionOfFASKTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"friend_ask"];
        [_contactTableView registerNib:[UINib nibWithNibName:@"ContactListTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
        _contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _contactTableView.sectionIndexColor = COLOR_TEXT_II;
    }
    return _contactTableView;
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        _dataSource = [self.accountManager contactsByPinyin];
    }
    return _dataSource;
}

#pragma mark - Private Methods

- (void)updateContactList
{
    self.dataSource = [self.accountManager contactsByPinyin];
    [self.contactTableView reloadData];
}

- (IBAction)chat:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:self.contactTableView];
    NSIndexPath *indexPath = [self.contactTableView indexPathForRowAtPoint:point];
    FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
    
    IMClientManager *manager = [IMClientManager shareInstance];
    ChatConversation *conversation = [manager.conversationManager getConversationWithChatterId:contact.userId chatType:IMChatTypeIMChatSingleType];
    [manager.conversationManager addConversation: conversation];
    conversation.chatterId = contact.userId;
    
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithConversation:conversation];
    chatCtl.chatterName = contact.nickName;
    
    UIViewController *menuViewController = [[ChatSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatCtl menuViewController:menuViewController];
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.resumeNavigationBar = NO;
    frostedViewController.limitMenuViewSize = YES;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

#pragma mark - http method

- (void)confirmChange:(NSString *)text withContacts:(FrendModel *)contact success:(saveComplteBlock)completed
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    contact.memo = text;
    [self.contactTableView reloadData];
    completed(YES);
    [accountManager asyncChangeRemark:text withUserId:contact.userId completion:^(BOOL isSuccess) {
        if (isSuccess) {
        } else {
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    switch (index) {
        case 0:
        {
            NSIndexPath *indexPath = [_contactTableView indexPathForCell:cell];
            FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            
            BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
            bsvc.navTitle = @"修改备注";
            if (contact.memo.length > 0) {
                bsvc.content = contact.memo;
            } else {
                bsvc.content = contact.nickName;
            }
            bsvc.acceptEmptyContent = NO;
            bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
                [self confirmChange:editText withContacts:contact success:completed];
            };
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
        }
        default:
            break;
    }
}

#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 27;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 22)];
        label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1]];
        label.backgroundColor = APP_PAGE_COLOR;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = COLOR_TEXT_II;
        return label;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        NSArray *contacts = [[self.dataSource objectForKey:@"content"] objectAtIndex:section-1];
        return [contacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OptionOfFASKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend_ask"];
        
        // 获取好友未读数
        IMClientManager *imclientManager = [IMClientManager shareInstance];
        
        /**
         *  判断是否已经查看了好友的未读数,如果已经查看了,显示未读数为0,否则显示从服务器返回的数据
         */
        cell.numberOfUnreadFrendRequest = imclientManager.frendRequestManager.unReadFrendRequestCount;
        NSLog(@"%ld",cell.numberOfUnreadFrendRequest);
        if (cell.numberOfUnreadFrendRequest == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    } else {
        FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        cell.delegate = self;
        
        if (![contact.avatarSmall isBlankString]) {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        } else {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        }
    
        if (contact.memo.length > 0) {
            cell.nickNameLabel.text = contact.memo;
        } else {
            cell.nickNameLabel.text = contact.nickName;
        }
        return cell;
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] icon:[UIImage imageNamed:@"ic_guide_edit.png"]];
    return rightUtilityButtons;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        FrendRequestTableViewController *frendRequestCtl = [[FrendRequestTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:frendRequestCtl animated:YES];
        
    } else {
        
        FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
        contactDetailCtl.userId = contact.userId;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
