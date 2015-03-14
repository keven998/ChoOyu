//
//  CommentTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentDetail.h"

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, strong) CommentDetail *commentDetail;

+ (CGFloat)heightForCommentCellWithComment:(NSString *)comment;


@end
