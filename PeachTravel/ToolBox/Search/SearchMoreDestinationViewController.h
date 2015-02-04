//
//  SearchMoreDestinationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"
#import "TripDetail.h"

@interface SearchMoreDestinationViewController : TZViewController

@property (nonatomic) TZPoiType poiType;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, copy) NSString *poiTypeDesc;

@property (nonatomic, copy) NSString *chatter;

@property (nonatomic) BOOL isChatGroup;

/**
 *  搜索的字段
 */
@property (nonatomic, copy) NSString *keyWord;



@end