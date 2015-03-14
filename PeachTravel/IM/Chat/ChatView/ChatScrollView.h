//
//  ChatScrollView.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/6.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatScrollView : UIView

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *deleteBtns;
@property (nonatomic) BOOL isEditting;

@property (nonatomic, strong) UIButton *dismissBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UIButton *addBtn;
@property (nonatomic) BOOL shouldshowDeleteBtn;
@property (nonatomic, strong) NSArray *titles;

@end
