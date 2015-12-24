//
//  DialCodeTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DialCodeTableViewControllerDelegate <NSObject>

/**
 *  选中的国际码
 *
 *  @param dialCode 
 */
- (void)didSelectDialCode:(NSDictionary *)dialCode;

@end

@interface DialCodeTableViewController : UITableViewController

@property (nonatomic, weak) id <DialCodeTableViewControllerDelegate> delegate;

@end
