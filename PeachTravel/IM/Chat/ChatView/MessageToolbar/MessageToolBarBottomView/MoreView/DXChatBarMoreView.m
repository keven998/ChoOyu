/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "DXChatBarMoreView.h"
#import "DXChatBarMoreViewAddBtnCell.h"
#define MOREVIEWCELL @"moreViewCell"

@interface DXChatBarMoreView ()<UICollectionViewDataSource,DXChatBarMoreViewAddBtnCellDelegate>

@end


@implementation DXChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame typw:(ChatMoreType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        UIView *shadowImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.6)];
        shadowImg.backgroundColor = COLOR_LINE;
        [self addSubview:shadowImg];
        [self setupSubviewsForType:type];
    }
    return self;
}

- (void)setupSubviewsForType:(ChatMoreType)type
{
    [self addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"collectionView":self.collectionView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];

}

- (NSArray *)btnPropertyList{
    if (_btnPropertyList == nil) {
        _btnPropertyList = @[
                             @{@"picN":@"icon_chat_moreView_plan",@"picH":@"icon_chat_moreView_plan",@"title":@"计划",@"selector":@"myStrategyAction"},
                             @{@"picN":@"icon_chat_moreView_travelnote",@"picH":@"icon_chat_moreView_travelnote",@"title":@"游记",@"selector":@"travelNoteAction"},
                             @{@"picN":@"icon_chat_moreView_spot",@"picH":@"icon_chat_moreView_spot",@"title":@"景点",@"selector":@"viewSpotAction"},
                             @{@"picN":@"icon_chat_moreView_food",@"picH":@"icon_chat_moreView_food",@"title":@"美食",@"selector":@"restaurantAction"},
                             @{@"picN":@"icon_chat_moreView_location",@"picH":@"icon_chat_moreView_location",@"title":@"位置",@"selector":@"locationAction"},
                             @{@"picN":@"icon_chat_moreView_album",@"picH":@"icon_chat_moreView_album",@"title":@"图册",@"selector":@"photoAction"},
                             @{@"picN":@"icon_chat_moreView_camera",@"picH":@"icon_chat_moreView_camera",@"title":@"拍照",@"selector":@"takePicAction"},
                             @{@"picN":@"icon_chat_moreView_shopping",@"picH":@"icon_chat_moreView_shopping",@"title":@"购物",@"selector":@"shoppingAction"},
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
        _collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
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


- (void)myStrategyAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewMyStrategyAction:)]){
        [_delegate moreViewMyStrategyAction:self];
    }
}

- (void)myFavoriteAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewMyFavoriteAction:)]){
        [_delegate moreViewMyFavoriteAction:self];
    }
}

- (void)restaurantAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewDestinationAction: poiType:)]){
        [_delegate moreViewDestinationAction:self poiType:kRestaurantPoi];
    }
}

- (void)shoppingAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewDestinationAction: poiType:)]){
        [_delegate moreViewDestinationAction:self poiType:kShoppingPoi];
    }
}

- (void)viewSpotAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewDestinationAction: poiType:)]){
        [_delegate moreViewDestinationAction:self poiType:kSpotPoi];
    }
}

- (void)travelNoteAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTravelNoteAction:)]){
        [_delegate moreViewTravelNoteAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)takePicAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

@end
