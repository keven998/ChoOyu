////
////  DestinationViewController.m
////  PeachTravel
////
////  Created by liangpengshuai on 14/10/9.
////  Copyright (c) 2014年 com.aizou.www. All rights reserved.
////
//
//#import "DestinationViewController.h"
//#import "DomesticDestinationCell.h"
//#import "ForeignDestinationCell.h"
//#import "Destinations.h"
//#import "UIImageView+WebCache.h"
//#import "DestinationCollectionHeaderView.h"
//#import "DestinationToolBar.h"
//
//#define searchCell              @ "searchCell"
//#define domesticCell            @ "domesticDestinationCell"
//#define foreignCell             @ "foreignDestinationCell"
//
//#define collectionHeader        @ "destinationCollectionHeader"
//#define contentViewWidth        50.0          //选中目的地的内容大小
//
//@interface DestinationViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
//{
//    UISearchDisplayController *searchDisplayController;
//    BOOL isDomesticDestination;         //国内目的地还是国外目的地，默认是国内
//}
//
//@property (nonatomic, strong) NSMutableArray *viewsOnScrollView;      //选中目的地操纵栏中的视图
//@property (weak, nonatomic) IBOutlet DestinationToolBar *destinationToolBar;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *areaSegmented;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UICollectionView *destinationCollection;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIButton *planBtn;
//
//@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
//
//@property (strong, nonatomic) Destinations *destinations;
//
//@end
//
//@implementation DestinationViewController
//
//#pragma mark - LifeCycle
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    isDomesticDestination = YES;
//    
//    //进来如果没有选择任何目的地则destinationToolBar为隐藏状态
//    if (self.destinations.destinationsSelected.count == 0) {
//        [self.destinationToolBar setHidden:YES withAnimation:NO];
//    }
//    
//    [_areaSegmented addTarget:self action:@selector(changeArea:) forControlEvents:UIControlEventValueChanged];
//    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
//    searchDisplayController.active = NO;
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
//    [searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:searchCell];
//    
//    _destinationCollection.collectionViewLayout = self.flowLayout;
//    _destinationCollection.backgroundColor = [UIColor clearColor];
//    self.destinationCollection.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
//
//    [_destinationCollection registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil] forCellWithReuseIdentifier:domesticCell];
//    [_destinationCollection registerNib:[UINib nibWithNibName:@"ForeignDestinationCell" bundle:nil] forCellWithReuseIdentifier:foreignCell];
//    [_destinationCollection registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forCellWithReuseIdentifier:collectionHeader];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//#pragma mark - setter & getter
//
//- (Destinations *)destinations
//{
//    if (!_destinations) {
//        _destinations = [[Destinations alloc] init];
//    }
//    return _destinations;
//}
//
//- (NSMutableArray *)viewsOnScrollView
//{
//    if (!_viewsOnScrollView) {
//        _viewsOnScrollView = [[NSMutableArray alloc] init];
//    }
//    return _viewsOnScrollView;
//}
//
//- (UICollectionViewLayout *)flowLayout
//{
//    CGFloat width = self.view.bounds.size.width;
//    if (!_flowLayout) {
//        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    }
//    if (isDomesticDestination) {
//        _flowLayout.itemSize = CGSizeMake((width-80)/3, (width-80)/3);
//        _flowLayout.minimumInteritemSpacing = 10.;
//        _flowLayout.minimumLineSpacing = 10.;
//        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
//        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//        _flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 64);
//        
//    } else {
//        _flowLayout.itemSize = CGSizeMake(width-20, 150);
//        _flowLayout.minimumInteritemSpacing = 10.;
//        _flowLayout.minimumLineSpacing = 10.;
//        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
//        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//        _flowLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 64);
//    }
//    
//    return _flowLayout;
//}
//
//#pragma mark - IBAction methods
//
//- (IBAction)changeArea:(UISegmentedControl *)sender
//{
//    switch (sender.selectedSegmentIndex) {
//        case 0:
//            isDomesticDestination = YES;
//            _destinationCollection.collectionViewLayout = self.flowLayout;
//            [self.destinationCollection reloadData];
//            break;
//            
//        case 1:
//            isDomesticDestination = NO;
//            _destinationCollection.collectionViewLayout = self.flowLayout;
//            [self.destinationCollection reloadData];
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (IBAction)addDestination:(UIButton *)sender
//{
//    CGPoint point = [sender convertPoint:sender.center toView:_destinationCollection];
//    NSIndexPath *indexPath = [_destinationCollection indexPathForItemAtPoint:point];
//    [deleteBtn addTarget:self action:@selector(removeDestination:) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (IBAction)removeDestination:(UIButton *)sender
//{
//    NSInteger index = [self.viewsOnScrollView indexOfObject:[sender superview]];
//    
//    NSLog(@"%ld", (long)index);
//    [self.destinations.destinationsSelected removeObjectAtIndex:index];
//    [self.viewsOnScrollView[index] removeFromSuperview];
//    [self.viewsOnScrollView removeObjectAtIndex:index];
//    
//    for (NSInteger i = index; i<self.viewsOnScrollView.count; i++) {
//        UIButton *needUpdateBtn = self.viewsOnScrollView[i];
//        CGRect newFrame = CGRectMake(needUpdateBtn.frame.origin.x-55, needUpdateBtn.frame.origin.y, needUpdateBtn.frame.size.width, needUpdateBtn.frame.size.height);
//        [UIView animateWithDuration:0.3 animations:^{
//            [needUpdateBtn setFrame:newFrame];
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
//    self.scrollView.contentSize = CGSizeMake((contentViewWidth + 10)*_viewsOnScrollView.count, 60);
//    if (self.destinations.destinationsSelected.count == 0) {
//        [self.destinationToolBar setHidden:YES withAnimation:YES];
//    }
//}
//
//#pragma mark - private methods
//
//- (UIButton *)addDestinationWithName:(NSString *)destinationName andImage:(NSString *)imageStr
//{
//    CGFloat x = 0;
//    x = (contentViewWidth + 5) * _viewsOnScrollView.count;
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, contentViewWidth, contentViewWidth)];
//    [button setTitle:destinationName forState:UIControlStateNormal];
//    
//    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(button.frame.size.width-20, 0, 20, 20)];
//    [deleteBtn setBackgroundColor:[UIColor blackColor]];
//    [button addSubview:deleteBtn];
//    [_scrollView addSubview:button];
//    [self.viewsOnScrollView addObject:button];
//    
//    self.scrollView.contentSize = CGSizeMake((contentViewWidth + 5)*_viewsOnScrollView.count, 60);
//    
//    if (x >= _scrollView.bounds.size.width-contentViewWidth) {
//        [_scrollView setContentOffset:CGPointMake(x-_scrollView.bounds.size.width+60, 0) animated:YES];
//    }
//    if (self.destinationToolBar.hidden) {
//        [self.destinationToolBar setHidden:NO withAnimation:YES];
//    }
//    return deleteBtn;
//}
//
//#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    if (isDomesticDestination) {
//        return [[[self.destinations.domesticDestinations objectAtIndex:section] objectForKey:@"Pois"] count];
//    } else {
//        return 1;
//    }
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    if (isDomesticDestination) {
//        return self.destinations.domesticDestinations.count;
//    } else {
//        return self.destinations.foreignDestinations.count;
//    }
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (isDomesticDestination) {
//        DestinationCityPoi *domesticCityPoi = [((NSMutableArray *)[[self.destinations.domesticDestinations objectAtIndex:indexPath.section] objectForKey:@"Pois"])objectAtIndex:indexPath.row];
//        DomesticDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:domesticCell forIndexPath:indexPath];
//        [cell.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[[domesticCityPoi imageList] firstObject]] placeholderImage:nil];
//        
//        [cell.titleBtn setTitle:domesticCityPoi.poiName forState:UIControlStateNormal];
//        cell.titleBtn.userInteractionEnabled = NO;
//        
//        [cell.addBtn addTarget:self action:@selector(addDestination:) forControlEvents:UIControlEventTouchUpInside];
//        
//        return cell;
//        
//    } else {
//        ForeignDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:foreignCell forIndexPath:indexPath];
//        DestinationCountryPoi *foreignCountryPoi =[[self.destinations.foreignDestinations objectAtIndex:indexPath.section] objectForKey:@"Poi"];
//
//        [cell.backgroundImageView sd_setImageWithURL:[foreignCountryPoi.imageList firstObject] placeholderImage:nil];
//        return cell;
//    }
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeader forIndexPath:indexPath];
//    if (isDomesticDestination) {
//        headerView.headerLabel.text = [[self.destinations.domesticDestinations objectAtIndex:indexPath.section] objectForKey:@"Title"];
//    } else {
//        headerView.headerLabel.text = [[self.destinations.foreignDestinations objectAtIndex:indexPath.section] objectForKey:@"Title"];
//    }
//    return headerView;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (isDomesticDestination) {
//       
//    } else {
//        
//    }
//}
//
//#pragma mark - UITableViewDataSource & UITableViewDelegate
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 0;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell forIndexPath:indexPath];
//    return cell;
//}
//
//#pragma mark - UISearchBarDelegate, UISearchDisplayDelegate
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    
//}
//
//@end
