    //
//  TZTagsCollectionView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TZTagsCollectionView.h"
#import "TZTagsCollectionViewCell.h"
#import "TaoziCollectionLayout.h"

@interface TZTagsCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate>



@end

@implementation TZTagsCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _tagsList = @[@"货到付款", @"货到付款", @"货到付款"];
        self.delegate = self;
        self.dataSource = self;
        [self registerNib:[UINib nibWithNibName:@"TZTagsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"tzTagsCollectionViewCell"];
        TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
        self.collectionViewLayout = layout;
        self.scrollEnabled = NO;
        layout.delegate = self;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _tagsList = @[@"货到付款", @"货到付款", @"货到付款"];
    self.delegate = self;
    self.dataSource = self;
    [self registerNib:[UINib nibWithNibName:@"TZTagsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"tzTagsCollectionViewCell"];
    TaoziCollectionLayout *layout =  (TaoziCollectionLayout *)self.collectionViewLayout;
    layout.spacePerItem = 10;
    layout.delegate = self;
    self.scrollEnabled = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tagsList.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TZTagsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tzTagsCollectionViewCell" forIndexPath:indexPath];
    cell.tagLabel.text = _tagsList[indexPath.row];
    cell.tagLabel.layer.borderColor = APP_THEME_COLOR.CGColor;
    cell.tagLabel.textColor = APP_THEME_COLOR;

    return cell;
}


- (CGSize)tzCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [_tagsList objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9.0]}];
    return CGSizeMake(size.width+10, 16);
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
    return _tagsList.count;
}

- (CGFloat)tzCollectionLayoutWidth
{
    return self.bounds.size.width;
}

@end






