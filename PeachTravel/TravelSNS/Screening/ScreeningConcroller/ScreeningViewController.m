//
//  ScreeningViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/4/28.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScreeningViewController.h"
#import "ForeignScreeningViewController.h"
#import "DomesticScreeningViewController.h"
#import "DomesticDestinationCell.h"
#import "ScreenningViewCell.h"
@interface ScreeningViewController ()

@end

@implementation ScreeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedCityArray = [NSMutableArray array];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
//    UIBarButtonItem *rbi = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(doScreening)];
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    NSMutableDictionary *dTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    dTextAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
//    [rbi setTitleTextAttributes:dTextAttrs forState:UIControlStateDisabled];
//    self.navigationItem.rightBarButtonItem = rbi;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    

}
- (void) setupSelectPanel {
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
    toolBar.backgroundColor = [UIColor whiteColor];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:toolBar];
    
//    CGRect collectionViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), toolBar.frame.size.height);
//    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
//    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
//    self.selectPanel.showsHorizontalScrollIndicator = NO;
//    self.selectPanel.showsVerticalScrollIndicator = NO;
//    self.selectPanel.delegate = self;
//    self.selectPanel.dataSource = self;
//    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
//    [self.selectPanel registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
//    [toolBar addSubview:_selectPanel];
//    
//    if (self.selectedCityArray.count == 0) {
//        [self hideDestinationBar];
//    }
}



- (void)hideDestinationBar
{
    CGRect frame = self.selectPanel.superview.frame;
    frame.origin.y = CGRectGetHeight(self.view.bounds);
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPanel.superview.frame = frame;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }];
}

- (void)showDestinationBar
{
    CGRect frame = self.selectPanel.superview.frame;
    frame.origin.y = CGRectGetHeight(self.view.bounds) - 49;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPanel.superview.frame = frame;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}
-(void)doScreening
{
    [self.delegate screeningTravelers:_selectedCityArray];
    [self performSelector:@selector(cancel) withObject:nil afterDelay:0.3];
    __weak typeof(self)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
}
- (void)cancel {
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud hideTZHUD];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
