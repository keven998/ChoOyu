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
    self.navigationItem.title = @"分享设置";
    _accountTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _accountTableView.delegate = self;
    _accountTableView.dataSource = self;
    [_accountTableView registerNib:[UINib nibWithNibName:@"AccountManagerTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifiner];
    [self.view addSubview:_accountTableView];
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountManagerTableViewCell *accountCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiner forIndexPath:indexPath];

    [accountCell.snsSwitch addTarget:self action:@selector(switchMethod:) forControlEvents:UIControlEventValueChanged];
    switch (indexPath.row) {
        case 0:
            [accountCell.snsBtn setImage:[UIImage imageNamed:@"sns_icon_qq.png"] forState:UIControlStateNormal];
            if (![self.snsAccnout objectForKey:@"qq"]) {
                [accountCell.userName setTitle:@"QQ账号" forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:NO animated:YES];
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"qq"];
                [accountCell.userName setTitle:[NSString stringWithFormat:@"QQ账号 (%@)",accountEntity.userName] forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 0;
            break;
            
        case 1:
            [accountCell.snsBtn setImage:[UIImage imageNamed:@"sns_icon_sina.png"] forState:UIControlStateNormal];
            if (![self.snsAccnout objectForKey:@"sina"]) {
                [accountCell.userName setTitle:@"新浪微博" forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:NO animated:YES];
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"sina"];
                [accountCell.userName setTitle:[NSString stringWithFormat:@"新浪微博 (%@)",accountEntity.userName] forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:YES animated:YES];
                
            }
            accountCell.snsSwitch.tag = 1;
            break;
            
        case 2:
            [accountCell.snsBtn setImage:[UIImage imageNamed:@"sns_icon_qqweibo.png"] forState:UIControlStateNormal];
            if (![self.snsAccnout objectForKey:@"tencent"]) {
                [accountCell.userName setTitle:@"腾讯微博" forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:NO animated:YES];

            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"tencent"];
                [accountCell.userName setTitle:[NSString stringWithFormat:@"腾讯微博 (%@)",accountEntity.userName] forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 2;
            break;
        
        case 3:
            [accountCell.snsBtn setImage:[UIImage imageNamed:@"sns_icon_douban.png"] forState:UIControlStateNormal];
            if (![self.snsAccnout objectForKey:@"douban"]) {
                [accountCell.userName setTitle:@"豆瓣" forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:NO animated:YES];
                
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"douban"];
                [accountCell.userName setTitle:[NSString stringWithFormat:@"豆瓣 (%@)",accountEntity.userName] forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 3;
            break;
            
        case 4:
            [accountCell.snsBtn setImage:[UIImage imageNamed:@"sns_icon_renren.png"] forState:UIControlStateNormal];
            if (![self.snsAccnout objectForKey:@"renren"]) {
                [accountCell.userName setTitle:@"人人" forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:NO animated:YES];
            } else {
                UMSocialAccountEntity *accountEntity = [self.snsAccnout objectForKey:@"renren"];
                [accountCell.userName setTitle:[NSString stringWithFormat:@"人人 (%@)",accountEntity.userName] forState:UIControlStateNormal];
                [accountCell.snsSwitch setOn:YES animated:YES];
            }
            accountCell.snsSwitch.tag = 4;
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
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToTencent completion:^(UMSocialResponseEntity * response) {
                NSLog(@"%@", response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
                
            }];
        }
            break;
            
        case 3: {
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToDouban completion:^(UMSocialResponseEntity * response) {
                NSLog(@"%@", response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            }];
        }
            break;
            
        case 4: {
            [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToRenren completion:^(UMSocialResponseEntity * response) {
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
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTencent];
            snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                NSLog(@"response is %@",response);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.snsAccnout = [UMSocialAccountManager socialAccountDictionary];
                    [self.accountTableView reloadData];
                });
            });
        }
            break;
            
        case 3: {
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
            
        case 4: {
            UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
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















