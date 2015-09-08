//
//  BaseProfileViewController.h
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"
#import "GuiderDetailInfoCell.h"
#import "GuiderProfileAlbumCell.h"
#import "GuiderProfileTourViewCell.h"
#import "GuiderProfileAbout.h"

#import "PlansListTableViewController.h"
#import "HeaderCell.h"
#import "OtherUserBasicInfoCell.h"
#import "OthersAlbumCell.h"
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "UIImage+resized.h"
#import "ChatListViewController.h"
#import "MWPhotoBrowser.h"
#import "UserAlbumViewController.h"
#import "BaseTextSettingViewController.h"
#import "FootPrintViewController.h"
#import "CMPopTipView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "LoginViewController.h"
#import "TZNavigationViewController.h"
#import "BaseProfileHeaderView.h"

@interface BaseProfileViewController : TZViewController

@property (nonatomic) NSInteger userId;


- (void)loadUserProfile:(NSInteger)userId;

@end
