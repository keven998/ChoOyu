//
//  TravelNoteTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TravelNoteTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *travelNoteImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *authorAvatar;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *resource;
@property (nonatomic, copy) NSString *time;

@end
