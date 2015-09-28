//
//  UserAlbumViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/2/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <QiniuSDK.h>
#import "UserAlbumViewController.h"
#import "JGProgressHUDPieIndicatorView.h"
#import "AlbumImageCell.h"
#import "UserAlbumReviewViewController.h"
#import "UserAlbumOverViewTableViewController.h"
#import "UploadUserAlbumViewController.h"

@interface UserAlbumViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AccountManager *manager;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) JGProgressHUD *HUD;

@end

@implementation UserAlbumViewController

static NSString * const reuseIdentifier = @"albumImageCell";

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"相册";    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.manager = [AccountManager shareAccountManager];
    if (_isMyself){
        UIButton *addPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        addPhoto.frame = CGRectMake(0, 0, 40, 40);
        [addPhoto setImage:[UIImage imageNamed:@"icon_add_photo.png"] forState:UIControlStateNormal];
        [addPhoto addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
        addPhoto.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [addPhoto setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [addPhoto setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:addPhoto];
        self.navigationItem.rightBarButtonItem = right;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat itemWidth = (kWindowWidth-10*2-8*3)/4;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumImageCell" bundle:nil]forCellWithReuseIdentifier:@"albumImageCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [MobClick beginLogPageView:@"page_profile_album"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoHasSelected:) name:uploadUserAlbumNoti object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_profile_album"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)photoHasSelected:(NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSMutableArray *selectedPhotos = [noti.userInfo objectForKey:@"images"];
    UploadUserAlbumViewController *ctl = [[UploadUserAlbumViewController alloc] init];
    ctl.selectedPhotos = [[NSMutableArray alloc] initWithArray:selectedPhotos];
    [self.navigationController pushViewController:ctl animated:NO];
}

#pragma mark - private Methods

- (void)addPhoto:(UIButton *)button
{
    UserAlbumOverViewTableViewController *ctl = [[UserAlbumOverViewTableViewController alloc] init];
    ctl.selectedPhotos = [[NSMutableArray alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _albumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    id image = [_albumArray objectAtIndex:indexPath.row];
    if ([image isKindOfClass:[UIImage class]]) {
        [cell.imageView sd_setImageWithURL:nil];
        cell.imageView.image = (UIImage *)image;
    } else {
        cell.imageView.image = nil;
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:((AlbumImageModel *)image).smallImageUrl] placeholderImage:[UIImage imageNamed:@"icon_userAlbum_placeholder.png"]];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserAlbumReviewViewController *ctl = [[UserAlbumReviewViewController alloc] init];
    ctl.dataSource = _albumArray;
    ctl.canEidt = _isMyself;
    ctl.currentIndex = indexPath.row;
    [self.navigationController pushViewController:ctl animated:YES];
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













