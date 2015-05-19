//
//  OtherUserInfoViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "OtherUserInfoViewController.h"
#import "MyGuideListTableViewController.h"
#import "HeaderCell.h"
#import "OtherUserBasicInfoCell.h"
#import "OthersAlbumCell.h"
#import "MyTripSpotsMapViewController.h"

#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"

@interface OtherUserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
//    UIView *_headerView;
    UIImageView *_headerView;
    UIView *_footerView;
}
@end

@implementation OtherUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"达人资料";
    _dataArray = [NSMutableArray array];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = APP_DIVIDER_COLOR;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellReuseIdentifier:@"zuji"];
     [_tableView registerNib:[UINib nibWithNibName:@"OtherUserBasicInfoCell" bundle:nil] forCellReuseIdentifier:@"basicInfoCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OthersAlbumCell" bundle:nil] forCellReuseIdentifier:@"albumCell"];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIBarButtonItem *left = [UIBarButtonItem itemWithIcon:@"ic_navigation_back" highIcon:@"nav_back" target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = left;
    
    [self createHeader];
    [self createFooter];
    [self.view addSubview:_tableView];
}
-(void)createHeader
{
    _headerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 94)];
//    _headerView.image = [UIImage imageNamed:@"picture_background"];
    _headerView.userInteractionEnabled = YES;
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 17, 60, 60)];
    avatarView.clipsToBounds = YES;
    avatarView.backgroundColor = APP_IMAGEVIEW_COLOR;
    avatarView.layer.cornerRadius = 10;
    [_headerView addSubview:avatarView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 17, 0, 21)];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = TEXT_COLOR_TITLE;
    [_headerView addSubview:nameLabel];
    
    UILabel *statusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 13, 13)];
    statusLable.font = [UIFont systemFontOfSize:10];
    statusLable.textColor = [UIColor whiteColor];
    statusLable.backgroundColor = APP_THEME_COLOR;
    statusLable.layer.cornerRadius = 2.0;
    statusLable.textAlignment = NSTextAlignmentCenter;
    statusLable.clipsToBounds = YES;
    [_headerView addSubview:statusLable];
    
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 0, 13)];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.font = [UIFont systemFontOfSize:10];
    levelLabel.backgroundColor = UIColorFromRGB(0xf4b713);
    levelLabel.textAlignment = NSTextAlignmentCenter;
    levelLabel.layer.cornerRadius = 2.0;
    levelLabel.clipsToBounds = YES;
    [_headerView addSubview:levelLabel];
    
    UILabel *resideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 0, 18)];
    resideLabel.font = [UIFont systemFontOfSize:12];
    resideLabel.textAlignment = NSTextAlignmentCenter;
    resideLabel.textColor = TEXT_COLOR_TITLE_HINT;
    [_headerView addSubview:resideLabel];
    
    UIImageView *genderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    if ([_model.gender isEqualToString:@"F"] ) {
        genderImage.image = [UIImage imageNamed:@"girl"];
    }else{
        genderImage.image = [UIImage imageNamed:@"boy"];
    }
    [_headerView addSubview:genderImage];
    
    UILabel *signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 70, CGRectGetWidth(self.view.bounds) - 100, 18)];
    signatureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    signatureLabel.font = [UIFont systemFontOfSize:12];
    signatureLabel.textColor = TEXT_COLOR_TITLE_HINT;
    [_headerView addSubview:signatureLabel];
    [avatarView sd_setImageWithURL:[NSURL URLWithString:_model.avatarSmall]];
    nameLabel.text = _model.name;
    signatureLabel.text = _model.signature;
    statusLable.text = [_model getRolesDescription];
    UILabel *taoziId = [[UILabel alloc]initWithFrame:CGRectMake(116, 45, 200, 20)];
    taoziId.font = [UIFont systemFontOfSize:14];
    taoziId.textColor = TEXT_COLOR_TITLE_HINT;
    NSString *taoziIdStr = [NSString stringWithFormat:@"桃子号:%@",_model.userId];
    taoziId.text = taoziIdStr;
    [_headerView addSubview:taoziId];
    
    levelLabel.text = [NSString stringWithFormat:@"V%ld", _model.level];
    resideLabel.text = @"";

    CGSize reSize = [resideLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName : [UIFont systemFontOfSize:12]
                                                              }
                                                    context:nil].size;
    CGSize levelSize = [levelLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName : [UIFont systemFontOfSize:10]
                                                                }
                                                      context:nil].size;
    
    CGFloat maxSize = CGRectGetWidth(self.view.bounds) - 90 - 10 - 15 - 20 - reSize.width - levelSize.width - 5;
    CGSize nameSize = [nameLabel.text boundingRectWithSize:CGSizeMake(maxSize, 21)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                              }
                                                    context:nil].size;
    CGRect rf = resideLabel.frame;
    rf.size.width = reSize.width + 50;
    rf.origin.x = CGRectGetWidth(self.view.bounds) - rf.size.width;
    resideLabel.frame = rf;
    
    CGRect nf = nameLabel.frame;
    nf.size.width = nameSize.width;
    nameLabel.frame = nf;
    
    CGRect slf = statusLable.frame;
    slf.origin.x = nf.origin.x + nf.size.width + 4;
    statusLable.frame = slf;
    
    
    CGRect llf = levelLabel.frame;
    llf.size.width = levelSize.width + 5;
    llf.origin.x = slf.origin.x + slf.size.width + 5;
    levelLabel.frame = llf;

    
    genderImage.frame = CGRectMake(llf.origin.x + llf.size.width + 5, 21, 15, 15) ;
    _tableView.tableHeaderView = _headerView;
}
-(void)createFooter
{
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _footerView.backgroundColor = APP_PAGE_COLOR;
    UIButton *addFriend = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-1, 50)];
    [addFriend setTitle:@"加为好友" forState:UIControlStateNormal];
    [addFriend setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    addFriend.backgroundColor = [UIColor whiteColor];
    [addFriend addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:addFriend];
    
    UIButton *consultingBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-1, 0, SCREEN_WIDTH/2, 50)];
    [consultingBtn setTitle:@"咨询达人" forState:UIControlStateNormal];
    consultingBtn.backgroundColor = [UIColor whiteColor];
    [consultingBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [consultingBtn addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:consultingBtn];
    
    UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 3, 1, 46)];
    divide.backgroundColor = APP_DIVIDER_COLOR;
    [_footerView addSubview:divide];
    
    _tableView.tableFooterView = _footerView;
}
-(void)aaa
{
    NSLog(@"我是尾部视图");
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 4) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2||indexPath.section == 3||indexPath.section == 0) {
        return 90;
    }
    
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OthersAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
        cell.headerPicArray = nil;
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = @"他的旅行计划";
        return cell;
    }
    else if (indexPath.section == 2) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"旅行足迹";
        cell.backgroundColor = [UIColor whiteColor];
        cell.footPrint.text = @"上海  北京  杭州";
        cell.trajectory.text = [_model getFootprintDescription];
        return cell;
    }
    else if (indexPath.section == 3) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"签名";
        cell.backgroundColor = [UIColor whiteColor];
        cell.footPrint.text = _model.signature;
        cell.footPrint.textColor = TEXT_COLOR_TITLE;
        cell.trajectory.text = @"";
        return cell;
    }
    else  {
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"基本信息";
            cell.information.text = @"";
        }else if (indexPath.row == 1){
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   年龄";
            
            NSDateFormatter *format2=[[NSDateFormatter alloc]init];
            [format2 setDateFormat:@"yyyy/MM/dd"];
            NSString *str2=_model.birthday;
            NSDate *date = [format2 dateFromString:str2];
            NSTimeInterval dateDiff = [date timeIntervalSinceNow];
            int age=trunc(dateDiff/(60*60*24))/365;
            age = -age;
            cell.information.font = [UIFont systemFontOfSize:14];
            cell.information.text = [NSString stringWithFormat:@"%d",age];
        }else {
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   现居地";
            cell.information.text = _model.residence;
            cell.information.font = [UIFont systemFontOfSize:14];
        }
        return cell;
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        MyGuideListTableViewController *listCtl = [[MyGuideListTableViewController alloc]init];
        listCtl.isExpert = YES;
        listCtl.userId = _model.userId;
        [self.navigationController pushViewController:listCtl animated:YES];
    }else if (indexPath.section == 2){
        MyTripSpotsMapViewController *ctl = [[MyTripSpotsMapViewController alloc] init];
        ctl.pois = _model.travels;
//        ctl.currentDay = 0;
//        ctl.titleText = _tripDetail.tripTitle;
        [ctl setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:ctl];
        [self presentViewController:nCtl animated:YES completion:nil];
        
    }
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
















