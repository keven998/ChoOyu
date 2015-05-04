//
//  StatusListViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/4/29.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "JobListViewController.h"

@protocol ChangStatusDelegate <NSObject>

-(void)changeStatus;

@end

@interface StatusListViewController : UIViewController

@property (copy,nonatomic) NSArray *dataArray;
@property (weak,nonatomic) id<ChangStatusDelegate> delegate;
@end
