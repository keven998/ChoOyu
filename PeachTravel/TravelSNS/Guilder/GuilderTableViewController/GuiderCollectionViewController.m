//
//  GuiderCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionViewController.h"
#import "GuiderCollectionCell.h"

@interface GuiderCollectionViewController ()

@end

@implementation GuiderCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GuiderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

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
