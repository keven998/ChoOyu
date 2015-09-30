//
//  TZEmojiKeyBoardVC.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import "TZEmojiKeyBoardVC.h"

#import "TZEmojiKeyBoardCell.h"
#import "TZEmojiToolBar.h"
#import "SQLiteManager.h"
#import "ARGUMENTS.h"
#import "Constants.h"

//    cell.backgroundColor = [[UIColor alloc] initWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1.0];

@interface TZEmojiKeyBoardVC () <UICollectionViewDataSource,UICollectionViewDelegate,TZEmojiToolBarDelegate,TZEmojiKeyBoardCellDelegate>
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) TZEmojiToolBar* toolBar;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSArray* modelArray;

@property (nonatomic, assign) CGFloat toolBarHeight;

@end

@implementation TZEmojiKeyBoardVC


- (void)viewDidLoad{
    [super viewDidLoad];
    [self prepareSubviews];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHeight:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}

- (void)keyBoardHeight:(NSNotification*)notification{

    
    [self prepareViewsWithUserInfo:notification.userInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareSubviews{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolBar];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"collectionView":self.collectionView,@"toolBar":self.toolBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[collectionView]-0-[toolBar(%f)]-0-|",44.0] options:0 metrics:nil views:dict]];
    [self.view layoutIfNeeded];
    
    EmoticonPackageModel* package = [self.modelArray firstObject];
    EmoticonModel* model = [package.emoticons firstObject];
    if (model.png == nil && model.code == nil) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }

}

- (void)prepareViewsWithUserInfo:(NSDictionary*)userInfo{
    
    NSValue* rectValue = userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    
    CGRect rect = [rectValue CGRectValue];
    
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    
    CGFloat toolBarHeight = height * EMOJI_TOOLBAR_PERCENTAGE;
    self.toolBarHeight = toolBarHeight;
    CGFloat collectionViewHeight = height - toolBarHeight - 1;
    CGFloat itemHeigth = collectionViewHeight / EMOJI_ROW;
    CGFloat itemWidth = width / EMOJI_RANK;
    CGSize itemSize = CGSizeMake(itemWidth, itemHeigth);
    
    
    [self prepareFlowLayoutWithItemSize:itemSize];
    
}

- (void)prepareFlowLayoutWithItemSize:(CGSize)itemSize{
    self.flowLayout.itemSize = itemSize;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView reloadData];
}

#pragma mark - toolBarDelegateMethod
- (void)changePageWithIndex:(NSInteger)index{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}
- (void)sendBtnClickEvent{
    if ([self.delegate respondsToSelector:@selector(sendBtnClickEvent)]) {
        [self.delegate sendBtnClickEvent];
    }
}

#pragma mark - cellDelegateMethod
- (void)emoticonBtnClickEventWithModel:(EmoticonModel *)model{
    
    if ([self.delegate respondsToSelector:@selector(insertEmoticonWithModel:)]) {
        [self.delegate insertEmoticonWithModel:model];
    }
    
#ifndef EMOJI_SQLITE_LOCK
    
    if (model.isDeleteBtn) {
        return;
    }
    model.count++;
    EmoticonPackageModel* recent = self.modelArray.firstObject;
    NSMutableArray* recentArray = recent.emoticons;
    if ([recentArray containsObject:model]) {
        NSIndexPath* indexPath = [self.collectionView.indexPathsForVisibleItems firstObject];
        if (indexPath.section == 0) {
            return;
        }
        [recentArray sortUsingComparator:^NSComparisonResult(EmoticonModel* obj1, EmoticonModel* obj2) {
            //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
            if (obj1.count > obj2.count) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        return;
    }else{

        
        [recentArray addObject:model];
        SQLiteManager* manager = [SQLiteManager sharedSQLiteManager];
        [manager upDateGoodWithModel:model];
        [recentArray sortUsingComparator:^NSComparisonResult(EmoticonModel* obj1, EmoticonModel* obj2) {
            //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
            if (obj1.count > obj2.count) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        [recentArray removeObjectAtIndex:recentArray.count - 2];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
    }
#endif
}

#pragma mark - collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
        return self.modelArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    EmoticonPackageModel* model = self.modelArray[section];
    NSArray* array = model.emoticons;
    return array.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TZEmojiKeyBoardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    EmoticonPackageModel* package = self.modelArray[indexPath.section];
    EmoticonModel* model = package.emoticons[indexPath.item];
    cell.model = model;
    cell.delegate = self;

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger currentPage = (scrollView.contentOffset.x - 1)  / [UIScreen mainScreen].bounds.size.width + 1;
    self.toolBar.pageControl.currentPage = currentPage;
}

#pragma mark - setter & getter
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = APP_PAGE_COLOR;
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = APP_PAGE_COLOR;
        _collectionView.backgroundView = view;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TZEmojiKeyBoardCell class] forCellWithReuseIdentifier:CELLIDENTIFY];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout{
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (NSArray *)modelArray{
    if (_modelArray == nil) {
        _modelArray = [EmoticonPackageModel emoticonPackages];
        
    }
    return _modelArray;
}

- (TZEmojiToolBar *)toolBar{
    if (_toolBar == nil) {
        _toolBar = [[TZEmojiToolBar alloc] initWithModelArray:self.modelArray height:self.toolBarHeight];
        _toolBar.backgroundColor = APP_PAGE_COLOR;
        _toolBar.delegate = self;
    }
    return _toolBar;
}



- (void)dealloc{
    NSLog(@"keyBoardDealloc");
}

@end
