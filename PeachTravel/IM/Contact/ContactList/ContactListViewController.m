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
#import "ContactDetailViewController.h"
#import "ContactListTableViewCell.h"
#import "OptionOfFASKTableViewCell.h"
#import "AddContactTableViewController.h"
#import "ConvertMethods.h"
#import "MJNIndexView.h"
#import "BaseTextSettingViewController.h"
#import "TZConversation.h"
#import "REFrostedViewController.h"
#import "ChatSettingViewController.h"
#import "OtherUserInfoViewController.h"
#import "UIBarButtonItem+MJ.h"
#define contactCell      @"contactCell"
#define requestCell      @"requestCell"

@interface ContactListViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, MJNIndexViewDataSource, SWTableViewCellDelegate>

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) AccountManager *accountManager;

//索引
@property (nonatomic, strong) MJNIndexView *indexView;

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(addContact)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"ic_add_friend" highIcon:@"ic_add_friend" target:self action:@selector(addContact)];
    self.navigationItem.title = @"联系人";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];

    [self.view addSubview:self.contactTableView];
    
    self.indexView = [[MJNIndexView alloc] initWithFrame:self.view.bounds];
    self.indexView.rightMargin = 0;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.indexView.fontColor = APP_SUB_THEME_COLOR;
    self.indexView.selectedItemFontColor = APP_SUB_THEME_COLOR_HIGHLIGHT;
    self.indexView.dataSource = self;
    self.indexView.maxItemDeflection = 60;
    self.indexView.rangeOfDeflection = 1;
    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, kWindowHeight-64)];
    [self.indexView refreshIndexItems];
//    [self.view addSubview:self.indexView];
    [self.accountManager loadContactsFromServer];
//    [self handleEmptyView];
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

- (void) addContact {
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

#pragma mark - private method

- (void) handleEmptyView {
    if ([[self.dataSource objectForKey:@"headerKeys"] count] <= 0) {
        if (self.emptyView == nil) {
            [self setupEmptyView];
        }
    } else {
        [self removeEmptyView];
    }
}

- (void) setupEmptyView {
    CGFloat width = CGRectGetWidth(self.contactTableView.frame);
    
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 192.0)];
    self.emptyView.userInteractionEnabled = YES;
    self.emptyView.center = CGPointMake(self.view.frame.size.width/2.0, 160.0);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, width - 50.0, 16.0)];
    label1.font = [UIFont systemFontOfSize:14.0];
    label1.textColor = APP_THEME_COLOR;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.text = @"蜜蜜新圈子";
    [self.emptyView addSubview:label1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 40.0, width - 50.0, 16.0)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    label.textAlignment = NSTextAlignmentCenter;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"爱旅行的蜜蜜们之间的专属小天地~";
    [self.emptyView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_indicator.png"]];
    imgView.center = CGPointMake(width*0.33, 75.0);
    [self.emptyView addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 108.0, 32.0);
    [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"加好友" forState:UIControlStateNormal];
    btn.center = CGPointMake(width/2.0, 114.0);
    btn.layer.cornerRadius = 2.0;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(addUserContact:) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyView addSubview:btn];
    
    [self.contactTableView addSubview:self.emptyView];
}

- (void) removeEmptyView {
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

- (void)setNumberOfUnreadFrendRequest:(NSUInteger)numberOfUnreadFrendRequest
{
    _numberOfUnreadFrendRequest = numberOfUnreadFrendRequest;
    if (_contactTableView) {
        [_contactTableView reloadData];
    }
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _contactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 27)];
//        _contactTableView.contentInset = UIEdgeInsetsMake(27, 0, 0, 0);
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contactTableView.showsVerticalScrollIndicator = NO;
        [_contactTableView registerNib:[UINib nibWithNibName:@"OptionOfFASKTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"friend_ask"];
        [_contactTableView registerNib:[UINib nibWithNibName:@"ContactListTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
        _contactTableView.sectionIndexColor = APP_SUB_THEME_COLOR;
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
   
    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, kWindowHeight-64)];
    [self.indexView refreshIndexItems];
}

- (IBAction)chat:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:self.contactTableView];
    NSIndexPath *indexPath = [self.contactTableView indexPathForRowAtPoint:point];
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];

    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
    chatCtl.title = contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:contact.easemobUser]) {
            [conversation markAllMessagesAsRead:YES];
            break;
        }
    }
    
    UIViewController *menuViewController = [[ChatSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatCtl menuViewController:menuViewController];
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.resumeNavigationBar = NO;
    frostedViewController.limitMenuViewSize = YES;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

#pragma mark - http method
- (void)confirmChange:(NSString *)text withContacts:(Contact *)contact success:(saveComplteBlock)completed
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [accountManager asyncChangeRemark:text withUserId:contact.userId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
            completed(YES);
        } else {
            [SVProgressHUD showHint:@"请求失败"];
            completed(NO);
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
            Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            
            //bug 需要返回备注昵称
            BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
            bsvc.navTitle = @"修改备注";
            bsvc.content = contact.nickName;
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
    return 45.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 27;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 27)];
        label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1]];
        label.backgroundColor = APP_PAGE_COLOR;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = TEXT_COLOR_TITLE_SUBTITLE;
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
        cell.numberOfUnreadFrendRequest = _numberOfUnreadFrendRequest;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        cell.delegate = self;

        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:nil];
//        NSString *detailStr;
//        if (![contact.memo isBlankString]) {
//            detailStr = [NSString stringWithFormat:@"%@ (%@)", contact.memo, contact.nickName];
//        } else {
//            detailStr = contact.nickName;
//        }
        cell.nickNameLabel.text = contact.nickName;
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
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
        FrendRequestTableViewController *frendRequestCtl = [[FrendRequestTableViewController alloc] init];
        [self.navigationController pushViewController:frendRequestCtl animated:YES];
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
//        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
        OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
        
        contactDetailCtl.userId = (NSString *)contact.userId;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark MJMIndexForTableView datasource methods
// 索引目录
-(NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.contactTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index+1] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

@end
