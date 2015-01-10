//
//  LocationTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *telephoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (copy, nonatomic) NSString *address;
@property (nonatomic, copy) NSString *tel;
@property (weak, nonatomic) IBOutlet UIButton *navigationBtn;

+ (CGFloat)heightForAddressCellWithAddress:(NSString *)address;

@end
