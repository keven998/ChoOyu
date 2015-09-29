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
        _btnPropertyList = @[
            @{@"picN":@"moreview_plan_normal",@"picH":@"moreview_plan_hilighted",@"title":@"计划",@"selector":@"myStrategyAction"},
            @{@"picN":@"moreview_travelnote_normal",@"picH":@"moreview_travelnote_highlight",@"title":@"游记",@"selector":@"travelNoteAction"},
            @{@"picN":@"moreview_screen_normal",@"picH":@"moreview_screen_hilighted",@"title":@"景点",@"selector":@"viewSpotAction"},
            @{@"picN":@"moreview_food-normal",@"picH":@"moreview_food-hilighted",@"title":@"美食",@"selector":@"restaurantAction"},
            @{@"picN":@"moreview_weizhi_normal",@"picH":@"moreview_weizhi_hilighted",@"title":@"位置",@"selector":@"locationAction"},
            @{@"picN":@"moreview_photo_normal",@"picH":@"moreview_photo_hilighted",@"title":@"图册",@"selector":@"photoAction"},
            @{@"picN":@"moreview_camera_normal",@"picH":@"moreview_camera_hilighted",@"title":@"拍照",@"selector":@"takePicAction"},
             @{@"picN":@"moreview_shopping_normal",@"picH":@"moreview_shopping_hilighted",@"title":@"购物",@"selector":@"shoppingAction"},
            ];
             
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
        _flowLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 1 - CHAT_PANEL_VIEW_MARGIN * (CHAT_PANEL_VIEW_RANK + 1)) / CHAT_PANEL_VIEW_RANK, (CHAT_PANEL_VIEW_HEIGHT - 1 - (2) * CHAT_PANEL_VIEW_MARGIN) / (2));
        _flowLayout.sectionInset = UIEdgeInsetsMake(CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN, CHAT_PANEL_VIEW_MARGIN);
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
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
