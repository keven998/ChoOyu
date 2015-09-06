//
//  SearchDestinationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"
#import "PeachTravel-swift.h"

@interface SearchDestinationViewController : UIViewController

@property (nonatomic) NSInteger chatterId;

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic) IMChatType chatType;

//是否是 tabbar 层的 viewcontroller
@property (nonatomic) BOOL isRootViewController;

/**
 *  点击是否可以发送
 */
@property (nonatomic) BOOL isCanSend;

@end
