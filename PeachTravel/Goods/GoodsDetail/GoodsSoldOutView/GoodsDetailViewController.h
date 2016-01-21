//
//  GoodsDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailViewController : TZViewController

@property (nonatomic) NSInteger goodsId;

//是不是商品快照
@property (nonatomic) BOOL isSnapshot;

//如果是查看商品快照的话，带上商品的 version
@property (nonatomic) long goodsVersion;


@end
