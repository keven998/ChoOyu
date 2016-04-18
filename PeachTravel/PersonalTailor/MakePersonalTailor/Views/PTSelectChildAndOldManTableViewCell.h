//
//  PTSelectChildAndOldManTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/12/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTDetailModel.h"

@interface PTSelectChildAndOldManTableViewCell : UITableViewCell

@property (nonatomic, strong) PTDetailModel *ptDetailModel;
@property (weak, nonatomic) IBOutlet UIButton *hasChildButton;
@property (weak, nonatomic) IBOutlet UIButton *hasOldManButton;

@end
