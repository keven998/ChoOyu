
//
//  MapMarkMenuVC.m
//  MapMark
//
//  Created by 冯宁 on 15/9/24.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "MapMarkMenuVC.h"
#import "MapMarkMenuCell.h"

@interface MapMarkMenuVC () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray* array;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* backView;
@property (nonatomic, strong) UIView* headView;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIView* constraintView;
@property (nonatomic, strong) UIView* maskView;

@property (nonatomic, strong) NSLayoutConstraint* animatedConstraint;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation MapMarkMenuVC

- (instancetype)initWithArray:(NSArray*)array{
    if (self = [super init]) {
        self.array = array;
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self setUpViews];
        [self layoutIfNeeded];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)goBack{
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0;
        self.animatedConstraint.constant = 141.7;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0.3;
        self.animatedConstraint.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)setUpViews {
    [self addSubview:self.maskView];
    [self addSubview:self.constraintView];

    [self.constraintView addSubview:self.headView];
    [self.constraintView addSubview:self.backView];
    [self.constraintView addSubview:self.tableView];
    
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraintView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"head":self.headView,@"back":self.backView,@"table":self.tableView,@"constraint":self.constraintView,@"mask":self.maskView};
    NSLayoutConstraint* animatedConstraint = [NSLayoutConstraint constraintWithItem:self.constraintView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:141.7];
    self.animatedConstraint = animatedConstraint;
    [self addConstraint:self.animatedConstraint];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[constraint(141.7)]" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[constraint]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mask]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mask]-0-|" options:0 metrics:nil views:dict]];
    [self.constraintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[head]-0-|" options:0 metrics:nil views:dict]];
    [self.constraintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[head(64)]-0-[table]-0-|" options:0 metrics:nil views:dict]];
    [self.constraintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[back]-0-|" options:0 metrics:nil views:dict]];
    [self.constraintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[table]-0-|" options:0 metrics:nil views:dict]];
    [self.constraintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[back]-0-|" options:0 metrics:nil views:dict]];
//    [self layoutIfNeeded];
    [self setUpHead];
}

- (void)setUpHead{
    [self.headView addSubview:self.iconImageView];
    [self.headView addSubview:self.titleLabel];
    
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"icon":self.iconImageView,@"title":self.titleLabel};
    [self.headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-18.7-[icon(21)]-10.7-[title]-0-|" options:0 metrics:nil views:dict]];
    [self.headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22.3-[icon(21)]" options:0 metrics:nil views:dict]];
    [self.headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-29.3-[title]" options:0 metrics:nil views:dict]];
    
}


#pragma mark - dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MapMarkMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.dayIndex = [(NSNumber*)self.array[indexPath.row] integerValue];
    NSLog(@"%@",self.array[indexPath.row]);

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(selectItem:atIndex:)]) {
        if (indexPath.row > 9) {
            [self.delegate selectItem:[NSString stringWithFormat:@"%ld.Day",indexPath.row + 1] atIndex:indexPath];
        }else{
            [self.delegate selectItem:[NSString stringWithFormat:@"0%ld.Day",indexPath.row + 1] atIndex:indexPath];
        }
     
    };
    [self goBack];
}


#pragma mark - setter & getter
- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0] animated:NO scrollPosition:0];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[MapMarkMenuCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}
- (UIView *)backView{
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.5;
    }
    return _backView;
}
- (UIView *)headView{
    if (_headView == nil) {
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor blackColor];
    }
    return _headView;
}
- (UIImageView *)iconImageView{
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"mapMark_my_trip"];
    }
    return _iconImageView;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"我的行程";
        _titleLabel.font = [UIFont systemFontOfSize:12.3];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
- (UIView *)constraintView{
    if (_constraintView == nil) {
        _constraintView = [[UIView alloc] init];
    }
    return _constraintView;
}
- (UIView *)maskView{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        _maskView.userInteractionEnabled = YES;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)]];
    }
    return _maskView;
}

@end
