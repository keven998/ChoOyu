
//  PTMakeSelectCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PTMakeSelectCityViewController.h"
#import "TaoziCollectionLayout.h"
#import "DestinationCollectionHeaderView.h"
#import "AreaDestination.h"
#import "CityDestinationPoi.h"
#import "DomesticCell.h"
#import "DestinationManager.h"
#import "DestinationCollectionViewCell.h"

@interface PTMakeSelectCityViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) NSInteger showCitiesIndex;

@property (nonatomic, strong) Destinations *destinations;

@property (strong, nonatomic) UICollectionView *foreignCollectionView;
@property (nonatomic, strong) TZProgressHUD *hud;

@property (strong, nonatomic) UITableView *foreignTableView;

// 下面定义一个CollectionView的数据源数组
@property (nonatomic, strong)NSArray * citiesArray;

@end

@implementation PTMakeSelectCityViewController

static NSString *reuseableHeaderIdentifier  = @"domesticHeader";
static NSString *reuseableCellIdentifier  = @"domesticCell";

// 懒加载
- (NSArray *)citiesArray
{
    if (_citiesArray == nil) {
        _citiesArray = [NSArray array];
    }
    return _citiesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _destinations = [[Destinations alloc] init];
    if (_selectCitys) {
        _destinations.destinationsSelected = [_selectCitys mutableCopy];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"选择目的地";
    
    if (self.navigationController.childViewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(commitSelect)];;
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    /**
     *  定义CollectionView的内容
     */
    _showCitiesIndex = 0;
    _foreignCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(75, 64, kWindowWidth-75, kWindowHeight-64-49) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    
    _foreignCollectionView.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:_foreignCollectionView];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DomesticCell" bundle:nil]  forCellWithReuseIdentifier:reuseableCellIdentifier];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.foreignCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    [self.foreignCollectionView setShowsVerticalScrollIndicator:NO];
    _foreignCollectionView.dataSource = self;
    _foreignCollectionView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    
    _foreignTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 75, kWindowHeight-64-49)];
    [self.view addSubview:_foreignTableView];
    self.foreignTableView.dataSource = self;
    self.foreignTableView.delegate = self;
    self.foreignTableView.showsVerticalScrollIndicator = NO;
    [self loadForeignDataFromServerWithLastModified:@""];
    
    [self setupSelectPanel];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _foreignCollectionView.delegate = nil;
    _foreignCollectionView.dataSource = nil;
    _foreignCollectionView = nil;
}

- (void)setupSelectPanel
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    toolBar.layer.shadowColor = COLOR_LINE.CGColor;
    toolBar.layer.shadowOffset = CGSizeMake(0, -1.0);
    toolBar.layer.shadowOpacity = 0.33;
    toolBar.layer.shadowRadius = 1.0;
    toolBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:toolBar];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.minimumInteritemSpacing = 0;
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:toolBar.bounds collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerNib:[UINib nibWithNibName:@"DestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [toolBar addSubview:_selectPanel];
    
    UILabel *hintText = [[UILabel alloc] initWithFrame:toolBar.bounds];
    hintText.textColor = TEXT_COLOR_TITLE_HINT;
    hintText.text = @"选择想去的城市";
    hintText.textAlignment = NSTextAlignmentCenter;
    hintText.font = [UIFont systemFontOfSize:14];
    hintText.tag = 1;
    [toolBar addSubview:hintText];
    if (_destinations.destinationsSelected.count) {
        [self showDestinationBar];
    } else {
        [self hideDestinationBar];
    }
}

- (void)hideDestinationBar
{
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = NO;
}

- (void)showDestinationBar
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = YES;
}

- (void)commitSelect
{
    [_delegate didSelectCitys:_destinations.destinationsSelected];
    [self dismiss];
}

- (void)reloadData
{
    [self.foreignCollectionView reloadData];
}

- (void)dismiss
{
    if (self.navigationController.childViewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * 获取国外目的地数据
 */
- (void)loadForeignDataFromServerWithLastModified:(NSString *)modifiedTime
{
    [DestinationManager loadForeignDestinationFromServer:_destinations lastModifiedTime:modifiedTime completionBlock:^(BOOL isSuccess, Destinations *destination) {
        if (isSuccess) {
            _destinations = destination;
            [self.foreignTableView reloadData];
            
            // 默认选中第一组
            NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.foreignTableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionTop];
            
            AreaDestination *country = _destinations.foreignCountries[0];
            self.citiesArray = country.cities;
            [_foreignCollectionView reloadData];
            if (_hud) {
                [_hud hideTZHUD];
            }
            
        } else {
            if (_hud) {
                [_hud hideTZHUD];
                if (self.isShowing) {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - IBAction Methods

- (IBAction)showCities:(UIButton *)sender
{
    if (_showCitiesIndex == sender.tag) {
        _showCitiesIndex = -1;
    } else {
        _showCitiesIndex = sender.tag;
    }
    
    [self.foreignCollectionView reloadData];
}

#pragma mark - notification

- (void)updateDestinationsSelected:(NSNotification *)noti
{
    CityDestinationPoi *city = [noti.userInfo objectForKey:@"city"];
    for (int i=0; i<[_destinations.foreignCountries count]; i++) {
        AreaDestination *country = _destinations.foreignCountries[i];
        for (int j=0; j<country.cities.count; j++) {
            CityDestinationPoi *cityPoi = country.cities[j];
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                [_foreignCollectionView reloadData];
            }
        }
    }
    if (self.destinations.destinationsSelected.count == 0) {
        
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        return self.citiesArray.count;
        
    } else {
        return self.destinations.destinationsSelected.count;

    }

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        AreaDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.section];
        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseableHeaderIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = APP_PAGE_COLOR;
        NSString * title = [NSString stringWithFormat:@"- %@ -",country.zhName];
        headerView.titleLabel.text = title;
        return headerView;
    } else {
        return nil;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        CityDestinationPoi *city = self.citiesArray[indexPath.item];
        
        DomesticCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseableCellIdentifier forIndexPath:indexPath];
        cell.tiltleLabel.text = city.zhName;
        
        BOOL find = NO;
        for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                cell.status.image = [UIImage imageNamed:@"dx_checkbox_selected"];
                find = YES;
            }
        }
        if (!find) {
            cell.status.image = nil;
        }
        
        TaoziImage *image = city.images.firstObject;
        
        [cell.backGroundImage sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
        
        return  cell;
    } else {
        DestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        CityDestinationPoi *city = self.citiesArray[indexPath.row];
        BOOL find = NO;
        for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
            if ([city.cityId isEqualToString:cityPoi.cityId]) {
                NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
                NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
                [_destinations.destinationsSelected removeObjectAtIndex:index];
                [self.selectPanel performBatchUpdates:^{
                    [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
                } completion:^(BOOL finished) {
                    if (_destinations.destinationsSelected.count == 0) {
                        [self hideDestinationBar];
                    }
                }];
                find = YES;
                break;
            }
        }
        if (!find) {
            if (_destinations.destinationsSelected.count == 0) {
                [self showDestinationBar];
            }
            [_destinations.destinationsSelected addObject:city];
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:_destinations.destinationsSelected.count - 1 inSection:0];

            [self.selectPanel performBatchUpdates:^{
                [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                if (finished) {
                    
                }
                
            }];
        }
        
        if (_destinations.destinationsSelected.count > 0) {
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:(_destinations.destinationsSelected.count-1) inSection:0];
            [self.selectPanel scrollToItemAtIndexPath:lnp
                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
        
        [self.foreignCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:indexPath.row];
        [_destinations.destinationsSelected removeObjectAtIndex:indexPath.row];
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
        [_selectPanel performBatchUpdates:^{
            [_selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            if (_destinations.destinationsSelected.count == 0) {
                [self hideDestinationBar];
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:updateDestinationsSelectedNoti object:nil userInfo:@{@"city":city}];
    }
   
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        return CGSizeMake(self.foreignCollectionView.frame.size.width, 0);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:_foreignCollectionView]) {
        return CGSizeMake((kWindowWidth - 75)/3, (kWindowWidth - 75)/3);
    } else {
        CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
        NSString *txt = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
        CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
        NSLog(@"%@", NSStringFromCGSize(size));
        return CGSizeMake(size.width, 28);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:_foreignCollectionView]) {
        return 0;
    }
    return 14;
}

#pragma mark - 实现tableView的数据源以及代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.destinations.foreignCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    AreaDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.row];

    NSString * title = [NSString stringWithFormat:@"%@",country.zhName];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

/**
 *  代理方法
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AreaDestination *country = _destinations.foreignCountries[indexPath.row];
    
    self.citiesArray = country.cities;
    [self.foreignCollectionView reloadData];
}



@end




