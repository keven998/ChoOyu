//
//  AddressBookTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AddressBookTableViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>

#import "AFgzipRequestSerializer.h"
#import "AccountManager.h"
#import "AddressBookTableViewCell.h"
#import "ContactDetailViewController.h"
#import "SearchUserInfoViewController.h"

#define addressBookCell    @"addressBookCell"

@interface AddressBookTableViewController () <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) TZProgressHUD *hud;

@end

@implementation AddressBookTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加通讯录好友";
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressBookTableViewCell" bundle:nil] forCellReuseIdentifier:addressBookCell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        [SVProgressHUD showHint:@"需要你开启通讯录的访问权限"];
//        [self performSelector:@selector(goBack) withObject:nil afterDelay:1];
    } else {
        [self loadContactsInAddrBook];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_hud) {
        [_hud hideTZHUD];
    }
      
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setter & getter

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - Private Methods

//  展示所有联系人
-(void)loadContactsInAddrBook
{
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(AddressBookTableViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf.navigationController];

    NSMutableArray *addressBookList = [[NSMutableArray alloc] init];
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
                return ;
            }
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            NSArray *array = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            NSInteger entryId = 0;
            for (int i = 0; i < array.count; i++) {
                ABRecordRef thisPerson = CFBridgingRetain([array objectAtIndex:i]);
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
                firstName = firstName != nil?firstName:@"";
                NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
                lastName = lastName != nil?lastName:@"";
                NSString *name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
                
                ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
                NSArray* phoneNumberArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneNumberProperty));
                for(int j = 0; j< [phoneNumberArray count]; j++){
                    NSMutableDictionary *onePerson = [[NSMutableDictionary alloc] init];
                    NSString *phoneNumber = [phoneNumberArray objectAtIndex:j];
                    [onePerson setObject:name forKey:@"name"];
                    [onePerson setObject:phoneNumber forKey:@"tel"];
                    [onePerson setObject:[NSNumber numberWithInteger:entryId] forKey:@"entryId"];
                    [onePerson setObject:[NSNumber numberWithInt:i] forKey:@"sourceId"];
                    [addressBookList addObject:onePerson];
                    entryId++;
                }
                
                CFRelease(phoneNumberProperty);
            }
            CFRelease(addressBook);
            [self uploadAddressBook:addressBookList];
            
        } else {
        }
    });
    
    CFRelease(addressBook);
}

- (void)uploadAddressBook:(NSArray *)addressBookList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     manager.requestSerializer = [AFgzipRequestSerializer serializerWithSerializer:[AFJSONRequestSerializer serializer]];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:addressBookList forKey:@"contacts"];
    
    [manager POST:API_UPLOAD_ADDRESSBOOK parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseData:[responseObject objectForKey:@"result"] andSourceAddrBook:addressBookList];
        } else {

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];

}

- (void)parseData:(NSArray *)json andSourceAddrBook:(NSArray *)sourceAddrBook
{
    for (int i=0; i<json.count; i++) {
        NSDictionary *retBookDic = [json objectAtIndex:i];
        NSMutableDictionary *bookDic = [sourceAddrBook objectAtIndex:i];
        if ([[retBookDic objectForKey:@"entryId"] integerValue] == [[bookDic objectForKey:@"entryId"] integerValue]) {
            [bookDic setObject:[retBookDic objectForKey:@"isContact"] forKey:@"isContact"];
            [bookDic setObject:[retBookDic objectForKey:@"userId"] forKey:@"userId"];
            [bookDic setObject:[retBookDic objectForKey:@"isUser"] forKey:@"isUser"];
            [bookDic setObject:[retBookDic objectForKey:@"weixin"] forKey:@"weixin"];
            [bookDic setObject:[ConvertMethods chineseToPinyin:[bookDic objectForKey:@"name"]] forKey:@"pingyin"];
        }
    }
    
    self.dataSource = [sourceAddrBook sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectForKey:@"isContact"] boolValue] && ![[obj2 objectForKey:@"isContact"] boolValue]) {
            return NSOrderedDescending;
        }
        if (![[obj1 objectForKey:@"isContact"] boolValue] && [[obj2 objectForKey:@"isContact"] boolValue]) {
            return NSOrderedAscending;
        }
        
        if ([[obj1 objectForKey:@"isUser"] boolValue] && ![[obj2 objectForKey:@"isUser"] boolValue]) {
            return NSOrderedAscending;
        } else if(![[obj1 objectForKey:@"isUser"] boolValue] && [[obj2 objectForKey:@"isUser"] boolValue]) {
            return NSOrderedDescending;
        } else  {
            return [[obj1 objectForKey:@"name"] localizedCompare:[obj2 objectForKey:@"name"]];
        }
    }];
    
    [self.tableView reloadData];
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addUserContact:(UIButton *)sender
{
    [self addContactWithUserId:[self.dataSource[sender.tag] objectForKey:@"userId"]];
}

- (void)addContactWithUserId:(NSString *)userId
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];

    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, userId];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            SearchUserInfoViewController *searchUserInfoCtl = [[SearchUserInfoViewController alloc] init];
            searchUserInfoCtl.userInfo = [responseObject objectForKey:@"result"];
            [self.navigationController pushViewController:searchUserInfoCtl animated:YES];
        } else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (IBAction)invite:(UIButton *)sender
{
    [SVProgressHUD showHint:@"努力打开短信中....."];
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.recipients = @[[self.dataSource[sender.tag] objectForKey:@"tel"]];
    picker.body = @"嘿嘿。下个桃子旅行呗~";
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addressBookCell forIndexPath:indexPath];
    cell.titleLabel.text = [self.dataSource[indexPath.row] objectForKey:@"name"];
    cell.subTitleLabel.text = [self.dataSource[indexPath.row] objectForKey:@"tel"];
    cell.actionBtn.tag = indexPath.row;
    if ([[self.dataSource[indexPath.row] objectForKey:@"isContact"] boolValue]) {
        [cell.actionBtn setImage:[UIImage imageNamed:@"ic_gray_complete.png"] forState:UIControlStateNormal];
        [cell.actionBtn setTitle:nil forState:UIControlStateNormal];
        [cell.actionBtn setTitleEdgeInsets:UIEdgeInsetsZero];
        [cell.actionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [cell.actionBtn setTintColor:[UIColor grayColor]];
        [cell.actionBtn removeTarget:self action:@selector(addUserContact:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionBtn removeTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];

    } else if ([[self.dataSource[indexPath.row] objectForKey:@"isUser"] boolValue]) {
        [cell.actionBtn setImage:[UIImage imageNamed:@"ic_add_phone_contact.png"] forState:UIControlStateNormal];
        [cell.actionBtn setTitle:nil forState:UIControlStateNormal];
        [cell.actionBtn setTitleEdgeInsets:UIEdgeInsetsZero];
        [cell.actionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [cell.actionBtn setTintColor:APP_THEME_COLOR];
        [cell.actionBtn removeTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionBtn addTarget:self action:@selector(addUserContact:) forControlEvents:UIControlEventTouchUpInside];

    } else {
        [cell.actionBtn setTitle:@"邀请" forState:UIControlStateNormal];
        [cell.actionBtn setImage:[UIImage imageNamed:@"cell_accessory_pink.png"] forState:UIControlStateNormal];
        [cell.actionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [cell.actionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        [cell.actionBtn setTintColor:APP_THEME_COLOR];
        [cell.actionBtn removeTarget:self action:@selector(addUserContact:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionBtn addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
