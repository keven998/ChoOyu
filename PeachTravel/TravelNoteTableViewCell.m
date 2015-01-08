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

/**
 *  可以发送的情况下显示发送按钮，否则显示进入详情的标记
 */
@property (weak, nonatomic) IBOutlet UIImageView *accessImageView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceView;



@end

@implementation TravelNoteTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = APP_PAGE_COLOR;
    _authorImageView.layer.cornerRadius = 15.0;
    _authorImageView.clipsToBounds = YES;
    _travelNoteImageView.layer.cornerRadius = 3.0;
    _travelNoteImageView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 2.0;
    
    _travelNoteImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _travelNoteImageView.layer.borderWidth = 0.5;
    _travelNoteImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    /**
     *  发送按钮默认隐藏，是否显示需要设置 canSelecte
     */
    _sendBtn.hidden = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTravelNoteImage:(NSString *)travelNoteImage
{
    _travelNoteImage = travelNoteImage;
    if ([_travelNoteImage isEqual: [NSNull null]]) {
        return;
    }
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
    _resourceLabel.text = [NSString stringWithFormat:@"from %@", _resource];
}

- (void)setTime:(NSString *)time
{
    _time = time;
    _timeLabel.text = _time;
}


- (void)setCanSelect:(BOOL)canSelect
{
    _canSelect = canSelect ;
    if (_canSelect) {
        _sendBtn.hidden = NO;
        _accessImageView.hidden = YES;
        _rightSpaceConstraint.constant = 63.0;
    } else {
        _sendBtn.hidden = YES;
        _accessImageView.hidden = NO;
        _rightSpaceConstraint.constant = 19.0;
    }
}

















@end
