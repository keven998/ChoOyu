//
//  GoodsDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 10/26/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailViewController2 : TZViewController

@property (nonatomic) NSInteger goodsId;

//是不是商品快照
@property (nonatomic) BOOL isSnapshot;

//如果是查看商品快照的话，带上商品的 version
@property (nonatomic) long goodsVersion;


@end
