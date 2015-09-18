//
//  DXChatBarMoreViewAddBtn.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DXChatBarMoreViewAddBtn.h"
#import "DXChatBarMoreViewAddBtnCell.h"
#define MOREVIEWCELL @"moreViewCell"

@interface DXChatBarMoreViewAddBtn () <UICollectionViewDataSource,DXChatBarMoreViewAddBtnCellDelegate>

@property (nonatomic, strong) NSArray* btnPropertyList;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;

@end

@implementation DXChatBarMoreViewAddBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setupSubviewsForType:(ChatMoreType)type{
    
    [self addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"collectionView":self.collectionView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
    
}

#pragma mark - setter & getter

#pragma mark - setter & getter

#pragma mark - 如果要增删该按钮，修改这里数组
- (NSArray *)btnPropertyList{
    if (_btnPropertyList == nil) {
        _btnPropertyList = @[@{@"picN":@"messages_plus_plan_default",@"picH":@"messages_plus_plan_selected",@"title":@"计划",@"selector":@"myStrategyAction"},
             @{@"picN":@"messages_plus_search_default",@"picH":@"messages_plus_search_selected",@"title":@"游记",@"selector":@"destinationAction"},
             @{@"picN":@"messages_plus_pin_default",@"picH":@"messages_plus_pin_selected",@"title":@"位置",@"selector":@"locationAction"},
             @{@"picN":@"messages_plus_picture_default",@"picH":@"messages_plus_picture_selected",@"title":@"相册",@"selector":@"photoAction"},
             @{@"picN":@"messages_plus_camera_default",@"picH":@"messages_plus_camera_selected",@"title":@"拍照",@"selector":@"takePicAction"},
             @{@"picN":@"messages_plus_camera_default",@"picH":@"messages_plus_camera_selected",@"title":@"景点",@"selector":@"scenicAction"},
             @{@"picN":@"messages_plus_camera_default",@"picH":@"messages_plus_camera_selected",@"title":@"美食",@"selector":@"foodAction"},
             @{@"picN":@"messages_plus_camera_default",@"picH":@"messages_plus_camera_selected",@"title":@"购物",@"selector":@"shopAction"}];
    }
    return _btnPropertyList;
}

- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        [_collectionView registerClass:[DXChatBarMoreViewAddBtnCell class] forCellWithReuseIdentifier:MOREVIEWCELL];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout{
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - CHAT_PANEL_VIEW_MARGIN * (CHAT_PANEL_VIEW_RANK + 1)) / CHAT_PANEL_VIEW_RANK, (CHAT_PANEL_VIEW_HEIGHT - ((self.btnPropertyList.count / CHAT_PANEL_VIEW_RANK) + 1) * CHAT_PANEL_VIEW_MARGIN) / (self.btnPropertyList.count / CHAT_PANEL_VIEW_RANK));
        _flowLayout.sectionInset = UIEdgeInsetsMake(CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN);
        _flowLayout.minimumInteritemSpacing = CHAT_PANEL_VIEW_MARGIN;
        _flowLayout.minimumLineSpacing = CHAT_PANEL_VIEW_MARGIN;
    }
    return _flowLayout;
}

#pragma mark - collectionViewDataSource & delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.btnPropertyList.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DXChatBarMoreViewAddBtnCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:MOREVIEWCELL forIndexPath:indexPath];
    cell.data = self.btnPropertyList[indexPath.item];
    cell.tag = indexPath.item;
    cell.delegate = self;
    return cell;
}

#pragma mark - cellDelegate
- (void)CellClickEventWithTag:(NSInteger)tag{
    NSDictionary* dict = self.btnPropertyList[tag];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(dict[@"selector"]) withObject:nil];
#pragma clang diagnostic pop
}

@end
