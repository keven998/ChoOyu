//
//  UserAlbumReviewViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumReviewViewController.h"
#import "UserAlbumPreviewCollectionViewCell.h"
#import "EditUserAlbumDescViewController.h"
#import "UserAlbumManager.h"

@interface UserAlbumReviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *descScrollView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, copy) NSString *naviTitle;
@property (nonatomic, copy) NSString *imageDesc;

@end

@implementation UserAlbumReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_white_style.png"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIButton *moreBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setImage:[UIImage imageNamed:@"icon_navi_white_more.png"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction:)forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setFrame:CGRectMake(0, 0, 30, 30)];
    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.view.backgroundColor = COLOR_TEXT_I;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition: UICollectionViewScrollPositionLeft animated:NO];
    [self.view addSubview:self.descScrollView];
    
    self.naviTitle = [NSString stringWithFormat:@"%ld/%ld", _currentIndex+1, _dataSource.count];
    AlbumImageModel *image = [_dataSource objectAtIndex:_currentIndex];
    _descLabel.text = image.imageDesc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    AlbumImageModel *image = [_dataSource objectAtIndex:_currentIndex];
    _descLabel.text = image.imageDesc;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)moreAction:(id)sender
{
    UIActionSheet *sheet;
    if (_canEidt) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", @"编辑文字描述", @"删除", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
    }
    [sheet showInView:self.view];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    _currentIndex = currentIndex;
    self.naviTitle = [NSString stringWithFormat:@"%ld/%ld", _currentIndex+1, _dataSource.count];
    if (self.dataSource.count) {
        AlbumImageModel *image = [_dataSource objectAtIndex:_currentIndex];
        _descLabel.text = image.imageDesc;
    }
  }

- (void)setNaviTitle:(NSString *)naviTitle
{
    _naviTitle = naviTitle;
    self.navigationItem.title = _naviTitle;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = COLOR_TEXT_I;
        [_collectionView registerNib:[UINib nibWithNibName:@"UserAlbumPreviewCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"userAlbumPreviewCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (UIScrollView *)descScrollView
{
    if (!_descScrollView) {
        _descScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-140, self.view.bounds.size.width, 140)];
        _descScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        [_descScrollView addSubview:self.descLabel];
    }
    return _descScrollView;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.descScrollView.bounds.size.width-40, 120)];
        _descLabel.numberOfLines = 0;
        _descLabel.font = [UIFont systemFontOfSize:14.0];
        _descLabel.textColor = [UIColor whiteColor];
    }
    return _descLabel;
}

- (void)saveImage2Disk
{
    UserAlbumPreviewCollectionViewCell *cell = (UserAlbumPreviewCollectionViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
    UIImage *saveImage = cell.mainView.imageView.image;
    if (saveImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    } else {
        [SVProgressHUD showHint:@"请等待图片下载完成"];
    }
   

}

- (void)editImageDesc
{
    EditUserAlbumDescViewController *ctl = [[EditUserAlbumDescViewController alloc] init];
    ctl.albumImage = self.dataSource[_currentIndex];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

- (void)deleteUserAlbum
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            
        } else {
            AlbumImageModel *image = _dataSource[_currentIndex];
            [UserAlbumManager asyncDelegateUserAlbumImage:image userId:[AccountManager shareAccountManager].account.userId completion:^(BOOL isSuccess, NSString *errorStr) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"删除成功"];
                    [_dataSource removeObject:image];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
                    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    if (_currentIndex == _dataSource.count) {
                        self.currentIndex = self.currentIndex - 1;
                    }
                    self.currentIndex = _currentIndex;
                    [[AccountManager shareAccountManager] deleteUserAlbumImage:image.imageId];
                } else {
                    [SVProgressHUD showHint:@"删除失败"];
                    
                }
            }];
        }
    }];
  
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAlbumPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userAlbumPreviewCell" forIndexPath:indexPath];
    AlbumImageModel *imageModel = [_dataSource objectAtIndex:indexPath.row];
    cell.mainView.backgroundColor = COLOR_TEXT_I;
    [cell.mainView.imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imageUrl]];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = scrollView.contentOffset.x/_collectionView.bounds.size.width;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_canEidt) {
        if (buttonIndex == 0) {
            [self saveImage2Disk];
            
        } else if (buttonIndex == 1) {
            [self editImageDesc];
            
        } else if (buttonIndex == 2) {
            [self deleteUserAlbum];
            
        }
    } else {
        if (buttonIndex == 0) {
            [self saveImage2Disk];
            
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SVProgressHUD showHint:@"保存失败"];
    } else {
        [SVProgressHUD showHint:@"成功保存到相册"];
    }
}


@end


