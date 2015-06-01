//
//  JobListViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/4/29.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangJobDelegate <NSObject>

-(void)changeJob:(NSString *)jobStr;

@end

@interface JobListViewController : UIViewController

@property (nonatomic,weak) id<ChangJobDelegate> delegate;
@property (nonatomic,copy) NSArray *dataArray;

@end
