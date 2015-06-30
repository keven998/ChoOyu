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
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation TravelNoteTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    [_backgroundImageView setImage:[[UIImage imageNamed:@"city_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];

    _travelNoteImageView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 4.0;
    _travelNoteImageView.layer.cornerRadius = 23.5;
    
    _travelNoteImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    /**
     *  发送按钮默认隐藏，是否显示需要设置 canSelecte
     */
    _sendBtn.hidden = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = TEXT_COLOR_TITLE;
    _descLabel.font = [UIFont systemFontOfSize:13];
    _descLabel.numberOfLines = 3;
    _descLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    
    _propertyLabel.font = [UIFont systemFontOfSize:12];
    _propertyLabel.textColor = TEXT_COLOR_TITLE_PH;
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
}

- (void)setAuthorName:(NSString *)authorName
{
    _authorName = authorName;
}

- (void)setResource:(NSString *)resource
{
    _resource = resource;
}

- (void)setTime:(NSString *)time
{
    _time = time;
}

- (void) setProperty:(NSString *)property {
    _property = property;
    _propertyLabel.text = property;
}


- (void)setCanSelect:(BOOL)canSelect
{
    _canSelect = canSelect ;
    if (_canSelect) {
        _sendBtn.hidden = NO;
    } else {
        _sendBtn.hidden = YES;
    }
}

















@end
