//
//  TZEmojiToolBar.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#define TOOL_BAR_CELL @"toolBarCell"
#import "TZEmojiToolBar.h"
#import "EmoticonPackageModel.h"
#import "EmoticonModel.h"
#import "TZEmojiToolBarCell.h"
#import "Constants.h"

@interface TZEmojiToolBar () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UIButton* sendBtn;
@property (nonatomic, strong) NSArray* modelArray;
@property (nonatomic, assign) CGFloat height;

@end

@implementation TZEmojiToolBar

- (instancetype)initWithModelArray:(NSArray*)array height:(CGFloat)height{
    if (self = [super init]) {
        
        self.modelArray = array;
        self.height = height;
        [self prepareViews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    [self prepareViews];
}

- (void)prepareViews {
    if (self.modelArray.count == 1) {
        [self addSubview:self.pageControl];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.sendBtn];
        self.sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary* dict = @{@"collectionView":self.pageControl,@"sendBtn":self.sendBtn};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%d-[sendBtn]-%d-|",EMOJI_SENDBTN_MARGIN,EMOJI_SENDBTN_MARGIN] options:0 metrics:nil views:dict]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-0-[collectionView]-0-[sendBtn(%d)]-9-|",EMOJI_SENDBTN_WIDTH] options:0 metrics:nil views:dict]];
        return;
    }
    [self addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.sendBtn];
    self.sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"collectionView":self.collectionView,@"sendBtn":self.sendBtn};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%d-[sendBtn]-%d-|",EMOJI_SENDBTN_MARGIN,EMOJI_SENDBTN_MARGIN] options:0 metrics:nil views:dict]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-6-[collectionView]-0-[sendBtn(%d)]-9-|",EMOJI_SENDBTN_WIDTH] options:0 metrics:nil views:dict]];
    
}

- (void)sendBtnClickEventOfToolBar {
    if ([self.delegate respondsToSelector:@selector(sendBtnClickEvent)]) {
        [self.delegate sendBtnClickEvent];
    }
}

#pragma mark - collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TZEmojiToolBarCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:TOOL_BAR_CELL forIndexPath:indexPath];
    EmoticonPackageModel* model = self.modelArray[indexPath.item];
    cell.titleLabel.text = model.group_name_cn;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(changePageWithIndex:)]) {
        [self.delegate changePageWithIndex:indexPath.item];
    }
}



#pragma mark - setter & getter
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * EMOJI_TOOLBAR_BTN_PERCENTAGE, self.height - EMOJI_TOOLBAR_BTN_INSET * 2);
        flowLayout.sectionInset = UIEdgeInsetsMake(EMOJI_TOOLBAR_BTN_INSET, 0, EMOJI_TOOLBAR_BTN_INSET, 0);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        UIView* backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        _collectionView.backgroundView = backView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[TZEmojiToolBarCell class] forCellWithReuseIdentifier:TOOL_BAR_CELL];
    }
    return _collectionView;
}

- (UIButton *)sendBtn{
    if (_sendBtn == nil) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:APP_THEME_COLOR];
        _sendBtn.layer.cornerRadius = 5;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClickEventOfToolBar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}
- (UIPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        EmoticonPackageModel* package = [self.modelArray firstObject];
        _pageControl.numberOfPages = (package.emoticons.count - 1) / (EMOJI_RANK * EMOJI_ROW) + 1;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = APP_THEME_COLOR;
    }
    return _pageControl;
}

@end
