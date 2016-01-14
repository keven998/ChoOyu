//
//  ErrorEmptyView.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ErrorEmptyViewDelegate <NSObject>

@required
- (void)reloadPageAction;

@end

@interface ErrorEmptyView : UIView

@property (weak, nonatomic) id<ErrorEmptyViewDelegate>delegate;

@end
