//
//  MakeGoodsCommentViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//
#import "MakeGoodsCommentViewController.h"
#import "UploadUserPhotoOperationView.h"
#import "UploadUserAlbumCollectionViewCell.h"
#import "UserAlbumOverViewTableViewController.h"
#import "UserAlbumPreviewViewController.h"
#import "UploadUserPhotoStatus.h"
#import "UserAlbumManager.h"

@interface MakeGoodsCommentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UploadUserPhotoOperationView *containterView;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) NSMutableArray *userAlbumUploadStatusList;

@end

@implementation MakeGoodsCommentViewController

static NSString * const reuseIdentifier = @"uploadPhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"发表评价";
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _containterView = [UploadUserPhotoOperationView uploadUserPhotoView];
    CGFloat height = [UploadUserPhotoOperationView heigthWithPhotoCount:_selectedPhotos.count + 1];
    _containterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    CGFloat scrollViewHeight = height > _scrollView.bounds.size.height ? height : _scrollView.bounds.size.height+1;
    
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, scrollViewHeight+1);
    
    _containterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    _containterView.collectionView.dataSource = self;
    _containterView.collectionView.delegate = self;
    [_containterView.collectionView registerNib:[UINib nibWithNibName:@"UploadUserAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [_scrollView addSubview:_containterView];
    [self.view addSubview:_scrollView];
    
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [uploadBtn addTarget:self action:@selector(uploadUserAlbum) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoHasSelected:) name:uploadUserAlbumNoti object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.containterView.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goBack
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"亲,评价还未完成,您确定要离开在？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self dismissCtl];
        } else {
            
        }
    }];
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSMutableArray *)userAlbumUploadStatusList
{
    if (!_userAlbumUploadStatusList) {
        _userAlbumUploadStatusList = [[NSMutableArray alloc] init];
    }
    return _userAlbumUploadStatusList;
}

- (void)uploadUserAlbum
{
    [self.view endEditing:YES];
    [_userAlbumUploadStatusList removeAllObjects];
    
    for (int i = 0; i < _selectedPhotos.count; i++) {
        
        UploadUserPhotoStatus *status = [[UploadUserPhotoStatus alloc] init];
        status.isBegin = YES;
        [_userAlbumUploadStatusList addObject:status];
        
        ALAsset *asset = [_selectedPhotos objectAtIndex:i];
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        CGImageRef ref = [representation fullScreenImage];
        UIImage *uploadImage = [UIImage imageWithCGImage:ref];
        [UserAlbumManager uploadUserAlbumPhoto:uploadImage withPhotoDesc:_containterView.textView.text progress:^(CGFloat progressValue) {
            [self uploadIncrementWithProgress:progressValue itemIndex:i];
            
        } completion:^(BOOL isSuccess, AlbumImageModel *image) {
            [self uploadCompletion:isSuccess  albumImage:image itemIndex:i];
        }];
    }
}

- (void)uploadIncrementWithProgress:(float)progress itemIndex:(NSInteger)index
{
    UploadUserAlbumCollectionViewCell *cell = (UploadUserAlbumCollectionViewCell *)[_containterView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    UploadUserPhotoStatus *status = [_userAlbumUploadStatusList objectAtIndex:index];
    status.uploadProgressValue = progress;
    cell.uploadStatus = status;
}

- (void)uploadCompletion:(BOOL)isSuccess albumImage:(AlbumImageModel *)albumImage itemIndex:(NSInteger)index
{
    if (isSuccess) {
        [[AccountManager shareAccountManager].account.userAlbum insertObject:albumImage atIndex:0];
    }
    UploadUserAlbumCollectionViewCell *cell = (UploadUserAlbumCollectionViewCell *)[_containterView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    UploadUserPhotoStatus *status = [_userAlbumUploadStatusList objectAtIndex:index];
    status.isFailure = !isSuccess;
    status.isSuccess = isSuccess;
    status.isFinish = YES;
    cell.uploadStatus = status;
    
    for (UploadUserPhotoStatus *status in _userAlbumUploadStatusList) {
        if (!status.isFinish) {
            return;
        }
    }
    [SVProgressHUD showHint:@"上传完成"];
    [self dismissCtl];
}

- (void)choseMorePhotos
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_selectedPhotos];
    UserAlbumOverViewTableViewController *ctl = [[UserAlbumOverViewTableViewController alloc] init];
    ctl.selectedPhotos = tempArray;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

- (void)photoHasSelected:(NSNotification *)noti
{
    NSMutableArray *selectedPhotos = [noti.userInfo objectForKey:@"images"];
    self.selectedPhotos = [[NSMutableArray alloc] initWithArray:selectedPhotos];
    CGFloat height = [UploadUserPhotoOperationView heigthWithPhotoCount:_selectedPhotos.count + 1];
    _containterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
    CGFloat scrollViewHeight = height > _scrollView.bounds.size.height ? height : _scrollView.bounds.size.height+1;
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, scrollViewHeight)];
    [_containterView.collectionView reloadData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadUserAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row == _selectedPhotos.count) {
        cell.image = [UIImage imageNamed:@"icon_big_add_photo.png"];
    } else {
        ALAsset *asset = _selectedPhotos[indexPath.row];
        cell.image = [UIImage imageWithCGImage:asset.thumbnail];
    }
    
    if (self.userAlbumUploadStatusList.count >= indexPath.row+1) {
        UploadUserPhotoStatus *status = [_userAlbumUploadStatusList objectAtIndex:indexPath.row];
        cell.uploadStatus = status;
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedPhotos.count) {
        [self choseMorePhotos];
    } else {
        UserAlbumPreviewViewController *ctl = [[UserAlbumPreviewViewController alloc] init];
        ctl.currentIndex = indexPath.row;
        ctl.dataSource = _selectedPhotos;
        ctl.selectedPhotos = self.selectedPhotos;
        [self.navigationController pushViewController: ctl animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
@end


