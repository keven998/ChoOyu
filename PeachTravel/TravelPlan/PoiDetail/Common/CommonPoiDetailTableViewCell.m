//
//  CommonPoiDetailTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/2/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "CommonPoiDetailTableViewCell.h"

@implementation CommonPoiDetailTableViewCell

+ (CGFloat)heightWithContent:(NSString *)content
{
    CGFloat retHeight = 75;
    if (content.length) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:content attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-28, 60} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height;
    }
    return retHeight;
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
