//
//  FavoriteTableViewCell.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *standardImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentType;
@property (weak, nonatomic) IBOutlet UILabel *contentDescLabel;
    
@property (weak, nonatomic) IBOutlet UILabel *contentLocation;
@property (weak, nonatomic) IBOutlet UILabel *contentTitle;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *titleBkgImageView;
@property (weak, nonatomic) IBOutlet UIView *contentBkgView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sendBtnBkgImageView;

/**
 *  是否可以发送
 */
@property (nonatomic) BOOL isCanSend;


@end
