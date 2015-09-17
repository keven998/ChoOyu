//
//  GuiderCollectionViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 7/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuiderDistribute;

@interface GuiderCollectionViewController : UICollectionViewController

@property (nonatomic, copy) NSString *distributionArea;

// 传递模型进来
@property (nonatomic, strong)GuiderDistribute * guiderDistribute;

@end
