//
//  DropDownViewController.h
//  PeachTravel
//
//  Created by 王聪 on 15/7/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol dropDownMenuProtocol <NSObject>

- (void)didSelectedcityIndex:(NSInteger)cityindex categaryIndex:(NSInteger)categaryIndex andTag:(int)tag;

@end

@interface DropDownViewController : UITableViewController

// 将旅行详细信息传递过来
@property (nonatomic, strong)NSArray * siteArray;

// 设置一个属性判断点击了哪个按钮
@property (nonatomic, assign)int tag;

@property (nonatomic, assign)NSInteger showAccessory;

@property (nonatomic, assign)id<dropDownMenuProtocol> delegateDrop;

@end
