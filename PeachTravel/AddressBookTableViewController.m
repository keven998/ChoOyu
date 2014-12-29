//
//  AddressBookTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AddressBookTableViewController.h"
#import <AddressBook/AddressBook.h>
#import "AccountManager.h"

#define addressBookCell    @"addressBookCell"

@interface AddressBookTableViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation AddressBookTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加通讯录好友";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:addressBookCell];
    [self loadContactsInAddrBook];
    [SVProgressHUD show];
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
    NSMutableArray *addressBookList = [[NSMutableArray alloc] init];
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSLog(@"开始读取通讯录");
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
                    [onePerson setObject:[NSNumber numberWithInt:entryId] forKey:@"entryId"];
                    [onePerson setObject:[NSNumber numberWithInt:i] forKey:@"sourceId"];
                    [addressBookList addObject:onePerson];
                    entryId++;
                }
                
                CFRelease(phoneNumberProperty);
            }
            NSLog(@"成功读取通讯录");
            CFRelease(addressBook);
            
            [self uploadAddressBook:addressBookList];
            
        } else {
        }
    });
    
    CFRelease(addressBook);
}

- (void)uploadAddressBook:(NSArray *)addressBookList
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:addressBookList forKey:@"contacts"];
    
    [manager POST:API_UPLOAD_ADDRESSBOOK parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            
        } else {

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];

}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addressBookCell forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@      %@", [self.dataSource[indexPath.row] objectForKey:@"name"],[self.dataSource[indexPath.row] objectForKey:@"phoneNumber"]];
    return cell;
}

@end
