//
//  ChangeGroupTitleViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@protocol changeTitle <NSObject>

- (void)changeGroupTitle;

@end


@interface ChangeGroupTitleViewController : TZViewController

@property (nonatomic) IMDiscussionGroup *group;
@property (nonatomic, copy) NSString *oldTitle;
@property (weak,nonatomic) id<changeTitle> delegate;

@end
