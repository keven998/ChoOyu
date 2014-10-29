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

@end

@implementation AddressBook


//  展示所有联系人
-(void)getAllPerson
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        if (granted) {
            
            //查询所有
            [self filterContentForSearchText:@""];
        }
    });
    
    CFRelease(addressBook);
    
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    //如果没有授权则退出
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        return ;
    }
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if([searchText length]==0)
    {
        //查询所有
        NSArray *array = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    }
    CFRelease(addressBook); 
} 


@end
