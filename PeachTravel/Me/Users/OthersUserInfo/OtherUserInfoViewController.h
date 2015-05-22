//
//  OtherUserInfoViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/5/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"

@interface OtherUserInfoViewController : TZViewController

@property (nonatomic,strong) UserProfile *model;
@property (nonatomic,strong) NSString *userId;

@end
