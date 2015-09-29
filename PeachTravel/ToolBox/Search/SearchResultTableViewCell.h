//
//  SearchResultTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface SearchResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) IBOutlet EDStarRating* ratingView;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsCollectionView;

@property (nonatomic, strong) NSArray* tagsArray;

@property (nonatomic) BOOL isCanSend;

@end
