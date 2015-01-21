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


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceView;



@end

@implementation TravelNoteTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    _travelNoteImageView.layer.cornerRadius = 4.0;
    _travelNoteImageView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 4.0;
    
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
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:desc];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, desc.length)];
    _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _descLabel.attributedText = attrStr;
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
        _rightSpaceConstraint.constant = 63.0;
    } else {
        _sendBtn.hidden = YES;
        _rightSpaceConstraint.constant = 19.0;
    }
}

















@end
