//
//  AddressBook.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/28.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AddressBook.h"
#import <AddressBook/AddressBook.h>

@interface AddressBook()

@property (nonatomic, strong) NSMutableArray *addressBookList;

@end

@implementation AddressBook

#pragma mark - Private Methods
//  展示所有联系人
-(void)getAllPerson
{
    if (!_addressBookList) {
        _addressBookList = [[NSMutableArray alloc] init];
    }
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
            for (int i = 0; i < array.count; i++) {
                ABRecordRef thisPerson = CFBridgingRetain([array objectAtIndex:i]);
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
                firstName = firstName != nil?firstName:@"";
                NSString *lastName =  CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
                lastName = lastName != nil?lastName:@"";
                NSString *name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
                
                ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
                NSArray* phoneNumberArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneNumberProperty));
                for(int index = 0; index< [phoneNumberArray count]; index++){
                    NSMutableDictionary *onePerson = [[NSMutableDictionary alloc] init];
                    NSString *phoneNumber = [phoneNumberArray objectAtIndex:index];
                    [onePerson setObject:name forKey:@"name"];
                    [onePerson setObject:phoneNumber forKey:@"phoneNumber"];
                    [_addressBookList addObject:onePerson];
                }
                
                CFRelease(phoneNumberProperty);
            }
            NSLog(@"成功读取通讯录");
            CFRelease(addressBook);
            [[NSNotificationCenter defaultCenter] postNotificationName:loadedAddressBookNoti object:nil userInfo:@{@"addressBook":_addressBookList}];

        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:regectLoadAddressBookNoti object:nil];
        }
    });
    
    CFRelease(addressBook);
}


@end
