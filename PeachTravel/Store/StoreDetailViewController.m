//
//  StoreDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/29/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "RCTRootView.h"
#import "RCTBridgeModule.h"
#import "ShareActivity.h"
#import "UMSocial.h"

@interface StoreDetailViewController () <ActivityDelegate>

@end

@implementation StoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"店铺详情";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [shareBtn setImage:[UIImage imageNamed:@"icon_share_gray"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(share2Frend) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_gray"] forState:UIControlStateNormal];
    [favoriteBtn addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:favoriteBtn], [[UIBarButtonItem alloc] initWithCustomView:shareBtn]];

//    NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://192.168.1.47:8081/src/index.ios.bundle?platform=ios&dev=true"];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"StoreDetailClass"
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    [self.view addSubview:rootView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)share2Frend
{
    NSArray *shareButtonimageArray = @[@"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_qzone.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"朋友圈", @"微信朋友", @"QQ", @"QQ空间", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.navigationController.view];
}

- (void)favorite
{
    
}

#pragma mark - AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = @"http://7af4ik.com1.z0.glb.clouddn.com/react/index.html";
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"这个商品来自旅行派～"];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"这个商品来自旅行派 %@", url];
    NSString *imageUrl = @"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/300";
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionCenter];
    switch (imageIndex) {
            
        case 0: {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 1: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.qqData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qzoneData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContentWithoutUrl image:[UIImage imageNamed:@"app_icon.png"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 4:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil  socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        default:
            break;
    }
}


@end
