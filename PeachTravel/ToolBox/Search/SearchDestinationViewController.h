//
//  SearchDestinationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"

@interface SearchDestinationViewController : UIViewController

@property (nonatomic, copy) NSString *chatter;

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic) BOOL isChatGroup;

/**
 *  点击是否可以发送
 */
@property (nonatomic) BOOL isCanSend;

@end
