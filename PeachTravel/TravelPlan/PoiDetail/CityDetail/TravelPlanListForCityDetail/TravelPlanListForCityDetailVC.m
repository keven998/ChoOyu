//
//  TravelPlanListForCityDetailVC.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/24.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "TravelPlanListForCityDetailVC.h"
#import "MyGuideSummary.h"
#import "MyGuidesTableViewCell.h"

@interface TravelPlanListForCityDetailVC () <SWTableViewCellDelegate>

@property (nonatomic, copy) NSString* cityId;
@property (nonatomic, strong) NSArray* travelPlanArray;

@end

@implementation TravelPlanListForCityDetailVC

- (instancetype)initWithCityId:(NSString*)cityId{
    if (self = [super init]) {
        self.cityId = cityId;
        [self loadTravelList];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell"  bundle:nil] forCellReuseIdentifier:@"myGuidesCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.travelPlanArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myGuidesCell" forIndexPath:indexPath];
    MyGuideSummary *summary = self.travelPlanArray[indexPath.row];
    if ([summary.status isEqualToString:@"traveled"]) {
        cell.markImageView.hidden = NO;
    } else {
        cell.markImageView.hidden = YES;
    }
//    if (_isOwner) {
//        cell.rightUtilityButtons = [self rightButtonsWithIndexPath:indexPath];
//    }
    cell.delegate = self;
    cell.guideSummary = summary;
//    cell.isCanSend = _selectToSend;
    
    TaoziImage *image = [summary.images firstObject];
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    
//    if ((_copyPatch && indexPath.row == 0) || (_isNewCopy && indexPath.row == 0)) {
//        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"(新复制) %@", summary.title]];
//        [attr addAttribute:NSForegroundColorAttributeName value:COLOR_CHECKED range:NSMakeRange(0, 5)];
//        cell.titleBtn.attributedText = attr;
//    } else {
        cell.titleBtn.attributedText = nil;
        cell.titleBtn.text = summary.title;
//    }
//    
//    if (_isOwner) {
//        [cell.playedBtn addTarget:self action:@selector(played:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.deleteBtn addTarget:self action:@selector(deletePlane:) forControlEvents:UIControlEventTouchUpInside];
//        cell.playedBtn.hidden = NO;
//        cell.deleteBtn.hidden = NO;
//        
//    } else {
//        cell.playedBtn.hidden = YES;
//        cell.deleteBtn.hidden = YES;
//    }
//    
//    if (_selectToSend) {
//        cell.playedBtn.hidden = YES;
//        cell.deleteBtn.hidden = YES;
//        [cell.sendBtn addTarget:self action:@selector(sendPoi:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 136;
}

- (void)loadTravelList{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = [NSString stringWithFormat: @"http://api-dev.lvxingpai.com/app/geo/localities/%@/guides", self.cityId];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"%@",url);
            NSLog(@"%@",responseObject);
            self.travelPlanArray = [MyGuideSummary guideSummarysWithArray:[responseObject objectForKey:@"result"]];
            [self.tableView reloadData];
            
        } else {
            [self showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        [self showHint:HTTP_FAILED_HINT];
    }];
    
    



}

@end
