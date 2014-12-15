//
//  SuperWebViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *titleStr;

@end

