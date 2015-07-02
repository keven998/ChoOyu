//
//  TravelerTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/20.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TravelerTableViewCell.h"

@implementation TravelerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1)];
        divider.backgroundColor = APP_PAGE_COLOR;
        [self.contentView addSubview:divider];
        
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11, 67, 67)];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.backgroundColor = APP_IMAGEVIEW_COLOR;
        _avatarView.layer.cornerRadius = 10;
        [self.contentView addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 12, 0, 21)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = TEXT_COLOR_TITLE;
        [self.contentView addSubview:_nameLabel];
        
        _statusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 13, 13)];
        _statusLable.font = [UIFont systemFontOfSize:10];
        _statusLable.textColor = [UIColor whiteColor];
        _statusLable.backgroundColor = APP_THEME_COLOR;
        _statusLable.layer.cornerRadius = 2.0;
        _statusLable.textAlignment = NSTextAlignmentCenter;
        _statusLable.clipsToBounds = YES;
        [self.contentView addSubview:_statusLable];
        
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 0, 13)];
        _levelLabel.textColor = [UIColor whiteColor];
        _levelLabel.font = [UIFont systemFontOfSize:10];
        _levelLabel.backgroundColor = UIColorFromRGB(0xf4b713);
        _levelLabel.textAlignment = NSTextAlignmentCenter;
        _levelLabel.layer.cornerRadius = 2.0;
        _levelLabel.clipsToBounds = YES;
        [self.contentView addSubview:_levelLabel];
        
        _resideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 0, 18)];
        _resideLabel.font = [UIFont systemFontOfSize:12];
        _resideLabel.textAlignment = NSTextAlignmentCenter;
        _resideLabel.textColor = TEXT_COLOR_TITLE_HINT;
        [self.contentView addSubview:_resideLabel];
        
        _footprintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 37, CGRectGetWidth(self.bounds) - 100, 18)];
        _footprintsLabel.font = [UIFont systemFontOfSize:13];
        _footprintsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _footprintsLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        [self.contentView addSubview:_footprintsLabel];
        
        _signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, CGRectGetWidth(self.bounds) - 100, 18)];
        _signatureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _signatureLabel.font = [UIFont systemFontOfSize:12];
        _signatureLabel.textColor = TEXT_COLOR_TITLE_HINT;
        [self.contentView addSubview:_signatureLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize reSize = [_resideLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName : [UIFont systemFontOfSize:12]
                                                              }
                                                    context:nil].size;
    CGSize levelSize = [_levelLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName : [UIFont systemFontOfSize:10]
                                                                }
                                                      context:nil].size;
    
    CGFloat maxSize = CGRectGetWidth(self.bounds) - 90 - 10 - 15 - 20 - reSize.width - levelSize.width - 5;
    CGSize nameSize = [_nameLabel.text boundingRectWithSize:CGSizeMake(maxSize, 21)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                              }
                                                    context:nil].size;
    CGRect rf = _resideLabel.frame;
    rf.size.width = reSize.width + 24;
    rf.origin.x = CGRectGetWidth(self.bounds) - rf.size.width;
    _resideLabel.frame = rf;
    
    CGRect nf = _nameLabel.frame;
    nf.size.width = nameSize.width;
    _nameLabel.frame = nf;
    
    CGRect slf = _statusLable.frame;
    slf.origin.x = nf.origin.x + nf.size.width + 4;
    _statusLable.frame = slf;
    
    CGRect llf = _levelLabel.frame;
    llf.size.width = levelSize.width + 5;
    llf.origin.x = slf.origin.x + slf.size.width + 5;
    _levelLabel.frame = llf;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
