//
//  MakeOrderContactInfoTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeOrderContactInfoTableViewCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;



@end
