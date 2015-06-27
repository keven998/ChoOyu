//
//  TravelNoteListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZTBViewController.h"
#import "PeachTravel-swift.h"

@interface TravelNoteListViewController : TZTBViewController

/**
 *  是搜索游记还是查看城市的游记
 */
@property (nonatomic) BOOL isSearch;

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *cityName;

@property (nonatomic) NSInteger chatterId;
@property (nonatomic) IMChatType chatType;

@end
