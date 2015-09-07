//
//  ChatAlbumCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/11/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChatAlbumCollectionViewController.h"
#import "ChatAlbumCollectionViewCell.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface ChatAlbumCollectionViewController ()

@end

@implementation ChatAlbumCollectionViewController


static NSString * const reuseIdentifier = @"albumImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"图集";
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width/4, (self.view.bounds.size.width/4));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumImageCell" bundle:nil]forCellWithReuseIdentifier:@"albumImageCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setImageList:(NSArray *)imageList
{
    _imageList = imageList;
}

- (void)setAlbumList:(NSArray *)albumList
{
    _albumList = albumList;
    [self.collectionView reloadData];
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIImage *image = [UIImage imageWithContentsOfFile:[_albumList objectAtIndex:indexPath.row]];
    cell.imageView.image = image;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChatAlbumCollectionViewCell *cell = (ChatAlbumCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger count = _imageList.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [_imageList objectAtIndex:i]; // 图片路径
        photo.srcImageView = (UIImageView *)cell.imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}




@end
