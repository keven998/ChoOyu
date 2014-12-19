//
//  ContactDetailViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 14/11/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactDetailViewController : TZViewController

@property (nonatomic, strong) Contact *contact;

//点击 talk 按钮是否是退回到聊天界面。 因为当在聊天界面点击联系人图标的时候，会进入到这个界面，当我们点聊天的时候需要饭回到聊天界面
//但是别的情况进入到此界面不需要这样
@property (nonatomic) BOOL goBackToChatViewWhenClickTalk;

@end
