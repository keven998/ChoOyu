//
//  AccountManagerViewController.m
//  lvxingpai
//
//  Created by liangpengshuai on 14-8-6.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "AccountManagerTableViewCell.h"
#import "UMSocial.h"
#import "UIAlertView+Block.h"

#define   cellIdentifiner   @"accountCell"

@interface AccountManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) NSDictionary *snsAccnout;

@end

@implementation AccountManagerViewController

#pragma mark - lifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"分享绑定";
    
    _accountTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _accountTableView.delegate = self;
    _accountTableView.dataSource = self;
    _accountTableView.backgroundColor = APP_PAGE_COLOR;
    _accountTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _accountTableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    [_accountTableView registerNib:[UINib nibWithNibName:@"AccountManagerTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifiner];
    [self.view addSubview:_accountTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark setter&getter

- (NSDictionary *)snsAccnout
{
    if (!_snsAccnout) {
        _snsAccnout = [UMSocialAccountManager socialAccountDictionary];
    }
    return _snsAccnout;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountManagerTableViewCell *accountCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiner forIndexPath:indexPath];
    [accountCell.snsSwitch addTarget:self action:@selector(switchMethod:) forControlEvents:UIControlEventValueChanged];
    switch (indexPath.row) {
        case 0:
            accountCell.snsFlag.image = [UIImage imageNamed:@"sns_icon_qq.png"];
            if (![self.snsAccnout objectForKey:@"qq"]) {
                accountCell.snsTitle.text = @"QQ";
                [accountCell.snsSwitch setOn:NO animated:YES];
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"qq"];
                accountCell.snsTitle.text = [NSString stringWithFormat:@"QQ (%@)",accountEntity.userName];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 0;
            break;
            
        case 1:
            accountCell.snsFlag.image = [UIImage imageNamed:@"sns_icon_sina.png"];
            if (![self.snsAccnout objectForKey:@"sina"]) {
                accountCell.snsTitle.text = @"新浪微博";
                [accountCell.snsSwitch setOn:NO animated:YES];
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"sina"];
                accountCell.snsTitle.text = [NSString stringWithFormat:@"新浪微博 (%@)",accountEntity.userName];
                [accountCell.snsSwitch setOn:YES animated:YES];
                
            }
            accountCell.snsSwitch.tag = 1;
            break;
        
        case 2:
            accountCell.snsFlag.image = [UIImage imageNamed:@"sns_icon_douban.png"];
            if (![self.snsAccnout objectForKey:@"douban"]) {
                accountCell.snsTitle.text = @"豆瓣";
                [accountCell.snsSwitch setOn:NO animated:YES];
                
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"douban"];
                accountCell.snsTitle.text = [NSString stringWithFormat:@"豆瓣 (%@)",accountEntity.userName];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 2;
            break;

        default:
            break;
    }
    return accountCell;
}


#pragma mark - actionMethods

- (void)switchMethod:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    if (switchButton.isOn) {
        [self binding:sender];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认解除绑定？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self unBinding:sender];
            } else {
                [switchButton setOn:YES animated:YES];
            }
        }];
    }
}

- (void)unBinding:(UIButton *)sender
{
    switch (sender.tag) {
        case 0: {
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToQQ completion:^(UMSocialResponseEntity * response) {
                NSLog(@"%@", response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
                
            }];

        }
            break;
            
        case 1: {
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina completion:^(UMSocialResponseEntity * response) {
                NSLog(@"%@", response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
                
            }];

        }
            break;
            
        case 2: {
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToDouban completion:^(UMSocialResponseEntity * response) {
                NSLog(@"%@", response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)binding:(UIButton *)sender
{
    switch (sender.tag) {
        case 0: {
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                NSLog(@"response is %@",response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            });
        }

            break;
            
        case 1: {
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                NSLog(@"response is %@",response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            });
        }
            
            break;
        
        case 2: {
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban];
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                NSLog(@"response is %@",response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            });
        }
            break;


        default:
            break;
    }
}
@end















