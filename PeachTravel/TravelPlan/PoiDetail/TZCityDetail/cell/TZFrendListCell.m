//
//  TZFrendListCell.m
//  TZCityDetail
//
//  Created by 冯宁 on 15/9/19.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "TZFrendListCell.h"
#import "FrendListTagCell.h"
#import "TaoziCollectionLayout.h"
#import "ARGUMENTSFORTZFrendList.h"
#import "Constants.h"



@interface TZFrendListCell () <UICollectionViewDataSource,UICollectionViewDelegate, TaoziLayoutDelegate>

@property (nonatomic, strong) UIImageView* crownImageView;
@property (nonatomic, strong) UIImageView* headerImageView;

@property (nonatomic, strong) UIImageView* levelImageView;
@property (nonatomic, strong) UILabel* levelLabel;
@property (nonatomic, strong) UILabel* descriptionLabel;

@property (nonatomic, strong) UIView* seperatorView;


@end

@implementation TZFrendListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareSubViews];
        
    }
    return  self;
}

- (void)prepareSubViews{
    
    [self.contentView addSubview: self.headerImageView];
    [self.contentView addSubview:self.crownImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.levelImageView];
    [self.levelImageView addSubview:self.levelLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.tagCollectionView];
    [self.contentView addSubview:self.seperatorView];
    [self.contentView addSubview:self.cityAndAgeLabel];
    
    
    
    
    
#ifdef COLORDEBUG
    //    self.crownImageView.backgroundColor = RANDOMCOLOR;
    //    self.headerImageView.backgroundColor = RANDOMCOLOR;
    //    self.titleLabel.backgroundColor = RANDOMCOLOR;
    //    self.levelLabel.backgroundColor = RANDOMCOLOR;
    //    self.levelImageView.backgroundColor = RANDOMCOLOR;
    //    self.descriptionLabel.backgroundColor = RANDOMCOLOR;
#endif
    
    self.crownImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.levelLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.levelImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cityAndAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"crown":self.crownImageView,
                           @"header":self.headerImageView,
                           @"title":self.titleLabel,
                           @"levelImage":self.levelImageView,
                           @"levelLabel":self.levelLabel,
                           @"description":self.descriptionLabel,
                           @"seperator":self.seperatorView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-16-[header(%d)]-8-[title]",HEADERSIZE] options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-16-[header(%d)]",HEADERSIZE] options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[crown]" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[crown]" options:0 metrics:nil views:dict]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[description]-24-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[levelImage]-16-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[levelImage]" options:0 metrics:nil views:dict]];
    
    [self.levelImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.levelLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.levelImageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.levelImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.levelLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.levelImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:8]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self prepareSubViewsForArea];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.cityAndAgeLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.cityAndAgeLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.descriptionLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.levelImageView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[seperator]-24-|" options:0 metrics:nil views:dict]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[seperator(0.5)]-0-|" options:0 metrics:nil views:dict]];
    
    _headerImageView.layer.cornerRadius = HEADERSIZE / 2;
    _headerImageView.layer.borderWidth = 2;
    UIColor* borderColor= APP_BORDER_COLOR;
    _headerImageView.layer.borderColor = borderColor.CGColor;
    _headerImageView.clipsToBounds = YES;
    
//    self.contentView.backgroundColor = APP_IMAGEVIEW_COLOR;
}

- (void)prepareSubViewsForArea{
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:2]];
    
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.model.tags.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FrendListTagCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:FREND_LIST_TAG_CELL forIndexPath:indexPath];
    if (indexPath.item%5 == 0) {
        cell.tintColor = UIColorFromRGB(0xB9DC96);
    } else if (indexPath.item%5 == 1) {
        cell.tintColor = UIColorFromRGB(0xFF96A0);
    } else if (indexPath.item%5 == 2) {
        cell.tintColor = UIColorFromRGB(0x8CC8FF);
    } else if (indexPath.item%5 == 3) {
        cell.tintColor = UIColorFromRGB(0xFFBE64);
    } else {
        cell.tintColor = UIColorFromRGB(0x82F0FA);
    }
    NSString* tagStr = self.model.tags[indexPath.item];
    cell.tagString = tagStr;
    return cell;
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)tzCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.model.tags[indexPath.item];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.0]}];
    return CGSizeMake(size.width+10, 15);
}

- (CGSize)tzCollectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(kWindowWidth, 0);
}

- (NSInteger)tzNumberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.tags.count;
}

- (CGFloat)tzCollectionLayoutWidth
{
    return self.bounds.size.width-20;
}

#pragma mark - setter & getter

- (void)setModel:(ExpertModel *)model {
    _model = model;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:self.model.avatar] placeholderImage:nil];
    [self.levelLabel setText:[NSString stringWithFormat:@"V%ld", self.model.level]];
    self.titleLabel.text = self.model.nickName;
    self.descriptionLabel.text = self.model.signature;
    [self.tagCollectionView reloadData];


}

- (UIImageView *)crownImageView{
    if (_crownImageView == nil) {
        _crownImageView = [[UIImageView alloc] init];
        _crownImageView.image = [UIImage imageNamed:@"citydetail_king_head"];
    }
    return _crownImageView;
}
- (UIImageView *)headerImageView{
    if (_headerImageView == nil) {
        _headerImageView = [[UIImageView alloc] init];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headerImageView;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"大雄";
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}
- (UIImageView *)levelImageView{
    if (_levelImageView == nil) {
        _levelImageView = [[UIImageView alloc] init];
        _levelImageView.image = [UIImage imageNamed:@"citydetail_lv_bg"];
    }
    return _levelImageView;
}
- (UILabel *)levelLabel{
    if (_levelLabel == nil) {
        _levelLabel = [[UILabel alloc] init];
        _levelLabel.text = @"V0";
        _levelLabel.font = [UIFont systemFontOfSize:10];
        _levelLabel.textAlignment = NSTextAlignmentCenter;
        _levelLabel.textColor = [UIColor whiteColor];
    }
    return _levelLabel;
}
- (UILabel *)descriptionLabel{
    if (_descriptionLabel == nil) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.font = [UIFont systemFontOfSize:12];
        _descriptionLabel.text = @"丽江古城，又名“大研古镇”，坐落在云南省丽江市大研镇，地理坐标为东经100°14′，北纬26°52′。海拔2400余米。是一座风景秀丽，历史悠久和文化灿烂的名城，也是中国罕见的保存相当完好的少数民族古镇。丽江古城是第二批被批准的中国历史文化名城之一，也是中国仅有的以整座古城申报世界文化遗产获得成功的两座古县城之一（另一座为山西平遥古城）。";
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.textColor = COLOR_TEXT_II;
    }
    return _descriptionLabel;
}
- (UICollectionView *)tagCollectionView{
    if (_tagCollectionView == nil) {
        TaoziCollectionLayout* flowLayout = [[TaoziCollectionLayout alloc] init];
        flowLayout.spacePerItem = 7;
        flowLayout.delegate = self;
        _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _tagCollectionView.scrollEnabled = NO;
        _tagCollectionView.userInteractionEnabled = NO;
        [_tagCollectionView registerClass:[FrendListTagCell class] forCellWithReuseIdentifier:FREND_LIST_TAG_CELL];
        UIView* backView = [[UIView alloc] init];
        _tagCollectionView.backgroundView = backView;

        _tagCollectionView.backgroundColor = [UIColor clearColor];
        _tagCollectionView.dataSource = self;
        _tagCollectionView.delegate = self;
    }
    return _tagCollectionView;
}
- (UIView *)seperatorView{
    if (_seperatorView == nil) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = COLOR_TEXT_IV;
    }
    return _seperatorView;
}

- (UILabel *)cityAndAgeLabel{
    if (_cityAndAgeLabel == nil) {
        _cityAndAgeLabel = [[UILabel alloc] init];
        _cityAndAgeLabel.font = [UIFont systemFontOfSize:8];
        _cityAndAgeLabel.textColor = COLOR_TEXT_II;
    }
    return _cityAndAgeLabel;
}


@end
