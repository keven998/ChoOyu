//
//  MakeOrderContactInfoTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeOrderContactInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectTravelerBtn;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
