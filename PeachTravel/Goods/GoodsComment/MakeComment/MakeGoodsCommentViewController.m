//
//  MakeGoodsCommentViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//
#import "MakeGoodsCommentViewController.h"
#import "UploadPhotoOperationView.h"
#import "UploadUserAlbumCollectionViewCell.h"
#import "UserAlbumOverViewTableViewController.h"
#import "UserAlbumPreviewViewController.h"
#import "UploadUserPhotoStatus.h"
#import "UserAlbumManager.h"
#import "EDStarRating.h"
#import "UserCommentManager.h"

@interface MakeGoodsCommentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, EDStarRatingProtocol>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UploadPhotoOperationView *containterView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *anonymousBtn;
@property (nonatomic, strong) EDStarRating *ratingView;

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
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    _containterView = [UploadPhotoOperationView uploadUserPhotoView];
    
    _containterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 150);
    _containterView.collectionView.hidden = YES;   //暂时屏蔽掉发送图片的功能
    _containterView.collectionView.dataSource = self;
    _containterView.collectionView.delegate = self;
    [_containterView.collectionView registerNib:[UINib nibWithNibName:@"UploadUserAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [_scrollView addSubview:_containterView];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_containterView.frame), kWindowWidth, 10)];
    spaceView.backgroundColor = APP_PAGE_COLOR;
    [_scrollView addSubview:spaceView];
    
    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, CGRectGetMaxY(spaceView.frame)+15, kWindowWidth-20, 20)];
    ratingLabel.text = @"评个分吧~";
    ratingLabel.textColor = COLOR_TEXT_II;
    ratingLabel.font = [UIFont systemFontOfSize:15.0];
    [_scrollView addSubview:ratingLabel];
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(ratingLabel.frame)+5, 100, 30)];
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = YES;
    _ratingView.horizontalMargin = 5;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.delegate = self;
    _ratingView.rating = 5;
    [_scrollView addSubview:_ratingView];
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_ratingView.frame)+10, kWindowWidth, 0.5)];
    buttomView.backgroundColor = COLOR_LINE;
    [_scrollView addSubview:buttomView];
    
    [self setupToolBar];
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupToolBar
{
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    [self.view addSubview:toolBarView];
    _anonymousBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 100, 49)];
    [_anonymousBtn setTitle:@"匿名评价" forState:UIControlStateNormal];
    [_anonymousBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    _anonymousBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _anonymousBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _anonymousBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_anonymousBtn addTarget:self action:@selector(anonymousAction:) forControlEvents:UIControlEventTouchUpInside];
    [_anonymousBtn setImage:[UIImage imageNamed:@"icon_makeOrder_checkBox_normal"] forState:UIControlStateNormal];
    [_anonymousBtn setImage:[UIImage imageNamed:@"icon_makeOrder_checkBox_selected"] forState:UIControlStateSelected];
    [toolBarView addSubview:_anonymousBtn];
    
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-100, 0, 100, 49)];
    [submitBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFB4F28)] forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn setTitle:@"发表评价" forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [submitBtn addTarget:self action:@selector(submitUserComment) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:submitBtn];
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 0.5)];
    buttomView.backgroundColor = COLOR_LINE;
    [toolBarView addSubview:buttomView];
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

- (void)submitUserComment
{
    [UserCommentManager asyncMakeCommentWithGoodsId:_goodsId ratingValue:_ratingView.rating/5 andContent:_containterView.textView.text isAnonymous:_anonymousBtn.selected completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"评价成功"];
            [self dismissCtl];
        } else {
            [SVProgressHUD showHint:@"评价失败"];
        }
    }];
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

- (void)anonymousAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
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
//    CGFloat height = [UploadPhotoOperationView heigthWithPhotoCount:_selectedPhotos.count + 1];
//    _containterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
//    CGFloat scrollViewHeight = height > _scrollView.bounds.size.height ? height : _scrollView.bounds.size.height+1;
//    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, scrollViewHeight)];
    [_containterView.collectionView reloadData];
}

#pragma mark - EDStarRatingProtocol

- (void)starsSelectionChanged:(EDStarRating*)control rating:(float)rating;
{
    
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


