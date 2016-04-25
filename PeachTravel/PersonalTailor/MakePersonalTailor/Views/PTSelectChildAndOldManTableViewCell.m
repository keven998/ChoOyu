//
//  PTSelectChildAndOldManTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/12/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTSelectChildAndOldManTableViewCell.h"

@implementation PTSelectChildAndOldManTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_hasChildButton setTitle:@"儿童 " forState:UIControlStateNormal];
    [_hasOldManButton setTitle:@"老人 " forState:UIControlStateNormal];

}
- (IBAction)selectChildAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    _ptDetailModel.hasChild = sender.selected;
}

- (IBAction)selectOldManAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    _ptDetailModel.hasOldMan = sender.selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end