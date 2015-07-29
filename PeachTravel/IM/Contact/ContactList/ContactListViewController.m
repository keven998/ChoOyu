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
    self.navigationItem.title = @"我的朋友";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
    
    [self.view addSubview:self.contactTableView];
    [self.accountManager loadContactsFromServer];
    [[IMClientManager shareInstance].frendRequestManager addFrendRequestDelegate:self];
    
}

#pragma mark - 实现代理方法,这个方法会在同意添加一个好友的情况下调用
- (void)friendRequestNumberNeedUpdate
{
    [self.contactTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_friends_lists"];
    [self.contactTableView reloadData];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_friends_lists"];
}

- (void)dealloc
{
    [[IMClientManager shareInstance].frendRequestManager removeFrendRequestDelegate:self];
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
    [MobClick event:@"navigation_item_add_lxp_friend"];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

#pragma mark - private method

- (void)removeEmptyView {
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
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
    NSLog(@"%@",self.dataSource);
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
    // 第一组是新朋友,如果未读数不为0的话,就需要显示有多少条未读数
    if (indexPath.section == 0) {
        OptionOfFASKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend_ask"];
        
        // 获取好友未读数
        IMClientManager *imclientManager = [IMClientManager shareInstance];
        
        /**
         *  判断是否已经查看了好友的未读数,如果已经查看了,显示未读数为0,否则显示从服务器返回的数据
         */
        NSUInteger unreadCount = 0;
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        // 如果此时为NO,说明没有查看过联系人界面
        BOOL isShowUnreadCount = [defaults boolForKey:kShouldShowUnreadFrendRequestNoti];
        
        if (isShowUnreadCount && imclientManager.frendRequestManager.unReadFrendRequestCount > 0) {
            unreadCount = imclientManager.frendRequestManager.unReadFrendRequestCount;
        }
        
        cell.numberOfUnreadFrendRequest = unreadCount;
        
        NSLog(@"%ld",(long)cell.numberOfUnreadFrendRequest);
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
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
        } else {
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
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
        
        [MobClick event:@"cell_item_new_friends_request"];
        
    } else {
        
        FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
        contactDetailCtl.userId = contact.userId;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
