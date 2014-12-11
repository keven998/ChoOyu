//
//  LocalTableViewCell.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface LocalTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentTypeFlag;
@property (weak, nonatomic) IBOutlet UILabel *contentTitle;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *propertyView;
@property (weak, nonatomic) IBOutlet UIImageView *standardImg;
@property (weak, nonatomic) IBOutlet UIButton *address;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingBar;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthor;
@property (weak, nonatomic) IBOutlet UILabel *commentContent;
@property (weak, nonatomic) IBOutlet UIButton *commentCount;

@end
