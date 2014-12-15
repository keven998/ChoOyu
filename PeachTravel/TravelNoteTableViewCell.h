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


@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

/**
 *游记是否可以选择后发送
 */
@property (nonatomic) BOOL canSelect;

@end
