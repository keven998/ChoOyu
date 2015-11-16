//
//  MakeOrderPackageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderPackageTableViewCell.h"

@implementation MakeOrderPackageTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [_orderContentBtn setBackgroundImage:[[UIImage imageNamed:@"icon_makeOrder_packageNormal"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 15)] forState:UIControlStateNormal];
    [_orderContentBtn setBackgroundImage:[[UIImage imageNamed:@"icon_makeOrder_packageSelected"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 25, 25)] forState:UIControlStateSelected];
  }

- (void)setPackageTitle:(NSString *)packageTitle
{
    _packageTitle = packageTitle;
    [_orderContentBtn setTitle:_packageTitle forState:UIControlStateNormal];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _orderContentBtn.selected = _isSelected;
}

@end
