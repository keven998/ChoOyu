//
//  TravelNoteTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNoteTableViewCell.h"

@interface TravelNoteTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *travelNoteImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *resourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation TravelNoteTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTravelNoteImage:(NSString *)travelNoteImage
{
    _travelNoteImage = travelNoteImage;
    [_travelNoteImageView sd_setImageWithURL:[NSURL URLWithString:_travelNoteImage] placeholderImage:nil];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

- (void)setDesc:(NSString *)desc
{
    _desc = desc;
    _descLabel.text = desc;
}

- (void)setAuthorAvatar:(NSString *)authorAvatar
{
    _authorAvatar = authorAvatar;
    [_authorImageView sd_setImageWithURL:[NSURL URLWithString:_authorAvatar] placeholderImage:nil];
}

- (void)setAuthorName:(NSString *)authorName
{
    _authorName = authorName;
    _authorNameLabel.text = _authorName;
}

- (void)setResource:(NSString *)resource
{
    _resource = resource;
    _resourceLabel.text = _resource;
}

- (void)setTime:(NSString *)time
{
    _time = time;
    _timeLabel.text = _time;
}




















@end
