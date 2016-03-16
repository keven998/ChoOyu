//
//  GoodsDetailDescTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailDescTableViewCell.h"

@implementation GoodsDetailDescTableViewCell

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    CGFloat retHeight = 80;
    if (goodsDetail.goodsDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-25, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height+15;
    }
    return retHeight;
 
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    _addressLabel.text = [NSString stringWithFormat:@"地址: %@  %@", _goodsDetail.locality.zhName, _goodsDetail.address];
    _timecostLabel.text = [NSString stringWithFormat:@"游玩时长: %@小时", _goodsDetail.timecost];
    
    if (goodsDetail.goodsDescSummary.length) {

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsDescSummary attributes:attribs];
        _descLabel.attributedText = attrstr;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
