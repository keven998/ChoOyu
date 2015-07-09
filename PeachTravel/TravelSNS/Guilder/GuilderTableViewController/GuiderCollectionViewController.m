//
//  GuiderCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionViewController.h"
#import "GuiderCollectionCell.h"
#import "PeachTravel-swift.h"
#import "OtherUserInfoViewController.h"

@interface GuiderCollectionViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GuiderCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTravelers:0];
    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    if (IS_IPHONE_6P) {
        layout.minimumLineSpacing = 21;
        layout.minimumInteritemSpacing = 20;
        CGFloat width = (self.collectionView.bounds.size.width-58)/2;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 19, 0, 19);
        layout.itemSize = CGSizeMake(width, width*780/537);
        
    } else if (IS_IPHONE_6) {
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 18;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 15, 0, 15);
        CGFloat width = (self.collectionView.bounds.size.width-48)/2;
        layout.itemSize = CGSizeMake(width, width*780/537);

    } else {
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 10;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 10, 0, 10);
        CGFloat width = (self.collectionView.bounds.size.width-30)/2;
        layout.itemSize = CGSizeMake(width, width*780/537+20);
    }
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"GuiderCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - http method
- (void)loadTravelers:(NSInteger)number
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    [params setObject:[NSNumber numberWithInt:10] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(GuiderCollectionViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    //搜索达人
    [manager GET:API_SEARCH_USER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseSearchResult:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
    }];
}

- (void)parseSearchResult:(id)searchResult
{
    NSInteger count = [searchResult count];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FrendModel *user;
    for (int i = 0; i < count; ++i) {
        user = [[FrendModel alloc] initWithJson:[searchResult objectAtIndex:i]];
        [array addObject:user];
    }
    _dataSource = array;
    [self.collectionView reloadData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GuiderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OtherUserInfoViewController *otherInfoCtl = [[OtherUserInfoViewController alloc]init];
    FrendModel *model = _dataSource[indexPath.row];
    //    otherInfoCtl.model = model;
    otherInfoCtl.userId = model.userId;
    [self.navigationController pushViewController:otherInfoCtl animated:YES] ;
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
