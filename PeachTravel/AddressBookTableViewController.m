//
//  AddressBookTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AddressBookTableViewController.h"
#import <AddressBook/AddressBook.h>

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [SVProgressHUD showWithStatus:@"正在加载通讯录"];
    [SVProgressHUD show];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

#pragma mark - setter & getter

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSArray alloc] init];
    }
    return _dataSource;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

//  展示所有联系人
-(void)getAllPerson
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
            NSInteger index = 0;
            for (int i = 0; i < array.count; i++) {
                ABRecordRef thisPerson = CFBridgingRetain([array objectAtIndex:i]);
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
                firstName = firstName != nil?firstName:@"";
                NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
                lastName = lastName != nil?lastName:@"";
                NSString *name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
                
                ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
                NSArray* phoneNumberArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneNumberProperty));
                for(int y = 0; y< [phoneNumberArray count]; y++){
                    NSMutableDictionary *onePerson = [[NSMutableDictionary alloc] init];
                    NSString *phoneNumber = [phoneNumberArray objectAtIndex:y];
                    [onePerson setObject:name forKey:@"name"];
                    [onePerson setObject:phoneNumber forKey:@"tel"];
                    [onePerson setObject:[NSNumber numberWithInt:index] forKey:@"entryId"];
                    [onePerson setObject:[NSNumber numberWithInt:y] forKey:@"sourceId"];
                    [addressBookList addObject:onePerson];
                    index++;
                }
                
                CFRelease(phoneNumberProperty);
            }
            NSLog(@"成功读取通讯录");
            CFRelease(addressBook);
            
        } else {
        }
    });
    
    CFRelease(addressBook);
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
