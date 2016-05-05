//
//  MakePersonalTailorViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/5/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "MakePersonalTailorViewController.h"
#import "PTMakeContentTableViewCell.h"
#import "PTMakeTelContentTableViewCell.h"
#import "DialCodeTableViewController.h"
#import "PTMakeOtherContentTableViewCell.h"
#import "PTPayMoneyViewController.h"
#import "CityListTableViewController.h"
#import "PDTSimpleCalendarViewController.h"
#import "PTMakeSelectContentTableViewController.h"
#import "PTDetailModel.h"
#import "PTMakeSelectCityViewController.h"
#import "PTSelectChildAndOldManTableViewCell.h"

@interface MakePersonalTailorViewController ()<DialCodeTableViewControllerDelegate, CityListTableViewControllerDelegate, PDTSimpleCalendarViewDelegate, PTMakeSelectContentTableViewControllerDelegate, PTMakeSelectCityViewControllerDelegate>

@property (nonatomic, strong) NSArray *headerDatasource;
@property (nonatomic, strong) PTDetailModel *ptDetailModel;

@end

@implementation MakePersonalTailorViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _ptDetailModel = [[PTDetailModel alloc] init];
        _ptDetailModel.contact = [[OrderTravelerInfoModel alloc] init];
        _ptDetailModel.contact.dialCode = @"86";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"私人定制";
    _headerDatasource = @[@"联系人信息", @"出行信息", @"旅行信息", @"其他需求"];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = COLOR_LINE;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTMakeContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTMakeContentTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTMakeContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTMakeContentTableViewCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTMakeTelContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTMakeTelContentTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTMakeOtherContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTMakeOtherContentTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PTSelectChildAndOldManTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTSelectChildAndOldManTableViewCell"];

    [self renderFooterView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)renderFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 80)];
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, kWindowWidth-40, 40)];
    [commitButton setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_PRICE_RED] forState:UIControlStateNormal];
    commitButton.layer.cornerRadius = 5.0;
    commitButton.clipsToBounds = YES;
    [commitButton addTarget:self action:@selector(commitPT) forControlEvents:UIControlEventTouchUpInside];
    [commitButton setTitle:@"下一步" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [footerView addSubview:commitButton];
    self.tableView.tableFooterView = footerView;
    
}

- (void)changeDailCode:(UIButton *)sender
{
    DialCodeTableViewController *ctl = [[DialCodeTableViewController alloc] init];
    ctl.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)commitPT
{

    if (!_ptDetailModel.contact.lastName.length) {
        [SVProgressHUD showHint:@"请输入联系人姓名"];
        return;
    }
    if (!_ptDetailModel.contact.firstName.length) {
        [SVProgressHUD showHint:@"请输入联系人姓名"];
        return;
    }

    if (!_ptDetailModel.contact.telNumber.length) {
        [SVProgressHUD showHint:@"请输入联系人电话"];
        return;
    }
    if (!_ptDetailModel.fromCity) {
        [SVProgressHUD showHint:@"请选择出发城市"];
        return;
    }
    if (!_ptDetailModel.departureDate) {
        [SVProgressHUD showHint:@"请选择出发日期"];
        return;
    }
    if (!_ptDetailModel.timeCost) {
        [SVProgressHUD showHint:@"请输入出行天数"];
        return;
    }
    if (!_ptDetailModel.memberCount) {
        [SVProgressHUD showHint:@"请输入出行人数"];
        return;
    }
    if (!_ptDetailModel.totalPrice) {
        [SVProgressHUD showHint:@"请输入总预算"];
        return;
    }
    if (!_ptDetailModel.destinations.count) {
        [SVProgressHUD showHint:@"请选择旅行城市"];
        return;
    }
    if (!_ptDetailModel.serviceList.count) {
        [SVProgressHUD showHint:@"请选择服务包含"];
        return;
    }
    if (!_ptDetailModel.topicList.count) {
        [SVProgressHUD showHint:@"请选择旅行主题"];
        return;
    }
    [self.view endEditing:YES];
    PTPayMoneyViewController *ctl = [[PTPayMoneyViewController alloc] init];
    ctl.ptDetailModel = _ptDetailModel;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didSelectDialCode:(NSDictionary *)dialCode
{
    if (dialCode) {
        PTMakeTelContentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        cell.dailCode = [dialCode objectForKey:@"dialCode"];
        _ptDetailModel.contact.dialCode = [dialCode objectForKey:@"dialCode"];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
        
    } else if (section == 1) {
        return 6;
        
    } else if (section == 2) {
        return 3;
        
    } else if (section == 3) {
        return 1;
        
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return 130;
    }
    if (indexPath.section == 1 && indexPath.row == 4) {
        return 40;
    }
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, kWindowWidth-8, 40)];
    titleLabel.text = _headerDatasource[section];
    titleLabel.textColor = COLOR_TEXT_I;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.contentPlaceHolder = @"英文或拼音";
            cell.typeDesc = @"姓";
            cell.contentTextfield.textAlignment = NSTextAlignmentLeft;
            cell.contentTextfield.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = ^(NSString *content) {
                _ptDetailModel.contact.lastName = content;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentTextfield.text = _ptDetailModel.contact.lastName;
            return cell;
            
        } else if (indexPath.row == 1) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.contentPlaceHolder = @"英文或拼音";
            cell.typeDesc = @"名";
            cell.contentTextfield.textAlignment = NSTextAlignmentLeft;
            cell.contentTextfield.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = ^(NSString *content) {
                _ptDetailModel.contact.firstName = content;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentTextfield.text = _ptDetailModel.contact.firstName;

            return cell;
            
        } else if (indexPath.row == 2) {
            PTMakeTelContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeTelContentTableViewCell" forIndexPath:indexPath];
            [cell.dailCodeButton addTarget:self action:@selector(changeDailCode:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.endEditBlock = ^(NSString *dailCode, NSString *number) {
                _ptDetailModel.contact.dialCode = dailCode;
                _ptDetailModel.contact.telNumber = number;
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!_ptDetailModel.contact.dialCode) {
                _ptDetailModel.contact.dialCode = @"86";
            }
            cell.dailCode = _ptDetailModel.contact.dialCode;
            cell.telConentTextfield.text = _ptDetailModel.contact.telNumber;
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.typeDesc = @"出发城市";
            cell.contentPlaceHolder = nil;
            cell.contentTextfield.userInteractionEnabled = NO;
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.contentTextfield.text = _ptDetailModel.fromCity.zhName;

            return cell;
            
        } else if (indexPath.row == 1) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.contentTextfield.userInteractionEnabled = NO;
            cell.typeDesc = @"出发日期";
            cell.contentPlaceHolder = nil;
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.contentTextfield.text = _ptDetailModel.departureDate;
            return cell;
            
        } else if (indexPath.row == 2) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.contentPlaceHolder = @"天左右";
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.typeDesc = @"出行天数";
            cell.contentTextfield.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            if (_ptDetailModel.timeCost) {
                cell.contentTextfield.text = [[NSString alloc] initWithFormat:@"%ld", _ptDetailModel.timeCost];
            } else {
                cell.contentTextfield.text = nil;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.endEditBlock = ^(NSString *content) {
                _ptDetailModel.timeCost = [content integerValue];
            };

            return cell;
            
        } else if (indexPath.row == 3) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.contentPlaceHolder = @"人左右";
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.contentTextfield.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.typeDesc = @"出行人数";
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            if (_ptDetailModel.memberCount) {
                cell.contentTextfield.text = [[NSString alloc] initWithFormat:@"%ld", _ptDetailModel.memberCount];
            } else {
                cell.contentTextfield.text = nil;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.endEditBlock = ^(NSString *content) {
                _ptDetailModel.memberCount = [content integerValue];
            };
            return cell;
            
        } else if (indexPath.row == 4) {
            PTSelectChildAndOldManTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTSelectChildAndOldManTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.ptDetailModel = _ptDetailModel;
            return cell;
            
        } else if (indexPath.row == 5) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.contentPlaceHolder = @"元左右";
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.typeDesc = @"总预算";
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = ^(NSString *content) {
                _ptDetailModel.totalPrice = [content floatValue];
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.contentTextfield.userInteractionEnabled = YES;
            if (_ptDetailModel.totalPrice) {
                cell.contentTextfield.text = [[NSString alloc] initWithFormat:@"%ld", (NSInteger)_ptDetailModel.totalPrice];
            } else {
                cell.contentTextfield.text = nil;
            }

            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;

        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.typeDesc = @"旅行城市";
            cell.contentPlaceHolder = nil;
            cell.contentTextfield.userInteractionEnabled = NO;
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            NSMutableString *content = [[NSMutableString alloc] init];
            for (CityDestinationPoi *poi in _ptDetailModel.destinations) {
                [content appendFormat:@"%@ ", poi.zhName];
            }
            cell.contentTextfield.text = content;
            return cell;
        } else if (indexPath.row == 1) {
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.typeDesc = @"服务包含";
            cell.contentPlaceHolder = nil;
            cell.contentTextfield.userInteractionEnabled = NO;
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            cell.contentTextfield.text = _ptDetailModel.service;
            return cell;
            
        } else if (indexPath.row == 2) {
            
            PTMakeContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeContentTableViewCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = COLOR_TEXT_I;
            cell.typeDesc = @"主题偏向";
            cell.contentPlaceHolder = nil;
            cell.contentTextfield.userInteractionEnabled = NO;
            cell.contentTextfield.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentTextfield.keyboardType = UIKeyboardTypeDefault;
            cell.endEditBlock = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.contentTextfield.text = _ptDetailModel.topic;
            return cell;
        }
    } else {
        PTMakeOtherContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTMakeOtherContentTableViewCell" forIndexPath:indexPath];
        cell.contentTextView.text = _ptDetailModel.demand;
        cell.endEditBlock = ^(NSString *content) {
            _ptDetailModel.demand = content;
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            CityListTableViewController *ctl = [[CityListTableViewController alloc] init];
            NSString *url = [[NSBundle mainBundle] pathForResource:@"DomesticCityDataSource" ofType:@"plist"];
            NSArray *cityArray = [NSArray arrayWithContentsOfFile:url];
            ctl.cityDataSource = cityArray;
            ctl.delegate = self;
            ctl.needUserLocation = NO;
            ctl.isSelectCity = YES;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            PDTSimpleCalendarViewController *ctl = [[PDTSimpleCalendarViewController alloc] init];
            [ctl setDelegate:self];
            ctl.weekdayHeaderEnabled = YES;
            ctl.firstDate = [NSDate date];
            ctl.canSelect = YES;
            ctl.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
            
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row ==0) {
            PTMakeSelectCityViewController *ctl = [[PTMakeSelectCityViewController alloc] initWithNibName:@"PTMakeSelectCityViewController" bundle:nil];
            ctl.delegate = self;
            ctl.selectCitys = _ptDetailModel.destinations;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            PTMakeSelectContentTableViewController *ctl = [[PTMakeSelectContentTableViewController alloc] init];
            ctl.delegate = self;
            ctl.isSelectTopic = NO;
            ctl.selectContentList = [_ptDetailModel.serviceList mutableCopy];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
            
        } else if (indexPath.row == 2) {
            PTMakeSelectContentTableViewController *ctl = [[PTMakeSelectContentTableViewController alloc] init];
            ctl.delegate = self;
            ctl.isSelectTopic = YES;
            ctl.selectContentList = [_ptDetailModel.topicList mutableCopy];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
        }
    }
}

- (void)didSelectCity:(NSString *)cityId cityName:(NSString *)cityName
{
    PTMakeContentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.contentTextfield.text = cityName;
    CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
    poi.zhName = cityName;
    poi.cityId = cityId;
    _ptDetailModel.fromCity = poi;
}

- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date andDateStr:(NSString *)dateStr price:(float)price
{
    PTMakeContentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.contentTextfield.text = dateStr;
    _ptDetailModel.departureDate = dateStr;
}

- (void)didSelectTopicContent:(NSArray *)contentList
{
    _ptDetailModel.topicList = contentList;
    [self.tableView reloadData];
}

- (void)didSelectServiceContent:(NSArray *)contentList
{
    _ptDetailModel.serviceList = contentList;
    [self.tableView reloadData];
}

- (void)didSelectCitys:(NSArray *)cityList
{
    _ptDetailModel.destinations = cityList;
    [self.tableView reloadData];
}

@end
