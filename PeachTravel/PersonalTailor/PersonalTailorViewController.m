//
//  PersonalTailorViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PersonalTailorViewController.h"
#import "PTListTableViewCell.h"
#import "PTMakePlanViewController.h"

@interface PersonalTailorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *toolBar;

@end

@implementation PersonalTailorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"需求详情";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
    [self renderToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)renderToolBar
{
    if (_toolBar) {
        [_toolBar removeFromSuperview];
        _toolBar = nil;
    }
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    
    UIButton *makePTPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/2, 49)];
    [makePTPlanButton setTitle:@"制作方案" forState:UIControlStateNormal];
    [makePTPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [makePTPlanButton addTarget:self action:@selector(makePTPlanAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:makePTPlanButton];
    
    UIButton *chatWithUser = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth/2, 0, kWindowWidth/2, 49)];
    [chatWithUser setTitle:@"联系买家" forState:UIControlStateNormal];
    [chatWithUser setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [chatWithUser addTarget:self action:@selector(makePTPlanAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:makePTPlanButton];

}

- (void)setPtDetailModel:(PTDetailModel *)ptDetailModel
{
    _ptDetailModel = ptDetailModel;
    [_tableView reloadData];
}

- (void)makePTPlanAction:(UIButton *)sender
{
    PTMakePlanViewController *ctl = [[PTMakePlanViewController alloc] init];
    ctl.ptId = _ptDetailModel.itemId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTListTableViewCell" forIndexPath:indexPath];
        cell.ptDetailModel = _ptDetailModel;
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = COLOR_TEXT_III;
        if (indexPath.section == 1) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"联系人信息\n"];
            [content appendFormat:@"  姓名: %@ %@\n", _ptDetailModel.contact.lastName, _ptDetailModel.contact.firstName];
            [content appendFormat:@"  电话: %@", _ptDetailModel.contact.telDesc];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;
            
        } else if (indexPath.section == 2) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"出行信息\n"];
            [content appendFormat:@"  出发城市: %@\n", _ptDetailModel.fromCity.zhName];
            [content appendFormat:@"  出发日期: %@\n", _ptDetailModel.departureDate];
            [content appendFormat:@"  出发天数: %ld\n", _ptDetailModel.timeCost];
            [content appendFormat:@"  出游人数: %ld", _ptDetailModel.memberCount];
            if (_ptDetailModel.hasChild) {
                [content appendFormat:@"含儿童"];
            }
            if (_ptDetailModel.hasOldMan) {
                [content appendFormat:@"含老人"];
            }
            [content appendFormat:@"\n  总预算: %@", _ptDetailModel.contact.telDesc];

            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        } else if (indexPath.section == 3) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"旅行信息\n"];
            NSMutableString *destinationStr = [[NSMutableString alloc] init];
            for (CityDestinationPoi *poi in _ptDetailModel.destinations) {
                if ([poi isEqual:[_ptDetailModel.destinations lastObject]]) {
                    [destinationStr appendString:poi.zhName];
                } else {
                    [destinationStr appendFormat:@"%@, ", poi.zhName];
                }
            }
            [content appendFormat:@"  旅游城市: %@\n", destinationStr];
            [content appendFormat:@"  服务包含: %@\n", _ptDetailModel.service];
            [content appendFormat:@"  主题偏向: %@", _ptDetailModel.topic];

            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        } else if (indexPath.section == 4) {
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendFormat:@"其他需求\n"];
            [content appendFormat:@"%@", _ptDetailModel.demand];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
            [attr addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, 5)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 5.0;
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 ] range:NSMakeRange(0, content.length)];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
            cell.textLabel.attributedText = attr;

            
        }
        return cell;
    }
}

@end




