//
//  BNGoodsDetailPackageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNGoodsDetailPackageTableViewCell.h"

@implementation BNGoodsDetailPackageTableViewCell

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    CGFloat retHeight = 40;
    if (goodsDetail.packages.count) {
        
        NSMutableString *content = [[NSMutableString alloc] init];
        
        for (int i=0; i<goodsDetail.packages.count; i++) {
            GoodsPackageModel *package = [goodsDetail.packages objectAtIndex:i];
            [content appendFormat:@"￥%@起   %@", package.formatCurrentPrice, package.packageName];
            if (i != goodsDetail.packages.count-1) {
                [content appendString:@"\n"];
            }
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:content attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height+5;
    }
    
    return retHeight;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setGoodsDetail:(BNGoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    if (goodsDetail.packages.count) {
        
        NSMutableString *content = [[NSMutableString alloc] init];
        
        for (int i=0; i<goodsDetail.packages.count; i++) {
            GoodsPackageModel *package = [goodsDetail.packages objectAtIndex:i];
            [content appendFormat:@"%d.￥%@起   %@", i+1, package.formatCurrentPrice, package.packageName];
            if (i != goodsDetail.packages.count-1) {
                [content appendString:@"\n"];
            }
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:content attributes:attribs];
        
        _contentLabel.attributedText = attrstr;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
