//
//  CityDetailHeaderBottomView.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/22.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "CityDetailHeaderBottomView.h"

#import "CityDetailHeaderBtnSqure.h"
#import "ArgumentsOfCityDetailHeaderView.h"
#import "Constants.h"
#import "CityDetailHeaderCircleBtnCell.h"
#import "CityDetailHeaderFlowLayout.h"

@interface CityDetailHeaderBottomView () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray* cirvleBtnSettingArray;
@property (nonatomic, strong) NSArray* squreBtnSettingArray;
@property (nonatomic, strong) UICollectionView* circleBtnCollection;
@property (nonatomic, strong) CityDetailHeaderFlowLayout* flowLayout;
@property (nonatomic, strong) NSArray* squreBtnArray;

@property (nonatomic, strong) UIView* seperateHor;
@property (nonatomic, strong) UIView* seperateVer;

@end

@implementation CityDetailHeaderBottomView

/** 配置按钮的属性 */
- (NSArray *)cirvleBtnSettingArray{
    if (_cirvleBtnSettingArray == nil) {
        _cirvleBtnSettingArray = @[
                             @{@"picN":@"citydetail_food_normal",@"picH":@"citydetail_food_hilighted",@"title":@"美食",@"selector":@"restaurantAction"},
                             @{@"picN":@"citydetail_jingdian_normal",@"picH":@"citydetail_jingdian_hilighted",@"title":@"景点",@"selector":@"spotAction"},
                             @{@"picN":@"citydetail_point_normal",@"picH":@"citydetail_point_hilighted",@"title":@"指南",@"selector":@"guideAction"},
                             @{@"picN":@"citydetail_shopping_normal",@"picH":@"citydetail_shopping_hilighted",@"title":@"购物",@"selector":@"shoppingAction"}
                             ];
    }
    return _cirvleBtnSettingArray;
}
- (NSArray *)squreBtnSettingArray{
    if (_squreBtnSettingArray == nil) {
        _squreBtnSettingArray = @[
                              @{@"picN":@"citydetail_journey_plan_normal",@"picH":@"citydetail_joyney_plan_hilighted",@"title":@"推荐行程",@"selector":@"planAction"},
                              @{@"picN":@"citydetail_write_journey_normal",@"picH":@"citydetail_write_journey_hilighted",@"title":@"相关游记",@"selector":@"journeyAction"}
                                  ];
    }
    return _squreBtnSettingArray;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    NSLog(@"didmovetosuperview  ---  %@",NSStringFromCGRect(self.frame));
    [self setUpViews];
}

- (void)setUpViews{
    [self addSubview:self.circleBtnCollection];
    [self addSubview:self.seperateHor];
    [self addSubview:self.squreBtnArray[0]];
    [self addSubview:self.squreBtnArray[1]];
    [self addSubview:self.seperateVer];
    self.circleBtnCollection.translatesAutoresizingMaskIntoConstraints = NO;
    self.seperateVer.translatesAutoresizingMaskIntoConstraints = NO;
    self.seperateHor.translatesAutoresizingMaskIntoConstraints = NO;
    for (UIButton* btn in self.squreBtnArray) {
        btn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    CGFloat centerOffset = [UIScreen mainScreen].bounds.size.width / 4;
    
    NSDictionary* dict = @{@"colleciton":self.circleBtnCollection,@"sh":self.seperateHor,@"sBtnA":self.squreBtnArray[0],@"sBtnB":self.squreBtnArray[1],@"sv":self.seperateVer};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[colleciton]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sh]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[colleciton(89)]-0-[sh(0.5)]-12-[sBtnA]-12-|" options:0 metrics:nil views:dict]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sh]-12-[sBtnB]-12-|" options:0 metrics:nil views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.squreBtnArray[0] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-centerOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.squreBtnArray[1] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:centerOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.seperateVer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sh]-12-[sv]-12-|" options:0 metrics:nil views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.seperateVer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    

}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.cirvleBtnSettingArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CityDetailHeaderCircleBtnCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary* dict = self.cirvleBtnSettingArray[indexPath.item];
    [cell setPicH:[UIImage imageNamed:dict[@"picH"]]];
    [cell setPicN:[UIImage imageNamed:dict[@"picN"]]];
    [cell setTitle:dict[@"title"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* selectorDict = self.cirvleBtnSettingArray[indexPath.item];
    NSString* selectorStr = selectorDict[@"selector"];
    NSLog(@"%ld",indexPath.item);
    [self performSelector:NSSelectorFromString(selectorStr) withObject:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CityDetailHeaderCircleBtnCell* cell = [[CityDetailHeaderCircleBtnCell alloc] init];
    NSDictionary* dict = self.cirvleBtnSettingArray[indexPath.item];
    [cell setPicH:[UIImage imageNamed:dict[@"picH"]]];
    [cell setPicN:[UIImage imageNamed:dict[@"picN"]]];
    [cell setTitle:dict[@"title"]];
    [cell sizeToFit];
    return cell.bounds.size;
}

#pragma mark - actions
- (void)restaurantAction{
    if ([self.delegate respondsToSelector:@selector(restaurantBtnAction)]) {
        [self.delegate restaurantBtnAction];
    }
}
- (void)spotAction{
    if ([self.delegate respondsToSelector:@selector(spotBtnAction)]) {
        [self.delegate spotBtnAction];
    }
}
- (void)guideAction{
    if ([self.delegate respondsToSelector:@selector(guideBtnAction)]) {
        [self.delegate guideBtnAction];
    }
}
- (void)shoppingAction{
    if ([self.delegate respondsToSelector:@selector(shoppingBtnAction)]) {
        [self.delegate shoppingBtnAction];
    }
}
- (void)planAction{
    if ([self.delegate respondsToSelector:@selector(planBtnAction)]) {
        [self.delegate planBtnAction];
    }
}
- (void)journeyAction{
    if ([self.delegate respondsToSelector:@selector(journeyBtnAction)]) {
        [self.delegate journeyBtnAction];
    }
}

#pragma mark - setter & getter
- (NSArray *)squreBtnArray{
    if (_squreBtnArray == nil) {
        NSMutableArray* tempArray = [NSMutableArray array];
        for (int i = 0; i < self.squreBtnSettingArray.count; i++) {
            CityDetailHeaderBtnSqure* btn = [CityDetailHeaderBtnSqure buttonWithType:UIButtonTypeSystem];
            NSDictionary* dict = self.squreBtnSettingArray[i];
            [btn setImage:[[UIImage imageNamed:dict[@"picN"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [btn setImage:[[UIImage imageNamed:dict[@"picH"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
            [btn setTitle:dict[@"title"] forState:UIControlStateNormal];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
            [btn addTarget:self action:NSSelectorFromString(dict[@"selector"]) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            
            [tempArray addObject:btn];
        }
        _squreBtnArray = [tempArray copy];
    }
    return _squreBtnArray;
}
- (UIView *)seperateHor{
    if (_seperateHor == nil) {
        _seperateHor = [[UIView alloc] init];
        _seperateHor.backgroundColor = COLOR_TEXT_III;
        _seperateHor.alpha = 0.4;
    }
    return _seperateHor;
}
- (UIView *)seperateVer{
    if (_seperateVer == nil) {
        _seperateVer = [[UIView alloc] init];
        _seperateVer.backgroundColor = COLOR_TEXT_II;
        _seperateVer.alpha = 0.4;
    }
    return _seperateVer;
}
- (CityDetailHeaderFlowLayout *)flowLayout{
    if (_flowLayout == nil) {
        _flowLayout = [[CityDetailHeaderFlowLayout alloc] init];
//        _flowLayout.minimumInteritemSpacing = 0;
//        _flowLayout.minimumLineSpacing = 0;
//        _flowLayout.itemSize = CGSizeZero;
        _flowLayout.delegate = self;
    }
    return _flowLayout;
}
- (UICollectionView *)circleBtnCollection{
    if (_circleBtnCollection == nil) {
        _circleBtnCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _circleBtnCollection.dataSource = self;
        _circleBtnCollection.delegate = self;
        _circleBtnCollection.scrollEnabled = NO;
        [_circleBtnCollection registerClass:[CityDetailHeaderCircleBtnCell class] forCellWithReuseIdentifier:@"cell"];
        _circleBtnCollection.backgroundColor = [UIColor clearColor];
    }
    return _circleBtnCollection;
}

@end
