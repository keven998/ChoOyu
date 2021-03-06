//
//  SearchMoreDestinationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"
#import "TripDetail.h"
#import "PeachTravel-swift.h"

@interface SearchMoreDestinationViewController : TZViewController

@property (nonatomic) TZPoiType poiType;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, copy) NSString *poiTypeDesc;

@property (nonatomic) NSInteger chatterId;

@property (nonatomic) IMChatType chatType;

/**
 *  点击是否可以发送
 */
@property (nonatomic) BOOL isCanSend;

/**
 *  搜索的字段
 */
@property (nonatomic, copy) NSString *keyWord;



@end
