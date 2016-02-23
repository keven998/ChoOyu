//
//  SearchFrendTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 7/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateConversationViewController.h"

@interface SearchInviteUser2GroupViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *selectedContacts;

@property (weak, nonatomic) CreateConversationViewController *rootViewController;

@end
