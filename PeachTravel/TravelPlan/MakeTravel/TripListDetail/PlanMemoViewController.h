//
//  PlanMemoViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlanMemoViewControllerDelegate <NSObject>

- (void)memoSave:(NSString *)memo;

@end

@interface PlanMemoViewController : UIViewController

@property (nonatomic, strong) NSString *memo;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) id <PlanMemoViewControllerDelegate> delegate;

@end
