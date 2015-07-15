//
//  PlanScheduleTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PlanScheduleTableViewCell.h"

@interface PlanScheduleTableViewCell () 

@end

@implementation PlanScheduleTableViewCell

- (void)awakeFromNib {
    _headerImageView.clipsToBounds = YES;
    _dayLabel.textAlignment = NSTextAlignmentCenter;
    _dayScheduleSummary.numberOfLines = 0;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:_content attributes:@{
                                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                                   NSParagraphStyleAttributeName : style
                                                                                                   }];
    _dayScheduleSummary.attributedText = attrStr;
}

- (void) setDay:(NSString *)dayIndex {
    NSAttributedString *unitAStr = [[NSAttributedString alloc] initWithString:@"\nDay" attributes:@{
                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:10.0],
                                                                                                    }];
    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:dayIndex attributes:nil];
    [attrstr appendAttributedString:unitAStr];
    _dayLabel.attributedText = attrstr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)heightOfCellWithContent:(NSString *)content {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;
    
    CGSize labelSize = [content boundingRectWithSize:CGSizeMake(kWindowWidth-100-24, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                                       NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                       NSParagraphStyleAttributeName : style
                                                       }
                                             context:nil].size;
    return labelSize.height+55;
    
}

@end
