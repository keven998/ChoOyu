//
//  GuiderCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderCell.h"
#import "GuilderDistribute.h"
@interface GuiderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UILabel *expertUserCnt;

@property (weak, nonatomic) IBOutlet UILabel *zhName;


@end

@implementation GuiderCell

// 初始化
+ (id)guiderWithTableView:(UITableView *)tableView
{
    static NSString * ID = @"cell";
    
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    [tableView registerNib:nib forCellReuseIdentifier:ID];
    
    return [tableView dequeueReusableCellWithIdentifier:ID];
}

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = APP_PAGE_COLOR;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = COLOR_LINE.CGColor;
}

// 2.给成员变量赋值
- (void)setGuiderDistribute:(GuilderDistribute *)guiderDistribute
{
    _guiderDistribute = guiderDistribute;
    
    // 判断图片数组是否为空,如果为空,就不显示
    NSArray * array = guiderDistribute.images;
    if (array.count != 0) {
        NSString * imageUrl = array[0][@"url"];
        NSURL * url = [NSURL URLWithString:imageUrl];
        [self.bgImage sd_setImageWithURL:url];
    }
    self.expertUserCnt.text = [NSString stringWithFormat:@"%@位",guiderDistribute.expertUserCnt];
    self.zhName.text = [NSString stringWithFormat:@"~派派 · %@ · 达人~",guiderDistribute.zhName];
    
}

@end
