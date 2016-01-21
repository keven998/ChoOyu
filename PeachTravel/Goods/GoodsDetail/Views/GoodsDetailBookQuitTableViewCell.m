//
//  GoodsDetailBookQuitTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailBookQuitTableViewCell.h"

@implementation GoodsDetailBookQuitTableViewCell

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    CGFloat retHeight = 115;
    if (goodsDetail.goodsBookDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsBookDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height;
    }
    if (goodsDetail.goodsQuitDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };

        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:goodsDetail.goodsQuitDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
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
    
    if (_goodsDetail.goodsBookDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };

        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_goodsDetail.goodsBookDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _bookContentHightConstraint.constant = rect.size.height+5;
        _bookContentLabel.attributedText = attrstr;

    }
    if (_goodsDetail.goodsQuitDescSummary.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };

        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_goodsDetail.goodsQuitDescSummary attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _quitContentHightConstraint.constant = rect.size.height+5;
        _quitContentLabel.attributedText = attrstr;

    }
    

    
}

@end

