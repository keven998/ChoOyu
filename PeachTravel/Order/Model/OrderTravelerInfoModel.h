//
//  OrderTravelerInfoModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderTravelerInfoModel : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *firstNamePY;
@property (nonatomic, copy) NSString *lastNamePY;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *IDNumber;         //证件号码
@property (nonatomic, copy) NSString *IDCategory;       //证件类型
@property (nonatomic, copy) NSString *IDCategoryDesc;   //证件类型描述，中文
@property (nonatomic, copy) NSString *sex;              //证件类型描述，中文


- (id)initWithJson:(id)json;

@end
