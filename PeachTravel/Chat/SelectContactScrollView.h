//
//  SelectContactScrollView.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZSelectView.h"
#import "SelectContactUnitView.h"

@interface SelectContactScrollView : TZSelectView

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)addSelectUnit:(SelectContactUnitView *)selectContactUnit;

@end
