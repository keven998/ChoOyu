//
//  PoiDetailSuperViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRecoredListTableViewController.h"
#import "CreateConversationViewController.h"
#import "TaoziChatMessageBaseViewController.h"


@interface PoiDetailSuperViewController : TZViewController

enum {
    kASMap = 1,
    kASShare = 11
};

@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

/**
 *  当把景点发送到桃talk 的时候子类里实现传值,因为不同的 poi 详情需要传递的值不一样
 *
 *  @param taoziMessageCtl 接收值的 ctl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl;

/**
 *  所有 poi 的收藏接口
 *
 *  @param poiId
 *  @param type       poi 类型
 *  @param isFavorite 是收藏还是取消收藏 yes ： 收藏    no：取消收藏
 *  @param completion 收藏回掉
 */
- (void)asyncFavorite:(NSString *)poiId poiType:(NSString *)type isFavorite:(BOOL)isFavorite completion:(void (^) (BOOL isSuccess))completion;

/**
 *  发送到桃talk
 */
- (IBAction)chat:(id)sender;

- (void)shareToTalk;

@end


