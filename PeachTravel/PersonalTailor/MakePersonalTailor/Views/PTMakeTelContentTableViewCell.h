//
//  PTMakeTelContentTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/5/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTMakeTelContentTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) NSString *dailCode;
@property (weak, nonatomic) IBOutlet UITextField *telConentTextfield;
@property (weak, nonatomic) IBOutlet UIButton *dailCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (nonatomic, copy) void (^endEditBlock)(NSString *dailCode, NSString *number);

@end
