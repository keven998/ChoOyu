//
//  PlansListTableHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 15/8/11.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PlansListTableHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIButton *addTourPlan;

+ (id)planListHeaderView;

@end
