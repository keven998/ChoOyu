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
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "UserAlbumOverViewTableViewController.h"
#import "UploadUserAlbumViewController.h"

@interface UserAlbumViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) AccountManager *manager;
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
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
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
    ctl.selectedPhotos = selectedPhotos;
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
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:((AlbumImage *)image).image.imageUrl] placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumImageCell *cell = (AlbumImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger count = _albumArray.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 1; i<count +1; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];

        id album = [_albumArray objectAtIndex:i-1];
        if ([album isKindOfClass:[UIImage class]]) {
            photo.image = album;
        } else {
            photo.url = ((AlbumImage *)album).image.imageUrl; // 图片路径
        }
        photo.srcImageView = (UIImageView *)cell.imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
  }

/**
 *  获取上传七牛服务器所需要的 token，key
 *
 *  @param image
 */
- (void)uploadPhotoImage:(UIImage *)image
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    __weak typeof(UserAlbumViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)self.manager.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager GET:API_POST_PHOTOALBUM parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            
            [self uploadPhotoToQINIUServer:image withToken:[[responseObject objectForKey:@"result"] objectForKey:@"uploadToken"] andKey:[[responseObject objectForKey:@"result"] objectForKey:@"key"]];
            
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        
    }];
}

/**
 *  将图片上传至七牛服务器
 *
 *  @param image       上传的图片
 *  @param uploadToken 上传的 token
 *  @param key         上传的 key
 */
- (void)uploadPhotoToQINIUServer:(UIImage *)image withToken:(NSString *)uploadToken andKey:(NSString *)key
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [self.HUD showInView:self.view animated:YES];
    
    typedef void (^QNUpProgressHandler)(NSString *key, float percent);
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain"
                                               progressHandler:^(NSString *key, float percent) {
                                                   [self incrementWithProgress:percent]
                                                   ;}
                                                        params:@{ @"x:foo":@"fooval" }
                                                      checkCrc:YES
                                            cancellationSignal:nil];
    
    [upManager putData:data key:key token:uploadToken
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  [_HUD dismiss];
                  _HUD = nil;
                  AlbumImage *abImage = [[AlbumImage alloc] init];
                  TaoziImage * tzImage = [[TaoziImage alloc] init];
                  abImage.imageId = [resp objectForKey:@"id"];
                  tzImage.imageUrl = [resp objectForKey:@"url"];
                  abImage.image = tzImage;
                  NSMutableArray *mutableArray = [self.manager.account.userAlbum mutableCopy];
                  [mutableArray addObject:abImage];
                  self.manager.account.userAlbum = mutableArray;
                  [_albumArray addObject:image];
                  [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                  [self.collectionView reloadData];
                  
              } option:opt];
    
}

- (void)incrementWithProgress:(float)progress
{
    _HUD.textLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress*100)];
    [self.HUD setProgress:progress animated:YES];
    
    if (progress == 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_HUD dismiss];
            _HUD = nil;
            [SVProgressHUD showHint:@"修改成功"];
            [self.collectionView reloadData];
        });
    }
}

- (JGProgressHUD *)HUD
{
    if (!_HUD) {
        _HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        _HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:JGProgressHUDStyleDark];
        _HUD.detailTextLabel.text = nil;
        _HUD.textLabel.text = @"正在上传";
        _HUD.layoutChangeAnimationDuration = 0.0;
    }
    return _HUD;
}

- (void)deletePhoto:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            
        } else {
            AlbumImage *image = [self.manager.account.userAlbum objectAtIndex:sender.tag-101];
            [self.manager asyncDelegateUserAlbumImage:image completion:^(BOOL isSuccess, NSString *error) {
                if (isSuccess) {
                    NSMutableArray *mutableArray = [_albumArray mutableCopy];
                    [mutableArray removeObjectAtIndex:sender.tag - 101];
                    _albumArray = mutableArray;
                    [self.collectionView reloadData];
                } else {
                    [SVProgressHUD showHint:@"删除失败"];
                }
            }];
        }
    }];
   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *headerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self uploadPhotoImage:headerImage];
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













