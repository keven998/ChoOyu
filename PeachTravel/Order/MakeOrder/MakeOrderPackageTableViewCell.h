//
//  MakeOrderPackageTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeOrderPackageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *orderContentBtn;

@property (nonatomic, strong) NSString *packageTitle;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic) BOOL isSelected;

@end
