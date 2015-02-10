//
//  FrendRequestTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FrendRequestTableViewController.h"
#import "FrendRequestTableViewCell.h"
#import "FrendRequest.h"
#import "AccountManager.h"
#import "ContactDetailViewController.h"

#define requestCell      @"requestCell"

@interface FrendRequestTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AccountManager *accountManager;

@end

@implementation FrendRequestTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"好友请求";
    [self.tableView registerNib:[UINib nibWithNibName:@"FrendRequestTableViewCell" bundle:nil] forCellReuseIdentifier:requestCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataSource) name:frendRequestListNeedUpdateNoti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        NSComparator cmptr = ^(FrendRequest *obj1, FrendRequest *obj2) {
            if ([obj1.requestDate doubleValue] < [obj2.requestDate doubleValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        };
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id request in self.accountManager.account.frendrequestlist) {
            [tempArray addObject:request];
        }
        _dataSource = [[tempArray sortedArrayUsingComparator:cmptr] mutableCopy];
    }
    return _dataSource;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (void)insertMsgToEasemobDB:(FrendRequest *)frendRequest
{
    id  chatManager = [[EaseMob sharedInstance] chatManager];
    NSDictionary *loginInfo = [chatManager loginInfo];
    NSString *account = [loginInfo objectForKey:kSDKUsername];
    EMChatText *chatText = [[EMChatText alloc] initWithText:@""];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:frendRequest.easemobUser bodies:@[textBody]];
    
    NSString *str = [NSString stringWithFormat:@"你已添加%@为好友",frendRequest.nickName];
    message.ext = @{
                    @"tzType":[NSNumber numberWithInt:TZTipsMsg],
                    @"content":str
                    };
    [message setIsGroup:NO];
    [message setIsReadAcked:NO];
    [message setTo:account];
    [message setFrom:frendRequest.easemobUser];
    [message setIsGroup:NO];
    message.conversationChatter = frendRequest.easemobUser;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *messageID = [NSString stringWithFormat:@"%.0f", interval];
    [message setMessageId:messageID];
    
    [chatManager importMessage:message
                   append2Chat:YES];
}

- (void)updateDataSource
{
    [self.dataSource removeAllObjects];
    NSComparator cmptr = ^(FrendRequest *obj1, FrendRequest *obj2) {
        if ([obj1.requestDate doubleValue] < [obj2.requestDate doubleValue]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    };
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (id request in self.accountManager.account.frendrequestlist) {
        [tempArray addObject:request];
    }
    _dataSource = [[tempArray sortedArrayUsingComparator:cmptr] mutableCopy];
}

- (void)addContactWithFrendRequest:(FrendRequest *)frendRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    [params setObject:frendRequest.userId forKey:@"userId"];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak FrendRequestTableViewController *weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    
    //同意添加好友
    [manager POST:API_ADD_CONTACT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self.accountManager agreeFrendRequest:frendRequest];
            [self.accountManager addContact:frendRequest];
            [self.tableView reloadData];
            [self insertMsgToEasemobDB:frendRequest];
            
//            [SVProgressHUD showHint:@"已添加"];
            for (Contact *contact in self.accountManager.account.contacts) {
                if ([((FrendRequest *)frendRequest).userId longValue] == [contact.userId longValue]) {
                    ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
                    contactDetailCtl.contact = contact;
                    [self.navigationController pushViewController:contactDetailCtl animated:YES];
                    break;
                }
            }
           
            
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)agreeFrendRequest:(UIButton *)sender
{
    NSLog(@"我同意好友请求，好友信息为：%@", [_dataSource objectAtIndex: sender.tag]);
    [self addContactWithFrendRequest:[_dataSource objectAtIndex: sender.tag]];

}


#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrendRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestCell forIndexPath:indexPath];
    FrendRequest *request = [_dataSource objectAtIndex:indexPath.row];
    cell.nickNameLabel.text = request.nickName;
    cell.attachMsgLabel.text = request.attachMsg;
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:request.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
    cell.requestBtn.tag = indexPath.row;
    if ([request.status integerValue] == TZFrendAgree) {
        [cell.requestBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [cell.requestBtn setTitle:@"已添加" forState:UIControlStateNormal];
        cell.requestBtn.userInteractionEnabled = NO;
    } else if ([request.status integerValue] == TZFrendDefault) {
        [cell.requestBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [cell.requestBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [cell.requestBtn setTitle:@"同意" forState:UIControlStateNormal];
        cell.requestBtn.userInteractionEnabled = YES;
        [cell.requestBtn addTarget:self action:@selector(agreeFrendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FrendRequest *frendRequest = [self.dataSource objectAtIndex:indexPath.row];
        [self.accountManager removeFrendRequest:frendRequest];
        [self.dataSource removeObject:frendRequest];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

@end
