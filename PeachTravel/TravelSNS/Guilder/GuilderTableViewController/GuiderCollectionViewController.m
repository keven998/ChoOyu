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
#import "GuilderDistribute.h"
@interface GuiderCollectionViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation GuiderCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    if (IS_IPHONE_6P) {
        layout.minimumLineSpacing = 21;
        layout.minimumInteritemSpacing = 20;
        CGFloat width = (self.collectionView.bounds.size.width-58)/2;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 19, 5, 19);
        layout.itemSize = CGSizeMake(width, width*780/537);
    } else if (IS_IPHONE_6) {
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 18;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 15, 5, 15);
        CGFloat width = (self.collectionView.bounds.size.width-48)/2;
        layout.itemSize = CGSizeMake(width, width*780/537);
    } else {
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 10;
        self.collectionView.contentInset = UIEdgeInsetsMake(16, 10, 5, 10);
        CGFloat width = (self.collectionView.bounds.size.width-30)/2;
        layout.itemSize = CGSizeMake(width, width*780/537+20);
    }
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"GuiderCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self loadTravelers:_distributionArea withPageNo:0];
}

// 传递模型的时候给导航栏标题赋值
- (void)setGuiderDistribute:(GuilderDistribute *)guiderDistribute
{
    _guiderDistribute = guiderDistribute;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 200, 18)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.text = [NSString stringWithFormat:@"~派派 · %@ · 达人~",guiderDistribute.zhName];
    [view addSubview:nameLabel];
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200, 12)];
    idLabel.textColor = [UIColor whiteColor];
    idLabel.font = [UIFont boldSystemFontOfSize:10];
    idLabel.textAlignment = NSTextAlignmentCenter;
//    idLabel.text = @"999位";
    idLabel.text = [NSString stringWithFormat:@"%@位",guiderDistribute.expertUserCnt];
    [view addSubview:idLabel];
    self.navigationItem.titleView = view;
    
    
}

#pragma mark - http method
- (void)loadTravelers:(NSString *)areaId withPageNo:(NSInteger)page
{
    // 1.初始化管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    // 2.设置请求的一些类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // 3.设置请求参数
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    [params setObject:areaId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:16] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(GuiderCollectionViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    
    NSLog(@"%@",API_SEARCH_USER);
    
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
    
    NSLog(@"%@",self.dataSource);
    
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
    
    // 初始化cell并对cell赋值
    GuiderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // 达人模型,dataSource是达人列表数组
    FrendModel * up = self.dataSource[indexPath.row];
    NSLog(@"haha%ld",up.guideCount);

    cell.titleLabel.text = @"99个城市";
    cell.subtitleLabel.text = @"泰国足迹";
    if ([up.sex isEqualToString:@"M"]) {
        [cell.genderBkgImageView setImage:[UIImage imageNamed:@"master_boy.png"]];
    } else if ([up.sex isEqualToString:@"F"]) {
        [cell.genderBkgImageView setImage:[UIImage imageNamed:@"master_girl.png"]];
    } else {
        [cell.genderBkgImageView setImage:[UIImage imageNamed:@"master_no.png"]];
    }
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:up.avatarSmall]];
    
    //星座
    if (up.costellation == nil || [up.costellation isBlankString]) {
        [cell.costellationBtn setImage:[UIImage imageNamed:@"master_star.png"] forState:UIControlStateNormal];
        [cell.costellationBtn setTitle:@"星座" forState:UIControlStateNormal];
    } else {
        [cell.costellationBtn setImage:[UIImage imageNamed:@"master_star.png"] forState:UIControlStateNormal];
        [cell.costellationBtn setTitle:up.costellation forState:UIControlStateNormal];
    }
    
    //昵称
    [cell.nickNmaeLabel setText:up.nickName];
    
    //所住
    if (up.residence == nil || [up.residence isBlankString]) {
        [cell.addressBtn setTitle:@"现住地" forState:UIControlStateNormal];
    } else {
        [cell.addressBtn setTitle:up.residence forState:UIControlStateNormal];
    }
    
    //年龄
    NSDateFormatter *format2=[[NSDateFormatter alloc]init];
    [format2 setDateFormat:@"yyyy/MM/dd"];
    NSString *str2 = up.birthday;
    NSDate *date = [format2 dateFromString:str2];
    NSTimeInterval dateDiff = [date timeIntervalSinceNow];
    int age = trunc(dateDiff/(60*60*24))/365;
    age = -age;
    if (up.birthday == nil || [up.birthday isBlankString]) {
        cell.ageLabel.text = @"年龄";
    } else {
        cell.ageLabel.text = [NSString stringWithFormat:@"%d", age];
    }
    
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

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
