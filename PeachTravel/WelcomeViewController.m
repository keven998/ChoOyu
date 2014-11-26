//
//  WelcomeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/10.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ICETutorialController.h"
#import "AppUtils.h"
#import "YWeatherUtils.h"
#import "ToolBoxViewController.h"
#import "FBShimmeringView.h"
#import <CoreLocation/CoreLocation.h>

@interface WelcomeViewController () <CLLocationManagerDelegate,ICETutorialControllerDelegate, YWeatherInfoDelegate>
{
    CLLocationManager* locationManager;
    BOOL locationIsGotten;
}

@property (nonatomic, strong) ICETutorialController *viewController;
@property (weak, nonatomic) IBOutlet UIButton *jumpTaozi;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (nonatomic, strong) ToolBoxViewController *toolBoxCtl;
@property (strong, nonatomic) WeatherInfo *weatherInfo;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation WelcomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    locationIsGotten = NO;
    self.navigationController.navigationBar.hidden = YES;
    NSString *backGroundImageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"];
    
    [_backGroundImageView sd_setImageWithURL:[NSURL URLWithString:backGroundImageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            _backGroundImageView.image = [UIImage imageNamed:@"tutorial_background_01@2x.jpg"];
        }
    }];
    
    if (!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) {
        [self beginIntroduce];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    }
    [self loadData];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
    [locationManager requestAlwaysAuthorization];
//    [locationManager startUpdatingLocation];
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
    shimmeringView.shimmering = YES;
    shimmeringView.shimmeringBeginFadeDuration = 0.1;
    shimmeringView.shimmeringEndFadeDuration = 0.1;
    shimmeringView.shimmeringPauseDuration = 0.1;
    shimmeringView.shimmeringAnimationOpacity = 1.0;
    shimmeringView.shimmeringHighlightLength = 0.15;
    shimmeringView.shimmeringOpacity = 0.7;
    shimmeringView.shimmeringSpeed = 80.0;
    [self.view addSubview:shimmeringView];
    shimmeringView.contentView = _jumpTaozi;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (ToolBoxViewController *)toolBoxCtl
{
    if (!_toolBoxCtl) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _toolBoxCtl = [board instantiateViewControllerWithIdentifier:@"toolsSB"];
    }
    return _toolBoxCtl;
}

- (void)loadData
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.width*2] forKey:@"width"];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.height*2] forKey:@"height"];
    
    //获取封面故事接口
    [manager GET:API_GET_COVER_STORIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!([[[responseObject objectForKey:@"result"] objectForKey:@"image"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"]])) {
                [self updateBackgroundData:[[responseObject objectForKey:@"result"] objectForKey:@"image"]];
            }
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

}


- (void)updateBackgroundData:(NSString *)imageUrl
{
    [self.backGroundImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"tutorial_background_01@2x.jpg"]];
    [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:@"backGroundImage"];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"beginTravel"]) {
        _toolBoxCtl = ((ToolBoxViewController *)((UINavigationController *)[((UITabBarController *)segue.destinationViewController).viewControllers firstObject]).topViewController);
        _toolBoxCtl.location = _currentLocation;
        _toolBoxCtl.weatherInfo = _weatherInfo;
    }
}

- (void)beginIntroduce
{
    _jumpTaozi.hidden = YES;
    _backGroundImageView.hidden = YES;
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithTitle:@"Picture 1"
                                                            subTitle:@"Champs-Elysées by night"
                                                         pictureName:@"tutorial_background_00@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithTitle:@"Picture 2"
                                                            subTitle:@"The Eiffel Tower with\n cloudy weather"
                                                         pictureName:@"tutorial_background_01@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithTitle:@"Picture 3"
                                                            subTitle:@"An other famous street of Paris"
                                                         pictureName:@"tutorial_background_02@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithTitle:@"Picture 4"
                                                            subTitle:@"The Eiffel Tower with a better weather"
                                                         pictureName:@"tutorial_background_03@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithTitle:@"Picture 5"
                                                            subTitle:@"The Louvre's Museum Pyramide"
                                                         pictureName:@"tutorial_background_04@2x.jpg"
                                                            duration:3.0];
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Set the common style for the title.
    ICETutorialLabelStyle *titleStyle = [[ICETutorialLabelStyle alloc] init];
    [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
    [titleStyle setTextColor:[UIColor whiteColor]];
    [titleStyle setLinesNumber:1];
    [titleStyle setOffset:180];
    [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
    
    // Set the subTitles style with few properties and let the others by default.
    [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
    [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
    
    // Init tutorial.
    self.viewController = [[ICETutorialController alloc] initWithPages:tutorialLayers
                                                              delegate:self];
    [self.view addSubview:self.viewController.view];
    
    // Run it.
    [self.viewController startScrolling];

}

- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController
{
    _backGroundImageView.hidden = NO;
    _jumpTaozi.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.viewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.viewController.view removeFromSuperview];
        
    }];
}

- (void)updateWeatherWithLocation:(CLLocation *)location
{
    YWeatherUtils* yweatherUtils = [YWeatherUtils getInstance];
    [yweatherUtils setMAfterRecieveDataDelegate: self];
    [yweatherUtils queryYahooWeather:location.coordinate.latitude andLng:location.coordinate.longitude apiKey:@""];
}

#pragma mark - YWeatherInfoDelegate
- (void)gotWeatherInfo:(WeatherInfo *)weatherInfo
{
    NSLog(@"/*****接收到天气数据******/\n");
    _weatherInfo = weatherInfo;
    if (_toolBoxCtl) {
        _toolBoxCtl.weatherInfo = self.weatherInfo;
        _toolBoxCtl.location = self.currentLocation;
    }
    
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    if (!locationIsGotten) {
        locationIsGotten = YES;
        CLLocation *location = [locations firstObject];
        NSLog(@"oh my god我被定位到了：%f, %f", location.coordinate.latitude, location.coordinate.longitude);
        _currentLocation = location;
        [self updateWeatherWithLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [locationManager startUpdatingLocation];

            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager startUpdatingLocation];
            
        default:
            break;
    } 
}


@end
