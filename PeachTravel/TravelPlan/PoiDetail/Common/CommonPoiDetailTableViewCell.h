//
//  CommonPoiDetailTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/2/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonPoiDetailTableViewCell : UITableViewCell

+ (CGFloat)heightWithContent:(NSString *)content;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *showMoreButton;

@property (weak, nonatomic) IBOutlet UIButton *addressButton;


@end
