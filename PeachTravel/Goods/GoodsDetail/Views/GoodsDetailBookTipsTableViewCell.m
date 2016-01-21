//
//  GoodsDetailBookTipsTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailBookTipsTableViewCell.h"

@implementation GoodsDetailBookTipsTableViewCell

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    CGFloat retHeight = 95;
    if (goodsDetail.goodsFeeDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsFeeDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height+15;
    }
 
    return retHeight;
    
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5.0;
    
    if (goodsDetail.goodsFeeDescSummary) {
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsFeeDescSummary attributes:attribs];
        _feeDescLabel.attributedText = attrstr;
    }
  
}

@end
