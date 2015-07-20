//
//  UserAlbumViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/2/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumViewController.h"
#import "JGProgressHUDPieIndicatorView.h"
#import "AlbumImageCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <QiniuSDK.h>
@interface UserAlbumViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,strong) AccountManager *manager;
@property (nonatomic, strong) JGProgressHUD *HUD;
@property (nonatomic) BOOL canEdit;
@end

@implementation UserAlbumViewController

static NSString * const reuseIdentifier = @"albumImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.manager = [AccountManager shareAccountManager];
    if (_isMyself){
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(0, 0, 40, 40);
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [editBtn setTitle:@"完成" forState:UIControlStateSelected];
        [editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
        editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [editBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
        self.navigationItem.rightBarButtonItem = right;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width/4, (self.view.bounds.size.width/4));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumImageCell" bundle:nil]forCellWithReuseIdentifier:@"albumImageCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)edit:(UIButton *)button {
    BOOL selected = !button.selected;
    button.selected = selected;
    _canEdit = selected;
    self.navigationItem.leftBarButtonItem.customView.hidden = selected;
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_isMyself) {
        return _albumArray.count + 1;
    } else {
        return _albumArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (_isMyself) {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"ic_userInfo_add_avatar"];
            cell.editBtn.hidden = YES;
        } else {
            if (_canEdit) {
                cell.editBtn.hidden = NO;
            } else {
                cell.editBtn.hidden = YES;
            }
            AlbumImage *image = [_albumArray objectAtIndex:indexPath.row-1];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image.image.imageUrl] placeholderImage:nil];
            [cell.editBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
            cell.editBtn.tag = 100 + indexPath.row;
        }
    } else {
        AlbumImage *image = [_albumArray objectAtIndex:indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image.image.imageUrl] placeholderImage:nil];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isMyself) {
        if (indexPath.row == 0) {
            [self presentImagePicker];
        } else {
            
            AlbumImageCell *cell = (AlbumImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
            NSInteger count = _albumArray.count;
            // 1.封装图片数据
            NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
            for (NSInteger i = 1; i<count +1; i++) {
                // 替换为中等尺寸图片
                AlbumImage *album = [_albumArray objectAtIndex:i-1];
                MJPhoto *photo = [[MJPhoto alloc] init];
                photo.url = album.image.imageUrl; // 图片路径
                photo.srcImageView = (UIImageView *)cell.imageView; // 来源于哪个UIImageView
                [photos addObject:photo];
            }
            
            // 2.显示相册
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            browser.currentPhotoIndex = indexPath.row-1; // 弹出相册时显示的第一张图片是？
            browser.photos = photos; // 设置所有的图片
            [browser show];
        }
    }
    else {
        AlbumImageCell *cell = (AlbumImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSInteger count = _albumArray.count;
        // 1.封装图片数据
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i<count; i++) {
            // 替换为中等尺寸图片
            AlbumImage *album = [_albumArray objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = album.image.imageUrl; // 图片路径
            photo.srcImageView = (UIImageView *)cell.imageView; // 来源于哪个UIImageView
            [photos addObject:photo];
        }
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show];
    }
}

- (void)presentImagePicker
{
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                                     message:nil
                                                 cancelTitle:@"取消"
                                                 otherTitles:@[@"拍照", @"相册"]
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      UIImagePickerControllerSourceType sourceType;
                                                      if (buttonIndex == 1) {
                                                          sourceType  = UIImagePickerControllerSourceTypeCamera;
                                                      } else if (buttonIndex == 2) {
                                                          sourceType  = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      } else {
                                                          return;
                                                      }
                                                      UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                                      picker.delegate = self;
                                                      picker.allowsEditing = YES;
                                                      picker.sourceType = sourceType;
                                                      [self presentViewController:picker animated:YES completion:nil];
                                                  }];
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView useDefaultIOS7Style];
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
                  
                  AlbumImage *image = [[AlbumImage alloc] init];
                  TaoziImage * tzImage = [[TaoziImage alloc] init];
                  image.imageId = [resp objectForKey:@"id"];
                  tzImage.imageUrl = [resp objectForKey:@"url"];
                  image.image = tzImage;
                  NSMutableArray *mutableArray = [self.manager.account.userAlbum mutableCopy];
                  [mutableArray addObject:image];
                  self.manager.account.userAlbum = mutableArray;
                  _albumArray = mutableArray;
                  [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                  
              } option:opt];
    
}

- (void)incrementWithProgress:(float)progress {
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

- (JGProgressHUD *)HUD {
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













