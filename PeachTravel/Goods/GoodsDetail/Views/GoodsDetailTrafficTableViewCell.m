//
//  GoodsDetailTrafficTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailTrafficTableViewCell.h"

@implementation GoodsDetailTrafficTableViewCell

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    CGFloat retHeight = 42;
    
    if (goodsDetail.goodsTrafficDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };

        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsTrafficDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height;
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
    if (_goodsDetail.goodsTrafficDescSummary) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsTrafficDescSummary attributes:attribs];
        _contentLabel.attributedText = attrstr;

    }
}

@end

