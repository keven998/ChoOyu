//
//  HeaderCell.m
//  PeachTravel
//
//  Created by dapiao on 15/4/30.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "HeaderCell.h"
#import "TaoziCollectionLayout.h"
#import "ScreenningViewCell.h"
#import "DestinationCollectionHeaderView.h"
@interface HeaderCell ()<UICollectionViewDelegateFlowLayout>


@end

@implementation HeaderCell
- (void)awakeFromNib {
//    [self createUI];
    _footPrint.font = [UIFont systemFontOfSize:14];
    _footPrint.numberOfLines = 0;
    _footPrint.textColor = TEXT_COLOR_TITLE_DESC;
    
    _trajectory.textColor = APP_THEME_COLOR;
}
-(void)createUI
{
//    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
//    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 14, 100, 15)];
//    na
//    [self.contentView addSubview:nameLabel];
    
//    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_collectionView.collectionViewLayout;
//    layout.delegate = self;
//    
//    _collectionView.dataSource=self;
//    _collectionView.delegate=self;
//    [_collectionView setBackgroundColor:[UIColor clearColor]];
//    _collectionView.scrollEnabled = NO;
//    
//    [_collectionView registerNib:[UINib nibWithNibName:@"ScreenningViewCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
//    
//    
//    [self.contentView addSubview:_collectionView];
//    layout.delegate = self;
//    layout.showDecorationView = YES;
//    layout.margin = 10;
//    layout.spacePerItem = 10;
//    layout.spacePerLine = 10;
//    //
//    _collectionView.delegate = self;
//    _collectionView.dataSource = self;
//    NSLog(@"22222-----");
}

//#pragma mark - TaoziLayoutDelegate
//
//- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
//{
////    return CGSizeMake(_collectionView.frame.size.width, 38);
//    return CGSizeZero;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize size = [_dataArray[indexPath.row] sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
//    return CGSizeMake(size.width + 25 + 28, 28);;
//}
//
//- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return _dataArray.count;
//}
//
//- (CGFloat)tzcollectionLayoutWidth
//{
//    NSLog(@"@%f",_collectionView.frame.size.height);
//    return _collectionView.frame.size.width;
//}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
////    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
////        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"domesticHeader" forIndexPath:indexPath];
//////        AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
////        headerView.titleLabel.text = @"旅行足迹";
////        return headerView;
////    }
////    return nil;
//    NSString *reuseIdentifier;
//    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
//        reuseIdentifier = kfooterIdentifier;
//    }else{
//        reuseIdentifier = kheaderIdentifier;
//    }
//    
//    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
//    
//    UILabel *label = (UILabel *)[view viewWithTag:1];
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
//        label.text = [NSString stringWithFormat:@"这是header:%d",indexPath.section];
//    }
//    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
//        view.backgroundColor = [UIColor lightGrayColor];
//        label.text = [NSString stringWithFormat:@"这是footer:%d",indexPath.section];
//    }
//    return view;
//
//}

//#pragma mark - UICollectionViewDataSource
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    //    if (section == _showCitiesIndex) {
//    return _dataArray.count;
//    //    }
//    //    return 0;
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString * CellIdentifier = @"cell";
//    ScreenningViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//
//    cell.nameLabel.text = _dataArray[indexPath.row];
//    NSLog(@"---------%@",_dataArray);
//    return cell;
//}
//
//
//
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
