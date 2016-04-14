//
//  PTMakeContentTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/5/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTravelerInfoModel.h"

@interface PTMakeContentTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (copy, nonatomic) NSString *typeDesc;
@property (copy, nonatomic) NSString *contentPlaceHolder;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *contentTextfield;

@property (nonatomic, copy) void (^endEditBlock)(NSString *content);

@end
